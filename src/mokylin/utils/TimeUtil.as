package mokylin.utils
{
    public class TimeUtil 
    {
		public static const MINIMUM_TIME:Number = 0;
		public static const MAXIMUM_TIME:Number = 1000000;
        public static const SUNDAY:int = 0;
        public static const MONDAY:int = 1;
        public static const TUESDAY:int = 2;
        public static const WEDNESDAY:int = 3;
        public static const THURSDAY:int = 4;
        public static const FRIDAY:int = 5;
        public static const SATURDAY:int = 6;
        private static const dayMilliseconds:Number = TimeUnit.DAY.milliseconds;
        private static const hourMilliseconds:Number = TimeUnit.HOUR.milliseconds;
        private static const minutesMilliseconds:Number = TimeUnit.MINUTE.milliseconds;
        private static const secondsMilliseconds:Number = TimeUnit.SECOND.milliseconds;

//        private static var _defaultGregorianCalendar:GregorianCalendar = new GregorianCalendar();


        public static function bound(time:Number, minValue:Number, maxValue:Number):Number
        {
            if (time < minValue)
            {
                return minValue;
            }
            if (time > maxValue)
            {
                return maxValue;
            }
            return time;
        }

		/**
		 * 一天最开始的那个时刻的数据 
		 * @param time
		 * @return 
		 * 
		 */		
        public static function startOfDay(time:Date):Date
        {
            time.hours = 0;
            time.minutes = 0;
            time.seconds = 0;
            time.milliseconds = 0;
            return time;
        }

		/**
		 * 一天最后一个时刻的数据 
		 * @param time
		 * @return 
		 * 
		 */		
        public static function endOfDay(time:Date):Date
        {
            time.hours = 23;
            time.minutes = 59;
            time.seconds = 59;
            time.milliseconds = 999;
            return time;
        }

        public static function getDate(value:Object):Date
        {
            if (value is Date)
            {
                return value as Date;
            }
            if (value)
            {
                return new Date(String(value));
            }
            return null;
        }

		/**
		 * 获得这个时间的总毫秒数 
		 * @param hours
		 * @param minutes
		 * @param seconds
		 * @param milliseconds
		 * @return 
		 * 
		 */		
        public static function getTimeInMillis(hours:Number, minutes:Number=0, seconds:Number=0, milliseconds:Number=0):Number
        {
            return hours * hourMilliseconds + minutes * minutesMilliseconds + seconds * secondsMilliseconds + milliseconds;
        }
		/**
		 * 比较2个日期，是否是在同一天 
		 * @param d1
		 * @param d2
		 * @return 
		 * 
		 */
		public static function areOnSameDay(d1:Date, d2:Date):Boolean
        {
            var startOf_d1:Date = new Date(d1.fullYear, d1.month, d1.date);
            var endOf_d1:Date = new Date(d1.fullYear, d1.month, d1.date, 24);
            return d2 >= startOf_d1 && d2 <= endOf_d1;
        }
		/**
		 * 北京时间 某天已经过去的毫秒数
		 * @param value
		 * @return 
		 * 
		 */
		public static function getTimeOfDayInMillis(value:Date):Number
        {
            var adjustedMillis:Number = value.time - (value.timezoneOffset * TimeUnit.MINUTE.milliseconds);
            var result:Number = adjustedMillis % TimeUnit.DAY.milliseconds;
            if (result < 0)
            {
                result = result + TimeUnit.DAY.milliseconds;
            }
            return result;
        }
		/**
		 * 设置某天 的某个时刻
		 * @param date
		 * @param timeOfDay
		 * @return 
		 * 
		 */
		public static function setTimeOfDayInMillis(date:Date, timeOfDay:Number):Date
        {
            var initialTimezoneOffset:Number = date.timezoneOffset;
            var initialTimeOfDay:Number = getTimeOfDayInMillis(date);//已经过去的毫秒数
            date.time = date.time + timeOfDay - initialTimeOfDay;
            var timezoneOffset:Number = date.timezoneOffset;
            if (timezoneOffset != initialTimezoneOffset)
            {
                date.time = date.time + (timezoneOffset - initialTimezoneOffset) * TimeUnit.MINUTE.milliseconds;
            }
            return date;
        }

		/**
		 * 多少天 
		 * @param milliseconds
		 * @return 
		 * 
		 */		
		public static function getDays(milliseconds:Number):Number
        {
            return Math.floor(milliseconds / dayMilliseconds);
        }
		/**
		 * 获得最小的那个日期 
		 * @param date1
		 * @param date2
		 * @return 
		 * 
		 */
		public static function min(date1:Date, date2:Date):Date
        {
            return date1 < date2 ? date1 : date2;
        }
		/**
		 * 获得最大的那个日期 
		 * @param date1
		 * @param date2
		 * @return 
		 * 
		 */
		public static function max(date1:Date, date2:Date):Date
        {
            return date1 > date2 ? date1 : date2;
        }
		/**
		 * 多少个小时 
		 * @param milliseconds
		 * @return 
		 * 
		 */
		public static function getTotalHours(milliseconds:Number):Number
        {
            return milliseconds / hourMilliseconds;
        }
    }
}
