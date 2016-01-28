package mokylin.gantt
{
    import mokylin.utils.TimeUnit;
    import mokylin.utils.TimeIterator;
    import mx.graphics.SolidColorStroke;
    import flash.display.LineScaleMode;
    import flash.display.CapsStyle;
    import flash.geom.Rectangle;
    import mokylin.utils.TimeSampler;
    import mokylin.utils.GregorianCalendar;

    public class TimeGrid extends TimeGridBase 
    {

        private const _minimumSizeBetweenTimeElements:Number = 20;

        private var _timeScaleUnit:TimeUnit;
        private var _timeScaleSteps:Number = 1;
        private var _timeScaleChanged:Boolean;
        private var _timeUnit:TimeUnit;
        private var _timeUnitChanged:Boolean;
        private var _timeUnitSteps:Number = 1;
        private var _timeUnitStepsChanged:Boolean;

        public function TimeGrid()
        {
            this._timeScaleUnit = TimeUnit.WEEK;
            stroke = null;
            dashStyle = true;
        }

        public function get timeUnit():TimeUnit
        {
            return this._timeUnit;
        }

        public function set timeUnit(value:TimeUnit):void
        {
            if (this._timeUnit == value)
            {
                return;
            }
            this._timeUnit = value;
            this._timeUnitChanged = true;
            invalidateProperties();
        }

        public function get timeUnitSteps():Number
        {
            return this._timeUnitSteps;
        }

        public function set timeUnitSteps(value:Number):void
        {
            if (this.timeUnitSteps == value)
            {
                return;
            }
            this._timeUnitSteps = value;
            this._timeUnitStepsChanged = true;
            invalidateProperties();
        }

        override public function clone():GanttSheetGridBase
        {
            var grid:TimeGrid = new TimeGrid();
            grid.drawPerRow = drawPerRow;
            grid.drawToBottom = drawToBottom;
            grid.stroke = stroke;
            grid.dashStyle = dashStyle;
            grid.timeElementSkin = timeElementSkin;
            grid.timeUnit = this.timeUnit;
            grid.timeUnitSteps = this.timeUnitSteps;
            return grid;
        }

		public function setTimeScaleUnit(timeUnit:TimeUnit, timeSteps:Number):void
        {
            if (this._timeScaleUnit == timeUnit && this._timeScaleSteps == timeSteps)
            {
                return;
            }
            this._timeScaleUnit = timeUnit;
            this._timeScaleSteps = timeSteps;
            this._timeScaleChanged = true;
            invalidateProperties();
        }

        private function get synchronizedWithTimeScale():Boolean
        {
            return this._timeUnit == null;
        }

        override protected function commitProperties():void
        {
            super.commitProperties();
            if (this._timeUnitChanged)
            {
                this._timeUnitChanged = false;
                invalidateDisplayList();
            }
            if (this._timeScaleChanged)
            {
                this._timeScaleChanged = false;
                if (this.synchronizedWithTimeScale)
                {
                    invalidateDisplayList();
                }
            }
        }

        override protected function updateGridDisplayList(r:Rectangle, rowIndex:int, data:Object):void
        {
            var color:uint;
            var alpha:Number;
            var iterator:TimeIterator;
            if (timeController == null || !timeController.configured)
            {
                return;
            }
            if (stroke == null)
            {
                color = getStyle("timeGridColor");
                alpha = getStyle("timeGridAlpha");
                if (isNaN(alpha))
                {
                    alpha = 1;
                }
                stroke = new SolidColorStroke(color, 1, alpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);
            }
            var size:Number = getRendererWidth();
            var startTime:Date = timeController.getTime(-size);
            var endTime:Date = timeController.getTime(timeController.width + size);
            var unit:TimeUnit = this.synchronizedWithTimeScale ? this._timeScaleUnit : this.timeUnit;
            var steps:Number = this.synchronizedWithTimeScale ? this._timeScaleSteps : this.timeUnitSteps;
            if (unit != null && timeController.getSizeOf(unit.milliseconds * steps) > this._minimumSizeBetweenTimeElements)
            {
                iterator = this.createTimeIterator(calendar, startTime, endTime, unit, steps);
                while (iterator.hasNext())
                {
                    drawLine(r, timeController.getCoordinate((iterator.next() as Date)), data);
                }
            }
        }

        private function createTimeIterator(calendar:GregorianCalendar, start:Date, end:Date, unit:TimeUnit, steps:Number, referenceDate:Date=null):TimeIterator
        {
            var sampler:TimeSampler;
            if (timeController.isHidingNonworkingTimes)
            {
                sampler = new WorkingTimeSampler(timeController.workCalendar, calendar, start, end, unit, steps, referenceDate);
            }
            else
            {
                sampler = new TimeSampler(calendar, start, end, unit, steps, referenceDate);
            }
            sampler.extendRange = true;
            return sampler.createIterator();
        }
    }
}
