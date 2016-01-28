package mokylin.gantt
{
    import flash.events.Event;

    public class TimeScaleEvent extends Event 
    {
        public static const SCALE_CHANGE:String = "scaleChange";

        public var adjusting:Boolean;

        public function TimeScaleEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }

        override public function clone():Event
        {
            var event:TimeScaleEvent = new TimeScaleEvent(type, bubbles, cancelable);
            return event;
        }
    }
}
