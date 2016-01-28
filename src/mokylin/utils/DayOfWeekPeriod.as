package mokylin.utils
{
    import mokylin.utils.WorkCalendar;
    import mokylin.utils.WorkCalendarDayOfWeek;

    public class DayOfWeekPeriod extends CalendarPeriodBase 
    {

        private var _dayOfWeek:int;

        public function DayOfWeekPeriod(workCalendar:WorkCalendar, working:Boolean, dayOfWeek:int)
        {
            super(workCalendar, working);
            this._dayOfWeek = dayOfWeek;
            if (workCalendar.isBaseCalendar)
            {
                this.isInherited = true;
            }
        }

        public static function createDayOfWeekPeriod(workCalendar:WorkCalendar, source:WorkCalendarDayOfWeek):DayOfWeekPeriod
        {
            var dp:DayOfWeekPeriod = new DayOfWeekPeriod(workCalendar, source.isWorking, source.dayOfWeek);
            dp._workingTimes = source.workingTimes;
            return dp;
        }


        public function get dayOfWeek():int
        {
            return this._dayOfWeek;
        }

        override public function clone():CalendarPeriodBase
        {
            var copy:DayOfWeekPeriod = new DayOfWeekPeriod(_workCalendar, isWorking, this._dayOfWeek);
            copyCalendarPeriodTo(copy);
            return copy;
        }

        override public function workBetween(t1:Date, t2:Date):Number
        {
            return workBetweenHours(t1, t2);
        }

        override public function add(time:Date, duration:Number):Number
        {
            return addWorkInDay(time, duration);
        }

        override public function remove(time:Date, duration:Number):Number
        {
            return removeWorkInDay(time, duration);
        }

        public function equals(other:DayOfWeekPeriod):Boolean
        {
            return other.isWorking == this.isWorking && other._dayOfWeek == this._dayOfWeek && this.sameWorkingTimes(other);
        }
    }
}
