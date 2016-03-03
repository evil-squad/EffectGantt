package mokylin.utils
{
    [ExcludeClass]
    public class TimeSampler 
    {

        protected var _extendedEnd:Number;
        protected var _extendedStart:Number;
//        private var _calendar:GregorianCalendar;
		private var _timeComputer:TimeComputer;
        
        private var _extendRange:Boolean;
		
		protected var _explicitEnd:Number=TimeUnit.HOUR.milliseconds;
        protected var _explicitStart:Number=0;
		
        private var _steps:Number;
        private var _unit:TimeUnit;

        public function TimeSampler(timeComputer:TimeComputer, start:Number, end:Number, unit:TimeUnit, steps:Number=1)
        {
            this._timeComputer = timeComputer;
            this._explicitStart = start;
            this._explicitEnd = end;
            this._unit = unit;
            this._steps = steps;
        }

        public function get timeComputer():TimeComputer
        {
            return this._timeComputer;
        }

        public function get end():Number
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

        public function get start():Number
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

        protected function getExtendedStart():Number
        {
            return this.timeComputer.floor(this._explicitStart, this.unit, this.steps);
        }

        protected function getExtendedEnd():Number
        {
            var date:Number = this.timeComputer.floor(this._explicitEnd, this.unit, this.steps);
            return this.getNextTime(date);
			//return this.timeComputer.floor(this._explicitEnd, this.unit, this.steps);
        }

        public function getFirstTime():Number
        {
            var first:Number = this.timeComputer.floor(this.start, this.unit, this.steps);
            if (first < this.start)
            {
                first = this.getNextTime(first);
            }
            return first;
        }

        public function getNextTime(time:Number):Number
        {
            var n:Number;
            var r:Number = this.getNextTimeImpl(time, this.steps);
            if (r == time)
            {
                n = this.unit.milliseconds >= TimeUnit.HOUR.milliseconds ? 2 : Math.floor(TimeUnit.HOUR.milliseconds / this.steps * this.unit.milliseconds);
                while (r == time)
                {
                    r = this.getNextTimeImpl(time, (this.steps * n));
                    n = n + 1;
                }
            }
            return r;
        }

        private function getNextTimeImpl(time:Number, steps:Number):Number
        {
            var r:Number = this.timeComputer.addUnits(time, this.unit, steps);
            return this.timeComputer.floor(r, this.unit, steps);
        }

        public function createIterator():TimeIterator
        {
            return new TimeIterator(this);
        }
    }
}
