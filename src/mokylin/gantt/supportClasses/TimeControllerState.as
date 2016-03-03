package mokylin.gantt.supportClasses
{
    [ExcludeClass]
    public final class TimeControllerState 
    {
		public var nowTime:Number;
        public var endTime:Number;
        public var startTime:Number;
        public var zoomFactor:Number;

        public function TimeControllerState(nowTime:Number,endTime:Number, startTime:Number, zoomFactor:Number)
        {
			this.nowTime = nowTime;
            this.endTime = endTime;
            this.startTime = startTime;
            this.zoomFactor = zoomFactor;
        }

        public function equals(other:Object):Boolean
        {
            if (other == this)
            {
                return true;
            }
            if (!(other is TimeControllerState))
            {
                return false;
            }
            var otherState:TimeControllerState = TimeControllerState(other);
            return this.startTime == otherState.startTime
				&& this.endTime == otherState.endTime 
				&& this.zoomFactor == otherState.zoomFactor;
//				&& this.nowTime == otherState.nowTime
        }
		
		public function equalsNowTime(other:Object):Boolean
		{
			if (other == this)
			{
				return true;
			}
			if (!(other is TimeControllerState))
			{
				return false;
			}
			var otherState:TimeControllerState = TimeControllerState(other);
			return this.nowTime == otherState.nowTime;
		}
    }
}
