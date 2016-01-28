package mokylin.gantt
{
    import mokylin.gantt.TaskChart;
    import mx.collections.ICollectionView;
    import mx.collections.IViewCursor;
    import mokylin.gantt.GanttSheet;
    import mokylin.gantt.ConstraintItem;
    import mx.collections.errors.ItemPendingError;
    import mx.collections.ItemResponder;
    import mx.messaging.messages.ErrorMessage;
    import mx.collections.CursorBookmark;
    import mokylin.gantt.*;

    [ExcludeClass]
    public class ConstraintsCache 
    {

        private var _valid:Boolean;
        private var _root:ConstraintCacheNode;
        private var _taskChart:TaskChart;
        private var _oldConstraintCollection:ICollectionView;
        private var _constraintCursor:IViewCursor;
        private var _lastPendingInfo:Object;


        public function set taskChart(value:TaskChart):void
        {
            this._taskChart = value;
            this.invalidate();
        }

        private function get ganttSheet():GanttSheet
        {
            return this._taskChart.ganttSheet;
        }

        private function get rowController():IRowController
        {
            return this._taskChart.rowController;
        }

        public function remove(item:Object):void
        {
            if (!this._valid)
            {
                return;
            }
            var constraintItem:ConstraintItem = this.ganttSheet.itemToConstraintItem(item);
            if (constraintItem)
            {
                this.removeConstraintItem(constraintItem);
            }
        }

        private function removeConstraintItem(constraintItem:ConstraintItem):void
        {
            var fromIndex:int;
            var toIndex:int;
            try
            {
                fromIndex = this.rowController.getItemIndex(constraintItem.fromTask);
                if (fromIndex == -1)
                {
                    return;
                }
                toIndex = this.rowController.getItemIndex(constraintItem.toTask);
                if (toIndex == -1)
                {
                    return;
                }
                if (fromIndex < toIndex)
                {
                    this._root.remove(constraintItem, fromIndex, toIndex);
                }
                else
                {
                    this._root.remove(constraintItem, toIndex, fromIndex);
                }
            }
            catch(pending:ItemPendingError)
            {
                pending.addResponder(new ItemResponder(removeConstraintItemPendingResultHandler, removeConstraintItemPendingFailureHandler, {"constraintItem":constraintItem}));
            }
        }

        private function removeConstraintItemPendingResultHandler(result:Object, info:Object):void
        {
            this.removeConstraintItem(info.constraintItem);
        }

        private function removeConstraintItemPendingFailureHandler(error:ErrorMessage, info:Object):void
        {
        }

        public function add(item:Object):void
        {
            if (!this._valid)
            {
                return;
            }
            var constraintItem:ConstraintItem = this.ganttSheet.itemToConstraintItem(item);
            if (constraintItem)
            {
                this.addConstraintItem(constraintItem);
            }
        }

        private function addConstraintItem(constraintItem:ConstraintItem):void
        {
            var fromIndex:int;
            var toIndex:int;
            try
            {
                fromIndex = this.rowController.getItemIndex(constraintItem.fromTask);
                if (fromIndex == -1)
                {
                    return;
                }
                toIndex = this.rowController.getItemIndex(constraintItem.toTask);
                if (toIndex == -1)
                {
                    return;
                }
                if (fromIndex < toIndex)
                {
                    this._root.add(constraintItem, fromIndex, toIndex);
                }
                else
                {
                    this._root.add(constraintItem, toIndex, fromIndex);
                }
            }
            catch(pending:ItemPendingError)
            {
                pending.addResponder(new ItemResponder(addConstraintItemPendingResultHandler, addConstraintItemPendingFailureHandler, {"constraintItem":constraintItem}));
            }
        }

        private function addConstraintItemPendingResultHandler(result:Object, info:Object):void
        {
            this.addConstraintItem(info.constraintItem);
        }

        private function addConstraintItemPendingFailureHandler(error:ErrorMessage, info:Object):void
        {
        }

        public function invalidate():void
        {
            this._valid = false;
            this._root = null;
            this._lastPendingInfo = null;
        }

        public function getInRange(from:int, to:int):Array
        {
            this.validate();
            var constraints:Array = [];
            this._root.getInRange(from, to, constraints);
            return constraints;
        }

        public function getInRangeStrict(from:int, to:int):Array
        {
            this.validate();
            var constraints:Array = [];
            this._root.getInRangeStrict(from, to, constraints);
            return constraints;
        }

        public function getOverRangeBoundaries(from:int, to:int):Array
        {
            this.validate();
            var constraints:Array = [];
            this._root.getOverRangeBoundaries(from, to, constraints);
            return constraints;
        }

        public function validate():void
        {
            var itemCount:int;
            if (this._valid)
            {
                return;
            }
            this._lastPendingInfo = null;
            try
            {
                itemCount = this.rowController.getItemCount();
                this._root = new ConstraintCacheNode(null, 0, itemCount);
            }
            catch(pending:ItemPendingError)
            {
                pending.addResponder(new ItemResponder(validatePendingResultHandler, validatePendingFailureHandler));
                throw pending;
            }
            var constraints:ICollectionView = ICollectionView(this._taskChart.constraintDataProvider);
            if (constraints != this._oldConstraintCollection)
            {
                this._oldConstraintCollection = constraints;
                this._constraintCursor = null;
            }
            if (!constraints)
            {
                return;
            }
            if (!this._constraintCursor)
            {
                this._constraintCursor = constraints.createCursor();
            }
            try
            {
                this._constraintCursor.seek(CursorBookmark.FIRST);
            }
            catch(pending:ItemPendingError)
            {
                pending.addResponder(new ItemResponder(validatePendingResultHandler, validatePendingFailureHandler));
                throw pending;
            }
            this.validateLoop();
        }

        private function validatePendingResultHandler(data:Object, token:Object=null):void
        {
            try
            {
                this.validate();
            }
            catch(error:ItemPendingError)
            {
            }
        }

        private function validatePendingFailureHandler(info:Object, token:Object=null):void
        {
        }

        private function validateLoop():void
        {
            var item:Object;
            var constraintItem:ConstraintItem;
            var fromIndex:int;
            var toIndex:int;
            try
            {
                while (!(this._constraintCursor.afterLast))
                {
                    item = this._constraintCursor.current;
                    constraintItem = this.ganttSheet.itemToConstraintItem(item);
                    if (constraintItem)
                    {
                        fromIndex = this.rowController.getItemIndex(constraintItem.fromTask);
                        if (fromIndex >= 0)
                        {
                            toIndex = this.rowController.getItemIndex(constraintItem.toTask);
                            if (toIndex >= 0)
                            {
                                if (fromIndex < toIndex)
                                {
                                    this._root.add(constraintItem, fromIndex, toIndex);
                                }
                                else
                                {
                                    this._root.add(constraintItem, toIndex, fromIndex);
                                }
                            }
                        }
                    }
                    this._constraintCursor.moveNext();
                }
                this._lastPendingInfo = null;
                this._valid = true;
            }
            catch(pending:ItemPendingError)
            {
                _lastPendingInfo = {};
                pending.addResponder(new ItemResponder(validateLoopPendingResultHandler, validateLoopPendingFailureHandler, _lastPendingInfo));
                throw pending;
            }
        }

        private function validateLoopPendingResultHandler(data:Object, token:Object=null):void
        {
            if (token != this._lastPendingInfo)
            {
                return;
            }
            try
            {
                this.validateLoop();
            }
            catch(error:ItemPendingError)
            {
            }
        }

        private function validateLoopPendingFailureHandler(info:Object, token:Object=null):void
        {
        }
    }
}
