package mokylin.utils
{
    import flash.utils.Dictionary;

    [ExcludeClass]
    public class LRUCache 
    {

        private var _dictionary:Dictionary;
        private var _list:LinkedList;
        private var _size:uint;

        public function LRUCache(size:uint=0x0100)
        {
            this._dictionary = new Dictionary();
            this._list = new LinkedList();
            super();
            this._size = size;
        }

        public function getData(key:Object):Object
        {
            var node:LinkedListNode = (this._dictionary[key] as LinkedListNode);
            if (node == null)
            {
                return null;
            }
            this._list.removeCell(node);
            this._list.appendCell(node);
            return node.value.value;
        }

        public function add(key:Object, value:Object):void
        {
            if (this._list.count > this._size)
            {
                this._dictionary[this._list.head.value.key] = null;
                this._list.removeCell(this._list.head);
            }
            this._dictionary[key] = this._list.append({
                "key":key,
                "value":value
            });
        }
    }
}
