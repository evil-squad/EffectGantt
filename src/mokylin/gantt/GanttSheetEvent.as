package mokylin.gantt
{
    import flash.events.Event;
    import mx.core.IDataRenderer;
    import flash.geom.Point;

    public class GanttSheetEvent extends Event 
    {

        public static const AUTO_SCROLL:String = "autoScroll";
        public static const CHANGE:String = "change";
        public static const ITEM_CLICK:String = "itemClick";
        public static const ITEM_DOUBLE_CLICK:String = "itemDoubleClick";
        public static const ITEM_EDIT_BEGIN:String = "itemEditBegin";
        public static const ITEM_EDIT_END:String = "itemEditEnd";
        public static const ITEM_EDIT_DRAG:String = "itemEditDrag";
        public static const ITEM_EDIT_MOVE:String = "itemEditMove";
        public static const ITEM_EDIT_REASSIGN:String = "itemEditReassign";
        public static const ITEM_EDIT_RESIZE:String = "itemEditResize";
        public static const ITEM_EDIT_CONSTRAINT:String = "itemEditConstraint";
        public static const ITEM_ROLL_OUT:String = "itemRollOut";
        public static const ITEM_ROLL_OVER:String = "itemRollOver";
        public static const VISIBLE_TIME_RANGE_CHANGE:String = "visibleTimeRangeChange";

        public var adjusting:Boolean;
        public var editKind:String;
        public var editTime:Date;
        public var item:Object;
        public var itemArea:String;
        public var itemRenderer:IDataRenderer;
        public var projectionChanged:Boolean;
        public var offset:Point;
        public var reason:String;
        public var sourceResource:Object;
        public var sourceTask:Object;
        public var targetResource:Object;
        public var targetTask:Object;
        public var triggerEvent:Event;
        public var zoomFactorChanged:Boolean;

        public function GanttSheetEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, item:Object=null, itemArea:String=null, 
										itemRenderer:IDataRenderer=null, reason:String=null, adjusting:Boolean=false)
        {
            super(type, bubbles, cancelable);
            this.item = item;
            this.itemArea = itemArea;
            this.itemRenderer = itemRenderer;
            this.reason = reason;
            this.adjusting = adjusting;
        }

        public function get taskItem():TaskItem
        {
            return this.itemRenderer != null ? this.itemRenderer.data as TaskItem : null;
        }

        public function reassignTask():void
        {
            var taskItem:TaskItem = (this.itemRenderer.data as TaskItem);
            if (taskItem == null)
            {
                return;
            }
            taskItem.resource = this.targetResource != null ? this.targetResource : this.sourceResource;
        }

        public function moveTask():void
        {
            var taskItem:TaskItem = (this.itemRenderer.data as TaskItem);
            if (taskItem == null)
            {
                return;
            }
            var duration:Number = taskItem.endTime.time - taskItem.startTime.time;
            taskItem.startTime = new Date(this.editTime.time);
            taskItem.endTime = new Date(taskItem.startTime.time + duration);
        }

        public function resizeTask():void
        {
            var taskItem:TaskItem = (this.itemRenderer.data as TaskItem);
            if (taskItem == null)
            {
                return;
            }
            if (this.editKind == TaskItemEditKind.RESIZE_START)
            {
                taskItem.startTime = this.editTime>taskItem.endTime ? new Date(taskItem.endTime.time) : new Date(this.editTime.time);
            }
            else if (this.editKind == TaskItemEditKind.RESIZE_END)
			{
				taskItem.endTime = this.editTime<taskItem.startTime ? new Date(taskItem.startTime.time) : new Date(this.editTime.time);
			}
        }

        public function cancelInteraction():void
        {
            var ganttSheet:GanttSheet = (target as GanttSheet);
            if (ganttSheet != null)
            {
                ganttSheet.cancelInteraction();
            }
        }

        public function validateInteraction():void
        {
            var ganttSheet:GanttSheet = (target as GanttSheet);
            if (ganttSheet != null)
            {
                ganttSheet.validateInteraction();
            }
        }

        override public function clone():Event
        {
            var event:GanttSheetEvent = new GanttSheetEvent(type, bubbles, cancelable, this.item, this.itemArea, this.itemRenderer, this.reason, this.adjusting);
            event.sourceResource = this.sourceResource;
            event.targetResource = this.targetResource;
            event.editTime = this.editTime;
            event.editKind = this.editKind;
            event.offset = this.offset;
            event.triggerEvent = this.triggerEvent;
            event.zoomFactorChanged = this.zoomFactorChanged;
            return (event);
        }
    }
}
