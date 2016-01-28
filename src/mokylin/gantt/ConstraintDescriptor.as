package mokylin.gantt
{
    import mokylin.gantt.ConstraintItem;

    [ExcludeClass]
    public class ConstraintDescriptor 
    {
        public var _constraint:ConstraintItem;
        public var _from:int;
        public var _to:int;

        public function ConstraintDescriptor(constraint:ConstraintItem, from:int, to:int)
        {
            this._constraint = constraint;
            this._from = from;
            this._to = to;
        }
    }
}
