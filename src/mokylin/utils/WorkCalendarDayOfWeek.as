package mokylin.utils
{
    import __AS3__.vec.Vector;
    import __AS3__.vec.*;

    public class WorkCalendarDayOfWeek 
    {

        public var dayOfWeek:int = -1;
        public var isWorking:Boolean = true;
        private var _workingTimes:Vector.<WorkingTime>;

        public function WorkCalendarDayOfWeek()
        {
            this._workingTimes = new Vector.<WorkingTime>();
            super();
        }

		public static function createWorkCalendarDayOfWeek(p:DayOfWeekPeriod):WorkCalendarDayOfWeek
        {
            var wd:WorkCalendarDayOfWeek = new WorkCalendarDayOfWeek();
            wd.dayOfWeek = p.dayOfWeek;
            wd.isWorking = p.isWorking;
            wd.workingTimes = p.workingTimes;
            return wd;
        }


        public function get workingTimes():Vector.<WorkingTime>
        {
            return WorkingTime.copyWorkingTimes(this._workingTimes);
        }

        public function set workingTimes(value:Vector.<WorkingTime>):void
        {
            this._workingTimes = WorkingTime.copyWorkingTimes(value);
        }
    }
}
