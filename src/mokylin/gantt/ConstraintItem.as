package mokylin.gantt
{
    import mokylin.core.DataItem;
    import mokylin.utils.DataUtil;
    import mokylin.gantt.supportClasses.MessageUtil;
    import mx.logging.LogEventLevel;
    import mokylin.gantt.supportClasses.GanttProperties;

    public class ConstraintItem extends DataItem 
    {

        public var fromId:String;
        public var toId:String;
        public var kind:String;

        public function ConstraintItem(owner:GanttSheet, data:Object)
        {
            super(owner, data);
        }

        public function set fromTask(value:Object):void
        {
            this.checkTaskChart("fromTask");
            if (value == null)
            {
                this.fromId = null;
                return;
            }
            var taskChart:TaskChart = this.ganttSheet.taskChart;
            var fieldValue:Object = DataUtil.getFieldValue(value, taskChart.constraintFromIdField, null, taskChart.constraintFromIdFunction);
            this.fromId = fieldValue != null ? String(fieldValue) : null;
        }

        public function get fromTask():Object
        {
            this.checkTaskChart("fromTask");
            var taskChart:TaskChart = this.ganttSheet.taskChart;
            return taskChart.dataDescriptor.getTaskById(this.fromId);
        }

        public function get ganttSheet():GanttSheet
        {
            return owner as GanttSheet;
        }

        public function set toTask(value:Object):void
        {
            this.checkTaskChart("toTask");
            if (value == null)
            {
                this.toId = null;
                return;
            }
            var taskChart:TaskChart = this.ganttSheet.taskChart;
            var fieldValue:Object = DataUtil.getFieldValue(value, taskChart.constraintToIdField, null, taskChart.constraintToIdFunction);
            this.toId = fieldValue != null ? String(fieldValue) : null;
        }

        public function get toTask():Object
        {
            this.checkTaskChart("toTask");
            var taskChart:TaskChart = this.ganttSheet.taskChart;
            return (taskChart.dataDescriptor.getTaskById(this.toId));
        }

        private function checkTaskChart(property:String):void
        {
            if (this.ganttSheet.taskChart)
            {
                return;
            }
            throw new Error(MessageUtil.log(ConstraintItem, LogEventLevel.ERROR, GanttProperties.ELIXIR_GANTT_BUNDLE, GanttProperties.NOT_SUPPORTED_MESSAGE, [("ConstraintItem." + property), String(this.ganttSheet.ganttChart.className)]));
        }
    }
}
