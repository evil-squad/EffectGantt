package mokylin.utils
{
    import __AS3__.vec.Vector;
    import __AS3__.vec.*;

    public class WorkCalendarPeriod 
    {

        private const DATE_FORMAT:String = "yyyy/MM/dd";

        private var _endDate:Date;
        public var isWorking:Boolean = true;
        private var _startDate:Date;
        private var _workingTimes:Vector.<WorkingTime>;

        public function WorkCalendarPeriod()
        {
            this._workingTimes = new Vector.<WorkingTime>();
            super();
        }

		public static function createWorkCalendarPeriod(p:Period):WorkCalendarPeriod
        {
            var period:WorkCalendarPeriod = new (WorkCalendarPeriod)();
            period.startDate = p.startDate;
            period.endDate = p.endDate;
            period.isWorking = p.isWorking;
            period.workingTimes = p.workingTimes;
            return period;
        }


        public function get end():String
        {
            var f:CLDRDateFormatter = new CLDRDateFormatter();
            f.formatString = this.DATE_FORMAT;
            return f.format(this._endDate);
        }

        public function set end(value:String):void
        {
            this.endDate = new Date(value);
        }

        public function get endDate():Date
        {
            return new Date(this._endDate.time);
        }

        public function set endDate(value:Date):void
        {
            this._endDate = TimeUtil.startOfDay(value);
        }

        public function get start():String
        {
            var f:CLDRDateFormatter = new CLDRDateFormatter();
            f.formatString = this.DATE_FORMAT;
            return f.format(this._startDate);
        }

        public function set start(value:String):void
        {
            this.startDate = new Date(value);
        }

        public function get startDate():Date
        {
            return new Date(this._startDate.time);
        }

        public function set startDate(value:Date):void
        {
            this._startDate = TimeUtil.startOfDay(value);
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
