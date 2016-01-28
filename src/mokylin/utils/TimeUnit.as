package mokylin.utils
{
    public class TimeUnit 
    {
		/**
		 * 毫秒 
		 */
        public static var MILLISECOND:TimeUnit = new TimeUnit("millisecond", 1);
		/**
		 * 秒  --- 1000
		 */		
        public static var SECOND:TimeUnit = new TimeUnit("second", 1000);
		/**
		 * 分钟  --- 60000
		 */		
        public static var MINUTE:TimeUnit = new TimeUnit("minute", 60 * 1000);
		/**
		 * 小时  --- 60 * 60000
		 */		
        public static var HOUR_CALENDAR:TimeUnit = new TimeUnit("hour (calendar)", 60 * MINUTE.milliseconds);
		/**
		 * 小时 --- 60 * 60000
		 */		
        public static var HOUR:TimeUnit = new TimeUnit("hour (elapsed)", 60 * MINUTE.milliseconds);
		/**
		 * 天 --- 24 * 60 * 60000
		 */		
        public static var DAY:TimeUnit = new TimeUnit("day", 24 * HOUR.milliseconds);
		/**
		 * 星期 
		 */		
        public static var WEEK:TimeUnit = new TimeUnit("week", 7 * DAY.milliseconds);
		/**
		 * 月 
		 */		
        public static var MONTH:TimeUnit = new TimeUnit("month", 31 * DAY.milliseconds);
		/**
		 * 季度 
		 */		
        public static var QUARTER:TimeUnit = new TimeUnit("quarter", (2 * 31 + 30) * DAY.milliseconds);
		/**
		 * 半年 
		 */		
        public static var HALFYEAR:TimeUnit = new TimeUnit("half-year", (4 * 31 + 2 * 30) * DAY.milliseconds);
		/**
		 * 一年 
		 */		
        public static var YEAR:TimeUnit = new TimeUnit("year", 366 * DAY.milliseconds);
		/**
		 * 十年
		 */		
        public static var DECADE:TimeUnit = new TimeUnit("decade", (8 * 366 + 2 * 365) * DAY.milliseconds);

        private var _milliseconds:Number;
        private var _name:String;

        public function TimeUnit(name:String, milliseconds:Number)
        {
            this._name = name;
            this._milliseconds = milliseconds;
        }

        final public function get milliseconds():Number
        {
            return this._milliseconds;
        }

        final public function get name():String
        {
            return this._name;
        }

        public function toString():String
        {
            return this._name;
        }
    }
}
