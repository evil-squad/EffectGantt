package mokylin.utils
{
    import flash.events.EventDispatcher;
    import mx.resources.IResourceManager;
    import mx.resources.ResourceManager;
    import flash.events.Event;

    [ResourceBundle("mokylinsparkutilities")]
    [ResourceBundle("controls")]
    [Event(name="change", type="flash.events.Event")]
    public class GregorianCalendar extends EventDispatcher 
    {

        private static const DAYS_OF_THE_YEAR_OFFSET:Array = [0, 
															31, //1月
															31 + 28, //1月+2月
															31 + 28 + 31, //1月+2月+3月
															31 + 28 + 31 + 30, //1月+2月+3月+4月
															31 + 28 + 31 + 30 + 31,//1月+2月+3月+4月+5月
															31 + 28 + 31 + 30 + 31 + 30,//1月+2月+3月+4月+5月+6月
															31 + 28 + 31 + 30 + 31 + 30 + 31, //1月+2月+3月+4月+5月+6月 + 7月
															31 + 28 + 31 + 30 + 31 + 30 + 31 + 31,//1月+2月+3月+4月+5月+6月 +7月+8月
															31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30, //1月+2月+3月+4月+5月+6月 +7月+8月+9月
															31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31, //1月+2月+3月+4月+5月+6月 +7月+8月+9月+10月
															31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31 + 30];//1月+2月+3月+4月+5月+6月 +7月+8月+9月+10月+11月
		/**
		 * 每月所有的天数 
		 */		
        private static const DAYS_IN_MONTH:Array = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

        private static var _defaultReferenceDate:Date;
		/**
		 * 不同地区的时差，比如中国北京时差是8小时，就是480分钟 
		 */		
        private static var _oldDefaultReferenceTimezoneOffset:Number;

        private var _resourceManager:IResourceManager;
        private var _firstDayOfWeek:Object;
        private var _firstDayOfWeekOverride:Object;
        private var _minimalDaysInFirstWeek:Object;
        private var _minimalDaysInFirstWeekOverride:Object;
        private var _previousStartOfYear:Date;
        private var _previousStartOfYearOffset:Number;

        public function GregorianCalendar()
        {
            this._resourceManager = ResourceManager.getInstance();
            this._resourceManager.addEventListener(Event.CHANGE, this.handleResourcesChanged, false, 0, true);
            this.resourcesChanged();
        }

        private static function getDefaultReferenceDate():Date
        {
            if (_defaultReferenceDate == null || _defaultReferenceDate.timezoneOffset != _oldDefaultReferenceTimezoneOffset)
            {
                _defaultReferenceDate = new Date(2016, 0, 1, 0, 0, 0, 0);
                _oldDefaultReferenceTimezoneOffset = _defaultReferenceDate.timezoneOffset;
            }
            return _defaultReferenceDate;
        }


        [Bindable("change")]
        public function get firstDayOfWeek():Object
        {
            return this._firstDayOfWeek;
        }

        public function set firstDayOfWeek(value:Object):void
        {
            this._firstDayOfWeekOverride = value;
            this._firstDayOfWeek = value!=null ? int(value) : this._resourceManager.getInt("controls", "firstDayOfWeek");
            dispatchEvent(new Event(Event.CHANGE));
        }

        [Bindable("change")]
        public function get minimalDaysInFirstWeek():Object
        {
            return this._minimalDaysInFirstWeek;
        }

        public function set minimalDaysInFirstWeek(value:Object):void
        {
            this._minimalDaysInFirstWeekOverride = value;
            this._minimalDaysInFirstWeek = value!=null ? int(value) : this._resourceManager.getInt("mokylinsparkutilities", "minimal.days.in.first.week");
            dispatchEvent(new Event(Event.CHANGE));
        }

        public function floor(time:Date, unit:TimeUnit, steps:Number, referenceDate:Date=null):Date
        {
            switch (unit)
            {
                case TimeUnit.MILLISECOND:
                    return this.floorToMillisecond(time, steps, referenceDate);
                case TimeUnit.SECOND:
                    return this.floorToSecond(time, steps, referenceDate);
                case TimeUnit.MINUTE:
                    return this.floorToMinute(time, steps, referenceDate);
                case TimeUnit.HOUR:
                    return this.floorToHour(time, steps, referenceDate);
                case TimeUnit.HOUR_CALENDAR:
                    return this.floorToHourCalendar(time, steps, referenceDate);
                case TimeUnit.DAY:
                    return this.floorToDay(time, steps, referenceDate);
                case TimeUnit.WEEK:
                    return this.floorToWeek(time, steps, referenceDate);
                case TimeUnit.MONTH:
                    return this.floorToMonth(time, steps, referenceDate);
                case TimeUnit.QUARTER:
                    return this.floorToMonth(time, (steps * 3), referenceDate);
                case TimeUnit.HALFYEAR:
                    return this.floorToMonth(time, (steps * 6), referenceDate);
                case TimeUnit.YEAR:
                    return this.floorToYear(time, steps, referenceDate);
                case TimeUnit.DECADE:
                    return this.floorToYear(time, (steps * 10), referenceDate);
                default:
                    throw new Error(ResourceUtil.getError(ResourceUtil.ELIXIR_UTILITIES, 4, ResourceManager.getInstance(), "mokylinsparkutilities", "unknown.timeunit", [unit]));
            }
        }

        public function round(time:Date, unit:TimeUnit, steps:Number, referenceDate:Date=null):Date
        {
            return this.floor(new Date(time.time + (unit.milliseconds * steps) / 2), unit, steps, referenceDate);
        }

        private function floorToMillisecond(time:Date, steps:Number, referenceDate:Date):Date
        {
            var millisecondsOffset:Number;
            if (referenceDate == null)
            {
                referenceDate = getDefaultReferenceDate();
            }
            var millisecondsSinceReference:Number = this.getElapsedMilliseconds(referenceDate, time);
            if (referenceDate.time < time.time)
            {
                millisecondsOffset = steps * Math.floor(millisecondsSinceReference / steps);
            }
            else if (referenceDate.time == time.time)
			{
				millisecondsOffset = 0;
			}
			else
			{
				millisecondsOffset = -steps * (1 + Math.floor(-millisecondsSinceReference / steps));
			}
            return new Date(referenceDate.time + millisecondsOffset);
        }

        private function floorToSecond(time:Date, steps:Number, referenceDate:Date):Date
        {
            var secondsOffset:Number;
            if (referenceDate == null)
            {
                referenceDate = getDefaultReferenceDate();
            }
            var secondsSinceReference:Number = this.getElapsedSeconds(referenceDate, time);
            if (referenceDate.time < time.time)
            {
                secondsOffset = steps * Math.floor(secondsSinceReference / steps);
            }
            else if (referenceDate.milliseconds == time.milliseconds)
			{
				secondsOffset = steps * Math.floor(secondsSinceReference / steps);
			}
			else
			{
				secondsOffset = -steps * (1 + Math.floor(-secondsSinceReference / steps));
			}
            return new Date(referenceDate.time + secondsOffset * TimeUnit.SECOND.milliseconds);
        }

        private function floorToMinute(time:Date, steps:Number, referenceDate:Date):Date
        {
            var minutesOffset:Number;
            if (referenceDate == null)
            {
                referenceDate = getDefaultReferenceDate();
            }
            var minutesSinceReference:Number = this.getElapsedMinutes(referenceDate, time);
            if (referenceDate.time < time.time)
            {
                minutesOffset = steps * Math.floor(minutesSinceReference / steps);
            }
            else if (referenceDate.seconds == time.seconds && referenceDate.milliseconds == time.milliseconds)
			{
				minutesOffset = steps * Math.floor(minutesSinceReference / steps);
			}
			else
			{
				minutesOffset = -steps * (1 + Math.floor(-minutesSinceReference / steps));
			}
            return new Date(referenceDate.time + (minutesOffset * TimeUnit.MINUTE.milliseconds));
        }

        private function floorToHour(time:Date, steps:Number, referenceDate:Date):Date
        {
            var hours:Number;
            if (referenceDate == null)
            {
                referenceDate = getDefaultReferenceDate();
            }
            var hoursSinceReference:Number = this.getElapsedHours(referenceDate, time);
            if (referenceDate.time < time.time)
            {
                hours = referenceDate.hours + (steps * Math.floor(hoursSinceReference / steps));
            }
            else if (referenceDate.minutes == time.minutes && referenceDate.seconds == time.seconds && referenceDate.milliseconds == time.milliseconds)
			{
				hours = (referenceDate.hours + (steps * Math.floor((hoursSinceReference / steps))));
			}
			else
			{
				hours = (referenceDate.hours - (steps * (1 + Math.floor((-(hoursSinceReference) / steps)))));
			}
            return new Date(referenceDate.time + (hours * TimeUnit.HOUR.milliseconds));
        }

        private function floorToHourCalendar(time:Date, steps:Number, referenceDate:Date):Date
        {
            if (referenceDate == null)
            {
                referenceDate = getDefaultReferenceDate();
            }
            var hours:Number = (referenceDate.hours + time.hours) - (time.hours % steps);
            return new Date(time.fullYear, time.month, time.date, hours, referenceDate.minutes, referenceDate.seconds, referenceDate.milliseconds);
        }

        private function floorToDay(time:Date, steps:Number, referenceDate:Date):Date
        {
            if (steps == 1 && referenceDate == null)
            {
                return new Date(time.fullYear, time.month, time.date);
            }
            return this.floorToDayWithReferenceDate(time, steps, referenceDate);
        }

        private function floorToDayWithReferenceDate(time:Date, steps:Number, referenceDate:Date):Date
        {
            var dayOfMonth:Number;
            var daysSinceReference:Number;
            if (referenceDate == null)
            {
                referenceDate = getDefaultReferenceDate();
            }
            if (steps == 1)
            {
                return new Date(time.fullYear, time.month, time.date, referenceDate.hours, referenceDate.minutes, referenceDate.seconds, referenceDate.milliseconds);
            }
            daysSinceReference = this.getElapsedDays(referenceDate, time);
            if (referenceDate.time < time.time)
            {
                dayOfMonth = (referenceDate.date + (steps * Math.floor((daysSinceReference / steps))));
            }
            else if (referenceDate.hours == time.hours && referenceDate.minutes == time.minutes && referenceDate.seconds == time.seconds && referenceDate.milliseconds == time.milliseconds)
			{
				dayOfMonth = (referenceDate.date + (steps * Math.floor((daysSinceReference / steps))));
			}
			else
			{
				dayOfMonth = (referenceDate.date - (steps * (1 + Math.floor((-(daysSinceReference) / steps)))));
			}
            return new Date(referenceDate.fullYear, referenceDate.month, dayOfMonth, referenceDate.hours, referenceDate.minutes, referenceDate.seconds, referenceDate.milliseconds);
        }

        private function floorToWeek(time:Date, steps:Number, referenceDate:Date):Date
        {
            var result:Date;
            var week:Number = this.getWeek(time);
            var targetWeek:Number = week - (week - 1) % steps;
            if (targetWeek < 1)
            {
                targetWeek = 1;
            }
            var dayOffset:Number = 7 * (week - targetWeek) + this.getRelativeDayOfWeek(time);
            if (referenceDate == null)
            {
                result = new Date(time.fullYear, time.month, time.date);
                return this.addDays(result, -dayOffset, true);
            }
            return new Date(time.fullYear, time.month, (time.date - dayOffset), referenceDate.hours, referenceDate.minutes, referenceDate.seconds, referenceDate.milliseconds);
        }

        private function floorToMonth(time:Date, steps:Number, referenceDate:Date):Date
        {
            var month:Number;
            if (referenceDate == null)
            {
                referenceDate = getDefaultReferenceDate();
            }
            var monthsSinceReference:Number = this.getElapsedMonths(referenceDate, time);
            if (referenceDate.time < time.time)
            {
                month = (referenceDate.month + (steps * Math.floor((monthsSinceReference / steps))));
            }
            else if (referenceDate.date == time.date && referenceDate.hours == time.hours && referenceDate.minutes == time.minutes && referenceDate.seconds == time.seconds && referenceDate.milliseconds == time.milliseconds)
			{
				month = referenceDate.month + (steps * Math.floor(monthsSinceReference / steps));
			}
			else
			{
				month = referenceDate.month - (steps * (1 + Math.floor(-monthsSinceReference / steps)));
			}
            return (new Date(referenceDate.fullYear, month, referenceDate.date, referenceDate.hours, referenceDate.minutes, referenceDate.seconds, referenceDate.milliseconds));
        }

        private function floorToYear(time:Date, steps:Number, referenceDate:Date):Date
        {
            if (steps == 1 && referenceDate == null)
            {
                return new Date(time.fullYear, 0, 1);
            }
            return this.floorToYearWithReferenceDate(time, steps, referenceDate);
        }

        private function floorToYearWithReferenceDate(time:Date, steps:Number, referenceDate:Date):Date
        {
            var year:Number;
            if (referenceDate == null)
            {
                referenceDate = getDefaultReferenceDate();
            }
            var yearsSinceReference:Number = this.getElapsedYears(referenceDate, time);
            if (referenceDate.time < time.time)
            {
                year = referenceDate.fullYear + (steps * Math.floor((yearsSinceReference / steps)));
            }
            else if (referenceDate.month == time.month && referenceDate.date == time.date && referenceDate.hours == time.hours && referenceDate.minutes == time.minutes && referenceDate.seconds == time.seconds && referenceDate.milliseconds == time.milliseconds)
			{
				year = referenceDate.fullYear + (steps * Math.floor((yearsSinceReference / steps)));
			}
			else
			{
				year = referenceDate.fullYear - (steps * (1 + Math.floor((-yearsSinceReference / steps))));
			}
            return new Date(year, referenceDate.month, referenceDate.date, referenceDate.hours, referenceDate.minutes, referenceDate.seconds, referenceDate.milliseconds);
        }

        public function addUnits(time:Date, unit:TimeUnit, count:Number, reuse:Boolean=false):Date
        {
            switch (unit)
            {
                case TimeUnit.MILLISECOND:
                case TimeUnit.SECOND:
                case TimeUnit.MINUTE:
                case TimeUnit.HOUR:
                    return this.addConstantUnits(time, unit, count, reuse);
                case TimeUnit.HOUR_CALENDAR:
                    return this.addHoursCalendar(time, count, reuse);
                case TimeUnit.DAY:
                    return this.addDays(time, count, reuse);
                case TimeUnit.WEEK:
                    return this.addDays(time, (count * 7), reuse);
                case TimeUnit.MONTH:
                    return this.addMonths(time, count, reuse);
                case TimeUnit.QUARTER:
                    return this.addMonths(time, (count * 3), reuse);
                case TimeUnit.HALFYEAR:
                    return this.addMonths(time, (count * 6), reuse);
                case TimeUnit.YEAR:
                    return this.addYears(time, count, reuse);
                case TimeUnit.DECADE:
                    return this.addYears(time, (count * 10), reuse);
                default:
                    throw new Error(ResourceUtil.getError(ResourceUtil.ELIXIR_UTILITIES, 4, ResourceManager.getInstance(), "mokylinsparkutilities", "unknown.timeunit", [unit]));
            }
        }

        private function addConstantUnits(time:Date, unit:TimeUnit, count:Number, reuse:Boolean):Date
        {
            if (reuse)
            {
                time.time = time.time + unit.milliseconds * count;
                return time;
            }
            return new Date(time.time + unit.milliseconds * count);
        }

        private function addHoursCalendar(time:Date, count:Number, reuse:Boolean):Date
        {
            var result:Date = reuse ? time : new Date(time.time);
            result.hours = result.hours + count;
            return result;
        }
		/**
		 * 加一天的毫秒数 
		 * @param time
		 * @param count
		 * @param reuse
		 * @return 
		 * 
		 */
        private function addDays(time:Date, count:Number, reuse:Boolean):Date
        {
            var result:Date = reuse ? time : new Date(time.time);
            var initialTimezoneOffset:Number = result.timezoneOffset;
            result.time = result.time + (count * TimeUnit.DAY.milliseconds);
            var finalTimezoneOffset:Number = result.timezoneOffset;
            if (finalTimezoneOffset != initialTimezoneOffset)
            {
                result.time = result.time + (finalTimezoneOffset - initialTimezoneOffset) * TimeUnit.MINUTE.milliseconds;
            }
            return result;
        }

        private function addMonths(time:Date, count:Number, reuse:Boolean):Date
        {
            var result:Date = reuse ? time : new Date(time.time);
            result.month = result.month + count;
            return result;
        }

        private function addYears(time:Date, count:Number, reuse:Boolean):Date
        {
            var result:Date = reuse ? time : new Date(time.time);
            result.fullYear = result.fullYear + count;
            return result;
        }

        public function getWeek(value:Date, referenceDate:Date=null):Number
        {
            var minimalDaysInFirstWeek:Number = this.minimalDaysInFirstWeek as Number;
            var lastDayOfWeek:Date = this.getLastDayOfWeek(value);
            var startOfYear:Date = this.floorToYear(lastDayOfWeek, 1, referenceDate);
            if (this.getDays(startOfYear, lastDayOfWeek) + 1 < minimalDaysInFirstWeek)
            {
                startOfYear = this.addYears(startOfYear, -1, true);
            }
            var lastDayOfFirstWeek:Date = this.addDays(startOfYear, (minimalDaysInFirstWeek - 1), false);
            lastDayOfFirstWeek = this.getLastDayOfWeek(lastDayOfFirstWeek, true);
            return 1 + Math.round((lastDayOfWeek.time - lastDayOfFirstWeek.time) / TimeUnit.WEEK.milliseconds);
        }

        public function getDaysInYear(year:Number):Number
        {
            return this.isLeapYear(year) ? 366 : 365;
        }

        public function getDayOfYear(value:Date):Number
        {
            var month:uint = value.month;
            var dayOfTheYear:Number = DAYS_OF_THE_YEAR_OFFSET[month] + value.date;
            if (month > 1 && this.isLeapYear(value.fullYear))
            {
                dayOfTheYear = dayOfTheYear + 1;
            }
            return dayOfTheYear;
        }

        public function getHoursInDay(value:Date):Number
        {
            var midnight:Date = this.floor(value, TimeUnit.DAY, 1);
            return Math.floor((value.time - midnight.time) / TimeUnit.HOUR.milliseconds);
        }

        public function getQuarter(value:Date):Number
        {
            return Math.floor(value.month / 3) + 1;
        }

        public function getHalfYear(value:Date):Number
        {
            return value.month < 6 ? 1 : 2;
        }

        public function getDecade(value:Date):Number
        {
            return Math.floor(value.fullYear / 10);
        }
		/**
		 * 是否是闰年 
		 * @param value
		 * @return 
		 * 
		 */
        public function isLeapYear(value:Number):Boolean
        {
            if (value % 400 == 0)
            {
                return true;
            }
            if (value % 100 == 0)
            {
                return false;
            }
            if (value % 4 == 0)
            {
                return true;
            }
            return false;
        }

		/**
		 * 获得一个月中有多少天 
		 * @param month
		 * @param year
		 * @return 
		 * 
		 */		
        public function getDaysInMonth(month:Number, year:Number):Number
        {
            var daysInMonth:Number = DAYS_IN_MONTH[month];
            if (month == 1 && this.isLeapYear(year))
            {
                daysInMonth = daysInMonth + 1;
            }
            return daysInMonth;
        }

		/**
		 * 2个日期之间的天数
		 * 比如2015-1-1 到 2016-1-1，中间有365天 
		 * @param fromDate
		 * @param toDate
		 * @return 
		 * 
		 */		
        public function getDays(fromDate:Date, toDate:Date):Number
        {
            var days:Number;
            var tmp:Date;
            if (fromDate > toDate)
            {
                tmp = fromDate;
                fromDate = toDate;
                toDate = tmp;
            }
            days = this.getDayOfYear(toDate) - this.getDayOfYear(fromDate);
            var toYear:Number = toDate.fullYear;
            var y:Number = fromDate.fullYear;
            while (y < toYear)
            {
                days = days + this.getDaysInYear(y);
                y++;
            }
            return days;
        }

        public function getUnitValue(time:Date, unit:TimeUnit, startOfYear:Date=null):Number
        {
            if (startOfYear == null)
            {
                return this.getPredefinedUnitValue(time, unit);
            }
            return this.getShiftedUnitValue(time, unit, startOfYear);
        }

		public function getPredefinedUnitValue(time:Date, unit:TimeUnit):Number
        {
            switch (unit)
            {
                case TimeUnit.MILLISECOND:
                    return time.milliseconds;
                case TimeUnit.SECOND:
                    return time.seconds;
                case TimeUnit.MINUTE:
                    return time.minutes;
                case TimeUnit.HOUR:
                    return this.getHoursInDay(time);
                case TimeUnit.HOUR_CALENDAR:
                    return time.hours;
                case TimeUnit.DAY:
                    return time.date;
                case TimeUnit.WEEK:
                    return this.getWeek(time);
                case TimeUnit.MONTH:
                    return time.month;
                case TimeUnit.QUARTER:
                    return this.getQuarter(time);
                case TimeUnit.HALFYEAR:
                    return this.getHalfYear(time);
                case TimeUnit.YEAR:
                    return time.fullYear;
                case TimeUnit.DECADE:
                    return this.getDecade(time);
                default:
                    throw new Error(ResourceUtil.getError(ResourceUtil.ELIXIR_UTILITIES, 4, ResourceManager.getInstance(), "mokylinsparkutilities", "unknown.timeunit", [unit]));
            }
        }

        private function getShiftedUnitValue(date:Date, unit:TimeUnit, startOfYear:Date):Number
        {
            var shiftedTime:Number;
            var startOfYear1999:Date;
            var january1_1999:Date;
            if (unit == TimeUnit.WEEK)
            {
                return this.getWeek(date, startOfYear);
            }
            if (this._previousStartOfYear == null || this._previousStartOfYear.time != startOfYear.time)
            {
                this._previousStartOfYear = new Date(startOfYear);
                startOfYear1999 = new Date(1999, startOfYear.month, startOfYear.date);
                january1_1999 = new Date(1999, 0, 1);
                this._previousStartOfYearOffset = startOfYear1999.time - january1_1999.time;
            }
            shiftedTime = date.time - this._previousStartOfYearOffset;
            if (this.isLeapYear(date.fullYear) && date.month > 1)
            {
                shiftedTime = shiftedTime - (24 * 3600) * 1000;
            }
            return this.getPredefinedUnitValue(new Date(shiftedTime), unit);
        }

        public function getElapsedUnits(fromDate:Date, toDate:Date, unit:TimeUnit):Number
        {
            switch (unit)
            {
                case TimeUnit.MILLISECOND:
                    return this.getElapsedMilliseconds(fromDate, toDate);
                case TimeUnit.SECOND:
                    return this.getElapsedSeconds(fromDate, toDate);
                case TimeUnit.MINUTE:
                    return this.getElapsedMinutes(fromDate, toDate);
                case TimeUnit.HOUR:
                    return this.getElapsedHours(fromDate, toDate);
                case TimeUnit.HOUR_CALENDAR:
                    return this.getElapsedCalendarHours(fromDate, toDate);
                case TimeUnit.DAY:
                    return this.getElapsedDays(fromDate, toDate);
                case TimeUnit.WEEK:
                    return this.getElapsedWeeks(fromDate, toDate);
                case TimeUnit.MONTH:
                    return this.getElapsedMonths(fromDate, toDate);
                case TimeUnit.QUARTER:
                    return this.getElapsedQuarters(fromDate, toDate);
                case TimeUnit.HALFYEAR:
                    return this.getElapsedHalfYears(fromDate, toDate);
                case TimeUnit.YEAR:
                    return this.getElapsedYears(fromDate, toDate);
                case TimeUnit.DECADE:
                    return this.getElapsedDecades(fromDate, toDate);
                default:
                    throw new Error("Unknown TimeUnit: " + TimeUnit);
            }
        }

		/**
		 * 返回2个时间段的差值 ---单位（毫秒）； 
		 * @param fromDate
		 * @param toDate
		 * @return 
		 * 
		 */		
		public function getElapsedMilliseconds(fromDate:Date, toDate:Date):Number
        {
            var tmp:Date;
            var positive:Boolean = true;
            if (fromDate > toDate)
            {
                tmp = fromDate;
                fromDate = toDate;
                toDate = tmp;
                positive = false;
            }
            var result:Number = toDate.time - fromDate.time;
            return positive ? result : -result;
        }

		/**
		 * 返回2个时间段的差值 ---单位（秒）； 
		 * @param fromDate
		 * @param toDate
		 * @return 
		 * 
		 */	
		public function getElapsedSeconds(fromDate:Date, toDate:Date):Number
        {
            var tmp:Date;
            var positive:Boolean = true;
            if (fromDate > toDate)
            {
                tmp = fromDate;
                fromDate = toDate;
                toDate = tmp;
                positive = false;
            }
            var elapsedMilliseconds:Number = toDate.time - fromDate.time;
            var result:Number = Math.floor(elapsedMilliseconds / 1000);
            return positive ? result : -result;
        }

		/**
		 * 返回2个时间段的差值 ---单位（分钟）； 
		 * @param fromDate
		 * @param toDate
		 * @return 
		 * 
		 */	
		public function getElapsedMinutes(fromDate:Date, toDate:Date):Number
        {
            var tmp:Date;
            var positive:Boolean = true;
            if (fromDate > toDate)
            {
                tmp = fromDate;
                fromDate = toDate;
                toDate = tmp;
                positive = false;
            }
            var elapsedMilliseconds:Number = (toDate.time - fromDate.time);
            var result:Number = Math.floor(elapsedMilliseconds / (60 * 1000));
            return positive ? result : -result;
        }

		/**
		 * 返回2个时间段的差值 ---单位（小时）； 
		 * @param fromDate
		 * @param toDate
		 * @return 
		 * 
		 */	
		public function getElapsedHours(fromDate:Date, toDate:Date):Number
        {
            var tmp:Date;
            var positive:Boolean = true;
            if (fromDate > toDate)
            {
                tmp = fromDate;
                fromDate = toDate;
                toDate = tmp;
                positive = false;
            }
            var elapsedMilliseconds:Number = toDate.time - fromDate.time;
            var result:Number = Math.floor(elapsedMilliseconds / (60 * 60 * 1000));
            return positive ? result : -result;
        }

		public function getElapsedCalendarHours(fromDate:Date, toDate:Date):Number
        {
            var tmp:Date;
            var positive:Boolean = true;
            if (fromDate > toDate)
            {
                tmp = fromDate;
                fromDate = toDate;
                toDate = tmp;
                positive = false;
            }
            var elapsedHours:Number = this.getElapsedHours(fromDate, toDate);
            var result:Number = elapsedHours;
            var timezoneDifferenceInMinutes:Number = toDate.timezoneOffset - fromDate.timezoneOffset;
            var timezoneDifferenceInHours:Number = Math.floor(timezoneDifferenceInMinutes / 60);
            result = result - timezoneDifferenceInHours;
            return positive ? result : -result;
        }

		public function getElapsedDays(fromDate:Date, toDate:Date):Number
        {
            var tmp:Date;
            var positive:Boolean = true;
            if (fromDate > toDate)
            {
                tmp = fromDate;
                fromDate = toDate;
                toDate = tmp;
                positive = false;
            }
            var elapsedMilliseconds:Number = toDate.time - fromDate.time + TimeUnit.MINUTE.milliseconds * (-toDate.timezoneOffset + fromDate.timezoneOffset);
            var result:Number = Math.floor(elapsedMilliseconds / TimeUnit.DAY.milliseconds);
            return positive ? result : -result;
        }

		public function getElapsedWeeks(fromDate:Date, toDate:Date):Number
        {
            var tmp:Date;
            var positive:Boolean = true;
            if (fromDate > toDate)
            {
                tmp = fromDate;
                fromDate = toDate;
                toDate = tmp;
                positive = false;
            }
            var elapsedDays:Number = this.getElapsedDays(fromDate, toDate);
            var result:Number = Math.floor(elapsedDays / 7);
            return positive ? result : -result;
        }

		public function getElapsedMonths(fromDate:Date, toDate:Date):Number
        {
            var tmp:Date;
            var positive:Boolean = true;
            if (fromDate > toDate)
            {
                tmp = fromDate;
                fromDate = toDate;
                toDate = tmp;
                positive = false;
            }
            var result:Number = 12 * (toDate.fullYear - fromDate.fullYear);
            result = result + toDate.month - fromDate.month;
            if (toDate.date < fromDate.date && toDate.date != this.getDaysInMonth(toDate.month, toDate.fullYear))
            {
                result = result - 1;
            }
            else if (toDate.date == fromDate.date && this.getTimeOfDayInMillis(toDate) < this.getTimeOfDayInMillis(fromDate))
			{
				result = result - 1;
			}
            return positive ? result : -result;
        }

		public function getElapsedQuarters(fromDate:Date, toDate:Date):Number
        {
            var tmp:Date;
            var positive:Boolean = true;
            if (fromDate > toDate)
            {
                tmp = fromDate;
                fromDate = toDate;
                toDate = tmp;
                positive = false;
            }
            var elapsedMonth:Number = this.getElapsedMonths(fromDate, toDate);
            var result:Number = Math.floor(elapsedMonth / 3);
            return positive ? result : -result;
        }

		public function getElapsedHalfYears(fromDate:Date, toDate:Date):Number
        {
            var tmp:Date;
            var positive:Boolean = true;
            if (fromDate > toDate)
            {
                tmp = fromDate;
                fromDate = toDate;
                toDate = tmp;
                positive = false;
            }
            var elapsedMonth:Number = this.getElapsedMonths(fromDate, toDate);
            var result:Number = Math.floor(elapsedMonth / 6);
            return positive ? result : -result;
        }

		public function getElapsedYears(fromDate:Date, toDate:Date):Number
        {
            var result:Number;
            var tmp:Date;
            var toDayOfLeapYear:Number;
            var fromDayOfLeapYear:Number;
            var positive:Boolean = true;
            if (fromDate > toDate)
            {
                tmp = fromDate;
                fromDate = toDate;
                toDate = tmp;
                positive = false;
            }
            if (fromDate.fullYear == toDate.fullYear)
            {
                result = 0;
            }
            else
            {
                result = toDate.fullYear - fromDate.fullYear;
                toDayOfLeapYear = this.getDayOfLeapYear(toDate);
                fromDayOfLeapYear = this.getDayOfLeapYear(fromDate);
                if (toDayOfLeapYear < fromDayOfLeapYear)
                {
                    result = result - 1;
                }
                else if (toDayOfLeapYear == fromDayOfLeapYear && this.getTimeOfDayInMillis(toDate) < this.getTimeOfDayInMillis(fromDate))
				{
					result = result - 1;
				}
            }
            return positive ? result : -result;
        }

        private function getDayOfLeapYear(value:Date):Number
        {
            var month:uint = uint(value.month);
            var dayOfTheYear:Number = DAYS_OF_THE_YEAR_OFFSET[month] + value.date;
            if (month > 1)
            {
                dayOfTheYear = dayOfTheYear + 1;
            }
            return dayOfTheYear;
        }

		public function getElapsedDecades(fromDate:Date, toDate:Date):Number
        {
            var tmp:Date;
            var positive:Boolean = true;
            if (fromDate > toDate)
            {
                tmp = fromDate;
                fromDate = toDate;
                toDate = tmp;
                positive = false;
            }
            var elapsedYears:Number = this.getElapsedYears(fromDate, toDate);
            var result:Number = Math.floor(elapsedYears / 10);
            return positive ? result : -result;
        }

		public function getLastDayOfWeek(value:Date, reuse:Boolean=false):Date
        {
            return this.addDays(value, 6 - this.getRelativeDayOfWeek(value), reuse);
        }

		public function getRelativeDayOfWeek(value:Date):Number
        {
            var rdow:Number = value.day - int(this.firstDayOfWeek);
            if (rdow < 0)
            {
                rdow = rdow + 7;
            }
            return rdow;
        }

        private function getTimeOfDayInMillis(value:Date):Number
        {
            return TimeUtil.getTimeOfDayInMillis(value);
        }

        private function handleResourcesChanged(event:Event):void
        {
            this.resourcesChanged();
        }

        private function resourcesChanged():void
        {
            this.firstDayOfWeek = this._firstDayOfWeekOverride;
            this.minimalDaysInFirstWeek = this._minimalDaysInFirstWeekOverride;
        }
    }
}