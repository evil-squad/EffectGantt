package mokylin.gantt
{
    [ExcludeClass]
    public class TaskLayoutInfo 
    {

        public var item:Object;
        public var y:Number;
        public var height:Number;
        public var laneIndex:uint;

        public function hasValidHeightAndPosition():Boolean
        {
            return !isNaN(this.height) && !isNaN(this.y);
        }
    }
}
