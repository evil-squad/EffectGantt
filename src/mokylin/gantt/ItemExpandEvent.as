package mokylin.gantt
{
    import flash.events.Event;

    public class ItemExpandEvent extends Event 
    {

        public static const START:String = "animatedItemExpandStart";
		public static const END:String = "animatedItemExpandEnd";
		public static const STEP:String = "animatedItemExpandStep";

        public var item:Object;
		public var itemChildren:Array;
		public var offset:Number;
		public var open:Boolean;

        public function ItemExpandEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, item:Object=null, itemChildren:Array=null, offset:Number=0, open:Boolean=false)
        {
            super(type, false, false);
            this.item = item;
            this.itemChildren = itemChildren;
            this.offset = offset;
            this.open = open;
        }

        override public function clone():Event
        {
            return new ItemExpandEvent(type, bubbles, cancelable, this.item, this.itemChildren, this.offset, this.open);
        }
    }
}
