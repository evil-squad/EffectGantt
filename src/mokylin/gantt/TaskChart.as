package mokylin.gantt
{
    import mx.collections.ICollectionView;
    import mx.core.IFlexModuleFactory;
    import mx.styles.CSSStyleDeclaration;
    import mokylin.utils.CSSUtil;
    import flash.ui.Keyboard;
    import mx.collections.errors.ItemPendingError;
    import mx.collections.ItemResponder;
    import mx.messaging.messages.ErrorMessage;
    import mx.collections.IHierarchicalCollectionView;
    import mokylin.utils.DataUtil;
    import mokylin.gantt.supportClasses.MessageUtil;
    import mx.logging.LogEventLevel;
    import mokylin.gantt.supportClasses.GanttProperties;
    import mx.events.CollectionEvent;
    import mx.events.CollectionEventKind;
    import mx.events.AdvancedDataGridEvent;
    import mx.collections.ArrayCollection;
    import mx.collections.IList;
    import mx.collections.ListCollectionView;
    import mx.collections.XMLListCollection;

    /*[IconFile("TaskChart.png")]*/
    [Style(name="constraintItemStyleName", type="String", inherit="no")]
    [Style(name="ganttSheetStyleName", type="String", inherit="no")]
    [Style(name="summaryItemStyleName", type="String", inherit="no")]
    [Style(name="taskItemStyleName", type="String", inherit="no")]
    public class TaskChart extends GanttChartBase 
    {

        private var _lastConstraint:Object;
        private var _constraints:Array;
        protected var _constraintFieldChanged:Boolean;
        private var _styleInitialized:Boolean = false;
        private var _autoResizeSummary:Boolean = true;
        private var _constraintDataProvider:Object;
        private var _constraintCollection:ICollectionView;
        private var _constraintKindField:String = "kind";
        private var _constraintKindFunction:Function = null;
        private var _dataDescriptor:TaskChartDataDescriptor;
        private var _taskIsSummaryField:String = null;
        private var _taskIsSummaryFunction:Function = null;

        public function TaskChart()
        {
            this._dataDescriptor = new TaskChartDataDescriptor();
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
            var styleDeclaration:CSSStyleDeclaration = CSSUtil.createSelector("TaskChart", "mokylin.gantt", styleManager);
            styleDeclaration.defaultFactory = function ():void
            {
                this.constraintItemStyleName = undefined;
                this.ganttSheetStyleName = "taskChartGanttSheet";
                this.summaryItemStyleName = "summaryTask";
                this.taskItemStyleName = "leafTask";
            }
        }

        public function get autoResizeSummary():Boolean
        {
            return this._autoResizeSummary;
        }

        public function set autoResizeSummary(value:Boolean):void
        {
            this._autoResizeSummary = value;
            if (_ganttSheet)
            {
                _ganttSheet.autoResizeSummary = this._autoResizeSummary;
            }
        }

        [Bindable("collectionChange")]
        [Inspectable(category="Data")]
        public function get constraintDataProvider():Object
        {
            return this._constraintCollection;
        }

        public function set constraintDataProvider(value:Object):void
        {
            if (this._constraintDataProvider != value)
            {
                this._constraintDataProvider = value;
                this.setConstraintDataProvider();
            }
        }

        [Inspectable(category="Data", defaultValue="fromId")]
        public function get constraintFromIdField():String
        {
            return this._dataDescriptor.constraintFromIdField;
        }

        public function set constraintFromIdField(value:String):void
        {
            this._dataDescriptor.constraintFromIdField = value;
            this._constraintFieldChanged = true;
            invalidateProperties();
        }

        [Inspectable(category="Data", defaultValue="null")]
        public function get constraintFromIdFunction():Function
        {
            return this._dataDescriptor.constraintFromIdFunction;
        }

        public function set constraintFromIdFunction(value:Function):void
        {
            this._dataDescriptor.constraintFromIdFunction = value;
            this._constraintFieldChanged = true;
            invalidateProperties();
        }

        [Inspectable(category="Data", defaultValue="kind")]
        public function get constraintKindField():String
        {
            return this._constraintKindField;
        }

        public function set constraintKindField(value:String):void
        {
            this._constraintKindField = value;
            this._constraintFieldChanged = true;
            invalidateProperties();
        }

        [Inspectable(category="Data", defaultValue="null")]
        public function get constraintKindFunction():Function
        {
            return this._constraintKindFunction;
        }

        public function set constraintKindFunction(value:Function):void
        {
            this._constraintKindFunction = value;
            this._constraintFieldChanged = true;
            invalidateProperties();
        }

        [Inspectable(category="Data", defaultValue="toId")]
        public function get constraintToIdField():String
        {
            return this._dataDescriptor.constraintToIdField;
        }

        public function set constraintToIdField(value:String):void
        {
            this._dataDescriptor.constraintToIdField = value;
            this._constraintFieldChanged = true;
            invalidateProperties();
        }

        [Inspectable(category="Data", defaultValue="null")]
        public function get constraintToIdFunction():Function
        {
            return this._dataDescriptor.constraintToIdFunction;
        }

        public function set constraintToIdFunction(value:Function):void
        {
            this._dataDescriptor.constraintToIdFunction = value;
            this._constraintFieldChanged = true;
            invalidateProperties();
        }

		public function get dataDescriptor():TaskChartDataDescriptor
        {
            return this._dataDescriptor;
        }

        override public function get taskDataProvider():Object
        {
            return _taskCollection;
        }

        override public function set taskDataProvider(value:Object):void
        {
            if (_taskDataProvider != value)
            {
                _taskDataProvider = value;
                this.setTaskDataProvider();
            }
        }

        [Inspectable(category="Data", defaultValue="id")]
        public function get taskIdField():String
        {
            return this._dataDescriptor.taskIdField;
        }

        public function set taskIdField(value:String):void
        {
            this._dataDescriptor.taskIdField = value;
            _taskFieldChanged = true;
            invalidateProperties();
        }

        [Inspectable(category="Data", defaultValue="null")]
        public function get taskIdFunction():Function
        {
            return this._dataDescriptor.taskIdFunction;
        }

        public function set taskIdFunction(value:Function):void
        {
            this._dataDescriptor.taskIdFunction = value;
            _taskFieldChanged = true;
            invalidateProperties();
        }

        [Inspectable(category="Data", defaultValue="null")]
        public function get taskIsSummaryField():String
        {
            return this._taskIsSummaryField;
        }

        public function set taskIsSummaryField(value:String):void
        {
            if (this._taskIsSummaryField != value)
            {
                this._taskIsSummaryField = value;
                _taskFieldChanged = true;
                invalidateProperties();
            }
        }

        [Inspectable(category="Data")]
        public function get taskIsSummaryFunction():Function
        {
            return this._taskIsSummaryFunction;
        }

        public function set taskIsSummaryFunction(value:Function):void
        {
            if (this._taskIsSummaryFunction != value)
            {
                this._taskIsSummaryFunction = value;
                _taskFieldChanged = true;
                invalidateProperties();
            }
        }

        override protected function commitProperties():void
        {
            super.commitProperties();
            if (this._constraintFieldChanged)
            {
                this._constraintFieldChanged = false;
                if (this._constraintCollection)
                {
                    this._constraintCollection.refresh();
                }
            }
        }

        override public function styleChanged(styleProp:String):void
        {
            super.styleChanged(styleProp);
            if (!styleProp || styleProp == "constraintItemStyleName")
            {
                if (_ganttSheet)
                {
                    _ganttSheet.invalidateItemsSize();
                }
            }
            if (!styleProp || styleProp == "summaryItemStyleName")
            {
                if (_ganttSheet)
                {
                    _ganttSheet.invalidateItemsSize();
                }
            }
        }

        override public function isTask(item:Object):Boolean
        {
            return _taskCollection && _taskCollection.contains(item);
        }

        public function isConstraint(item:Object):Boolean
        {
            return this._constraintCollection && this._constraintCollection.contains(item);
        }

        public function getFromTask(constraint:Object):Object
        {
            return this._dataDescriptor.getFromTask(constraint);
        }

        public function getToTask(constraint:Object):Object
        {
            return this._dataDescriptor.getToTask(constraint);
        }

        public function getFromConstraints(task:Object):Array
        {
            return this._dataDescriptor.getFromConstraints(task);
        }

        public function getToConstraints(task:Object):Array
        {
            return this._dataDescriptor.getToConstraints(task);
        }

        override public function nextItem(previousItem:Object, direction:uint):Object
        {
            var visibleItems:Array;
            var items:Array;
            var i:int;
            var constraints:Array;
            var index:int;
            var loop:int;
            var stop:Boolean;
            var newItem:Object;
            if (previousItem == null)
            {
                visibleItems = dataGrid.getVisibleItems();
                visibleItems.sort(rowSortFunction);
                i = 0;
                while (i < visibleItems.length)
                {
                    if (ganttSheet.isTaskItemVisible(ganttSheet.itemToTaskItem(visibleItems[i]), ganttSheet.timeController.startTime, ganttSheet.timeController.endTime))
                    {
                        newItem = visibleItems[i];
                        break;
                    }
                    i++;
                }
                if (newItem == null)
                {
                    newItem = dataGrid.firstVisibleItem;
                }
            }
            else
            {
                constraints = null;
                if (this.isTask(previousItem))
                {
                    if (direction == Keyboard.UP || direction == Keyboard.DOWN)
                    {
                        index = dataGrid.itemRendererToIndex(dataGrid.itemToItemRenderer(previousItem));
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
                                index = dataGrid.verticalTotalRows - 1;
                            }
                            else
                            {
                                if (index > (dataGrid.verticalTotalRows - 1))
                                {
                                    loop++;
                                    index = 0;
                                }
                            }
                            dataGrid.scrollToIndex(index);
                            newItem = dataGrid.indexToItemRenderer(index).data;
                        }
                    }
                    else
                    {
                        constraints = direction == Keyboard.LEFT ? this.getToConstraints(previousItem) : (direction == Keyboard.RIGHT ? this.getFromConstraints(previousItem) : null);
                        constraints = this.getVisibleContraints(constraints);
                        if (constraints != null && constraints.length > 0)
                        {
                            if (this._lastConstraint != null && constraints.indexOf(this._lastConstraint) != -1)
                            {
                                newItem = this._lastConstraint;
                            }
                            else
                            {
                                newItem = constraints[0];
                            }
                            this._constraints = constraints;
                        }
                        if (newItem == null)
                        {
                            newItem = previousItem;
                        }
                    }
                }
                else
                {
                    if (direction == Keyboard.UP || direction == Keyboard.DOWN)
                    {
                        newItem = this.nextConstraint(previousItem, this._constraints != null ? this._constraints : this.getVisibleContraints(this.getFromConstraints(this.getFromTask(previousItem))), direction);
                    }
                    else
                    {
                        if (direction == Keyboard.LEFT)
                        {
                            newItem = this.getFromTask(previousItem);
                        }
                        else
                        {
                            newItem = this.getToTask(previousItem);
                        }
                        this._lastConstraint = previousItem;
                    }
                }
            }
            return newItem;
        }

        private function getVisibleContraints(constraints:Array):Array
        {
            var item:Object;
            if (constraints == null)
            {
                return null;
            }
            var result:Array = [];
            for each (item in constraints)
            {
                if (ganttSheet.isItemVisible(item))
                {
                    result.push(item);
                }
            }
            return result;
        }

        private function nextConstraint(constraint:Object, constraints:Array, direction:uint):Object
        {
            var index:int = constraints.indexOf(constraint);
            index = direction == Keyboard.UP ? index - 1 : index + 1;
            if (index < 0)
            {
                index = constraints.length - 1;
            }
            else if (index > (constraints.length - 1))
			{
				index = 0;
			}
            return constraints[index];
        }

        override public function scrollToItem(item:Object, margin:Number=10):void
        {
            if (!initialized)
            {
                return;
            }
            if (this.isTask(item))
            {
                this.scrollToTask(item, margin);
            }
            else if (this.isConstraint(item))
			{
				this.scrollToConstraint(item, margin);
			}
        }

        private function scrollToTask(item:Object, margin:Number):void
        {
            var index:int;
            try
            {
                index = _dataGrid.getItemIndex(item);
                if (index != -1)
                {
                    _dataGrid.scrollToIndex(index);
                }
                if (_dataGrid.isItemVisible(item))
                {
                    _ganttSheet.scrollToItem(item, margin);
                }
            }
            catch(pending:ItemPendingError)
            {
                pending.addResponder(new ItemResponder(scrollToTaskPendingResultHandler, scrollToTaskPendingFailureHandler, {
                    "item":item,
                    "margin":margin
                }));
            };
        }

        private function scrollToTaskPendingResultHandler(result:Object, info:Object):void
        {
            this.scrollToTask(info.item, info.margin);
        }

        private function scrollToTaskPendingFailureHandler(error:ErrorMessage, info:Object):void
        {
        }

        private function scrollToConstraint(item:Object, margin:Number):void
        {
            var task:Object;
            var index:int;
            try
            {
                task = this.getFromTask(item);
                index = _dataGrid.getItemIndex(task);
                if (index != -1)
                {
                    _dataGrid.scrollToIndex(index);
                    if (_dataGrid.isItemVisible(task))
                    {
                        _ganttSheet.scrollToItem(item, margin);
                    }
                }
            }
            catch(pending:ItemPendingError)
            {
                pending.addResponder(new ItemResponder(scrollToConstraintPendingResultHandler, scrollToConstraintPendingFailureHandler, {
                    "item":item,
                    "margin":margin
                }));
            };
        }

        private function scrollToConstraintPendingResultHandler(result:Object, info:Object):void
        {
            this.scrollToConstraint(info.item, info.margin);
        }

        private function scrollToConstraintPendingFailureHandler(error:ErrorMessage, info:Object):void
        {
        }

        override public  function getVisibleTaskItems(rowItem:Object, start:Date, end:Date):Array
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

        override public function rowItemToTasks(rowItem:Object):Array
        {
            return rowItem == null ? null : [rowItem];
        }

        override public function taskItemToRowItem(taskItem:TaskItem):Object
        {
            return taskItem ? taskItem.data : null;
        }

        override public function updateTaskItem(item:TaskItem, property:Object):void
        {
            var value:Object;
            var hierarchicalCollection:IHierarchicalCollectionView;
            var children:ICollectionView;
            super.updateTaskItem(item, property);
            if (this.taskIsSummaryField != null || this.taskIsSummaryFunction != null)
            {
                value = DataUtil.getFieldValue(item.data, this.taskIsSummaryField, null, this.taskIsSummaryFunction);
            }
            else
            {
                hierarchicalCollection = (_taskCollection as IHierarchicalCollectionView);
                if (hierarchicalCollection != null && hierarchicalCollection.source != null)
                {
                    value = hierarchicalCollection.source.canHaveChildren(item.data);
                }
                else if (hierarchicalCollection != null)
				{
					children = hierarchicalCollection.getChildren(item.data);
					value = children && children.length > 0;
				}
				else
				{
					value = false;
				}
            }
            item.isSummary = value!=null ? Boolean(value) : false;
        }

        override public function commitTaskItem(item:TaskItem):void
        {
            super.commitTaskItem(item);
            if (this.taskIsSummaryField)
            {
                setItemField(item.data, this.taskIsSummaryField, item.isSummary);
            }
            else
            {
                if (this.taskIsSummaryFunction != null)
                {
                    MessageUtil.log(TaskChart, LogEventLevel.WARN, GanttProperties.ELIXIR_GANTT_BUNDLE, GanttProperties.DONT_KNOW_HOW_TO_COMMIT_MESSAGE, ["TaskItem.isSummary", "taskIsSummaryField"], resourceManager);
                }
            }
        }

		public function updateConstraintItem(item:ConstraintItem, property:Object):void
        {
            var value:Object;
            if (!property || property == this.constraintFromIdField || this.constraintFromIdFunction != null)
            {
                value = DataUtil.getFieldValue(item.data, this.constraintFromIdField, null, this.constraintFromIdFunction);
                item.fromId = value!=null ? String(value) : null;
            }
            if (!property || property == this.constraintToIdField || this.constraintToIdFunction != null)
            {
                value = DataUtil.getFieldValue(item.data, this.constraintToIdField, null, this.constraintToIdFunction);
                item.toId = value!=null ? String(value) : null;
            }
            if (!property || property == this.constraintKindField || this.constraintKindFunction != null)
            {
                value = DataUtil.getFieldValue(item.data, this.constraintKindField, null, this.constraintKindFunction);
                item.kind = value!=null ? String(value) : null;
            }
        }

		public function commitConstraintItem(item:ConstraintItem):void
        {
            if (this.constraintFromIdField)
            {
                setItemField(item.data, this.constraintFromIdField, item.fromId);
            }
            else
            {
                MessageUtil.log(TaskChart, LogEventLevel.WARN, GanttProperties.ELIXIR_GANTT_BUNDLE, GanttProperties.DONT_KNOW_HOW_TO_COMMIT_MESSAGE, ["ConstraintItem.fromId", "constraintFromIdField"], resourceManager);
            }
            if (this.constraintToIdField)
            {
                setItemField(item.data, this.constraintToIdField, item.toId);
            }
            else
            {
                MessageUtil.log(TaskChart, LogEventLevel.WARN, GanttProperties.ELIXIR_GANTT_BUNDLE, GanttProperties.DONT_KNOW_HOW_TO_COMMIT_MESSAGE, ["ConstraintItem.toId", "constraintToIdField"], resourceManager);
            }
            if (this.constraintKindField)
            {
                setItemField(item.data, this.constraintKindField, item.kind);
            }
            else
            {
                MessageUtil.log(TaskChart, LogEventLevel.WARN, GanttProperties.ELIXIR_GANTT_BUNDLE, GanttProperties.DONT_KNOW_HOW_TO_COMMIT_MESSAGE, ["ConstraintItem.kind", "constraintKindField"], resourceManager);
            }
        }

        public function getTaskSummaries(task:Object):Array
        {
            if (_ganttSheet)
            {
                return _ganttSheet.getTaskSummaries(task);
            }
            return null;
        }

        public function resizeSummaryTasks():void
        {
            if (_ganttSheet)
            {
                _ganttSheet.resizeSummaryTasks();
            }
        }

        override protected function integrateDataGrid():void
        {
            super.integrateDataGrid();
            if (_taskCollection)
            {
                _dataGrid.dataProvider = _taskCollection;
            }
            else
            {
                this.setTaskDataProvider();
            }
        }

        private function setTaskDataProvider():void
        {
            if (!_dataGrid)
            {
                return;
            }
            _dataGrid.dataProvider = _taskDataProvider;
            _dataGrid.validateProperties();
            _taskCollection = (_dataGrid.dataProvider as ICollectionView);
            this._dataDescriptor.setTasks(_taskCollection);
            if (_rowController)
            {
                _rowController.dataGridCollection = _taskCollection;
            }
            if (_ganttSheet)
            {
                _ganttSheet.taskCollection = _taskCollection;
            }
            var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
            event.kind = CollectionEventKind.RESET;
            dispatchEvent(event);
        }

        override protected function dataGridViewChangeHandler(event:AdvancedDataGridEvent):void
        {
            this.dataDescriptor.invalidateTaskInfo();
        }

        override protected function integrateGanttSheet():void
        {
            super.integrateGanttSheet();
            _ganttSheet.taskCollection = _taskCollection;
            _ganttSheet.autoResizeSummary = this._autoResizeSummary;
        }

        private function setConstraintDataProvider():void
        {
            var xl:XMLList;
            var tmp:Array;
            if (this._constraintDataProvider is Array)
            {
                this._constraintCollection = new ArrayCollection((this._constraintDataProvider as Array));
            }
            else if (this._constraintDataProvider is ICollectionView)
			{
				this._constraintCollection = ICollectionView(this._constraintDataProvider);
			}
			else if (this._constraintDataProvider is IList)
			{
				this._constraintCollection = new ListCollectionView(IList(this._constraintDataProvider));
			}
			else if (this._constraintDataProvider is XMLList)
			{
				this._constraintCollection = new XMLListCollection((this._constraintDataProvider as XMLList));
			}
			else if (this._constraintDataProvider is XML)
			{
				xl = new XMLList();
				xl = xl + this._constraintDataProvider;
				_taskCollection = new XMLListCollection(xl);
			}
			else
			{
				tmp = [];
				if (this._constraintDataProvider != null)
				{
					tmp.push(this._constraintDataProvider);
				}
				this._constraintCollection = new ArrayCollection(tmp);
			}
            this._dataDescriptor.setConstraints(this._constraintCollection);
            if (_ganttSheet)
            {
                _ganttSheet.constraintCollection = this._constraintCollection;
            }
            var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
            event.kind = CollectionEventKind.RESET;
            dispatchEvent(event);
        }
    }
}
