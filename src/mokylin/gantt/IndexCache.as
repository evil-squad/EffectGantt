package mokylin.gantt
{
    import mx.collections.ICollectionView;
    import mx.collections.IViewCursor;
    import mx.controls.listClasses.ListBaseSeekPending;
    import mx.events.CollectionEvent;
    import mx.core.EventPriority;
    import mx.events.CollectionEventKind;
    import mx.utils.UIDUtil;
    import mx.collections.CursorBookmark;
    import mx.collections.errors.ItemPendingError;
    import mx.collections.ItemResponder;

    [ExcludeClass]
    public class IndexCache 
    {

        private var _valid:Boolean;
        private var _map:Object;
        private var _collection:ICollectionView;
        private var _cursor:IViewCursor;
        private var _count:uint;
        private var _lastSeekPending:ListBaseSeekPending;


        public function set collection(value:ICollectionView):void
        {
            if (this._collection)
            {
                this._collection.removeEventListener(CollectionEvent.COLLECTION_CHANGE, this.collectionChangeHandler);
            }
            this._collection = value;
            this._cursor = null;
            if (this._collection)
            {
                this._collection.addEventListener(CollectionEvent.COLLECTION_CHANGE, this.collectionChangeHandler, false, (EventPriority.BINDING + 1));
            }
            this.invalidate();
        }

        private function collectionChangeHandler(event:CollectionEvent):void
        {
            if (event.kind == CollectionEventKind.UPDATE)
            {
                return;
            }
            this.invalidate();
        }

        public function getCount():uint
        {
            this.validate();
            return this._count;
        }

        public function getIndex(item:Object):int
        {
            this.validate();
            var uid:String = this.itemToUID(item);
            var o:* = this._map[uid];
            if (o !== undefined)
            {
                return int(o);
            }
            return -1;
        }

        public function invalidate():void
        {
            this._valid = false;
            this._map = null;
            this._count = 0;
        }

        public function itemToUID(item:Object):String
        {
            return UIDUtil.getUID(item);
        }

        public function validate():void
        {
            if (this._valid)
            {
                return;
            }
            if (!this._cursor && this._collection)
            {
                this._cursor = this._collection.createCursor();
            }
            this._map = {};
            if (!this._cursor)
            {
                return;
            }
            try
            {
                this._cursor.seek(CursorBookmark.FIRST, 0);
            }
            catch(e:ItemPendingError)
            {
                _lastSeekPending = new ListBaseSeekPending(CursorBookmark.FIRST, 0);
                e.addResponder(new ItemResponder(seekPendingResultHandler, seekPendingFailureHandler, _lastSeekPending));
            }
            this.validateLoop(0);
        }

        private function validateLoop(index:int):void
        {
            try
            {
                while (!this._cursor.afterLast)
                {
                    this._map[this.itemToUID(this._cursor.current)] = index;
                    index = (index + 1);
                    if (!this._cursor.moveNext())
                    {
                        break;
                    }
                }
                this._count = index;
                this._valid = true;
            }
            catch(e:ItemPendingError)
            {
                e.addResponder(new ItemResponder(validatePendingResultHandler, validatePendingFaultHandler, new ListBaseSeekPending(_cursor.bookmark, index)));
            }
        }

        private function validatePendingResultHandler(data:Object, info:ListBaseSeekPending):void
        {
            this._cursor.seek(info.bookmark, info.offset);
            this.validateLoop(info.offset);
        }

        private function validatePendingFaultHandler(data:Object, info:ListBaseSeekPending):void
        {
        }

        private function seekPendingResultHandler(data:Object, info:ListBaseSeekPending):void
        {
            if (info != this._lastSeekPending)
            {
                return;
            }
            this._lastSeekPending = null;
            try
            {
                this._cursor.seek(info.bookmark, info.offset);
            }
            catch(e:ItemPendingError)
            {
                _lastSeekPending = new ListBaseSeekPending(info.bookmark, info.offset);
                e.addResponder(new ItemResponder(seekPendingResultHandler, seekPendingFailureHandler, _lastSeekPending));
            }
        }

        private function seekPendingFailureHandler(data:Object, info:ListBaseSeekPending):void
        {
        }
    }
}
