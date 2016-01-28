package mokylin.gantt
{
    import mokylin.utils.TimeSampler;
    import mokylin.utils.WorkCalendar;
    import mokylin.utils.GregorianCalendar;
    import mokylin.utils.TimeUnit;

    [ExcludeClass]
    public class WorkingTimeSampler extends TimeSampler 
    {

        private var _workCalendar:WorkCalendar;

        public function WorkingTimeSampler(workCalendar:WorkCalendar, calendar:GregorianCalendar, start:Date, end:Date, unit:TimeUnit, steps:Number=1, referenceDate:Date=null)
        {
            super(calendar, start, end, unit, steps, referenceDate);
            this._workCalendar = workCalendar;
        }

        public function get workCalendar():WorkCalendar
        {
            return this._workCalendar;
        }

        override protected function getExtendedStart():Date
        {
            var previousWorkingTime:Date;
            var nextWorkingTime:Date;
            var date:Date = _explicitStart;
            while (true)
            {
                previousWorkingTime = this._workCalendar.previousWorkingTime(date);
                date = calendar.floor(previousWorkingTime, unit, steps, referenceDate);
                nextWorkingTime = this._workCalendar.nextWorkingTime(date);
                if (nextWorkingTime.time <= _explicitStart.time)
                {
                    return nextWorkingTime;
                }
            }
            return super.getExtendedStart();
        }

        override public function getFirstTime():Date
        {
            var first:Date = calendar.floor(start, unit, steps, referenceDate);
            var previousWorkingTime:Date = this._workCalendar.previousWorkingTime(first);
            if (first.time != previousWorkingTime.time)
            {
                first = previousWorkingTime;
            }
            if (first < start)
            {
                first = this.getNextTime(first);
            }
            return first;
        }

        override public function getNextTime(time:Date):Date
        {
            var nextTime:Date = super.getNextTime(time);
            var nextWorkingTime:Date = this._workCalendar.nextWorkingTime(nextTime);
            if (nextTime.time != nextWorkingTime.time)
            {
                nextTime = nextWorkingTime;
            }
            return nextTime;
        }
    }
}
