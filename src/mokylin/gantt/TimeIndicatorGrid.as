package mokylin.gantt
{
    import __AS3__.vec.Vector;
    import mokylin.utils.DataUtil;
    import flash.geom.Rectangle;
    import __AS3__.vec.*;

    public class TimeIndicatorGrid extends TimeGridBase 
    {

        private var _datesField:String;
        private var _datesFieldChanged:Boolean;
        private var _datesFunction:Function;
        private var _datesFunctionChanged:Boolean;
        private var _dates:Vector.<Date>;
        private var _datesChanged:Boolean;


        public function get datesField():String
        {
            return (this._datesField);
        }

        public function set datesField(value:String):void
        {
            if (this._datesField == value)
            {
                return;
            };
            this._datesField = value;
            this._datesFieldChanged = true;
            invalidateProperties();
        }

        public function get datesFunction():Function
        {
            return (this._datesFunction);
        }

        public function set datesFunction(value:Function):void
        {
            if (this._datesFunction == value)
            {
                return;
            };
            this._datesFunction = value;
            this._datesFunctionChanged = true;
            invalidateProperties();
        }

        public function get dates():Vector.<Date>
        {
            return (this._dates);
        }

        public function set dates(value:Vector.<Date>):void
        {
            var i:int;
            if (value == null)
            {
                this._dates = null;
            }
            else
            {
                this._dates = value.slice();
                i = 0;
                while (i < this._dates.length)
                {
                    this._dates[i] = new Date(this._dates[i].time);
                    i++;
                };
                this._dates.sort(this.datesCompareFunction);
            };
            this._datesChanged = true;
            invalidateProperties();
        }

        private function datesCompareFunction(x:Date, y:Date):Number
        {
            if (x.time == y.time)
            {
                return (0);
            };
            if (x < y)
            {
                return (-1);
            };
            return (1);
        }

        override public function clone():GanttSheetGridBase
        {
            var grid:TimeIndicatorGrid = new TimeIndicatorGrid();
            grid.drawPerRow = drawPerRow;
            grid.drawToBottom = drawToBottom;
            grid.stroke = stroke;
            grid.dashStyle = dashStyle;
            grid.timeElementSkin = timeElementSkin;
            if (this.dates != null)
            {
                grid.dates = this.dates.slice();
            };
            grid.datesField = this.datesField;
            grid.datesFunction = this.datesFunction;
            return (grid);
        }

        override protected function commitProperties():void
        {
            super.commitProperties();
            if (this._datesChanged)
            {
                this._datesChanged = false;
                invalidateDisplayList();
            };
            if (this._datesFieldChanged)
            {
                this._datesFieldChanged = false;
                invalidateDisplayList();
            };
            if (this._datesFunctionChanged)
            {
                this._datesFunctionChanged = false;
                invalidateDisplayList();
            };
        }

        protected function getDates(data:Object):Vector.<Date>
        {
            if (((!((this.datesFunction == null))) || (((!((this.datesField == null))) && (!((data == null)))))))
            {
                return ((DataUtil.getFieldValue(data, this.datesField, null, this.datesFunction) as Vector.<Date>));
            };
            return (this._dates);
        }

        override protected function updateGridDisplayList(r:Rectangle, rowIndex:int, data:Object):void
        {
            var date:Date;
            if ((((timeController == null)) || (!(timeController.configured))))
            {
                return;
            };
            var dates:Vector.<Date> = this.getDates(data);
            if (dates == null)
            {
                return;
            };
            var startTime:Date = timeController.getTime(-(getRendererWidth()));
            var endTime:Date = new Date((timeController.endTime.time + (timeController.startTime.time - startTime.time)));
            for each (date in dates)
            {
                if (date > endTime)
                {
                    break;
                };
                if (date < startTime)
                {
                }
                else
                {
                    drawLine(r, timeController.getCoordinate(date), data);
                };
            };
        }
    }
}
