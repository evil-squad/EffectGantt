package mokylin.gantt.supportClasses
{
    [ExcludeClass]
    public final class TimeControllerState 
    {
        public var endTime:Number;
        public var startTime:Number;
        public var zoomFactor:Number;
        public var isHidingNonworkingTimes:Boolean;

        public function TimeControllerState(endTime:Number, startTime:Number, zoomFactor:Number, isHidingNonworkingTimes:Boolean)
        {
            this.endTime = endTime;
            this.startTime = startTime;
            this.zoomFactor = zoomFactor;
            this.isHidingNonworkingTimes = isHidingNonworkingTimes;
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
				&& this.zoomFactor == otherState.zoomFactor 
				&& this.isHidingNonworkingTimes == otherState.isHidingNonworkingTimes;
        }
    }
}
