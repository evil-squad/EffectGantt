package mokylin.utils
{
	import flash.events.EventDispatcher;

	public class TimeComputer extends EventDispatcher
	{
		public function TimeComputer()
		{
		}
		
		public function ceil(time:Number, unit:TimeUnit, steps:Number):Number
		{
			switch (unit)
			{
				case TimeUnit.MILLISECOND:
					return floorToMillisecond(time, steps);
				case TimeUnit.SECOND:
					return floorToSecond(time, steps);
			}
			return time;
		}
		
		public function round(time:Number, unit:TimeUnit, steps:Number):Number
		{
			return this.floor(time + (unit.milliseconds * steps) / 2, unit, steps);
		}
		
		public function addUnits(time:Number, unit:TimeUnit, count:Number):Number
		{
			return time + unit.milliseconds * count;
		}
		
		public function floor(time:Number, unit:TimeUnit, steps:Number):Number
		{
			/*switch (unit)
			{
				case TimeUnit.MILLISECOND:
					return floorToMillisecond(time, steps);
				case TimeUnit.SECOND:
					return floorToSecond(time, steps);
				case TimeUnit.MINUTE:
					return floorToMinute(time, steps);
				case TimeUnit.HOUR:
					return floorToHour(time, steps);
			}*/
			return time;
		}
		
		private function floorToMillisecond(time:Number, steps:Number):Number
		{
			var millisecondsOffset:Number;
			
			millisecondsOffset = steps * Math.floor(time / steps);
			
			return millisecondsOffset;
		}
		
		private function floorToSecond(time:Number, steps:Number):Number
		{
			var secondsOffset:Number;

			secondsOffset = steps * Math.floor(time / steps);
			return  secondsOffset * TimeUnit.SECOND.milliseconds;
		}
	}
}