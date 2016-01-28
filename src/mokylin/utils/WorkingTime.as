package mokylin.utils
{
    import mx.resources.ResourceManager;
    
    import __AS3__.vec.Vector;

	/**
	 * 一天的时间 
	 * @author neil
	 * 
	 */
    public class WorkingTime 
    {

        public var endTime:Number;
        public var startTime:Number = 0;

        public function WorkingTime()
        {
            this.endTime = TimeUnit.DAY.milliseconds;
            super();
        }

        public static function createWorkingTime(start:Number, end:Number):WorkingTime
        {
            var wt:WorkingTime = new WorkingTime();
            wt.startTime = start;
            wt.endTime = end == 0 ? TimeUnit.DAY.milliseconds : end;
            wt.checkWorkingTime();
            return wt;
        }

        public static function copyWorkingTimes(source:Vector.<WorkingTime>):Vector.<WorkingTime>
        {
            if (source == null)
            {
                return new Vector.<WorkingTime>();
            }
            var newTimes:Vector.<WorkingTime> = source.slice(0);
            var count:uint = newTimes.length;
            var i:uint;
            while (i < count)
            {
                newTimes[i] = newTimes[i].clone();
                i++;
            }
            return newTimes;
        }

        public static function sameWorkingTimes(a:Vector.<WorkingTime>, b:Vector.<WorkingTime>):Boolean
        {
            if (a == b)
            {
                return true;
            }
            if (a == null || b == null)
            {
                return false;
            }
            var count:uint = a.length;
            if (b.length != count)
            {
                return false;
            }
            var i:uint;
            while (i < count)
            {
                if (!a[i].equals(b[i]))
                {
                    return false;
                }
                i++;
            }
            return true;
        }


        public function get duration():Number
        {
            return this.endTime - this.startTime;
        }

        public function get end():String
        {
            return this.convertTimeToString(this.endTime);
        }

        public function set end(value:String):void
        {
            this.endTime = this.parseTime(value);
        }

        public function get start():String
        {
            return this.convertTimeToString(this.startTime);
        }

        public function set start(value:String):void
        {
            this.startTime = this.parseTime(value);
        }

        public function clone():WorkingTime
        {
            return createWorkingTime(this.startTime, this.endTime);
        }

        private function convertTimeToString(time:Number):String
        {
            var hours:Number = Math.floor(time / TimeUnit.HOUR.milliseconds);
            time = time - (hours * TimeUnit.HOUR.milliseconds);
            if (time == 0)
            {
                return this.formatNumber(hours) + ":00";
            }
            var minutes:Number = Math.floor(time / TimeUnit.MINUTE.milliseconds);
            time = time - (minutes * TimeUnit.MINUTE.milliseconds);
            if (time == 0)
            {
                return this.formatNumber(hours) + ":" + this.formatNumber(minutes);
            }
            var seconds:Number = Math.floor(time / TimeUnit.SECOND.milliseconds);
            time = time - (seconds * TimeUnit.SECOND.milliseconds);
            if (time == 0)
            {
                return this.formatNumber(hours) + ":" + this.formatNumber(minutes) + ":" + this.formatNumber(seconds);
            }
            return this.formatNumber(hours) + ":" + this.formatNumber(minutes) + ":" + this.formatNumber(seconds) + ":" + this.formatNumber(time, 3);
        }

        private function formatNumber(n:Number, digits:uint=2):String
        {
            var s:String = "00" + n.toString();
            return s.substring(s.length - digits);
        }

        private function parseTime(value:String):Number
        {
            var values:Array = value.split(":");
            switch (values.length)
            {
                case 1:
                    return TimeUtil.getTimeInMillis(parseInt(String(values[0])));
                case 2:
                    return TimeUtil.getTimeInMillis(parseInt(String(values[0])), parseInt(String(values[1])));
                case 3:
                    return TimeUtil.getTimeInMillis(parseInt(String(values[0])), parseInt(String(values[1])), parseInt(String(values[2])));
                case 4:
                    return TimeUtil.getTimeInMillis(parseInt(String(values[0])), parseInt(String(values[1])), parseInt(String(values[2])), parseInt(String(values[3])));
                default:
                    ResourceUtil.logAndThrowError(WorkingTime, ResourceUtil.ELIXIR_UTILITIES, 7, ResourceManager.getInstance(), "mokylinsparkutilities", "invalid.argument.message", ["WorkingTime.parseTime", "value"]);
                    return NaN;
            }
        }

        public function checkWorkingTime():void
        {
            if (this.startTime >= this.endTime)
            {
                ResourceUtil.logAndThrowError(WorkingTime, ResourceUtil.ELIXIR_UTILITIES, 7, ResourceManager.getInstance(), "mokylinsparkutilities", "invalid.argument.message", ["WorkingTime.checkWorkingTime", "startTime >= endTime"]);
            }
            if (this.startTime > TimeUnit.DAY.milliseconds)
            {
                ResourceUtil.logAndThrowError(WorkingTime, ResourceUtil.ELIXIR_UTILITIES, 7, ResourceManager.getInstance(), "mokylinsparkutilities", "invalid.argument.message", ["WorkingTime.checkWorkingTime", "startTime > TimeUnit.DAY.milliseconds"]);
            }
            if (this.endTime > TimeUnit.DAY.milliseconds)
            {
                ResourceUtil.logAndThrowError(WorkingTime, ResourceUtil.ELIXIR_UTILITIES, 7, ResourceManager.getInstance(), "mokylinsparkutilities", "invalid.argument.message", ["WorkingTime.checkWorkingTime", "endTime > TimeUnit.DAY.milliseconds"]);
            }
        }

        public function equals(other:WorkingTime):Boolean
        {
            return other != null && this.startTime == other.startTime && this.endTime == other.endTime;
        }
    }
}