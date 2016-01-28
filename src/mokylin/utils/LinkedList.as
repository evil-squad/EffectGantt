package mokylin.utils
{
    [ExcludeClass]
    public class LinkedList 
    {
        private var _count:uint;
        private var _tail:LinkedListNode;
        private var _head:LinkedListNode;

        public function LinkedList():void
        {
        }

        public function get count():uint
        {
            return this._count;
        }

        public function get head():LinkedListNode
        {
            return this._head;
        }

        public function get tail():LinkedListNode
        {
            return this._tail;
        }

        public function append(value:Object):LinkedListNode
        {
            var node:LinkedListNode = new LinkedListNode(value);
            this.appendCell(node);
            return node;
        }

        public function appendCell(node:LinkedListNode):void
        {
            if (this._head == null)
            {
                this._head = node;
            }
            else
            {
                this._tail.next = node;
                node.previous = this._tail;
            }
            this._tail = node;
            this._count++;
        }

        public function removeCell(node:LinkedListNode):void
        {
            var prev:LinkedListNode = node.previous;
            var next:LinkedListNode = node.next;
            if (node == this._head && node == this._tail)
            {
                this._head = (this._tail = null);
            }
            else
            {
                if (node == this._head)
                {
                    this._head = next;
                    this._head.previous = null;
                }
                else
                {
                    if (node == this._tail)
                    {
                        this._tail = prev;
                        this._tail.next = null;
                    }
                    else
                    {
                        next.previous = prev;
                        prev.next = next;
                    }
                }
            }
            node.previous = node.next = null;
            this._count--;
        }
    }
}
