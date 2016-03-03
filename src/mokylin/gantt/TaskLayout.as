package mokylin.gantt
{
    import __AS3__.vec.Vector;
    import flash.display.DisplayObject;
    import mx.styles.ISimpleStyleClient;
    import mx.core.IDataRenderer;
    import mx.managers.ILayoutManagerClient;
    import mx.managers.LayoutManager;
    import mx.core.IUIComponent;
    import mx.core.IFlexDisplayObject;
    import mokylin.utils.MathUtil;
    import __AS3__.vec.*;

    [ExcludeClass]
    public class TaskLayout 
    {

        private var _ganttSheet:GanttSheet;
        private var _taskIgnoredWhenDistributingUID:String;
        private var _taskIgnoredWhenDistributing:Object;
        private var _lockedTaskUID:String;
        private var _lockedTask:Object;
        public var liveTaskLayout:Boolean = false;
        private var _lockedRowUID:String;
        private var _lockedRow:Object;
        private var _paddingBottom:Number = 2;
        private var _paddingTop:Number = 2;
        private var _percentOverlap:Number = 60;
        private var _verticalGap:Number = 1;
        private var _uidToRowLayoutInfo:Object;
        private var _uidToTaskLayoutInfo:Object;
        private var _measuringRenderer:Object;

        public function TaskLayout()
        {
            this._uidToRowLayoutInfo = {};
            this._uidToTaskLayoutInfo = {};
            super();
        }

        final public function set ganttSheet(value:GanttSheet):void
        {
            if (this._ganttSheet == value)
            {
                return;
            }
            this._ganttSheet = value;
            this.invalidate();
        }

        final public function get ganttSheet():GanttSheet
        {
            return this._ganttSheet;
        }

        final public function set taskIgnoredWhenDistributing(value:Object):void
        {
            if (this._taskIgnoredWhenDistributing == value)
            {
                return;
            }
            var uid:String = value != null ? this.itemToUID(value) : null;
            this._taskIgnoredWhenDistributingUID = uid;
            this._taskIgnoredWhenDistributing = value;
        }

        final public function get taskIgnoredWhenDistributing():Object
        {
            return this._taskIgnoredWhenDistributing;
        }

        private function isTaskIgnoredWhenDistributing(item:Object, uid:String=null):Boolean
        {
            if (this._taskIgnoredWhenDistributingUID == null)
            {
                return false;
            }
            if (uid == null)
            {
                uid = this.itemToUID(item);
            }
            return uid == this._taskIgnoredWhenDistributingUID;
        }

        final public function set lockedTask(value:Object):void
        {
            if (this._lockedTask == value)
            {
                return;
            }
            var uid:String = value != null ? this.itemToUID(value) : null;
            this._lockedTaskUID = uid;
            this._lockedTask = value;
        }

        final public function get lockedTask():Object
        {
            return this._lockedTask;
        }

        public function isTaskLocked(item:Object):Boolean
        {
            if (this._lockedTaskUID == null)
            {
                return false;
            }
            if (this._lockedTask === item)
            {
                return true;
            }
            var uid:String = this.itemToUID(item);
            return uid == this._lockedTaskUID;
        }

        final public function set lockedRow(value:Object):void
        {
            if (this._lockedRow == value)
            {
                return;
            }
            var uid:String = value != null ? this.itemToUID(value) : null;
            this._lockedRowUID = uid;
            this._lockedRow = value;
        }

        final public function get lockedRow():Object
        {
            return this._lockedRow;
        }

        public function isRowLocked(item:Object):Boolean
        {
            if (this._lockedRowUID == null)
            {
                return false;
            }
            if (this._lockedRow == item)
            {
                return true;
            }
            var uid:String = this.itemToUID(item);
            return uid == this._lockedRowUID;
        }

        final public function set paddingBottom(value:Number):void
        {
            if (this._paddingBottom == value)
            {
                return;
            }
            this._paddingBottom = value;
            this.invalidate();
        }

        final public function get paddingBottom():Number
        {
            return this._paddingBottom;
        }

        final public function set paddingTop(value:Number):void
        {
            if (this._paddingTop == value)
            {
                return;
            }
            this._paddingTop = value;
            this.invalidate();
        }

        final public function get paddingTop():Number
        {
            return this._paddingTop;
        }

        final public function set percentOverlap(value:Number):void
        {
            if (value > 100)
            {
                value = 100;
            }
            if (value < 0)
            {
                value = 0;
            }
            if (this._percentOverlap == value)
            {
                return;
            }
            this._percentOverlap = value;
            this.invalidate();
        }

        final public function get percentOverlap():Number
        {
            return this._percentOverlap;
        }

        final public function set verticalGap(value:Number):void
        {
            if (this._verticalGap == value)
            {
                return;
            }
            this._verticalGap = value;
            this.invalidate();
        }

        final public function get verticalGap():Number
        {
            return this._verticalGap;
        }

        public function getRowLayoutInfo(item:Object, uid:String=null, create:Boolean=true):RowLayoutInfo
        {
            if (uid == null)
            {
                uid = this.itemToUID(item);
            }
            var info:RowLayoutInfo = RowLayoutInfo(this._uidToRowLayoutInfo[uid]);
            if (info == null && create)
            {
                info = new RowLayoutInfo();
                info.item = item;
                this._uidToRowLayoutInfo[uid] = info;
            }
            return info;
        }

        public function getTaskLayoutInfo(item:Object, uid:String=null, create:Boolean=true):TaskLayoutInfo
        {
            if (uid == null)
            {
                uid = this.itemToUID(item);
            }
            var info:TaskLayoutInfo = TaskLayoutInfo(this._uidToTaskLayoutInfo[uid]);
            if (info == null && create)
            {
                info = new TaskLayoutInfo();
                info.item = item;
                this._uidToTaskLayoutInfo[uid] = info;
            }
            return info;
        }

        public function invalidate():void
        {
            this._uidToRowLayoutInfo = {};
            this._uidToTaskLayoutInfo = {};
        }

        public function calculateMinRowHeight(rowItem:Object):Number
        {
            var rowLayoutInfo:RowLayoutInfo = this.getRowLayoutInfo(rowItem);
            this.validateRowSize(rowLayoutInfo);
            return rowLayoutInfo.minHeight;
        }

        public function invalidateRowDistribution(rowItem:Object):void
        {
            if (this.isRowLocked(rowItem))
            {
                return;
            }
            var rowLayoutInfo:RowLayoutInfo = this.getRowLayoutInfo(rowItem, null, false);
            if (rowLayoutInfo != null)
            {
                rowLayoutInfo.invalidDistribution = true;
            }
        }

        public function validateRowSize(rowLayoutInfo:RowLayoutInfo):void
        {
            this.validateTaskDistribution(rowLayoutInfo);
            if (rowLayoutInfo.invalidSize)
            {
                this.measureRow(rowLayoutInfo);
                rowLayoutInfo.invalidSize = false;
            }
        }

        private function validateTaskDistribution(rowLayoutInfo:RowLayoutInfo):void
        {
            var previousLaneCount:uint = rowLayoutInfo.laneCount;
            if (rowLayoutInfo.invalidDistribution)
            {
                this.distributeTasksInLanes(rowLayoutInfo);
                rowLayoutInfo.invalidDistribution = false;
            }
            if (previousLaneCount != rowLayoutInfo.laneCount)
            {
                rowLayoutInfo.invalidSize = true;
                rowLayoutInfo.laneHeight = NaN;
            }
        }

        private function measureRow(rowLayoutInfo:RowLayoutInfo):void
        {
            var minRowHeight:Number;
            var overlap:Number;
            rowLayoutInfo.minHeight = NaN;
            if (!(this.ganttSheet.rowController.variableRowHeight))//如果不允许各行有自己的高度，那么这个函数就不用执行了
            {
                return;
            }
            this.measureTasksOfRow(rowLayoutInfo);
            if (isNaN(rowLayoutInfo.minTaskHeight))
            {
                return;
            }
            var laneHeight:Number = rowLayoutInfo.minTaskHeight;
            if (this.percentOverlap == 0)
            {
                minRowHeight = (this.paddingTop + this.paddingBottom) + 1 + rowLayoutInfo.laneCount * laneHeight + (rowLayoutInfo.laneCount - 1) * (this.verticalGap + 1);
            }
            else
            {
                overlap = (laneHeight * this.percentOverlap) / 100;
                minRowHeight = ((((this.paddingTop + this.paddingBottom) + 1) + (rowLayoutInfo.laneCount * laneHeight)) - ((rowLayoutInfo.laneCount - 1) * overlap));
            }
            rowLayoutInfo.minHeight = minRowHeight;
        }

        public function validateActualRowHeightAndPosition(rowLayoutInfo:RowLayoutInfo):void
        {
            rowLayoutInfo.y = this.ganttSheet.rowController.getRowPosition(rowLayoutInfo.item);
            rowLayoutInfo.height = this.ganttSheet.rowController.getRowHeight(rowLayoutInfo.item);
        }

        private function distributeTasksInLanes(rowLayoutInfo:RowLayoutInfo):void
        {
            var t:TaskItem;
            var tasks:Array = this.ganttSheet.rowItemToTasks(rowLayoutInfo.item);
            if (tasks == null || tasks.length == 0)
            {
                rowLayoutInfo.laneCount = 0;
                return;
            }
            var lanes:Vector.<Vector.<TaskItem>> = new Vector.<Vector.<TaskItem>>();
            var taskItems:Vector.<TaskItem> = this.getTaskItemsForTasks(tasks);
            taskItems.sort(this.compareStartAndDuration);
            for each (t in taskItems)
            {
                this.distributeOneTaskInLane(t, lanes);
            }
            rowLayoutInfo.laneCount = lanes.length;
        }

        private function distributeOneTaskInLane(taskItem:TaskItem, lanes:Vector.<Vector.<TaskItem>>):void
        {
            var taskLayoutInfo:TaskLayoutInfo = this.getTaskLayoutInfo(taskItem.data, taskItem.uid);
            if (this.isTaskIgnoredWhenDistributing(taskItem.data, taskItem.uid))
            {
                taskLayoutInfo.laneIndex = 0;
                return;
            }
            var i:uint;
            while (i < lanes.length)
            {
                if (this.addTaskToLaneIfPossible(taskItem, lanes[i]))
                {
                    taskLayoutInfo.laneIndex = i;
                    return;
                }
                i++;
            }
            var newLane:Vector.<TaskItem> = new Vector.<TaskItem>();
            newLane.push(taskItem);
            lanes.push(newLane);
            taskLayoutInfo.laneIndex = (lanes.length - 1);
        }

        private function addTaskToLaneIfPossible(taskItem:TaskItem, lane:Vector.<TaskItem>):Boolean
        {
            var t:TaskItem = lane[(lane.length - 1)];
            if (taskItem.startTime >= t.endTime)
            {
                lane.push(taskItem);
                return true;
            }
            return false;
        }

        private function measureTasksOfRow(rowLayoutInfo:RowLayoutInfo):void
        {
            var maxMeasuredMinHeight:Number;
            var t:Object;
            var taskItem:TaskItem;
            var renderer:Object;
            var measuredMinHeight:Number;
            var tasks:Array = this.ganttSheet.rowItemToTasks(rowLayoutInfo.item);
            for each (t in tasks)
            {
                taskItem = this.ganttSheet.itemToTaskItem(t);
                renderer = this.getMeasuringRenderer(taskItem);
                this.prepareRenderer(renderer, taskItem);
                measuredMinHeight = this.getExplicitOrMeasuredMinHeight(renderer);
                maxMeasuredMinHeight = isNaN(maxMeasuredMinHeight) ? (measuredMinHeight) : Math.max(maxMeasuredMinHeight, measuredMinHeight);
            }
            this.recycleMeasuringRenderer();
            rowLayoutInfo.minTaskHeight = maxMeasuredMinHeight;
        }

        private function getMeasuringRenderer(item:TaskItem):Object
        {
            if (this._measuringRenderer == null)
            {
                this._measuringRenderer = this.ganttSheet.taskItemContainer.createItemRenderer();
                if (this._measuringRenderer)
                {
                    this._measuringRenderer.visible = false;
                }
            }
            return this._measuringRenderer;
        }

        private function recycleMeasuringRenderer():void
        {
            if (this._measuringRenderer == null)
            {
                return;
            }
            this.ganttSheet.taskItemContainer.recycleRenderer(DisplayObject(this._measuringRenderer));
            this._measuringRenderer = null;
        }

        private function prepareRenderer(renderer:Object, item:TaskItem):void
        {
            if (renderer is ISimpleStyleClient)
            {
                ISimpleStyleClient(renderer).styleName = this.ganttSheet.itemToStyleName(item);
            }
            if (renderer is IDataRenderer)
            {
                IDataRenderer(renderer).data = item;
            }
            if (renderer is ILayoutManagerClient)
            {
                LayoutManager.getInstance().validateClient(ILayoutManagerClient(renderer), true);
            }
        }

        private function getExplicitOrMeasuredMinHeight(r:Object):Number
        {
            var c:IUIComponent;
            if (r is IUIComponent)
            {
                c = IUIComponent(r);
                return !isNaN(c.explicitMinHeight) ? c.explicitMinHeight : c.measuredMinHeight;
            }
            if (r is IFlexDisplayObject)
            {
                return IFlexDisplayObject(r).measuredHeight;
            }
            return NaN;
        }

        public function calculateTaskLayout(taskLayoutInfo:TaskLayoutInfo, rowLayoutInfo:RowLayoutInfo):void
        {
            var overlap:Number;
            this.validateLaneHeight(rowLayoutInfo);
            var laneHeight:Number = rowLayoutInfo.laneHeight;
            taskLayoutInfo.height = laneHeight;
            if (this.isTaskIgnoredWhenDistributing(taskLayoutInfo.item))
            {
                taskLayoutInfo.y = this.paddingTop;
                return;
            }
            if (this.percentOverlap == 0)
            {
                taskLayoutInfo.y = (this.paddingTop + (taskLayoutInfo.laneIndex * ((laneHeight + this.verticalGap) + 1)));
            }
            else
            {
                overlap = ((laneHeight * this.percentOverlap) / 100);
                taskLayoutInfo.y = (this.paddingTop + (taskLayoutInfo.laneIndex * (laneHeight - overlap)));
            }
        }

        private function validateLaneHeight(rowLayoutInfo:RowLayoutInfo):void
        {
            if (isNaN(rowLayoutInfo.laneHeight))
            {
                this.calculateLaneHeight(rowLayoutInfo);
            }
        }

        private function calculateLaneHeight(rowLayoutInfo:RowLayoutInfo):void
        {
            var laneHeight:Number;
            var rowContentHeight:Number = (((rowLayoutInfo.height - this.paddingTop) - this.paddingBottom) - 1);
            var laneCount:Number = rowLayoutInfo.laneCount;
            if (laneCount == 0)
            {
                laneHeight = rowContentHeight;
            }
            else if (this.percentOverlap == 0)
			{
				laneHeight = ((rowContentHeight - ((laneCount - 1) * (this.verticalGap + 1))) / laneCount);
			}
			else
			{
				laneHeight = (rowContentHeight / (laneCount - (((laneCount - 1) * this.percentOverlap) / 100)));
			}
            rowLayoutInfo.laneHeight = laneHeight;
        }

        private function itemToUID(item:Object):String
        {
            return this.ganttSheet.itemToUID(item);
        }

        public function compareStartAndDuration(a:TaskItem, b:TaskItem):int
        {
            var r:Number = (a.startTime - b.startTime);
            if (r == 0)
            {
                r = b.endTime - a.endTime;
            }
            return MathUtil.sign(r);
        }

        public function compareLaneIndexAndStart(a:TaskItem, b:TaskItem):int
        {
            var aLayoutInfo:TaskLayoutInfo = this.getTaskLayoutInfo(a.data, a.uid);
            var bLayoutInfo:TaskLayoutInfo = this.getTaskLayoutInfo(b.data, b.uid);
            var r:Number = (aLayoutInfo.laneIndex - bLayoutInfo.laneIndex);
            if (r == 0)
            {
                r = a.startTime - b.startTime;
            }
            return MathUtil.sign(r);
        }

        private function getTaskItemsForTasks(tasks:Array):Vector.<TaskItem>
        {
            var taskItems:Vector.<TaskItem> = new Vector.<TaskItem>(tasks.length);
            var i:uint;
            while (i < tasks.length)
            {
                taskItems[i] = this.ganttSheet.itemToTaskItem(tasks[i]);
                i++;
            }
            return taskItems;
        }
    }
}
