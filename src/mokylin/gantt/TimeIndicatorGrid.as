package mokylin.gantt
{
    import flash.geom.Rectangle;
    
    import __AS3__.vec.Vector;
    
    import mokylin.utils.DataUtil;

    public class TimeIndicatorGrid extends TimeGridBase 
    {

        private var _datesField:String;
        private var _datesFieldChanged:Boolean;
        private var _datesFunction:Function;
        private var _datesFunctionChanged:Boolean;
        private var _times:Vector.<Number>;
        private var _timesChanged:Boolean;


        public function get datesField():String
        {
            return this._datesField;
        }

        public function set datesField(value:String):void
        {
            if (this._datesField == value)
            {
                return;
            }
            this._datesField = value;
            this._datesFieldChanged = true;
            invalidateProperties();
        }

        public function get datesFunction():Function
        {
            return this._datesFunction;
        }

        public function set datesFunction(value:Function):void
        {
            if (this._datesFunction == value)
            {
                return;
            }
            this._datesFunction = value;
            this._datesFunctionChanged = true;
            invalidateProperties();
        }

        public function get times():Vector.<Number>
        {
            return this._times;
        }

        public function set times(value:Vector.<Number>):void
        {
            var i:int;
            if (value == null)
            {
                this._times = null;
            }
            else
            {
                this._times = value.slice();
                /*i = 0;
                while (i < this._times.length)
                {
                    this._times[i] = new Date(this._dates[i].time);
                    i++;
                }*/
                this._times.sort(this.datesCompareFunction);
            }
            this._timesChanged = true;
            invalidateProperties();
        }

        private function datesCompareFunction(x:Number, y:Number):Number
        {
            if (x == y)
            {
                return 0;
            }
            if (x < y)
            {
                return -1;
            }
            return 1;
        }

        override public function clone():GanttSheetGridBase
        {
            var grid:TimeIndicatorGrid = new TimeIndicatorGrid();
            grid.drawPerRow = drawPerRow;
            grid.drawToBottom = drawToBottom;
            grid.stroke = stroke;
            grid.dashStyle = dashStyle;
            grid.timeElementSkin = timeElementSkin;
            if (this.times != null)
            {
                grid.times = this.times.slice();
            }
            grid.datesField = this.datesField;
            grid.datesFunction = this.datesFunction;
            return grid;
        }

        override protected function commitProperties():void
        {
            super.commitProperties();
            if (this._timesChanged)
            {
                this._timesChanged = false;
                invalidateDisplayList();
            }
            if (this._datesFieldChanged)
            {
                this._datesFieldChanged = false;
                invalidateDisplayList();
            }
            if (this._datesFunctionChanged)
            {
                this._datesFunctionChanged = false;
                invalidateDisplayList();
            }
        }

        protected function getTimes(data:Object):Vector.<Number>
        {
            if (this.datesFunction != null || (this.datesField != null && data != null))
            {
                return DataUtil.getFieldValue(data, this.datesField, null, this.datesFunction) as Vector.<Number>;
            }
            return this._times;
        }

        override protected function updateGridDisplayList(r:Rectangle, rowIndex:int, data:Object):void
        {
            var time:Number;
            if (timeController == null || !timeController.configured)
            {
                return;
            }
            var times:Vector.<Number> = this.getTimes(Number);
            if (times == null)
            {
                return;
            }
            var startTime:Number = timeController.getTime(-getRendererWidth());
            var endTime:Number = timeController.endTime + (timeController.startTime - startTime);
            for each (time in times)
            {
                if (time > endTime)
                {
                    break;
                }
                if (time < startTime)
                {
                }
                else
                {
                    drawLine(r, timeController.getCoordinate(time), data);
                }
            }
        }
    }
}