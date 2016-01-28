package mokylin.utils
{
    import mx.resources.ResourceManager;
    
    import __AS3__.vec.Vector;

    public class CalendarPeriodBase 
    {

        public var isWorking:Boolean;
        public var isInherited:Boolean;
        protected var _workCalendar:WorkCalendar;
        protected var _workingTimes:Vector.<WorkingTime>;

        public function CalendarPeriodBase(workCalendar:WorkCalendar, isWorking:Boolean)
        {
            this._workCalendar = workCalendar;
            this.isWorking = isWorking;
            if (isWorking)
            {
                this._workingTimes = WorkingTime.copyWorkingTimes(workCalendar.getDefaultWorkingTimesInternal());
            }
            else
            {
                this._workingTimes = new Vector.<WorkingTime>();
            }
        }

        public function get calendar():GregorianCalendar
        {
            return this._workCalendar.calendar;
        }

        public function get workCalendar():WorkCalendar
        {
            return this._workCalendar;
        }

        public function get workingTimes():Vector.<WorkingTime>
        {
            return this._workingTimes;
        }

		/**
		 * 是否是一整天 
		 * @return 
		 * 
		 */		
        public function is24HoursWork():Boolean
        {
            var wt:WorkingTime;
            if (this.isWorking && this._workingTimes.length == 1)
            {
                wt = this._workingTimes[0];
                return wt.startTime == 0 && wt.endTime == TimeUnit.DAY.milliseconds;
            }
            return false;
        }
		/**
		 * 一天中所有的工作时长 
		 * @return 
		 * 
		 */
        public function get workInOneDay():Number
        {
            if (!this.isWorking)
            {
                return 0;
            }
            var work:Number = 0;
            var count:uint = this._workingTimes.length;
            var i:uint;
            while (i < count)
            {
                work = work + this._workingTimes[i].duration;
                i++;
            }
            return work;
        }
		/**
		 *  
		 * @param t1
		 * @param t2
		 * @return 
		 * 
		 */
        public function workBetweenHours(t1:Date, t2:Date):Number
        {
            var wt:WorkingTime;
            var start:Number;
            var end:Number;
            if (!this.isWorking || t1.time == t2.time)
            {
                return 0;
            }
            if (t1 > t2)
            {
                ResourceUtil.logAndThrowError(CalendarPeriodBase, ResourceUtil.ELIXIR_UTILITIES, 7, ResourceManager.getInstance(), "mokylinsparkutilities", "invalid.argument.message", ["CalendarPeriodBase.workBetweenHours", "t1 > t2"]);
            }
            var h1:Number = TimeUtil.getTimeOfDayInMillis(t1);
            var h2:Number = TimeUtil.getTimeOfDayInMillis(t2);
            if (h2 == 0)
            {
                h2 = TimeUnit.DAY.milliseconds;
            }
            var duration:Number = 0;
            var count:uint = this._workingTimes.length;
            var i:uint;
            while (i < count)
            {
                wt = this._workingTimes[i];
                start = wt.startTime;
                end = wt.endTime;
                if (h1 < end)
                {
                    if (h1 < start)
                    {
                        h1 = start;
                    }
                    if (h2 < start)
                    {
                        h2 = start;
                    }
                    if (h2 <= end)
                    {
                        duration = duration + (h2 - h1);
                        break;
                    }
                    duration = duration + (end - h1);
                    h1 = end;
                }
                i++;
            }
            return duration;
        }

        public function addWorkInDay(d:Date, duration:Number):Number
        {
            var wt:WorkingTime;
            var start:Number;
            var work:Number;
            if (duration == 0)
            {
                return 0;
            }
            var date:Date = this.calendar.floor(d, TimeUnit.DAY, 1);
            if (!this.isWorking)
            {
                d.time = this.calendar.addUnits(date, TimeUnit.DAY, 1, true).time;
                return duration;
            }
            var timeInMillis:Number = TimeUtil.getTimeOfDayInMillis(d);
            var end:Number = TimeUnit.DAY.milliseconds;
            var searchFirstWorkTime:Boolean = true;
            var count:uint = this._workingTimes.length;
            var i:uint;
            for (;i < count;i++)
            {
                wt = this._workingTimes[i];
                start = wt.startTime;
                if (searchFirstWorkTime)
                {
                    if (timeInMillis <= wt.endTime)
                    {
                        searchFirstWorkTime = false;
                        if (timeInMillis < start)
                        {
                            timeInMillis = start;
                        }
                    }
                    else
                    {
                        continue;
                    }
                }
                else
                {
                    timeInMillis = start;
                }
                if (duration != 0)
                {
                    work = (wt.endTime - timeInMillis);
                    if (duration < work)
                    {
                        work = duration;
                    }
                    duration = duration - work;
                    end = timeInMillis + work;
                }
                if (duration == 0)
                {
                    break;
                }
            }
            d.time = TimeUtil.setTimeOfDayInMillis(date, end).time;
            return duration;
        }

        public function removeWorkInDay(d:Date, duration:Number):Number
        {
            var wt:WorkingTime;
            var work:Number;
            if (duration == 0)
            {
                return 0;
            }
            var date:Date = this.calendar.floor(d, TimeUnit.DAY, 1);
            if (!this.isWorking)
            {
                d.time = date.time;
                return duration;
            }
            var timeInMillis:Number = TimeUtil.getTimeOfDayInMillis(d);
            if (timeInMillis == 0)
            {
                timeInMillis = TimeUnit.DAY.milliseconds;
                this.calendar.addUnits(date, TimeUnit.DAY, -1, true);
                date = this.calendar.floor(date, TimeUnit.DAY, 1);
            }
            var end:Number = 0;
            var searchFirstWorkTime:Boolean = true;
            var count:uint = this._workingTimes.length;
            var i:int = (count - 1);
            for (;i >= 0;i--)
            {
                wt = this._workingTimes[i];
                if (searchFirstWorkTime)
                {
                    if (timeInMillis > wt.startTime)
                    {
                        searchFirstWorkTime = false;
                        if (timeInMillis > wt.endTime)
                        {
                            timeInMillis = wt.endTime;
                        }
                    }
                    else
                    {
                        continue;
                    }
                }
                else
                {
                    timeInMillis = wt.endTime;
                }
                if (duration != 0)
                {
                    work = (timeInMillis - wt.startTime);
                    if (duration < work)
                    {
                        work = duration;
                    }
                    duration = (duration - work);
                    end = (timeInMillis - work);
                }
                if (duration == 0)
                {
                    break;
                }
            }
            d.time = TimeUtil.setTimeOfDayInMillis(date, end).time;
            return duration;
        }

        public function add(time:Date, duration:Number):Number
        {
            throw new Error();
        }

        public function remove(time:Date, duration:Number):Number
        {
            throw new Error();
        }

        public function workBetween(date1:Date, date2:Date):Number
        {
            throw new Error();
        }

        public function nextWorkingTimeFromWT(d:Date):Boolean
        {
            var workingTime:WorkingTime;
            var date:Date = this.calendar.floor(d, TimeUnit.DAY, 1);
            var time:Number = TimeUtil.getTimeOfDayInMillis(d);
            var count:uint = this._workingTimes.length;
            var i:uint;
            while (i < count)
            {
                workingTime = this._workingTimes[i];
                if (time < workingTime.endTime)
                {
                    if (time < workingTime.startTime)
                    {
                        d.time = TimeUtil.setTimeOfDayInMillis(date, workingTime.startTime).time;
                    }
                    return true;
                }
                i++;
            }
            d.time = this.calendar.addUnits(date, TimeUnit.DAY, 1, true).time;
            return false;
        }

        public function nextNonWorkingTimeFromWT(d:Date):Boolean
        {
            var workingTime:WorkingTime;
            var date:Date = this.calendar.floor(d, TimeUnit.DAY, 1);
            var time:Number = TimeUtil.getTimeOfDayInMillis(d);
            var count:uint = this._workingTimes.length;
            var i:uint;
            while (i < count)
            {
                workingTime = this._workingTimes[i];
                if (time < workingTime.endTime)
                {
                    if (time >= workingTime.startTime)
                    {
                        if (workingTime.endTime != TimeUnit.DAY.milliseconds)
                        {
                            d.time = TimeUtil.setTimeOfDayInMillis(date, workingTime.endTime).time;
                            return true;
                        }
                        d.time = this.calendar.addUnits(date, TimeUnit.DAY, 1, true).time;
                        return false;
                    }
                    return true;
                }
                i++;
            }
            if (this._workingTimes[(count - 1)].endTime != TimeUnit.DAY.milliseconds)
            {
                return true;
            }
            d.time = this.calendar.addUnits(date, TimeUnit.DAY, 1, true).time;
            return false;
        }

        public function previousWorkingTimeFromWT(d:Date):Boolean
        {
            var wt:WorkingTime;
            var count:int = this._workingTimes.length;
            if (count == 0)
            {
                return true;
            }
            var date:Date = this.calendar.floor(d, TimeUnit.DAY, 1);
            var time:Number = TimeUtil.getTimeOfDayInMillis(d);
            if (time == 0)
            {
                time = TimeUnit.DAY.milliseconds;
                this.calendar.addUnits(date, TimeUnit.DAY, -1, true);
            }
            var i:int = (count - 1);
            while (i >= 0)
            {
                wt = this._workingTimes[i];
                if (time > wt.startTime)
                {
                    if (time >= wt.endTime)
                    {
                        d.time = TimeUtil.setTimeOfDayInMillis(date, wt.endTime).time;
                    }
                    return true;
                }
                i--;
            }
            d.time = date.time;
            return false;
        }

        public function sameWorkingTimes(other:CalendarPeriodBase):Boolean
        {
            return WorkingTime.sameWorkingTimes(this._workingTimes, other._workingTimes);
        }

        public function copyCalendarPeriodTo(copy:CalendarPeriodBase):void
        {
            copy.isInherited = this.isInherited;
            copy.isWorking = this.isWorking;
            copy._workingTimes = WorkingTime.copyWorkingTimes(this._workingTimes);
        }

        public function clone():CalendarPeriodBase
        {
            throw new Error();
        }
    }
}