package mokylin.gantt
{
    import mx.collections.ICollectionView;
    import mx.core.IFlexModuleFactory;
    import mx.styles.CSSStyleDeclaration;
    import mokylin.utils.CSSUtil;
    import mx.collections.ArrayCollection;
    import mx.collections.IList;
    import mx.collections.ListCollectionView;
    import mx.collections.XMLListCollection;
    import mx.events.CollectionEvent;
    import mx.events.CollectionEventKind;
    import flash.ui.Keyboard;
    import mx.collections.errors.ItemPendingError;
    import mx.collections.ItemResponder;
    import mx.messaging.messages.ErrorMessage;
    import mokylin.utils.DataUtil;
    import mokylin.gantt.supportClasses.MessageUtil;
    import mx.logging.LogEventLevel;
    import mokylin.gantt.supportClasses.GanttProperties;
    import mx.events.AdvancedDataGridEvent;

    /*[IconFile("ResourceChart.png")]*/
    [Style(name="ganttSheetStyleName", type="String", inherit="no")]
    [Style(name="taskItemStyleName", type="String", inherit="no")]
    public class ResourceChart extends GanttChartBase 
    {

        private var _styleInitialized:Boolean = false;
        private var _dataDescriptor:ResourceChartDataDescriptor;
        private var _resourceDataProvider:Object;
        private var _resourceCollection:ICollectionView;

        public function ResourceChart()
        {
            this._dataDescriptor = new ResourceChartDataDescriptor();
        }

        override public function set moduleFactory(factory:IFlexModuleFactory):void
        {
            super.moduleFactory = factory;
            if (!this._styleInitialized)
            {
                this._styleInitialized = true;
                this.initStyles();
            }
        }

        private function initStyles():void
        {
            var styleDeclaration:CSSStyleDeclaration = CSSUtil.createSelector("ResourceChart", "mokylin.gantt", styleManager);
            styleDeclaration.defaultFactory = function ():void
            {
                this.ganttSheetStyleName = "resourceChartGanttSheet";
                this.taskItemStyleName = "task";
            }
        }

		public function get dataDescriptor():ResourceChartDataDescriptor
        {
            return this._dataDescriptor;
        }

        [Bindable("collectionChange")]
        [Inspectable(category="Data")]
        public function get resourceDataProvider():Object
        {
            return this._resourceCollection;
        }

        public function set resourceDataProvider(value:Object):void
        {
            if (this._resourceDataProvider != value)
            {
                this._resourceDataProvider = value;
                this.setResourceDataProvider();
            }
        }

        [Inspectable(category="Data", defaultValue="id")]
        public function get resourceIdField():String
        {
            return this._dataDescriptor.resourceIdField;
        }

        public function set resourceIdField(value:String):void
        {
            this._dataDescriptor.resourceIdField = value;
            if (_ganttSheet)
            {
                _ganttSheet.invalidateItemsSize();
            }
        }

        [Inspectable(category="Data", defaultValue="null")]
        public function get resourceIdFunction():Function
        {
            return this._dataDescriptor.resourceIdFunction;
        }

        public function set resourceIdFunction(value:Function):void
        {
            this._dataDescriptor.resourceIdFunction = value;
            if (_ganttSheet)
            {
                _ganttSheet.invalidateItemsSize();
            }
        }

        override public function get taskDataProvider():Object
        {
            return _taskCollection;
        }

        override public function set taskDataProvider(value:Object):void
        {
            var xl:XMLList;
            var tmp:Array;
            if (value is Array)
            {
                _taskCollection = new ArrayCollection(value as Array);
            }
            else if (value is ICollectionView)
			{
				_taskCollection = ICollectionView(value);
			}
			else if (value is IList)
			{
				_taskCollection = new ListCollectionView(IList(value));
			}
			else if (value is XMLList)
			{
				_taskCollection = new XMLListCollection((value as XMLList));
			}
			else if (value is XML)
			{
				xl = new XMLList();
				xl = xl + value;
				_taskCollection = new XMLListCollection(xl);
			}
			else
			{
				tmp = [];
				if (value != null)
				{
					tmp.push(value);
				}
				_taskCollection = new ArrayCollection(tmp);
			}
            this._dataDescriptor.setTasks(_taskCollection);
            if (_ganttSheet)
            {
                _ganttSheet.taskCollection = _taskCollection;
            }
			
            var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
            event.kind = CollectionEventKind.RESET;
            dispatchEvent(event);
        }

        [Inspectable(category="Data", defaultValue="resource")]
        public function get taskResourceIdField():String
        {
            return this._dataDescriptor.taskResourceIdField;
        }

        public function set taskResourceIdField(value:String):void
        {
            this._dataDescriptor.taskResourceIdField = value;
            _taskFieldChanged = true;
            invalidateProperties();
        }

        [Inspectable(category="Data", defaultValue="null")]
        public function get taskResourceIdFunction():Function
        {
            return this._dataDescriptor.taskResourceIdFunction;
        }

        public function set taskResourceIdFunction(value:Function):void
        {
            this._dataDescriptor.taskResourceIdFunction = value;
            _taskFieldChanged = true;
            invalidateProperties();
        }

        public function isResource(item:Object):Boolean
        {
            return this._resourceCollection && this._resourceCollection.contains(item);
        }

        override public function isTask(item:Object):Boolean
        {
            return _taskCollection && _taskCollection.contains(item);
        }

        public function getResource(task:Object):Object
        {
            return this._dataDescriptor.getResource(task);
        }

        public function getTasks(resource:Object):Array
        {
            return this._dataDescriptor.getTasks(resource);
        }

        override public function nextItem(previousItem:Object, direction:uint):Object
        {
            var resourceItem:Object;
            var tasks:Array;
            var rowInfo:Array;
            var visibleItems:Array;
            var index:int;
            var j:int;
            var k:int;
            var loop:int;
            var stop:Boolean;
            var newItem:Object;
            if (previousItem == null)
            {
                visibleItems = dataGrid.getVisibleItems();
                visibleItems.sort(rowSortFunction);
                j = 0;
                while (j < visibleItems.length)
                {
                    resourceItem = visibleItems[j];
                    newItem = this.getTaskFromResource(resourceItem);
                    if (newItem != null)
                    {
                        break;
                    }
                    j++;
                }
                if (newItem == null)
                {
                    k = 0;
                    while (k < visibleItems.length)
                    {
                        resourceItem = visibleItems[k];
                        newItem = this.getTaskFromResource(resourceItem, true, false);
                        if (newItem != null)
                        {
                            break;
                        }
                        k++;
                    }
                }
            }
            else
            {
                if (direction == Keyboard.LEFT || direction == Keyboard.RIGHT)
                {
                    resourceItem = this.getResource(previousItem);
                    tasks = ganttSheet.sortTasks(this.getTaskItems(resourceItem));
                    index = tasks.indexOf(ganttSheet.itemToTaskItem(previousItem));
                    if (direction == Keyboard.LEFT)
                    {
                        if (index == 0)
                        {
                            index = tasks.length;
                        }
                        newItem = tasks[(index - 1)].data;
                    }
                    else if (direction == Keyboard.RIGHT)
					{
						if (index == (tasks.length - 1))
						{
							index = -1;
						}
						newItem = tasks[(index + 1)].data;
					}
                }
                else
                {
                    resourceItem = this.getResource(previousItem);
                    index = dataGrid.itemRendererToIndex(dataGrid.itemToItemRenderer(resourceItem));
                    loop = 0;
                    stop = false;
                    while (newItem == null && loop < 2)
                    {
                        if (direction == Keyboard.UP)
                        {
                            index--;
                        }
                        else if (direction == Keyboard.DOWN)
						{
							index++;
						}
                        if (index < 0)
                        {
                            loop++;
                            index = (dataGrid.verticalTotalRows - 1);
                        }
                        else if (index > (dataGrid.verticalTotalRows - 1))
						{
							loop++;
							index = 0;
						}
                        dataGrid.scrollToIndex(index);
                        resourceItem = dataGrid.indexToItemRenderer(index).data;
                        newItem = this.getTaskFromResource(resourceItem, true);
                    }
                }
            }
            return newItem;
        }

        private function getTaskItems(rowItem:Object):Array
        {
            var item:Object;
            var taskItem:TaskItem;
            var tasks:Array = this.rowItemToTasks(rowItem);
            var taskItems:Array = [];
            for each (item in tasks)
            {
                taskItem = _ganttSheet.itemToTaskItem(item);
                taskItems.push(taskItem);
            }
            return taskItems;
        }

        private function getTaskFromResource(resourceItem:Object, invisible:Boolean=false, visible:Boolean=true):Object
        {
            var tasks:Array;
            if (visible)
            {
                tasks = ganttSheet.sortTasks(this.getVisibleTaskItems(resourceItem, ganttSheet.timeController.startTime, ganttSheet.timeController.endTime));
                if (tasks != null && tasks.length > 0)
                {
                    return tasks[0].data;
                }
            }
            if (invisible)
            {
                tasks = this.getTasks(resourceItem);
                if (tasks != null && tasks.length > 0)
                {
                    return tasks[0];
                }
            }
            return null;
        }

        override public function scrollToItem(item:Object, margin:Number=10):void
        {
            if (!initialized)
            {
                return;
            }
            if (this.isResource(item))
            {
                this.scrollToResource(item, margin);
            }
            else if (this.isTask(item))
			{
				this.scrollToTask(item, margin);
			}
        }

        private function scrollToResource(item:Object, margin:Number):void
        {
            var index:int;
            try
            {
                index = _dataGrid.getItemIndex(item);
                if (index != -1)
                {
                    _dataGrid.scrollToIndex(index);
                }
            }
            catch(pending:ItemPendingError)
            {
                pending.addResponder(new ItemResponder(scrollToResourcePendingResultHandler, scrollToResourcePendingFailureHandler, {
                    "item":item,
                    "margin":margin
                }));
            }
        }

        private function scrollToResourcePendingResultHandler(result:Object, info:Object):void
        {
            this.scrollToResource(info.item, info.margin);
        }

        private function scrollToResourcePendingFailureHandler(error:ErrorMessage, info:Object):void
        {
        }

        private function scrollToTask(item:Object, margin:Number):void
        {
            var resource:Object;
            var index:int;
            try
            {
                resource = this.getResource(item);
                index = _dataGrid.getItemIndex(resource);
                if (index != -1)
                {
                    _dataGrid.scrollToIndex(index);
                    if (_dataGrid.isItemVisible(resource))
                    {
                        _ganttSheet.scrollToItem(item, margin);
                    }
                }
            }
            catch(pending:ItemPendingError)
            {
                pending.addResponder(new ItemResponder(scrollToTaskPendingResultHandler, scrollToTaskPendingFailureHandler, {
                    "item":item,
                    "margin":margin
                }));
            }
        }

        private function scrollToTaskPendingResultHandler(result:Object, info:Object):void
        {
            this.scrollToTask(info.item, info.margin);
        }

        private function scrollToTaskPendingFailureHandler(error:ErrorMessage, info:Object):void
        {
        }

        override public function getVisibleTaskItems(rowItem:Object, start:Date, end:Date):Array
        {
            var item:Object;
            var margin:Number;
            var duration:Number;
            var taskItem:TaskItem;
            if (ganttSheet != null && ganttSheet.initialized)
            {
                margin = 20;
                duration = (ganttSheet.getTime(margin).time - ganttSheet.getTime(0).time);
                start = new Date((start.time - duration));
                end = new Date((end.time + duration));
            }
            var tasks:Array = this.rowItemToTasks(rowItem);
            var taskItems:Array = [];
            for each (item in tasks)
            {
                taskItem = _ganttSheet.itemToTaskItem(item);
                if (_ganttSheet.isTaskItemVisible(taskItem, start, end))
                {
                    taskItems.push(taskItem);
                }
            }
            return taskItems;
        }

        override public function rowItemToTasks(rowItem:Object):Array
        {
            return this._dataDescriptor.getTasks(rowItem);
        }

        override public function taskItemToRowItem(taskItem:TaskItem):Object
        {
            return taskItem ? taskItem.resource : null;
        }

        override public function updateTaskItem(item:TaskItem, property:Object):void
        {
            var value:Object;
            super.updateTaskItem(item, property);
            if (!property || property == this.taskResourceIdField || this.taskResourceIdFunction != null)
            {
                value = DataUtil.getFieldValue(item.data, this.taskResourceIdField, null, this.taskResourceIdFunction);
                item.resourceId = value!=null ? String(value) : null;
            }
        }

        override public function commitTaskItem(item:TaskItem):void
        {
            super.commitTaskItem(item);
            if (this.taskResourceIdField)
            {
                setItemField(item.data, this.taskResourceIdField, item.resourceId);
            }
            else
            {
                MessageUtil.log(ResourceChart, LogEventLevel.WARN, GanttProperties.ELIXIR_GANTT_BUNDLE, GanttProperties.DONT_KNOW_HOW_TO_COMMIT_MESSAGE, ["TaskItem.resourceId", "taskResourceIdField"], resourceManager);
            }
        }

		public function getResourceId(rowItem:Object):String
        {
            return this.dataDescriptor.getResourceId(rowItem);
        }

        override protected function integrateDataGrid():void
        {
            super.integrateDataGrid();
            if (this._resourceCollection)
            {
                _dataGrid.dataProvider = this._resourceCollection;
            }
            else
            {
                this.setResourceDataProvider();
            }
        }

        private function setResourceDataProvider():void
        {
            if (!_dataGrid)
            {
                return;
            }
            _dataGrid.dataProvider = this._resourceDataProvider;
            _dataGrid.validateProperties();
            this._resourceCollection = (_dataGrid.dataProvider as ICollectionView);
            this._dataDescriptor.setResources(this._resourceCollection);
            if (_rowController)
            {
                _rowController.dataGridCollection = this._resourceCollection;
            }
            var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
            event.kind = CollectionEventKind.RESET;
            dispatchEvent(event);
        }

        override protected function dataGridViewChangeHandler(event:AdvancedDataGridEvent):void
        {
            this.dataDescriptor.invalidateResourceInfo();
        }

        override protected function integrateGanttSheet():void
        {
            super.integrateGanttSheet();
            if (_taskCollection)
            {
                _ganttSheet.taskCollection = _taskCollection;
            }
        }
    }
}
