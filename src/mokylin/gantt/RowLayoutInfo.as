package mokylin.gantt
{
    [ExcludeClass]
    public class RowLayoutInfo 
    {

        public var item:Object;
        public var height:Number;
        public var y:Number;
        public var invalidDistribution:Boolean;//n. 分布；分配
        public var invalidSize:Boolean;
        public var laneCount:uint;
        public var laneHeight:Number;
        public var minTaskHeight:Number;
        public var minHeight:Number;

        public function RowLayoutInfo()
        {
            this.clear();
        }

        final public function hasValidHeightAndPosition():Boolean
        {
            return !isNaN(this.height) && !isNaN(this.y);
        }

        final public function clear():void
        {
            this.item = null;
            this.height = NaN;
            this.minHeight = NaN;
            this.y = NaN;
            this.invalidDistribution = true;
            this.invalidSize = true;
            this.minTaskHeight = NaN;
            this.laneHeight = NaN;
            this.laneCount = 0;
        }
    }
}
