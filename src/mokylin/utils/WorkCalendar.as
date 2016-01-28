package mokylin.utils
{
    import flash.events.EventDispatcher;
    import mx.resources.IResourceManager;
    import __AS3__.vec.Vector;
    import mx.resources.ResourceManager;
    import flash.events.Event;
    import __AS3__.vec.*;

    [Event(name="change", type="flash.events.Event")]
    [ResourceBundle("mokylinsparkutilities")]
    public class WorkCalendar extends EventDispatcher 
    {

        public static const STANDARD:WorkCalendar = createStandard();
        public static const TWENTYFOURHOURS:WorkCalendar = create24Hours();
        public static const NIGHTSHIFT:WorkCalendar = createNightShift();
        private static const _maxCacheSize:Number = 1000;

        private static var _resourceManager:IResourceManager;
        private static var _defaultWorkingTimes:Vector.<WorkingTime>;
        private static var _defaultWorkingDays:Vector.<uint>;

        private var _subCalendars:Vector.<WorkCalendar>;
        private var _disableEvents:Boolean;
        private var _nextWorkingTimeCache:LRUCache;
        private var _nextNonWorkingTimeCache:LRUCache;
        private var _previousWorkingTimeCache:LRUCache;
        private var _workBetweenCache:LRUCache;
        private var _calendar:GregorianCalendar;
        private var _name:String;
        private var _baseCalendar:WorkCalendar;
        private var _periods:Vector.<Period>;
        private var _daysOfWeek:Vector.<DayOfWeekPeriod>;

        public function WorkCalendar(name:String="default", baseCalendar:WorkCalendar=null)
        {
            var i:uint;
            super();
            if (baseCalendar != null && !baseCalendar.isBaseCalendar)
            {
                ResourceUtil.logAndThrowError(WorkCalendar, ResourceUtil.ELIXIR_UTILITIES, 7, resourceManager, "mokylinsparkutilities", "invalid.argument.message", ["WorkCalendar.WorkCalendar", "baseCalendar"]);
            }
            this._calendar = new GregorianCalendar();
            this._name = name;
            this._periods = new Vector.<Period>();
            this._daysOfWeek = new Vector.<DayOfWeekPeriod>(7);
            this._baseCalendar = baseCalendar;
            if (this._baseCalendar != null)
            {
                this._baseCalendar.addSubcalendar(this);
                this.inheritBasePeriods();
            }
            else
            {
                i = 0;
                while (i < 7)
                {
                    this._daysOfWeek[i] = this.createDefaultWorkingDay(i);
                    i++;
                }
            }
        }

		public static function getDefaultWorkingTimes():Vector.<WorkingTime>
        {
            var array:Array;
            var i:int;
            var wt:WorkingTime;
            if (_defaultWorkingTimes == null)
            {
                _defaultWorkingTimes = new Vector.<WorkingTime>();
                array = resourceManager.getStringArray("mokylinsparkutilities", "default.working.times");
                if (array == null || array.length < 2 || (array.length % 2) != 0)
                {
                    _defaultWorkingTimes.push(WorkingTime.createWorkingTime(TimeUtil.getTimeInMillis(8), TimeUtil.getTimeInMillis(12)));
                    _defaultWorkingTimes.push(WorkingTime.createWorkingTime(TimeUtil.getTimeInMillis(13), TimeUtil.getTimeInMillis(17)));
                }
                else
                {
                    i = 0;
                    while (i < array.length)
                    {
                        wt = new WorkingTime();
                        wt.start = array[i];
                        wt.end = array[(i + 1)];
                        _defaultWorkingTimes.push(wt);
                        i = (i + 2);
                    }
                }
            }
            return _defaultWorkingTimes;
        }

        private static function get resourceManager():IResourceManager
        {
            if (_resourceManager == null)
            {
                _resourceManager = ResourceManager.getInstance();
            }
            return _resourceManager;
        }

		public static function getDefaultNonWorkingDays():Vector.<uint>
        {
            var daysString:String;
            var days:Array;
            var i:int;
            if (_defaultWorkingDays == null)
            {
                _defaultWorkingDays = new Vector.<uint>();
                daysString = resourceManager.getString("mokylinsparkutilities", "non.working.days.of.week");
                if (daysString == null)
                {
                    _defaultWorkingDays.splice(0, 0, 0, 6);
                }
                else
                {
                    days = daysString.split(",");
                    i = 0;
                    while (i < days.length)
                    {
                        _defaultWorkingDays.push(parseInt(days[i]));
                        i++;
                    }
                }
            }
            return _defaultWorkingDays;
        }

        private static function createStandard():WorkCalendar
        {
            return new WorkCalendar("Standard");
        }

        private static function create24Hours():WorkCalendar
        {
            var calendar:WorkCalendar = new WorkCalendar("24 Hours");
            var times:Vector.<WorkingTime> = new <WorkingTime>[WorkingTime.createWorkingTime(0, TimeUtil.getTimeInMillis(24))];
            var i:int;
            while (i < 7)
            {
                calendar.setDayOfWeekWorkingTimes(i, times);
                i++;
            }
            return calendar;
        }

        private static function createNightShift():WorkCalendar
        {
            var calendar:WorkCalendar = new WorkCalendar("Night Shift");
            calendar.setNonWorkingDayOfWeek(TimeUtil.SUNDAY);
            var times:Vector.<WorkingTime> = new <WorkingTime>[WorkingTime.createWorkingTime(TimeUtil.getTimeInMillis(23), TimeUtil.getTimeInMillis(24))];
            calendar.setDayOfWeekWorkingTimes(TimeUtil.MONDAY, times);
            times = new <WorkingTime>[WorkingTime.createWorkingTime(TimeUtil.getTimeInMillis(0), TimeUtil.getTimeInMillis(3)), WorkingTime.createWorkingTime(TimeUtil.getTimeInMillis(4), TimeUtil.getTimeInMillis(8)), WorkingTime.createWorkingTime(TimeUtil.getTimeInMillis(23), TimeUtil.getTimeInMillis(24))];
            calendar.setDayOfWeekWorkingTimes(TimeUtil.TUESDAY, times);
            calendar.setDayOfWeekWorkingTimes(TimeUtil.WEDNESDAY, times);
            calendar.setDayOfWeekWorkingTimes(TimeUtil.THURSDAY, times);
            calendar.setDayOfWeekWorkingTimes(TimeUtil.FRIDAY, times);
            times = new <WorkingTime>[WorkingTime.createWorkingTime(TimeUtil.getTimeInMillis(0), TimeUtil.getTimeInMillis(3)), WorkingTime.createWorkingTime(TimeUtil.getTimeInMillis(4), TimeUtil.getTimeInMillis(8))];
            calendar.setDayOfWeekWorkingTimes(TimeUtil.SATURDAY, times);
            return calendar;
        }

        private static function checkWorkingTimes(times:Vector.<WorkingTime>):void
        {
            if (times == null || times.length == 0)
            {
                ResourceUtil.logAndThrowError(WorkCalendar, ResourceUtil.ELIXIR_UTILITIES, 7, resourceManager, "mokylinsparkutilities", "invalid.argument.message", ["WorkCalendar.checkWorkingTimes", "times"]);
            }
            var i:uint = 1;
            while (i < times.length)
            {
                times[i].checkWorkingTime();
                if (times[i].startTime <= times[(i - 1)].endTime)
                {
                    ResourceUtil.logAndThrowError(WorkCalendar, ResourceUtil.ELIXIR_UTILITIES, 7, resourceManager, "mokylinsparkutilities", "invalid.argument.message", ["WorkCalendar.checkWorkingTimes", "times"]);
                }
                i++;
            }
        }

		public static function periodHasDefaultWorkingTimes(p:CalendarPeriodBase):Boolean
        {
            if (p.workCalendar.isPredefinedCalendar)
            {
                return true;
            }
            var defaultWorkingTimes:Vector.<WorkingTime> = getDefaultWorkingTimes();
            return WorkingTime.sameWorkingTimes(p.workingTimes, defaultWorkingTimes);
        }

        private static function sameDayOfWeekPeriods(a:Vector.<DayOfWeekPeriod>, b:Vector.<DayOfWeekPeriod>):Boolean
        {
            var i:uint;
            while (i < 7)
            {
                if (a[i] == null && b[i] == null)
                {
                }
                else
                {
                    if (a[i] == null || b[i] == null)
                    {
                        return false;
                    }
                    if (!(a[i].equals(b[i])))
                    {
                        return false;
                    }
                }
                i++;
            }
            return true;
        }

        private static function samePeriods(a:Vector.<Period>, b:Vector.<Period>):Boolean
        {
            var count:uint = a.length;
            if (count != b.length)
            {
                return false;
            }
            var i:uint;
            while (i < count)
            {
                if (!(a[i].equals(b[i])))
                {
                    return false;
                }
                i++;
            }
            return true;
        }


        public function get calendar():GregorianCalendar
        {
            if (!this._calendar)
            {
                this._calendar = new GregorianCalendar();
            }
            return this._calendar;
        }

        public function set calendar(value:GregorianCalendar):void
        {
            this.assertNotReadOnly();
            if (value != this._calendar)
            {
                this._calendar = value;
                this.onChanged();
            }
        }

        public function get name():String
        {
            return this._name == null ? "" : this._name;
        }

        public function set name(value:String):void
        {
            this.assertNotReadOnly();
            if (this._name != value)
            {
                this._name = value;
                this.onChanged();
            }
        }

        public function get baseCalendar():WorkCalendar
        {
            return this._baseCalendar;
        }

        public function set baseCalendar(value:WorkCalendar):void
        {
            var i:int;
            var p:Period;
            var subs:Vector.<WorkCalendar>;
            var sub:WorkCalendar;
            var j:int;
            var periods:Vector.<Period>;
            var count:int;
            var k:int;
            this.assertNotReadOnly();
            if (value != null && value == this)
            {
                ResourceUtil.logAndThrowError(WorkCalendar, ResourceUtil.ELIXIR_UTILITIES, 7, resourceManager, "mokylinsparkutilities", "invalid.argument.message", ["WorkCalendar.baseCalendar", "value"]);
            }
            if (value != null && !value.isBaseCalendar)
            {
                ResourceUtil.logAndThrowError(WorkCalendar, ResourceUtil.ELIXIR_UTILITIES, 7, resourceManager, "mokylinsparkutilities", "invalid.argument.message", ["WorkCalendar.baseCalendar", "value"]);
            }
            if (value == this.baseCalendar)
            {
                return;
            }
            if (this.isBaseCalendar)
            {
                if (this._subCalendars != null)
                {
                    subs = this._subCalendars.slice(0);
                    this._subCalendars.splice(0, this._subCalendars.length);
                    for each (sub in subs)
                    {
                        if (sub != null)
                        {
                            sub.baseCalendar = STANDARD;
                        }
                    }
                }
                i = 0;
                while (i < 7)
                {
                    if (this._daysOfWeek[i].equals(value._daysOfWeek[i]) || (this.dayOfWeekHasDefaultSetting(i) && value.dayOfWeekHasDefaultSetting(i)))
                    {
                        this._daysOfWeek[i] = null;
                    }
                    else
                    {
                        this._daysOfWeek[i].isInherited = false;
                    }
                    i++;
                }
                for each (p in this._periods)
                {
                    p.isInherited = false;
                }
                this._baseCalendar = value;
                this._baseCalendar.addSubcalendar(this);
                this.inheritBasePeriods();
            }
            else
            {
                this._baseCalendar.removeSubcalendar(this);
                if (value == null)
                {
                    j = 0;
                    while (j < 7)
                    {
                        if (this._daysOfWeek[j] == null)
                        {
                            this._daysOfWeek[j] = this.createDefaultWorkingDay(j);
                        }
                        this._daysOfWeek[j].isInherited = true;
                        j++;
                    }
                    periods = this._periods.slice(0);
                    count = periods.length;
                    k = 0;
                    while (k < count)
                    {
                        if (periods[k].isInherited)
                        {
                            this._periods.splice(k, 1);
                        }
                        k++;
                    }
                    this._baseCalendar = null;
                }
                else
                {
                    this._baseCalendar = value;
                    this._baseCalendar.addSubcalendar(this);
                    this.inheritBasePeriods();
                }
            }
            this.onChanged();
        }

        public function get periods():Vector.<WorkCalendarPeriod>
        {
            var p:Period;
            var result:Vector.<WorkCalendarPeriod> = new Vector.<WorkCalendarPeriod>();
            var count:uint = this._periods.length;
            var i:uint;
            while (i < count)
            {
                p = this._periods[i];
                if (!p.isInherited)
                {
                    result.push(WorkCalendarPeriod.createWorkCalendarPeriod(p));
                }
                i++;
            }
            return result;
        }

        public function set periods(value:Vector.<WorkCalendarPeriod>):void
        {
            var wp:WorkCalendarPeriod;
            var newPeriod:Period;
            this.assertNotReadOnly();
            this._periods = new Vector.<Period>();
            var count:uint = value.length;
            var i:uint;
            while (i < count)
            {
                wp = value[i];
                newPeriod = Period.createPeriod(this, wp);
                if (wp.isWorking)
                {
                    checkWorkingTimes(newPeriod.workingTimes);
                    this.addWorkingPeriod(newPeriod);
                }
                else
                {
                    this.addNonWorkingPeriod(newPeriod);
                }
                i++;
            }
            this.onChanged();
        }

        public function get daysOfWeek():Vector.<WorkCalendarDayOfWeek>
        {
            var day:DayOfWeekPeriod;
            var result:Vector.<WorkCalendarDayOfWeek> = new Vector.<WorkCalendarDayOfWeek>();
            for each (day in this._daysOfWeek)
            {
                if (day != null)
                {
                    result.push(WorkCalendarDayOfWeek.createWorkCalendarDayOfWeek(day));
                }
            }
            return result;
        }

        public function set daysOfWeek(value:Vector.<WorkCalendarDayOfWeek>):void
        {
            var wd:WorkCalendarDayOfWeek;
            var i:int;
            this.assertNotReadOnly();
            this._daysOfWeek = new Vector.<DayOfWeekPeriod>(7);
            for each (wd in value)
            {
                this._daysOfWeek[wd.dayOfWeek] = DayOfWeekPeriod.createDayOfWeekPeriod(this, wd);
            }
            if (this.isBaseCalendar)
            {
                i = 0;
                while (i < 7)
                {
                    if (this._daysOfWeek[i] == null)
                    {
                        this._daysOfWeek[i] = this.createDefaultWorkingDay(i);
                    }
                    i++;
                }
            }
            this.onChanged();
        }

        public function equals(obj:WorkCalendar):Boolean
        {
            if (obj == this)
            {
                return true;
            }
            return obj._baseCalendar == this._baseCalendar 
				&& obj._name == this._name 
				&& sameDayOfWeekPeriods(obj._daysOfWeek, this._daysOfWeek)
				&& samePeriods(obj._periods, this._periods);
        }

        public function get isPredefinedCalendar():Boolean
        {
            return this == STANDARD || this == TWENTYFOURHOURS || this == NIGHTSHIFT;
        }

        public function copyFrom(workCalendar:WorkCalendar):void
        {
            var p:Period;
            var dowPeriod:DayOfWeekPeriod;
            this.assertNotReadOnly();
            this._calendar = workCalendar._calendar;
            var i:uint;
            while (i < 7)
            {
                dowPeriod = workCalendar._daysOfWeek[i];
                this._daysOfWeek[i] = dowPeriod!=null ? DayOfWeekPeriod(dowPeriod.clone()) : null;
                i++;
            }
            this._periods.splice(0, this._periods.length);
            for each (p in workCalendar._periods)
            {
                this._periods.push(p.clone());
            }
            if (workCalendar.baseCalendar != this.baseCalendar)
            {
                this.inheritBasePeriods();
            }
            this.onChanged();
        }

        public function clone():WorkCalendar
        {
            var wc:WorkCalendar = new WorkCalendar(this.name, this.baseCalendar);
            wc._calendar = this.calendar;
            wc._periods = this._periods.slice(0);
            var count:uint = this._periods.length;
            var i:uint;
            while (i < count)
            {
                if (wc._periods[i] != null)
                {
                    wc._periods[i] = Period(wc._periods[i].clone());
                }
                i++;
            }
            wc._daysOfWeek = this._daysOfWeek.slice(0);
            var j:uint;
            while (j < 7)
            {
                if (wc._daysOfWeek[j] != null)
                {
                    wc._daysOfWeek[j] = DayOfWeekPeriod(this._daysOfWeek[j].clone());
                }
                j++;
            }
            return wc;
        }

        override public function toString():String
        {
            return this.isBaseCalendar ? this.name : this.name + " based on " + this.baseCalendar.name;
        }

        public function get isBaseCalendar():Boolean
        {
            return this._baseCalendar == null;
        }

        public function workBetween(t1:Date, t2:Date):Number
        {
            var value:Object;
            var key:Object = "" + t1.time + "," + t2.time;
            if (this._workBetweenCache != null)
            {
                value = this._workBetweenCache.getData(key);
                if (value != null)
                {
                    return Number(value);
                }
            }
            var result:Number = this.workBetweenInternal(t1, t2);
            if (this._workBetweenCache == null)
            {
                this._workBetweenCache = new LRUCache(0x1000);
            }
            this._workBetweenCache.add(key, result);
            return result;
        }

        public function workBetweenInternal(t1:Date, t2:Date):Number
        {
            var duration:Number;
            var tmp:Date;
            var p1:CalendarPeriodBase;
            var p:Period;
            var startDate:Date;
            if (t1.time == t2.time)
            {
                return 0;
            }
            t1 = new Date(t1.time);
            t2 = new Date(t2.time);
            var negate:Boolean = (t2.time < t1.time);
            if (negate)
            {
                tmp = t1;
                t1 = t2;
                t2 = tmp;
            }
            if (TimeUtil.areOnSameDay(t1, t2))
            {
                p1 = this.getCalendarPeriod(t1);
                duration = p1.workBetweenHours(t1, t2);
            }
            else
            {
                duration = 0;
                t1 = this.nextWorkingTime(t1);
                t2 = this.previousWorkingTime(t2);
                if (t1 >= t2)
                {
                    return 0;
                }
                while (true)
                {
                    p = this.nextPeriod(t1);
                    if (p != null)
                    {
                        startDate = p.startDate;
                        if (t2 < startDate)
                        {
                            duration = (duration + this.standardWorkBetween(t1, t2));
                            break;
                        }
                        if (t1 < startDate)
                        {
                            duration = (duration + this.standardWorkBetween(t1, startDate));
                            t1 = startDate;
                        }
                        if (t2 <= p.endDateAndTime)
                        {
                            duration = (duration + p.workBetween(t1, t2));
                            break;
                        }
                        duration = (duration + p.workBetween(t1, p.endDateAndTime));
                        t1.time = p.endDateAndTime.time;
                    }
                    else
                    {
                        duration = (duration + this.standardWorkBetween(t1, t2));
                        break;
                    }
                }
            }
            return negate ? -duration : duration;
        }

        public function removeWorkingTime(time:Date, duration:Number):Date
        {
            var p:Period;
            var toComplete:Number;
            var workInWeek:Number;
            var toNextPeriod:Number;
            var weeks:Number;
            time = new Date(time.time);
            while (duration > 0)
            {
                time = this.previousWorkingTime(time);
                if (!this.hasPreviousWorkingTime(time))
                {
                    return time;
                }
                p = this.getPeriodBackward(time);
                if (p != null)
                {
                    duration = p.remove(time, duration);
                }
                else
                {
                    p = this.previousPeriod(time);
                    toComplete = duration;
                    if (p != null)
                    {
                        toNextPeriod = this.standardWorkBetween(p.endDateAndTime, time);
                        toComplete = Math.min(duration, toNextPeriod);
                    }
                    duration = (duration - toComplete);
                    workInWeek = this.workInOneWeek;
                    if (toComplete >= workInWeek)
                    {
                        weeks = Math.floor((toComplete / workInWeek));
                        if (toComplete % workInWeek == 0)
                        {
                            weeks = (weeks - 1);
                        }
                        time = this.calendar.addUnits(time, TimeUnit.WEEK, -(weeks), true);
                        toComplete = (toComplete - (weeks * workInWeek));
                    }
                    while (toComplete != 0 && time.time != TimeUtil.MINIMUM_DATE.time)
                    {
                        time = this.previousWorkingTime(time);
                        toComplete = this.getDayOfWeekPeriodBackward(time).remove(time, toComplete);
                    }
                }
            }
            return time;
        }

        public function addWorkingTime(time:Date, duration:Number):Date
        {
            var p:Period;
            var toComplete:Number;
            var workInWeek:Number;
            var toNextPeriod:Number;
            var weeks:Number;
            time = new Date(time.time);
            while (duration > 0)
            {
                time = this.nextWorkingTime(time);
                if (!this.hasNextWorkingTime(time))
                {
                    return time;
                }
                p = this.getPeriod(time);
                if (p != null)
                {
                    duration = p.add(time, duration);
                }
                else
                {
                    p = this.nextPeriod(time);
                    toComplete = duration;
                    if (p != null)
                    {
                        toNextPeriod = this.standardWorkBetween(time, p.startDate);
                        toComplete = Math.min(duration, toNextPeriod);
                    }
                    duration = (duration - toComplete);
                    workInWeek = this.workInOneWeek;
                    if (workInWeek != 0 && toComplete >= workInWeek)
                    {
                        weeks = int(toComplete / workInWeek);
                        if ((toComplete % workInWeek) == 0)
                        {
                            weeks = (weeks - 1);
                        }
                        time = this.calendar.addUnits(time, TimeUnit.WEEK, weeks, true);
                        toComplete = (toComplete - (weeks * workInWeek));
                    }
                    while (toComplete != 0)
                    {
                        time = this.nextWorkingTime(time);
                        toComplete = this.getDayOfWeekPeriod(time).add(time, toComplete);
                    }
                }
            }
            return time;
        }

        public function previousWorkingTime(time:Date):Date
        {
            var ms:Object;
            if (this._previousWorkingTimeCache != null)
            {
                ms = this._previousWorkingTimeCache.getData(time.time);
                if (ms != null)
                {
                    return new Date(Number(ms));
                }
            }
            var result:Date = this.previousWorkingTimeInternal(time);
            if (time.time == result.time)
            {
                if (this._previousWorkingTimeCache == null)
                {
                    this._previousWorkingTimeCache = new LRUCache(0x0800);
                }
                this._previousWorkingTimeCache.add(time.time, result.time);
            }
            return result;
        }

		public function previousWorkingTimeInternal(time:Date):Date
        {
            var p:Period;
            var dowPeriod:DayOfWeekPeriod;
            var startOfDay:Date;
            time = new Date(time.time);
            if (!this.hasPreviousWorkingTime(time))
            {
                return time;
            }
            while (true)
            {
                p = this.getPeriodBackward(time);
                if (p != null)
                {
                    if (p.isWorking)
                    {
                        if (p.previousWorkingTimeFromWT(time))
                        {
                            return time;
                        }
                    }
                    else
                    {
                        time = p.startDate;
                    }
                }
                else
                {
                    dowPeriod = this.getDayOfWeekPeriodBackward(time);
                    if (dowPeriod.isWorking)
                    {
                        if (dowPeriod.previousWorkingTimeFromWT(time))
                        {
                            return time;
                        }
                    }
                    else
                    {
                        startOfDay = this.calendar.floor(time, TimeUnit.DAY, 1);
                        if (time.time == startOfDay.time)
                        {
                            this.calendar.addUnits(time, TimeUnit.DAY, -1, true);
                        }
                        else
                        {
                            time.time = startOfDay.time;
                        }
                    }
                }
            }
            return time;
        }

        public function nextWorkingTime(time:Date):Date
        {
            var ms:Object;
            var dd:Date;
            if (this._nextWorkingTimeCache != null)
            {
                ms = this._nextWorkingTimeCache.getData(time.time);
                if (ms != null)
                {
                    return new Date(Number(ms));
                }
            }
            var result:Date = this.nextWorkingTimeInternal(time);
            if (time.time != result.time)
            {
                dd = this.previousWorkingTimeInternal(time);
                if (dd.time == time.time)
                {
                    if (this._nextWorkingTimeCache == null)
                    {
                        this._nextWorkingTimeCache = new LRUCache(0x0400);
                    }
                    this._nextWorkingTimeCache.add(time.time, result.time);
                }
            }
            return result;
        }

		public function nextWorkingTimeInternal(time:Date):Date
        {
            var working:Boolean;
            var dowPeriod:DayOfWeekPeriod;
            var p:Period;
            var dowPeriod2:DayOfWeekPeriod;
            time = new Date(time.time);
            if (!this.hasNextWorkingTime(time))
            {
                return time;
            }
            if (this._periods.length == 0)
            {
                while (true)
                {
                    dowPeriod = this.getDayOfWeekPeriodForDay(time.day);
                    if (dowPeriod.isWorking)
                    {
                        working = dowPeriod.nextWorkingTimeFromWT(time);
                        if (working)
                        {
                            return time;
                        }
                    }
                    else
                    {
                        time = this.calendar.addUnits(time, TimeUnit.DAY, 1, true);
                    }
                }
            }
            else
            {
                while (true)
                {
                    p = this.getPeriod(time);
                    if (p != null)
                    {
                        if (p.isWorking)
                        {
                            working = p.nextWorkingTimeFromWT(time);
                            if (working)
                            {
                                return time;
                            }
                        }
                        else
                        {
                            time.time = p.endDateAndTime.time;
                        }
                    }
                    else
                    {
                        dowPeriod2 = this.getDayOfWeekPeriodForDay(time.day);
                        if (dowPeriod2.isWorking)
                        {
                            working = dowPeriod2.nextWorkingTimeFromWT(time);
                            if (working)
                            {
                                return time;
                            }
                        }
                        else
                        {
                            this.calendar.addUnits(time, TimeUnit.DAY, 1, true);
                        }
                    }
                }
            }
            return time;
        }

        public function nextNonWorkingTime(time:Date):Date
        {
            var ms:Object;
            if (this._nextNonWorkingTimeCache != null)
            {
                ms = this._nextNonWorkingTimeCache.getData(time.time);
                if (ms != null)
                {
                    return (new Date(Number(ms)));
                };
            };
            var result:Date = this.nextNonWorkingTimeInternal(time);
            if (time.time != result.time)
            {
                if (this._nextNonWorkingTimeCache == null)
                {
                    this._nextNonWorkingTimeCache = new LRUCache(0x0400);
                };
                this._nextNonWorkingTimeCache.add(time.time, result.time);
            };
            return (result);
        }

		public function nextNonWorkingTimeInternal(time:Date):Date
        {
            var p:Period;
            var dowPeriod:DayOfWeekPeriod;
            time = new Date(time.time);
            if (!(this.hasNextNonWorkingTime(time)))
            {
                return (time);
            };
            while (true)
            {
                p = this.getPeriod(time);
                if (p != null)
                {
                    if (((!(p.isWorking)) || (p.nextNonWorkingTimeFromWT(time))))
                    {
                        break;
                    };
                }
                else
                {
                    dowPeriod = this.getDayOfWeekPeriodForDay(time.day);
                    if (((!(dowPeriod.isWorking)) || (dowPeriod.nextNonWorkingTimeFromWT(time))))
                    {
                        break;
                    };
                };
            };
            return (time);
        }

        public function hasNextWorkingTime(time:Date):Boolean
        {
            var p:Period;
            var hour:Number;
            if (this.hasWorkingTimeInStandardWeek())
            {
                return true;
            }
            var date:Date = this.calendar.floor(time, TimeUnit.DAY, 1);
            var count:uint = this._periods.length;
            var i:int = (count - 1);
            while (i >= 0)
            {
                p = this._periods[i];
                if (date > p.endDate)
                {
                }
                else
                {
                    if (!(p.isWorking))
                    {
                    }
                    else
                    {
                        if (date < p.endDate)
                        {
                            return true;
                        }
                        hour = (time.time - date.time);
                        return hour < p.workingTimes[(p.workingTimes.length - 1)].endTime;
                    }
                }
                i--;
            }
            return false;
        }

        public function hasPreviousWorkingTime(time:Date):Boolean
        {
            var p:Period;
            var hour:Number;
            if (this.hasWorkingTimeInStandardWeek())
            {
                return (true);
            };
            var date:Date = this.calendar.floor(time, TimeUnit.DAY, 1);
            var count:uint = this._periods.length;
            var i:uint;
            while (i < count)
            {
                p = this._periods[i];
                if (date < p.startDate)
                {
                    return (false);
                };
                if (!(p.isWorking))
                {
                }
                else
                {
                    if (date > p.startDate)
                    {
                        return (true);
                    };
                    hour = (time.time - date.time);
                    return ((hour >= p.workingTimes[0].startTime));
                };
                i++;
            };
            return (false);
        }

        public function hasNextNonWorkingTime(time:Date):Boolean
        {
            var p:Period;
            var hour:Number;
            var max:Number;
            var k:int;
            var wt:WorkingTime;
            var i:int;
            while (i < 7)
            {
                if (!(this.getDayOfWeekPeriodForDay(i).is24HoursWork()))
                {
                    return (true);
                };
                i++;
            };
            var date:Date = this.calendar.floor(time, TimeUnit.DAY, 1);
            var count:uint = this._periods.length;
            var j:int = (count - 1);
            while (j >= 0)
            {
                p = this._periods[j];
                if (date > p.endDate)
                {
                    return (false);
                };
                if (!(p.isWorking))
                {
                    return (true);
                };
                if (p.is24HoursWork())
                {
                }
                else
                {
                    if (date < p.endDate)
                    {
                        return (true);
                    };
                    hour = (time.time - date.time);
                    max = TimeUnit.DAY.milliseconds;
                    k = (p.workingTimes.length - 1);
                    while (k >= 0)
                    {
                        wt = p.workingTimes[k];
                        if (wt.endTime == max)
                        {
                            max = wt.startTime;
                        }
                        else
                        {
                            return ((hour < max));
                        };
                        k--;
                    };
                };
                j--;
            };
            return (false);
        }

        private function hasWorkingTimeInStandardWeek():Boolean
        {
            var i:int;
            while (i < 7)
            {
                if (this.getDayOfWeekPeriodForDay(i).isWorking)
                {
                    return true;
                }
                i++;
            }
            return false;
        }

        public function resetPeriodToDefault(start:Date, end:Date):void
        {
            var p:Period;
            var date:Date;
            var index:int;
            var p1:Period;
            var p2:Period;
            var p3:Period;
            var p4:Period;
            var insert:int;
            var i:int;
            var p5:Period;
            this.assertNotReadOnly();
            start = this.calendar.floor(start, TimeUnit.DAY, 1);
            end = this.calendar.floor(end, TimeUnit.DAY, 1);
            if (end < start)
            {
                date = start;
                start = end;
                end = date;
            };
            if (this._periods.length == 0)
            {
                return;
            };
            var periods:Vector.<Period> = this._periods.slice(0);
            for each (p in periods)
            {
                if (p.intersects(start, end))
                {
                    index = this._periods.indexOf(p);
                    this._periods.splice(index, 1);
                    if (p.startDate < start)
                    {
                        p1 = Period(p.clone());
                        p1.endDate = this.calendar.addUnits(start, TimeUnit.DAY, -1, false);
                        this._periods.splice(index++, 0, p1);
                    };
                    if (p.endDate > end)
                    {
                        p2 = Period(p.clone());
                        p2.startDate = this.calendar.addUnits(end, TimeUnit.DAY, 1, false);
                        this._periods.splice(index, 0, p2);
                    };
                };
            };
            if (this._baseCalendar != null)
            {
                for each (p3 in this._baseCalendar._periods)
                {
                    if (p3.intersects(start, end))
                    {
                        p4 = Period(p3.clone());
                        p4.isInherited = true;
                        p4.startDate = TimeUtil.max(p4.startDate, start);
                        p4.endDate = TimeUtil.min(p4.endDate, end);
                        insert = this._periods.length;
                        i = 0;
                        for each (p5 in this._periods)
                        {
                            if (p4.startDate < p5.startDate)
                            {
                                insert = i;
                                break;
                            };
                            i++;
                        };
                        this._periods.splice(insert, 0, p4);
                    };
                };
            };
            this.onChanged();
        }

        public function setPeriodWorkingTimes(fromDate:Date, toDate:Date, times:Vector.<WorkingTime>):void
        {
            var wt:WorkingTime;
            this.assertNotReadOnly();
            var newPeriod:Period = new Period(this, true, fromDate, toDate);
            if (((!((times == null))) && (!((times.length == 0)))))
            {
                checkWorkingTimes(times);
                newPeriod.workingTimes.splice(0, newPeriod.workingTimes.length);
                for each (wt in times)
                {
                    newPeriod.workingTimes.push(wt.clone());
                };
            };
            this.addWorkingPeriod(newPeriod);
            this.onChanged();
        }

        public function setNonWorkingPeriod(fromDate:Date, toDate:Date):void
        {
            this.assertNotReadOnly();
            this.addNonWorkingPeriod(new Period(this, false, fromDate, toDate));
            this.onChanged();
        }

        public function setNonWorkingDayOfWeek(dayOfWeek:int):void
        {
            this.assertNotReadOnly();
            this._daysOfWeek[dayOfWeek] = new DayOfWeekPeriod(this, false, dayOfWeek);
            this.onChanged();
        }

        public function setDayOfWeekWorkingTimes(dayOfWeek:int, times:Vector.<WorkingTime>):void
        {
            var count:uint;
            var i:uint;
            this.assertNotReadOnly();
            var dowPeriod:DayOfWeekPeriod = new DayOfWeekPeriod(this, true, dayOfWeek);
            if (times != null && times.length != 0)
            {
                checkWorkingTimes(times);
                dowPeriod.workingTimes.splice(0, dowPeriod.workingTimes.length);
                count = times.length;
                i = 0;
                while (i < count)
                {
                    dowPeriod.workingTimes.push(times[i].clone());
                    i++;
                }
            }
            this._daysOfWeek[dayOfWeek] = dowPeriod;
            this.onChanged();
        }

        public function isWorkingDayOfWeek(dayOfWeek:int):Boolean
        {
            return this.getDayOfWeekPeriodForDay(dayOfWeek).isWorking;
        }

        public function isWorkingDate(date:Date):Boolean
        {
            return this.getCalendarPeriod(date).isWorking;
        }

        public function isModifiedFromBaseCalendar():Boolean
        {
            if (this.isBaseCalendar)
            {
                return false;
            }
            var i:uint;
            while (i < 7)
            {
                if (this._daysOfWeek[i] != null)
                {
                    if (!this._daysOfWeek[i].equals(this._baseCalendar._daysOfWeek[i]))
                    {
                        return true;
                    }
                }
                i++;
            }
            var j:uint;
            while (j < this._periods.length)
            {
                if (!(this._periods[j].isInherited))
                {
                    return true;
                }
                j++;
            }
            return false;
        }

        public function isModifiedPeriod(date:Date):Boolean
        {
            var p:CalendarPeriodBase = this.getCalendarPeriod(date);
            return (((this.isBaseCalendar) ? (!((p is Period))) : ((((p is Period)) ? p.isInherited : true))));
        }

        public function isDefaultWorkingDate(date:Date):Boolean
        {
            var p:CalendarPeriodBase = this.getCalendarPeriod(date);
            if (!this.isBaseCalendar)
            {
                return p.isInherited;
            }
            if (p is DayOfWeekPeriod)
            {
                return this.dayOfWeekHasDefaultSetting(DayOfWeekPeriod(p).dayOfWeek);
            }
            return periodHasDefaultWorkingTimes(p);
        }

        public function isDefaultWorkingDayOfWeek(dayOfWeek:int):Boolean
        {
            return (((this.isBaseCalendar) ? this.dayOfWeekHasDefaultSetting(dayOfWeek) : this.getDayOfWeekPeriodForDay(dayOfWeek).isInherited));
        }

        public function isDefaultDayOfWeek(dayOfWeek:int):Boolean
        {
            return (((this.isBaseCalendar) ? this._daysOfWeek[dayOfWeek].isInherited : (this._daysOfWeek[dayOfWeek] == null)));
        }

        public function getDateWorkingTimes(date:Date):Vector.<WorkingTime>
        {
            var period:CalendarPeriodBase = this.getCalendarPeriod(date);
            return (((((!((period == null))) && (period.isWorking))) ? (WorkingTime.copyWorkingTimes(period.workingTimes)) : (new Vector.<WorkingTime>())));
        }

        public function getDayOfWeekWorkingTimes(dayOfWeek:int):Vector.<WorkingTime>
        {
            var day:DayOfWeekPeriod = this.getDayOfWeekPeriodForDay(dayOfWeek);
            return (((((!((day == null))) && (day.isWorking))) ? (WorkingTime.copyWorkingTimes(day.workingTimes)) : (new Vector.<WorkingTime>())));
        }

        public function isStandardWorkingDate(date:Date):Boolean
        {
            return (periodHasDefaultWorkingTimes(this.getCalendarPeriod(date)));
        }

        public function isStandardWorkingDay(dayOfWeek:int):Boolean
        {
            return (periodHasDefaultWorkingTimes(this.getDayOfWeekPeriodForDay(dayOfWeek)));
        }

        public function resetDayOfWeekToDefault(dayOfWeek:int):void
        {
            this.assertNotReadOnly();
            if (!(this.isDefaultWorkingDayOfWeek(dayOfWeek)))
            {
                this._daysOfWeek[dayOfWeek] = ((this.isBaseCalendar) ? this.createDefaultWorkingDay(dayOfWeek) : null);
                this.onChanged();
            };
        }

        public function createDefaultWorkingDay(day:int):DayOfWeekPeriod
        {
            var isWorking:Boolean = getDefaultNonWorkingDays().indexOf(day) == -1;
            var dowPeriod:DayOfWeekPeriod = new DayOfWeekPeriod(this, isWorking, day);
            dowPeriod.isInherited = true;
            return dowPeriod;
        }

		public function getDefaultWorkingTimesInternal():Vector.<WorkingTime>
        {
            return getDefaultWorkingTimes();
        }

        private function removeSubcalendar(cal:WorkCalendar):void
        {
            if (this.isPredefinedCalendar || this._subCalendars == null)
            {
                return;
            }
            var index:int = this._subCalendars.indexOf(cal);
            if (index != -1)
            {
                this._subCalendars.splice(index, 1);
            }
        }

        private function addSubcalendar(cal:WorkCalendar):void
        {
            if (this.isPredefinedCalendar)
            {
                return;
            }
            if (this._subCalendars == null)
            {
                this._subCalendars = new Vector.<WorkCalendar>();
            }
            this._subCalendars.push(cal);
        }

        private function addNonWorkingPeriod(newPeriod:Period):void
        {
            var periods:Vector.<Period>;
            var newPeriods:Vector.<Period>;
            var p:Period;
            var index:int;
            var inserted:Boolean;
            var p5:Period;
            var p6:Period;
            var p1:Period;
            var p2:Period;
            var p3:Period;
            var p4:Period;
            if (this._periods.length == 0)
            {
                this._periods.push(newPeriod);
            }
            else
            {
                periods = this._periods.slice(0);
                newPeriods = new Vector.<Period>();
                for each (p in periods)
                {
                    if (!(p.isWorking))
                    {
                        if (((((p.intersects(newPeriod.startDate, newPeriod.endDate)) || ((p.endDateAndTime.time == newPeriod.startDate.time)))) || ((newPeriod.endDateAndTime.time == p.startDate.time))))
                        {
                            if (!(p.isInherited))
                            {
                                newPeriod.startDate = TimeUtil.min(p.startDate, newPeriod.startDate);
                                newPeriod.endDate = TimeUtil.max(p.endDate, newPeriod.endDate);
                            }
                            else
                            {
                                if (p.startDate < newPeriod.startDate)
                                {
                                    p1 = Period(p.clone());
                                    p1.endDate = this.calendar.addUnits(newPeriod.startDate, TimeUnit.DAY, -1);
                                    newPeriods.push(p1);
                                };
                                if (p.endDate > newPeriod.endDate)
                                {
                                    p2 = Period(p.clone());
                                    p2.startDate = this.calendar.addUnits(newPeriod.endDate, TimeUnit.DAY, 1);
                                    newPeriods.push(p2);
                                };
                            };
                        }
                        else
                        {
                            newPeriods.push(p);
                        };
                    }
                    else
                    {
                        if (p.intersects(newPeriod.startDate, newPeriod.endDate))
                        {
                            if (p.startDate < newPeriod.startDate)
                            {
                                p3 = Period(p.clone());
                                p3.endDate = this.calendar.addUnits(newPeriod.startDate, TimeUnit.DAY, -1);
                                newPeriods.push(p3);
                            };
                            if (p.endDate > newPeriod.endDate)
                            {
                                p4 = Period(p.clone());
                                p4.startDate = this.calendar.addUnits(newPeriod.endDate, TimeUnit.DAY, 1);
                                newPeriods.push(p4);
                            };
                        }
                        else
                        {
                            newPeriods.push(p);
                        };
                    };
                };
                index = 0;
                inserted = false;
                for each (p5 in newPeriods)
                {
                    if (newPeriod.endDate < p5.endDate)
                    {
                        newPeriods.splice(index, 0, newPeriod);
                        inserted = true;
                        break;
                    };
                    index++;
                };
                if (!(inserted))
                {
                    newPeriods.push(newPeriod);
                };
                this._periods.splice(0, this._periods.length);
                for each (p6 in newPeriods)
                {
                    this._periods.push(p6);
                };
            };
        }

        private function addWorkingPeriod(newPeriod:Period):void
        {
            var periods:Vector.<Period>;
            var newPeriods:Vector.<Period>;
            var p:Period;
            var index:int;
            var inserted:Boolean;
            var p5:Period;
            var p6:Period;
            var p1:Period;
            var p2:Period;
            var p3:Period;
            var p4:Period;
            if (this._periods.length == 0)
            {
                this._periods.push(newPeriod);
            }
            else
            {
                periods = this._periods.slice(0);
                newPeriods = new Vector.<Period>();
                for each (p in periods)
                {
                    if (p.isWorking)
                    {
                        if (((((newPeriod.intersects(p.startDate, p.endDate)) || (((p.endDate.time + TimeUnit.DAY.milliseconds) == newPeriod.startDate.time)))) || (((newPeriod.endDate.time + TimeUnit.DAY.milliseconds) == p.startDate.time))))
                        {
                            if (((!(p.isInherited)) && (newPeriod.sameWorkingTimes(p))))
                            {
                                newPeriod.startDate = TimeUtil.min(p.startDate, newPeriod.startDate);
                                newPeriod.endDate = TimeUtil.max(p.endDate, newPeriod.endDate);
                            }
                            else
                            {
                                if (p.startDate < newPeriod.startDate)
                                {
                                    p1 = Period(p.clone());
                                    p1.startDate = this.calendar.addUnits(newPeriod.startDate, TimeUnit.DAY, -1);
                                    newPeriods.push(p1);
                                };
                                if (p.endDate > newPeriod.endDate)
                                {
                                    p2 = Period(p.clone());
                                    p2.startDate = this.calendar.addUnits(newPeriod.endDate, TimeUnit.DAY, 1);
                                    newPeriods.push(p2);
                                };
                            };
                        }
                        else
                        {
                            newPeriods.push(p);
                        };
                    }
                    else
                    {
                        if (p.intersects(newPeriod.startDate, newPeriod.endDate))
                        {
                            if (p.startDate < newPeriod.startDate)
                            {
                                p3 = Period(p.clone());
                                p3.startDate = this.calendar.addUnits(newPeriod.startDate, TimeUnit.DAY, -1);
                                newPeriods.push(p3);
                            };
                            if (p.endDate > newPeriod.endDate)
                            {
                                p4 = Period(p.clone());
                                p4.startDate = this.calendar.addUnits(newPeriod.endDate, TimeUnit.DAY, 1);
                                newPeriods.push(p4);
                            };
                        }
                        else
                        {
                            newPeriods.push(p);
                        };
                    };
                };
                index = 0;
                inserted = false;
                for each (p5 in newPeriods)
                {
                    if (newPeriod.endDate < p5.endDate)
                    {
                        newPeriods.splice(index, 0, newPeriod);
                        inserted = true;
                        break;
                    };
                    index++;
                };
                if (!(inserted))
                {
                    newPeriods.push(newPeriod);
                };
                this._periods.splice(0, this._periods.length);
                for each (p6 in newPeriods)
                {
                    this._periods.push(p6);
                };
            };
        }

        private function standardWorkBetween(t1:Date, t2:Date):Number
        {
            if (t1.time == t2.time)
            {
                return 0;
            }
            if (t1 > t2)
            {
                ResourceUtil.logAndThrowError(WorkCalendar, ResourceUtil.ELIXIR_UTILITIES, 7, resourceManager, "mokylinsparkutilities", "invalid.argument.message", ["WorkCalendar.standardWorkBetween", "t1 > t2"]);
            }
            if (TimeUtil.areOnSameDay(t1, t2))
            {
                return this.standardWorkBetweenDatesOnSameDay(t1, t2);
            }
            return this.standardWorkBetweenDifferentDates(t1, t2);
        }

        private function standardWorkBetweenDatesOnSameDay(t1:Date, t2:Date):Number
        {
            var dowPeriod:DayOfWeekPeriod = this.getDayOfWeekPeriod(t1);
            return dowPeriod.workBetween(t1, t2);
        }

        private function standardWorkBetweenDifferentDates(t1:Date, t2:Date):Number
        {
            var duration:Number;
            var dowPeriod:DayOfWeekPeriod = this.getDayOfWeekPeriod(t1);
            var startDate:Date = this.calendar.floor(t1, TimeUnit.DAY, 1);
            var endDate:Date = this.calendar.floor(t2, TimeUnit.DAY, 1);
            var nextDay:Date = this.calendar.addUnits(startDate, TimeUnit.DAY, 1, false);
            nextDay = this.calendar.floor(nextDay, TimeUnit.DAY, 1);
            var current:Date = new Date(nextDay.time);
            duration = dowPeriod.workBetween(t1, current);
            var nbday:Number = TimeUtil.getDays((endDate.time - current.time));
            var weeks:Number = Math.floor((nbday / 7));
            if (weeks != 0)
            {
                duration = duration + (weeks * this.workInOneWeek);
                current = this.calendar.addUnits(current, TimeUnit.WEEK, weeks, true);
                current = this.calendar.floor(current, TimeUnit.DAY, 1);
            }
            while (current < endDate)
            {
                nextDay = this.calendar.addUnits(current, TimeUnit.DAY, 1, false);
                nextDay = this.calendar.floor(nextDay, TimeUnit.DAY, 1);
                dowPeriod = this.getDayOfWeekPeriod(current);
                duration = duration + dowPeriod.workBetween(current, nextDay);
                current.time = nextDay.time;
            }
            if (t2 > current)
            {
                dowPeriod = this.getDayOfWeekPeriod(current);
                duration = duration + dowPeriod.workBetween(current, t2);
            }
            return duration;
        }

        private function get workInOneWeek():Number
        {
            var duration:Number = 0;
            var i:int;
            while (i < 7)
            {
                duration = (duration + this.getDayOfWeekPeriodForDay(i).workInOneDay);
                i++;
            }
            return duration;
        }

        private function nextPeriod(t:Date):Period
        {
            var p:Period;
            var count:uint = this._periods.length;
            if (count == 0)
            {
                return null;
            }
            var i:uint;
            while (i < count)
            {
                p = this._periods[i];
                if (t <= p.endDateAndTime)
                {
                    return p;
                }
                i++;
            }
            return null;
        }

        private function previousPeriod(t:Date):Period
        {
            var p:Period;
            var count:int = this._periods.length;
            if (count == 0)
            {
                return null;
            }
            var i:int = count - 1;
            while (i >= 0)
            {
                p = this._periods[i];
                if (t > p.startDate)
                {
                    return p;
                }
                i--;
            }
            return null;
        }

        private function dayOfWeekHasDefaultSetting(dayOfWeek:int):Boolean
        {
            var dowPeriod:DayOfWeekPeriod = this.getDayOfWeekPeriodForDay(dayOfWeek);
            var defaultIsNonworking:Boolean = getDefaultNonWorkingDays().indexOf(dayOfWeek) != -1;
            return defaultIsNonworking ? !dowPeriod.isWorking : (dowPeriod.isWorking && periodHasDefaultWorkingTimes(dowPeriod));
        }

        private function onChanged():void
        {
            var subs:Vector.<WorkCalendar>;
            var count:uint;
            var i:int;
            var sub:WorkCalendar;
            this._nextNonWorkingTimeCache = null;
            this._nextWorkingTimeCache = null;
            this._previousWorkingTimeCache = null;
            this._workBetweenCache = null;
            if (this._disableEvents)
            {
                return;
            }
            if (this._subCalendars != null)
            {
                subs = this._subCalendars.slice(0);
                count = subs.length;
                i = (count - 1);
                while (i >= 0)
                {
                    sub = subs[i];
                    if (sub != null)
                    {
                        sub.onBaseCalendarChanged();
                    }
                    else
                    {
                        this._subCalendars.splice(i, 1);
                    }
                    i--;
                }
            }
            dispatchEvent(new Event(Event.CHANGE));
        }

        private function onBaseCalendarChanged():void
        {
            this.inheritBasePeriods();
            this.onChanged();
        }

        private function inheritBasePeriods():void
        {
            var oldPeriods:Vector.<Period>;
            var p:Period;
            var p2:Period;
            var a:Period;
            var wt:Vector.<WorkingTime>;
            try
            {
                try
                {
                    this._disableEvents = true;
                    oldPeriods = this._periods.slice(0);
                    this._periods.splice(0, this._periods.length);
                    for each (p in this._baseCalendar._periods)
                    {
                        a = Period(p.clone());
                        a.isInherited = true;
                        this._periods.push(a);
                    }
                    for each (p2 in oldPeriods)
                    {
                        if (!(p2.isInherited))
                        {
                            if (!(p2.isWorking))
                            {
                                this.setNonWorkingPeriod(p2.startDate, p2.endDate);
                            }
                            else
                            {
                                wt = p2.workingTimes.slice(0);
                                this.setPeriodWorkingTimes(p2.startDate, p2.endDate, wt);
                            }
                        }
                    }
                }
                finally
                {
                }
            }
            finally
            {
                this._disableEvents = false;
            }
            return;
            //not popped:
//            -1  
        }

        private function assertNotReadOnly():void
        {
            if (this.isPredefinedCalendar)
            {
                ResourceUtil.logAndThrowError(WorkCalendar, ResourceUtil.ELIXIR_UTILITIES, 8, resourceManager, "mokylinsparkutilities", "cannot.modify.readonly.calendar.message");
            }
        }

        private function getDayOfWeekPeriod(time:Date):DayOfWeekPeriod
        {
            return this.getDayOfWeekPeriodForDay(time.day);
        }

        private function getDayOfWeekPeriodBackward(time:Date):DayOfWeekPeriod
        {
            var dow:int;
            if (TimeUtil.getTimeOfDayInMillis(time) == 0)
            {
                dow = (time.day - 1);
                if (dow == -1)
                {
                    dow = 6;
                }
                return this.getDayOfWeekPeriodForDay(dow);
            }
            return this.getDayOfWeekPeriodForDay(time.day);
        }

        private function getDayOfWeekPeriodForDay(day:int):DayOfWeekPeriod
        {
            var dowPeriod:DayOfWeekPeriod = this._daysOfWeek[day];
            if (dowPeriod == null && !this.isBaseCalendar)
            {
                dowPeriod = this._baseCalendar.getDayOfWeekPeriodForDay(day);
            }
            return dowPeriod;
        }

        private function getPeriod(time:Date):Period
        {
            var p:Period;
            var count:uint = this._periods.length;
            if (count == 0)
            {
                return null;
            }
            var i:uint;
            while (i < count)
            {
                p = this._periods[i];
                if (time >= p.startDate)
                {
                    if (time < p.endDateAndTime)
                    {
                        return p;
                    }
                }
                else
                {
                    break;
                }
                i++;
            }
            return null;
        }

        private function getPeriodBackward(time:Date):Period
        {
            var p:Period;
            var count:uint = this._periods.length;
            if (count == 0)
            {
                return null;
            }
            var i:uint;
            while (i < count)
            {
                p = this._periods[i];
                if (time > p.startDate)
                {
                    if (time.time <= p.endDateAndTime.time)
                    {
                        return p;
                    }
                }
                else
                {
                    break;
                }
                i++;
            }
            return null;
        }

		public function getCalendarPeriod(time:Date):CalendarPeriodBase
        {
            var p:CalendarPeriodBase = this.getPeriod(time);
            return p == null ? this.getDayOfWeekPeriodForDay(time.day) : p;
        }

        public function getWorkingTimeForUnit(unit:TimeUnit, steps:Number):Number
        {
            var ratioOfWeek:Number = ((unit.milliseconds / TimeUnit.WEEK.milliseconds) * steps);
            if (ratioOfWeek >= 1)
            {
                return ratioOfWeek * this.workInOneWeek;
            }
            switch (unit)
            {
                case TimeUnit.MILLISECOND:
                    return steps;
                case TimeUnit.SECOND:
                    return steps * unit.milliseconds;
                case TimeUnit.MINUTE:
                    return steps * unit.milliseconds;
                case TimeUnit.HOUR:
                    return steps * unit.milliseconds;
                case TimeUnit.HOUR_CALENDAR:
                    return steps * unit.milliseconds;
                case TimeUnit.DAY:
                    return steps * this.getMinWorkingTimePerDay();
            }
            return 0;
        }

        private function getMinWorkingTimePerDay():Number
        {
            var minWorkingTime:Number;
            var dowPeriod:DayOfWeekPeriod;
            var workInOneDay:Number;
            var i:int;
            while (i < 7)
            {
                dowPeriod = this.getDayOfWeekPeriodForDay(i);
                if (!dowPeriod.isWorking)
                {
                }
                else
                {
                    workInOneDay = dowPeriod.workInOneDay;
                    if (isNaN(minWorkingTime) || workInOneDay < minWorkingTime)
                    {
                        minWorkingTime = workInOneDay;
                    }
                }
                i++;
            }
            return minWorkingTime;
        }

        private function getWorkingTimeForUnitInDay(unit:TimeUnit, steps:Number):Number
        {
            var minDuration:Number;
            var maxDuration:Number;
            var dowPeriod:DayOfWeekPeriod;
            var workingTimes:Vector.<WorkingTime>;
            var count:uint;
            var j:uint;
            var workingTime:WorkingTime;
            var duration:Number;
            var precisionInMillis:Number = (unit.milliseconds * steps);
            var i:int;
            while (i < 7)
            {
                dowPeriod = this.getDayOfWeekPeriodForDay(i);
                workingTimes = dowPeriod.workingTimes;
                count = workingTimes.length;
                j = 0;
                while (j < count)
                {
                    workingTime = workingTimes[j];
                    duration = workingTime.duration;
                    if (isNaN(minDuration) || duration < minDuration)
                    {
                        minDuration = duration;
                    }
                    if (isNaN(maxDuration) || duration > maxDuration)
                    {
                        maxDuration = duration;
                    }
                    j++;
                }
                i++;
            }
            if (minDuration >= (2 * precisionInMillis))
            {
                return unit.milliseconds;
            }
            if (maxDuration >= (2 * precisionInMillis))
            {
                return unit.milliseconds;
            }
            return maxDuration;
        }
    }
}
