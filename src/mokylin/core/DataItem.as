package mokylin.core
{
    import flash.events.EventDispatcher;
    import mx.core.IUIComponent;
	import mokylin.utils.*;

    public class DataItem extends EventDispatcher 
    {

        private var _owner:IUIComponent;
        private var _data:Object;

        public function DataItem(owner:IUIComponent, data:Object)
        {
            this._owner = owner;
            this._data = data;
        }

        public function get owner():IUIComponent
        {
            return this._owner;
        }

        public function get data():Object
        {
            return this._data;
        }

        protected function getFieldValue(field:Object, defaultValue:Object=null, fieldFunction:Function=null):Object
        {
            return DataUtil.getFieldValue(this._data, field, defaultValue, fieldFunction);
        }
    }
}