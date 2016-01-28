package mokylin.gantt
{
    public class ConstraintInfo 
    {
        public var path:Array;
        public var arrowDirection:String;

        public function ConstraintInfo(path:Array, arrowDirection:String)
        {
            this.path = path;
            this.arrowDirection = arrowDirection;
        }
    }
}
