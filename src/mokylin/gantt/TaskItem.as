package mokylin.gantt
{
    import mokylin.core.DataItem;
    import mokylin.utils.DataUtil;
    import mokylin.gantt.supportClasses.MessageUtil;
    import mx.logging.LogEventLevel;
    import mokylin.gantt.supportClasses.GanttProperties;

    public class TaskItem extends DataItem 
    {

        public var endTime:Date;
        public var isMilestone:Boolean;
        public var isSummary:Boolean;
        public var label:String;
        public var resourceId:String;
        public var startTime:Date;
        private var _uid:String;

        public function TaskItem(owner:GanttSheet, data:Object)
        {
            super(owner, data);
        }

        public function get ganttSheet():GanttSheet
        {
            return owner as GanttSheet;
        }

        public function set resource(value:Object):void
        {
            this.checkResourceChart();
            if (value == null)
            {
                this.resourceId = null;
                return;
            }
            var resourceChart:ResourceChart = this.ganttSheet.resourceChart;
            var fieldValue:Object = DataUtil.getFieldValue(value, resourceChart.resourceIdField, null, resourceChart.resourceIdFunction);
            this.resourceId = fieldValue != null ? String(fieldValue) : null;
        }

        public function get resource():Object
        {
            this.checkResourceChart();
            var resourceChart:ResourceChart = this.ganttSheet.resourceChart;
            return resourceChart.dataDescriptor.getResourceById(this.resourceId);
        }

		public function get uid():String
        {
            if (this._uid == null && data != null)
            {
                this._uid = this.ganttSheet.itemToUID(data);
            }
            return this._uid;
        }

        private function checkResourceChart():void
        {
            if (this.ganttSheet.resourceChart)
            {
                return;
            }
            throw new Error(MessageUtil.log(TaskItem, LogEventLevel.ERROR, GanttProperties.ELIXIR_GANTT_BUNDLE, GanttProperties.NOT_SUPPORTED_MESSAGE, ["TaskItem.resource", String(this.ganttSheet.ganttChart.className)]));
        }
    }
}
