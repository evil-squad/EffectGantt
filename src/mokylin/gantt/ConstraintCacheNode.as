package mokylin.gantt
{
    import __AS3__.vec.Vector;

    [ExcludeClass]
    public class ConstraintCacheNode 
    {

        private static const MaxObjects:int = 1000;

        private var _parent:ConstraintCacheNode;
        private var _fromIndex:int;
        private var _toIndex:int;
        private var _objects:Vector.<ConstraintDescriptor>;
        private var _top:ConstraintCacheNode;
        private var _bottom:ConstraintCacheNode;
        private var _divided:Boolean;

        public function ConstraintCacheNode(parent:ConstraintCacheNode, from:int, to:int)
        {
            this._parent = parent;
            this._fromIndex = from;
            this._toIndex = to;
        }

        private function get count():int
        {
            return this._objects ? this._objects.length : 0;
        }

        public function getInRange(from:int, to:int, constraints:Array):void
        {
            var cd:ConstraintDescriptor;
            if (this._top && from <= this._top._toIndex)
            {
                this._top.getInRange(from, to, constraints);
            }
            if (this._bottom && to >= this._bottom._fromIndex)
            {
                this._bottom.getInRange(from, to, constraints);
            }
            var length:int = this.count;
            var i:int;
            while (i < length)
            {
                cd = ConstraintDescriptor(this._objects[i]);
                if (cd._to >= from && cd._from <= to)
                {
                    constraints.push(cd._constraint);
                }
                i++;
            }
        }

        public function getInRangeStrict(from:int, to:int, constraints:Array):void
        {
            var cd:ConstraintDescriptor;
            if (this._top && from <= this._top._toIndex)
            {
                this._top.getInRangeStrict(from, to, constraints);
            }
            if (this._bottom && to >= this._bottom._fromIndex)
            {
                this._bottom.getInRangeStrict(from, to, constraints);
            }
            var length:int = this.count;
            var i:int;
            while (i < length)
            {
                cd = ConstraintDescriptor(this._objects[i]);
                if (cd._to <= to && cd._from >= from)
                {
                    constraints.push(cd._constraint);
                }
                i++;
            }
        }

        public function getOverRangeBoundaries(from:int, to:int, constraints:Array):void
        {
            var cd:ConstraintDescriptor;
            if (this._top && from <= this._top._toIndex)
            {
                this._top.getOverRangeBoundaries(from, to, constraints);
            }
            if (this._bottom && to >= this._bottom._fromIndex)
            {
                this._bottom.getOverRangeBoundaries(from, to, constraints);
            }
            var length:int = this.count;
            var i:int;
            while (i < length)
            {
                cd = ConstraintDescriptor(this._objects[i]);
                if (cd._from >= from && cd._from <= to && cd._to > to)
                {
                    constraints.push(cd._constraint);
                }
                else if (cd._from < from && cd._to >= from && cd._to <= to)
				{
					constraints.push(cd._constraint);
				}
                i++;
            }
        }

        private function divide():void
        {
            var objs:Vector.<ConstraintDescriptor>;
            var descriptor:ConstraintDescriptor;
            this._divided = true;
            if (this.count != 0)
            {
                objs = this._objects;
                this._objects = null;
                for each (descriptor in objs)
                {
                    this.addDescriptor(descriptor, true);
                }
            }
        }

        public function add(obj:ConstraintItem, from:int, to:int):void
        {
            this.addDescriptor(new ConstraintDescriptor(obj, from, to), false);
        }

        private function addDescriptor(obj:ConstraintDescriptor, dividing:Boolean):void
        {
            var middle:int;
            if (!dividing && this.count < MaxObjects && !this._divided)
            {
                this.addImpl(obj);
            }
            else
            {
                if ((this._toIndex - this._fromIndex) >= 5)
                {
                    if (!dividing && !this._divided)
                    {
                        this.divide();
                    }
                    middle = ((this._fromIndex + this._toIndex) / 2);
                    if (obj._from > middle)
                    {
                        if (!this._bottom)
                        {
                            this._bottom = new ConstraintCacheNode(this, (middle + 1), this._toIndex);
                        }
                        this._bottom.addDescriptor(obj, false);
                    }
                    else if (obj._to <= middle)
					{
						if (!this._top)
						{
							this._top = new ConstraintCacheNode(this, this._fromIndex, middle);
						}
						this._top.addDescriptor(obj, false);
					}
					else
					{
						this.addImpl(obj);
					}
                }
                else
                {
                    this.addImpl(obj);
                }
            }
        }

        private function addImpl(obj:ConstraintDescriptor):void
        {
            if (!this._objects)
            {
                this._objects = new Vector.<ConstraintDescriptor>();
            }
            this._objects.push(obj);
        }

        public function remove(obj:ConstraintItem, from:int, to:int):void
        {
            var length:int;
            var i:int;
            var descriptor:ConstraintDescriptor;
            if (this._top && from >= this._top._fromIndex && to <= this._top._toIndex)
            {
                this._top.remove(obj, from, to);
            }
            else if (this._bottom && from >= this._bottom._fromIndex && to <= this._bottom._toIndex)
			{
				this._bottom.remove(obj, from, to);
			}
			else
			{
				length = this.count;
				i = 0;
				while (i < length)
				{
					descriptor = ConstraintDescriptor(this._objects[i]);
					if (descriptor._constraint == obj)
					{
						this._objects.splice(i, 1);
						this.clean();
						break;
					}
					i++;
				}
			}
        }

        private function clean():void
        {
            if (this.count != 0)
            {
                return;
            }
            this._objects = null;
            if (!this._top && !this._bottom && this._parent)
            {
                if (this._parent._top == this)
                {
                    this._parent._top = null;
                }
                else if (this._parent._bottom == this)
				{
					this._parent._bottom = null;
				}
                this._parent.clean();
            }
        }
    }
}