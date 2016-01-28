package mokylin.utils
{
    [ExcludeClass]
    public class LinkedListNode 
    {
        public var value:Object;
        public var next:LinkedListNode;
        public var previous:LinkedListNode;

        public function LinkedListNode(value:Object)
        {
            this.previous = (this.next = null);
            this.value = value;
        }
    }
}
