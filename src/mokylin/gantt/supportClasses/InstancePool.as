package mokylin.gantt.supportClasses
{
    import mx.core.IFactory;
	/**
	 * 对象池 
	 * @author neil
	 * 
	 */
    [ExcludeClass]
    public class InstancePool 
    {
        protected var _factory:IFactory;
        protected var _unusedInstances:Array;

        public function InstancePool(factory:IFactory)
        {
            this._unusedInstances = new Array();
            super();
            this._factory = factory;
        }

        public function getInstance():Object
        {
            var instance:Object;
            if (this._unusedInstances.length > 0)
            {
                instance = this._unusedInstances.pop();
                this.instanceReused(instance);
            }
            else
            {
                instance = this._factory.newInstance();
                this.instanceCreated(instance);
            }
            return instance;
        }

		/**
		 * 重复利用 
		 * @param instance
		 * 
		 */		
        public function recycle(instance:Object):void
        {
            this._unusedInstances.push(instance);
            this.instanceRecycled(instance);
        }

        public function recycleAll(instances:Array):void
        {
            var instance:Object;
            this._unusedInstances = this._unusedInstances.concat(instances);
            for each (instance in instances)
            {
                this.instanceRecycled(instance);
            }
        }

        public function clear():void
        {
            var instance:Object;
            for each (instance in this._unusedInstances)
            {
                this.instanceRemoved(instance);
            }
            this._unusedInstances = new Array();
        }

        protected function instanceCreated(value:Object):void
        {
        }

        protected function instanceReused(value:Object):void
        {
        }

        protected function instanceRecycled(value:Object):void
        {
        }

        protected function instanceRemoved(value:Object):void
        {
        }
    }
}
