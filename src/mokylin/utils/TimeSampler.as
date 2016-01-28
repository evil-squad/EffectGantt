package mokylin.utils
{
    [ExcludeClass]
    public class TimeSampler 
    {

        protected var _extendedEnd:Date;
        protected var _extendedStart:Date;
        private var _calendar:GregorianCalendar;
        protected var _explicitEnd:Date;
        private var _extendRange:Boolean;
        private var _referenceDate:Date;
        protected var _explicitStart:Date;
        private var _steps:Number;
        private var _unit:TimeUnit;

        public function TimeSampler(calendar:GregorianCalendar, start:Date, end:Date, unit:TimeUnit, steps:Number=1, referenceDate:Date=null)
        {
            this._calendar = calendar;
            this._explicitStart = start;
            this._explicitEnd = end;
            this._unit = unit;
            this._steps = steps;
            this._referenceDate = referenceDate;
        }

        public function get calendar():GregorianCalendar
        {
            return this._calendar;
        }

        public function get end():Date
        {
            return this._extendRange ? this._extendedEnd : this._explicitEnd;
        }

        public function set extendRange(value:Boolean):void
        {
            this._extendRange = value;
            if (this._extendRange)
            {
                this._extendedStart = this.getExtendedStart();
                this._extendedEnd = this.getExtendedEnd();
            }
        }

        public function get extendRange():Boolean
        {
            return this._extendRange;
        }

        public function get referenceDate():Date
        {
            return this._referenceDate;
        }

        public function get start():Date
        {
            return this.extendRange ? this._extendedStart : this._explicitStart;
        }

        public function get steps():Number
        {
            return this._steps;
        }

        public function get unit():TimeUnit
        {
            return this._unit;
        }

        protected function getExtendedStart():Date
        {
            return this.calendar.floor(this._explicitStart, this.unit, this.steps, this.referenceDate);
        }

        protected function getExtendedEnd():Date
        {
            var date:Date = this.calendar.floor(this._explicitEnd, this.unit, this.steps, this.referenceDate);
            return this.getNextTime(date);
        }

        public function getFirstTime():Date
        {
            var first:Date = this._calendar.floor(this.start, this.unit, this.steps, this.referenceDate);
            if (first < this.start)
            {
                first = this.getNextTime(first);
            }
            return first;
        }

        public function getNextTime(time:Date):Date
        {
            var n:Number;
            var r:Date = this.getNextTimeImpl(time, this.steps);
            if (r.time == time.time)
            {
                n = this.unit.milliseconds >= TimeUnit.HOUR.milliseconds ? 2 : Math.floor(TimeUnit.HOUR.milliseconds / this.steps * this.unit.milliseconds);
                while (r.time == time.time)
                {
                    r = this.getNextTimeImpl(time, (this.steps * n));
                    n = n + 1;
                }
            }
            return r;
        }

        private function getNextTimeImpl(time:Date, steps:Number):Date
        {
            var r:Date = this._calendar.addUnits(time, this.unit, steps);
            return this._calendar.floor(r, this.unit, steps, this.referenceDate);
        }

        public function createIterator():TimeIterator
        {
            return new TimeIterator(this);
        }
    }
}
