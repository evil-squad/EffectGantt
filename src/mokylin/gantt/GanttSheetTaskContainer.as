package mokylin.gantt
{
    import flash.display.DisplayObject;
    import flash.geom.Rectangle;
    
    import mx.core.IDataRenderer;
    import mx.core.IFactory;
    import mx.core.IFlexDisplayObject;
    import mx.core.IInvalidating;
    import mx.core.IProgrammaticSkin;
    import mx.styles.ISimpleStyleClient;
    
    import __AS3__.vec.Vector;

    [ExcludeClass]
    public class GanttSheetTaskContainer extends GanttSheetItemContainer 
    {

        private var _taskToConnectionBounds:Object;

        public function GanttSheetTaskContainer(ganttSheet:GanttSheet)
        {
            this._taskToConnectionBounds = {};
            super(ganttSheet);
        }

        override public function set itemRenderer(value:IFactory):void
        {
            if (itemRenderer == value)
            {
                return;
            }
            super.itemRenderer = value;
            this.invalidateItemsSize();
        }

        final private function get taskLayout():TaskLayout
        {
            return ganttSheet.taskLayout;
        }

        final private function get rowController():IRowController
        {
            return ganttChart.rowController;
        }

        override public function invalidateTaskItemsLayout(items:Array):void
        {
            if (timeController == null || !timeController.configured)
            {
                return;
            }
            this.invalidateConnectionBoundsOfTasks(items);
            var rowItems:Array = this.getRowItemsForTasks(items);
            this.invalidateLayoutOfTasksInRows(rowItems);
        }

        public function invalidateLayoutOfTasksInRows(rowItems:Array):void
        {
            var item:Object;
            var variableRowHeight:Boolean = this.rowController.variableRowHeight;
            var visibleRowChanged:Boolean;
            for each (item in rowItems)
            {
                this.taskLayout.invalidateRowDistribution(item);
                if (!visibleRowChanged && this.rowController.isItemVisible(item))
                {
                    visibleRowChanged = true;
                }
            }
            if (visibleRowChanged)
            {
                if (variableRowHeight)
                {
                    this.rowController.invalidateItemsSize();
                }
                else
                {
                    _updateRenderersNeeded = true;
                    invalidateProperties();
                }
            }
        }

        private function getRowItemsForTasks(items:Array):Array
        {
            var item:Object;
            var taskItem:TaskItem;
            var rowItem:Object;
            var uid:String;
            var rowItems:Array = [];
            var rowItemUIDs:Object = {};
            for each (item in items)
            {
                taskItem = ganttSheet.itemToTaskItem(item);
                rowItem = this.taskItemToRowItem(taskItem);
                if (rowItem != null)
                {
                    uid = itemToUID(rowItem);
                    if (rowItemUIDs[uid] === undefined)
                    {
                        rowItemUIDs[uid] = rowItem;
                        rowItems.push(rowItem);
                    }
                }
            }
            return rowItems;
        }

        override public function invalidateItemsSize():void
        {
            this.taskLayout.invalidate();
            super.invalidateItemsSize();
        }

        override protected function updateItemRenderers():void
        {
            var uid:String;
            var renderer:DisplayObject;
            var rowItem:Object;//类型为用户自定义数据载体格式，目前DEMO是SchedulingTask类型
            var rowInfo:Object;
            var rowLayoutInfo:RowLayoutInfo;
            var updateItemsInRow:Boolean;
            var taskItems:Array;
            var rowExposesNewTasks:Boolean;
            var exposedTasksInRow:Array;
            var taskItem:TaskItem;
            if (timeController == null || !timeController.configured)
            {
                return;
            }
            var rowController:IRowController = this.rowController;
            var start:Number = timeController.startTime;
            var end:Number = timeController.endTime;
            var updateAllRows:Boolean;
            if (_sizeChanged || _itemsSizeChanged || _itemsPositionChanged)
            {
                this.invalidateConnectionBoundsOfAllTasks();
                updateAllRows = true;
            }
            var oldRenderers:Object = _visibleItemRenderers;
            _visibleItemRenderers = {};
            var rowItems:Array = rowController.getVisibleItems();
            var updatedRowItems:Array = [];
            var exposedRows:Array = [];
            for each (rowItem in rowItems)
            {
                rowLayoutInfo = this.taskLayout.getRowLayoutInfo(rowItem);
                updateItemsInRow = updateAllRows || rowLayoutInfo.invalidDistribution || rowLayoutInfo.invalidSize || rowItem == this.taskLayout.lockedRow;
                if (updateItemsInRow)
                {
                    this.taskLayout.validateRowSize(rowLayoutInfo);
                    this.taskLayout.validateActualRowHeightAndPosition(rowLayoutInfo);
                }
                if (!rowLayoutInfo.hasValidHeightAndPosition())
                {
                }
                else
                {
                    taskItems = this.getVisibleTaskItems(rowItem, start, end);
                    if (taskItems.length == 0)
                    {
                    }
                    else
                    {
                        updatedRowItems.push({
                            "rowItem":rowItem,
                            "taskItems":taskItems
                        });
                        rowExposesNewTasks = false;
                        exposedTasksInRow = [];
                        for each (taskItem in taskItems)
                        {
                            uid = taskItem.uid;
                            renderer = oldRenderers[uid];
                            if (renderer != null)
                            {
                                if (updateItemsInRow)
                                {
                                    this.updateItemRenderer(taskItem, renderer, rowLayoutInfo, uid, false);
                                }
                                delete oldRenderers[uid];
                                _visibleItemRenderers[uid] = renderer;
                            }
                            else
                            {
                                rowExposesNewTasks = true;
                                exposedTasksInRow.push(taskItem);
                            }
                        }
                        if (rowExposesNewTasks)
                        {
                            exposedRows.push({
                                "rowItem":rowItem,
                                "rowLayoutInfo":rowLayoutInfo,
                                "updateItemsInRow":updateItemsInRow,
                                "taskItems":exposedTasksInRow
                            });
                        }
                    }
                }
            }
            for each (uid in _lockedUIDs)
            {
                renderer = oldRenderers[uid];
                if (renderer != null)
                {
                    _visibleItemRenderers[uid] = renderer;
                    delete oldRenderers[uid];
                }
            }
            for each (renderer in oldRenderers)
            {
                if (renderer != null)
                {
                    renderer.visible = false;
                    _freeItemRenderers.push(renderer);
                }
            }
            for each (rowInfo in exposedRows)
            {
                rowLayoutInfo = (rowInfo.rowLayoutInfo as RowLayoutInfo);
                updateItemsInRow = (rowInfo.updateItemsInRow as Boolean);
                taskItems = (rowInfo.taskItems as Array);
                for each (taskItem in taskItems)
                {
                    uid = taskItem.uid;
                    renderer = createItemRenderer();
                    this.updateItemRenderer(taskItem, renderer, rowLayoutInfo, uid, true);
                    _visibleItemRenderers[uid] = renderer;
                }
            }
            this.updateZOrderOfTasksInRows(updatedRowItems);
        }

        private function updateItemRenderer(taskItem:TaskItem, renderer:DisplayObject, rowLayoutInfo:RowLayoutInfo, uid:String, updateData:Boolean=false):void
        {
            var taskLayoutInfo:TaskLayoutInfo = this.taskLayout.getTaskLayoutInfo(taskItem.data, uid);
            this.taskLayout.calculateTaskLayout(taskLayoutInfo, rowLayoutInfo);
            if (!taskLayoutInfo.hasValidHeightAndPosition())
            {
                renderer.visible = false;
                return;
            }
            this.layoutRenderer(renderer, taskItem, rowLayoutInfo, taskLayoutInfo);
            if (renderer is IDataRenderer)
            {
                IDataRenderer(renderer).data = taskItem;
            }
            if (renderer is ISimpleStyleClient)
            {
                ISimpleStyleClient(renderer).styleName = ganttSheet.itemToStyleName(taskItem);
            }
            this.invalidateDisplayObjectDisplayList(renderer);
            renderer.visible = true;
        }

        public function getConnectionBoundsMeasuringRenderer(item:Object):DisplayObject
        {
            var renderer:DisplayObject = DisplayObject(itemToItemRenderer(item));
            if (renderer != null && renderer.visible)
            {
                return renderer;
            }
            var taskItem:TaskItem = ganttSheet.itemToTaskItem(item);
            var rowItem:Object = this.taskItemToRowItem(taskItem);
            if (rowItem == null)
            {
                return null;
            }
            var index:int = this.rowController.getItemIndex(rowItem);
            if (index < 0)
            {
                return null;
            }
            var rowIsVisible:Boolean = this.rowController.isItemVisible(rowItem);
            var rowLayoutInfo:RowLayoutInfo = this.getMeasuringRowLayoutInfo(rowItem, rowIsVisible, index);
            var taskLayoutInfo:TaskLayoutInfo = this.getMeasuringTaskLayoutInfo(item, taskItem.uid, rowIsVisible, rowLayoutInfo);
            if (_measuringRenderer == null)
            {
                _measuringRenderer = itemRenderer.newInstance();
                _measuringRenderer.visible = false;
                addChild(_measuringRenderer);
            }
            renderer = _measuringRenderer;
            this.layoutRenderer(renderer, taskItem, rowLayoutInfo, taskLayoutInfo);
            if (renderer is IDataRenderer)
            {
                IDataRenderer(renderer).data = taskItem;
            }
            if (renderer is ISimpleStyleClient)
            {
                ISimpleStyleClient(renderer).styleName = ganttSheet.itemToStyleName(taskItem);
            }
            return renderer;
        }

        private function getMeasuringRowLayoutInfo(item:Object, rowIsVisible:Boolean, index:int):RowLayoutInfo
        {
            var rowLayoutInfo:RowLayoutInfo;
            if (rowIsVisible)
            {
                rowLayoutInfo = this.taskLayout.getRowLayoutInfo(item);
                this.taskLayout.validateRowSize(rowLayoutInfo);
                this.taskLayout.validateActualRowHeightAndPosition(rowLayoutInfo);
            }
            else
            {
                rowLayoutInfo = new RowLayoutInfo();
                rowLayoutInfo.item = item;
            }
            if (isNaN(rowLayoutInfo.y))
            {
                rowLayoutInfo.y = index < ganttChart.dataGrid.verticalScrollPosition ? -100 : height + 100;
            }
            if (isNaN(rowLayoutInfo.height))
            {
                rowLayoutInfo.height = 20;
            }
            return rowLayoutInfo;
        }

        private function getMeasuringTaskLayoutInfo(item:Object, uid:String, rowIsVisible:Boolean, rowLayoutInfo:RowLayoutInfo):TaskLayoutInfo
        {
            var taskLayoutInfo:TaskLayoutInfo;
            if (rowIsVisible)
            {
                taskLayoutInfo = this.taskLayout.getTaskLayoutInfo(item, uid);
                this.taskLayout.calculateTaskLayout(taskLayoutInfo, rowLayoutInfo);
            }
            else
            {
                taskLayoutInfo = new TaskLayoutInfo();
                taskLayoutInfo.item = item;
                taskLayoutInfo.laneIndex = 0;
                taskLayoutInfo.height = 20;
                taskLayoutInfo.y = 0;
            }
            return taskLayoutInfo;
        }

		/**
		 * 这个才是算出taskitem的宽度的函数入口--妈的，找半天 
		 * @param renderer
		 * @param taskItem
		 * @param rowLayoutInfo
		 * @param taskLayoutInfo
		 * 
		 */		
        private function layoutRenderer(renderer:DisplayObject, taskItem:TaskItem, rowLayoutInfo:RowLayoutInfo, taskLayoutInfo:TaskLayoutInfo):void
        {
            var taskLocked:Boolean = this.taskLayout.isTaskLocked(taskItem.data);
            var x0:Number = ganttSheet.getClippedCoordinate(taskItem.startTime);
            var x1:Number = ganttSheet.getClippedCoordinate(taskItem.endTime);
            var rx:Number = x0;
            var ry:Number = (isYLayoutOverride(renderer) || taskLocked) ? renderer.y : (rowLayoutInfo.y + taskLayoutInfo.y);
            var rw:Number = x1 - x0;
            var rh:Number = taskLocked ? renderer.height : taskLayoutInfo.height;
            this.moveAndResizeRenderer(renderer, rx, ry, rw, rh);
        }

        private function moveAndResizeRenderer(renderer:DisplayObject, rx:Number, ry:Number, rw:Number, rh:Number):void
        {
            var fdo:IFlexDisplayObject;
            if (renderer is IFlexDisplayObject)
            {
                fdo = IFlexDisplayObject(renderer);
                fdo.move(rx, ry);
                fdo.setActualSize(rw, rh);
            }
            else
            {
                renderer.x = rx;
                renderer.y = ry;
                renderer.width = rw;
                renderer.height = rh;
            }
        }

        private function getVisibleTaskItems(rowItem:Object, start:Number, end:Number):Array
        {
            return ganttSheet.getVisibleTaskItems(rowItem, start, end);
        }

        private function taskItemToRowItem(taskItem:TaskItem):Object
        {
            return ganttSheet.taskItemToRowItem(taskItem);
        }

        private function getVisibleTaskRenderers(taskItems:Array):Array
        {
            var taskItem:TaskItem;
            var uid:String;
            var renderer:Object;
            var renderers:Array = [];
            for each (taskItem in taskItems)
            {
                uid = taskItem.uid;
                renderer = _visibleItemRenderers[uid];
                if (renderer != null)
                {
                    renderers.push(renderer);
                }
            }
            return renderers;
        }

        private function updateZOrderOfTasksInRows(rowItemInfos:Array):void
        {
            var rowItemInfo:Object;
            if (rowItemInfos == null)
            {
                return;
            }
            for each (rowItemInfo in rowItemInfos)
            {
                this.updateZOrderOfTasks(rowItemInfo.taskItems, rowItemInfo.rowItem);
            }
        }

        private function updateZOrderOfTasks(taskItems:Array, rowItem:Object):void
        {
            var overlappingItems:Array;
            var sortedItems:Array;
            var renderers:Array;
            if (taskItems == null || taskItems.length == 0)
            {
                return;
            }
            var rowLayoutInfo:RowLayoutInfo = this.taskLayout.getRowLayoutInfo(rowItem);
            if (rowLayoutInfo.laneCount <= 1)
            {
                return;
            }
            var overlappingItemsGroups:Vector.<Array> = this.getOverlappingItemsGroups(taskItems, rowLayoutInfo);
            var i:uint;
            while (i < overlappingItemsGroups.length)
            {
                overlappingItems = overlappingItemsGroups[i];
                sortedItems = ganttSheet.sortTasks(overlappingItems);
                renderers = this.getVisibleTaskRenderers(sortedItems);
                this.updateZOrderOfDisplayObjects(renderers);
                i++;
            }
        }

        private function getOverlappingItemsGroups(taskItems:Array, rowLayoutInfo:RowLayoutInfo):Vector.<Array>
        {
            var i:uint;
            var lane:Vector.<TaskItem>;
            var group:Array;
            var groupStart:Number;
            var groupEnd:Number;
            var t1:TaskItem;
            var t1LaneIndex:uint;
            var extended:Boolean;
            var nextIndex:uint;
            var t:TaskItem;
            var j:uint;
            var t2:TaskItem;
            var lanes:Vector.<Vector.<TaskItem>> = this.getLanes(taskItems, rowLayoutInfo);
            var laneCount:uint = lanes.length;
            var groups:Vector.<Array> = new Vector.<Array>();
            if (laneCount == 1)
            {
                return groups;
            }
            var laneNextIndex:Vector.<uint> = new Vector.<uint>(laneCount);
            i = 0;
            while (i < laneCount)
            {
                laneNextIndex[i] = 0;
                i++;
            }
            while (true)
            {
                t1 = null;
                i = 0;
                while (i < laneCount)
                {
                    lane = lanes[i];
                    nextIndex = laneNextIndex[i];
                    if (nextIndex < lane.length)
                    {
                        t = (lane[nextIndex] as TaskItem);
                        if (t1 == null || t.startTime < t1.startTime)
                        {
                            t1 = t;
                            t1LaneIndex = i;
                        }
                    }
                    i++;
                }
                if (t1 == null)
                {
                    break;
                }
                var _local19:Vector.<uint> = laneNextIndex;
                var _local20:uint = t1LaneIndex;
                var _local21:uint = (_local19[_local20] + 1);
                _local19[_local20] = _local21;
                group = null;
                groupStart = t1.startTime;
                groupEnd = t1.endTime;
                do 
                {
                    extended = false;
                    i = 0;
                    while (i < laneCount)
                    {
                        lane = lanes[i];
                        j = laneNextIndex[i];
                        while (j < lane.length)
                        {
                            t2 = (lane[j] as TaskItem);
                            if (t2.startTime > groupEnd)
                            {
                                break;
                            }
                            if (t2.startTime < groupEnd && t2.endTime > groupStart)
                            {
                                if (group == null)
                                {
                                    group = [t1, t2];
                                }
                                else
                                {
                                    group.push(t2);
                                }
                                if (t2.endTime > groupEnd)
                                {
                                    groupEnd = t2.endTime;
                                    extended = true;
                                }
                            }
                            j++;
                        }
                        laneNextIndex[i] = j;
                        i++;
                    }
                } while (extended);
                if (group != null)
                {
                    groups.push(group);
                }
            }
            return groups;
        }

        private function getLanes(taskItems:Array, rowLayoutInfo:RowLayoutInfo):Vector.<Vector.<TaskItem>>
        {
            var item:TaskItem;
            var taskLayoutInfo:TaskLayoutInfo;
            var lane:Vector.<TaskItem>;
            var lanes:Vector.<Vector.<TaskItem>> = new Vector.<Vector.<TaskItem>>(rowLayoutInfo.laneCount, true);
            var count:uint = taskItems.length;
            var i:uint;
            while (i < count)
            {
                item = taskItems[i];
                taskLayoutInfo = this.taskLayout.getTaskLayoutInfo(item, item.uid);
                lane = lanes[taskLayoutInfo.laneIndex];
                if (lane == null)
                {
                    lane = new Vector.<TaskItem>();
                    lanes[taskLayoutInfo.laneIndex] = lane;
                }
                lane.push(item);
                i++;
            }
            var prunedLanes:Vector.<Vector.<TaskItem>> = new Vector.<Vector.<TaskItem>>();
            var j:uint;
            while (j < lanes.length)
            {
                if (lanes[j] != null && lanes[j].length != 0)
                {
                    prunedLanes.push(lanes[j].sort(this.taskLayout.compareStartAndDuration));
                }
                j++;
            }
            return prunedLanes;
        }

        private function updateZOrderOfDisplayObjects(renderers:Array):void
        {
            var i:uint;
            var j:uint;
            var k:uint;
            var min:int;
            var length:uint = renderers.length;
            if (length == 0)
            {
                return;
            }
            var indices:Vector.<int> = new Vector.<int>(length);
            i = 0;
            while (i < length)
            {
                indices[i] = getChildIndex(renderers[i]);
                i++;
            }
            i = 0;
            while (i < length)
            {
                k = i;
                min = indices[k];
                j = (i + 1);
                while (j < length)
                {
                    if (indices[j] < min)
                    {
                        k = j;
                        min = indices[k];
                    }
                    j++;
                }
                if (k != i)
                {
                    swapChildrenAt(min, indices[i]);
                    indices[k] = indices[i];
                    indices[i] = min;
                }
                i++;
            }
        }

        public function layoutFreeRenderer(renderer:DisplayObject, y:Number):void
        {
            var fdo:IFlexDisplayObject;
            if (renderer == null)
            {
                return;
            }
            if (renderer is IFlexDisplayObject)
            {
                fdo = IFlexDisplayObject(renderer);
                fdo.move(fdo.x, y);
                fdo.setActualSize(fdo.width, fdo.measuredHeight);
            }
            else
            {
                renderer.y = y;
            }
        }

        private function invalidateConnectionBoundsOfAllTasks():void
        {
            this._taskToConnectionBounds = {};
        }

        private function invalidateConnectionBoundsOfTasks(items:Array):void
        {
            var item:Object;
            var uid:String;
            for each (item in items)
            {
                uid = itemToUID(item);
                delete this._taskToConnectionBounds[uid];
            }
        }

        public function getConnectionBounds(task:Object):Rectangle
        {
            var bounds:Rectangle;
            var uid:String = itemToUID(task);
            var r:* = this._taskToConnectionBounds[uid];
            if (r !== undefined)
            {
                bounds = Rectangle(r);
            }
            else
            {
                bounds = this.measureConnectionBounds(task);
                this._taskToConnectionBounds[uid] = bounds;
            }
            return bounds;
        }

        private function measureConnectionBounds(task:Object):Rectangle
        {
            var b:IConstraintConnectionBounds;
            var renderer:DisplayObject = this.getConnectionBoundsMeasuringRenderer(task);
            if (renderer is IConstraintConnectionBounds)
            {
                b = IConstraintConnectionBounds(renderer);
                b.measureConnectionBounds();
                return b.connectionBounds.clone();
            }
            if (renderer)
            {
                return new Rectangle(renderer.x, renderer.y, renderer.width, renderer.height);
            }
            return null;
        }

        public function clearTaskData():void
        {
            this.invalidateConnectionBoundsOfAllTasks();
            this.taskLayout.invalidate();
            if (_measuringRenderer is IDataRenderer)
            {
                IDataRenderer(_measuringRenderer).data = null;
            }
        }

        private function invalidateDisplayObjectDisplayList(value:Object):void
        {
            if (value is IInvalidating)
            {
                IInvalidating(value).invalidateDisplayList();
            }
            else if (value is IProgrammaticSkin)
			{
				IProgrammaticSkin(value).validateDisplayList();
			}
        }
    }
}
