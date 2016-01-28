package mokylin.utils
{
    import mokylin.utils.WorkCalendar;
    import mokylin.utils.WorkCalendarPeriod;
    import mokylin.utils.TimeUnit;
    import mokylin.utils.TimeUtil;
    import mokylin.utils.ResourceUtil;
    import mx.resources.ResourceManager;

    public class Period extends CalendarPeriodBase 
    {

        private var _endDate:Date;
        private var _endDateAndTime:Date;
        private var _startDate:Date;

        public function Period(workCalendar:WorkCalendar, working:Boolean, start:Date, end:Date)
        {
            var date:Date;
            super(workCalendar, working);
            if (end < start)
            {
                date = start;
                start = end;
                end = date;
            }
            this.startDate = start;
            this.endDate = end;
        }

        public static function createPeriod(workCalendar:WorkCalendar, source:WorkCalendarPeriod):Period
        {
            var p:Period = new Period(workCalendar, source.isWorking, source.startDate, source.endDate);
            p._workingTimes = source.workingTimes;
            return p;
        }


        public function get endDate():Date
        {
            return new Date(this._endDate.time);
        }

        public function set endDate(value:Date):void
        {
            this._endDate = calendar.floor(value, TimeUnit.DAY, 1);
            this._endDateAndTime = calendar.addUnits(this._endDate, TimeUnit.DAY, 1, false);
            this._endDateAndTime = calendar.floor(this._endDateAndTime, TimeUnit.DAY, 1);
        }

        public function get endDateAndTime():Date
        {
            return this._endDateAndTime;
        }

        public function get numberOfDays():int
        {
            return TimeUtil.getDays(this._endDate.time - this._startDate.time) + 1;
        }

        public function get startDate():Date
        {
            return new Date(this._startDate.time);
        }

        public function set startDate(value:Date):void
        {
            this._startDate = calendar.floor(value, TimeUnit.DAY, 1);
        }

        public function get work():Number
        {
            return isWorking ? this.numberOfDays * workInOneDay : 0;
        }

        override public function workBetween(start:Date, end:Date):Number
        {
            var duration:Number;
            var startDate:Date;
            var endDate:Date;
            var date:Date;
            var nbdays:int;
            if (start > end)
            {
                ResourceUtil.logAndThrowError(Period, ResourceUtil.ELIXIR_UTILITIES, 7, ResourceManager.getInstance(), "mokylinsparkutilities", "invalid.argument.message", ["Period.workBetween", "start > end"]);
            }
            if (start < this._startDate)
            {
                ResourceUtil.logAndThrowError(Period, ResourceUtil.ELIXIR_UTILITIES, 7, ResourceManager.getInstance(), "mokylinsparkutilities", "invalid.argument.message", ["Period.workBetween", "start < startDate"]);
            }
            if (end > this._endDateAndTime)
            {
                ResourceUtil.logAndThrowError(Period, ResourceUtil.ELIXIR_UTILITIES, 7, ResourceManager.getInstance(), "mokylinsparkutilities", "invalid.argument.message", ["Period.workBetween", "end > endDate"]);
            }
            if (!isWorking || start.time == end.time)
            {
                return 0;
            }
            if (TimeUtil.areOnSameDay(start, end))
            {
                duration = workBetweenHours(start, end);
            }
            else
            {
                startDate = calendar.floor(start, TimeUnit.DAY, 1);
                endDate = calendar.floor(end, TimeUnit.DAY, 1);
                date = calendar.addUnits(startDate, TimeUnit.DAY, 1);
                duration = workBetweenHours(start, date);
                nbdays = (TimeUtil.getDays((endDate.time - startDate.time)) - 1);
                if (nbdays > 0)
                {
                    duration = (duration + (nbdays * workInOneDay));
                }
                duration = (duration + workBetweenHours(endDate, end));
            }
            return duration;
        }

        override public function add(time:Date, duration:Number):Number
        {
            var daywork:Number;
            var nbDays:int;
            var daysToGo:int;
            if (time < this._startDate)
            {
                ResourceUtil.logAndThrowError(Period, ResourceUtil.ELIXIR_UTILITIES, 7, ResourceManager.getInstance(), "mokylinsparkutilities", "invalid.argument.message", ["Period.add", "time < startDate"]);
            }
            if (time > this._endDateAndTime)
            {
                ResourceUtil.logAndThrowError(Period, ResourceUtil.ELIXIR_UTILITIES, 7, ResourceManager.getInstance(), "mokylinsparkutilities", "invalid.argument.message", ["Period.add", "time > endDate"]);
            }
            if (duration == 0)
            {
                return 0;
            }
            if (!isWorking)
            {
                time.time = this._endDate.time;
                calendar.addUnits(time, TimeUnit.DAY, 1, true);
                return duration;
            }
            duration = addWorkInDay(time, duration);
            if (duration == 0)
            {
                return 0;
            }
            var daysLeft:int = TimeUtil.getDays(this._endDate.time - calendar.floor(time, TimeUnit.DAY, 1).time);
            if (daysLeft > 0)
            {
                daywork = workInOneDay;
                nbDays = int((duration / daywork));
                daysToGo = Math.min(nbDays, daysLeft);
                if (daysToGo != 0)
                {
                    time.date = time.date + daysToGo;
                    duration = duration - (daywork * daysToGo);
                    daysLeft = daysLeft - daysToGo;
                }
                if (duration != 0 && daysLeft != 0)
                {
                    duration = addWorkInDay(time, duration);
                }
            }
            return duration;
        }

        override public function remove(time:Date, duration:Number):Number
        {
            var daywork:Number;
            var nbDays:Number;
            var daysToGo:Number;
            if (time > this._endDateAndTime)
            {
                ResourceUtil.logAndThrowError(Period, ResourceUtil.ELIXIR_UTILITIES, 7, ResourceManager.getInstance(), "mokylinsparkutilities", "invalid.argument.message", ["Period.remove", "time > endDate"]);
            }
            if (time < this._startDate)
            {
                ResourceUtil.logAndThrowError(Period, ResourceUtil.ELIXIR_UTILITIES, 7, ResourceManager.getInstance(), "mokylinsparkutilities", "invalid.argument.message", ["Period.remove", "time < startDate"]);
            }
            if (duration == 0)
            {
                return 0;
            }
            if (!isWorking)
            {
                return duration;
            }
            duration = removeWorkInDay(time, duration);
            if (duration == 0)
            {
                return 0;
            }
            var daysLeft:Number = TimeUtil.getDays(calendar.floor(time, TimeUnit.DAY, 1).time - this._startDate.time);
            if (daysLeft != 0)
            {
                daywork = workInOneDay;
                nbDays = Math.floor(duration / daywork);
                daysToGo = Math.min(nbDays, daysLeft);
                if (daysToGo != 0)
                {
                    calendar.addUnits(time, TimeUnit.DAY, -(daysToGo), true);
                    duration = duration - (daywork * daysToGo);
                    daysLeft = daysLeft - daysToGo;
                }
                if (duration != 0 && daysLeft != 0)
                {
                    duration = removeWorkInDay(time, duration);
                }
            }
            return duration;
        }

        override public function clone():CalendarPeriodBase
        {
            var copy:Period = new Period(_workCalendar, isWorking, this._startDate, this._endDate);
            copyCalendarPeriodTo(copy);
            return copy;
        }

        public function equals(p:Period):Boolean
        {
            return p.isWorking == isWorking 
				&& p._endDate.time == this._endDate.time 
				&& p._startDate.time == this._startDate.time
				&& p.sameWorkingTimes(this);
        }

		/**
		 * 时间是否有交叉 
		 * @param start
		 * @param end
		 * @return 
		 * 
		 */		
        public function intersects(start:Date, end:Date):Boolean
        {
            return start < this._endDateAndTime && end >= this._startDate;
        }
    }
}