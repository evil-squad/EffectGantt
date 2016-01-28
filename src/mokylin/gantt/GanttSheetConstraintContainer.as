package mokylin.gantt
{
    import mokylin.gantt.GanttSheetItemContainer;
    import flash.geom.Rectangle;
    import mokylin.gantt.GanttSheet;
    import flash.display.DisplayObject;
    import mokylin.gantt.TaskChart;
    import mokylin.gantt.ConstraintItem;
    import mx.collections.errors.ItemPendingError;
    import mx.collections.ItemResponder;
    import mx.core.IDataRenderer;
    import mx.styles.ISimpleStyleClient;
    import mx.core.IInvalidating;
    import mx.core.IProgrammaticSkin;
    import mokylin.gantt.ConstraintInfo;
    import flash.geom.Point;
    import mokylin.gantt.ConstraintKind;
    import mokylin.gantt.*;

    [ExcludeClass]
    public class GanttSheetConstraintContainer extends GanttSheetItemContainer 
    {

        private var _constraintToInfo:Object;
        private var _clipRectangle:Rectangle;
        private var _hiddenUIDs:Array;
        private var _hiddenUIDMap:Object;

        public function GanttSheetConstraintContainer(ganttSheet:GanttSheet)
        {
            this._constraintToInfo = {};
            this._hiddenUIDs = [];
            this._hiddenUIDMap = {};
            super(ganttSheet);
        }

        public function get clipRectangle():Rectangle
        {
            return this._clipRectangle;
        }

        public function set hiddenUIDs(value:Array):void
        {
            var uid:String;
            var renderer:DisplayObject;
            this._hiddenUIDs = value ? value : [];
            this._hiddenUIDMap = {};
            for each (uid in this._hiddenUIDs)
            {
                this._hiddenUIDMap[uid] = uid;
                renderer = _visibleItemRenderers[uid];
                if (renderer)
                {
                    recycleRenderer(renderer, uid);
                }
            }
        }

        override public function invalidateTaskItemsLayout(items:Array):void
        {
            var task:Object;
            var fromConstraints:Array;
            var toConstraints:Array;
            var taskChart:TaskChart = _ganttSheet.taskChart;
            if (!taskChart)
            {
                return;
            }
            var constraints:Array = [];
            for each (task in items)
            {
                fromConstraints = taskChart.getFromConstraints(task);
                toConstraints = taskChart.getToConstraints(task);
                if (fromConstraints)
                {
                    constraints = constraints.concat(fromConstraints);
                }
                if (toConstraints)
                {
                    constraints = constraints.concat(toConstraints);
                }
            }
            this.invalidateConstraintItemsLayout(constraints);
        }

        public function invalidateConstraintItemsLayout(items:Array):void
        {
            var constraint:Object;
            var uid:String;
            var constraintItem:ConstraintItem;
            var renderer:DisplayObject;
            for each (constraint in items)
            {
                uid = _ganttSheet.itemToUID(constraint);
                delete this._constraintToInfo[uid];
                constraintItem = _ganttSheet.itemToConstraintItem(constraint);
                renderer = _visibleItemRenderers[uid];
                if (this._hiddenUIDMap[uid] !== undefined)
                {
                    if (renderer)
                    {
                        recycleRenderer(renderer, uid);
                    }
                }
                else
                {
                    if (renderer)
                    {
                        this.updateConstraintRenderer(constraintItem, renderer);
                    }
                    else
                    {
                        if (this.isConstraintInRange(constraintItem))
                        {
                            renderer = createItemRenderer();
                            this.updateConstraintRenderer(constraintItem, renderer);
                            _visibleItemRenderers[uid] = renderer;
                        }
                    }
                }
            }
        }

        override protected function updateItemRenderers():void
        {
            var constraintItems:Array;
            var uid:String;
            var renderer:DisplayObject;
            var constraintItem:ConstraintItem;
            try
            {
                constraintItems = this.getVisibleConstraintItems();
            }
            catch(pending:ItemPendingError)
            {
                pending.addResponder(new ItemResponder(updateItemRenderersPendingResultHandler, updateItemRenderersPendingFailureHandler));
                return;
            }
            if (_sizeChanged || _itemsSizeChanged || _itemsPositionChanged)
            {
                this._constraintToInfo = {};
            }
            this._clipRectangle = new Rectangle(0, 0, unscaledWidth, unscaledHeight);
            this._clipRectangle.inflate(50, 50);
            var oldRenderers:Object = _visibleItemRenderers;
            _visibleItemRenderers = {};
            for each (constraintItem in constraintItems)
            {
                uid = _ganttSheet.itemToUID(constraintItem.data);
                renderer = oldRenderers[uid];
                if (this._hiddenUIDMap[uid] !== undefined)
                {
                    if (renderer)
                    {
                        recycleRenderer(renderer, uid);
                        delete oldRenderers[uid];
                    }
                }
                else
                {
                    if (renderer)
                    {
                        this.updateConstraintRenderer(constraintItem, renderer);
                        delete oldRenderers[uid];
                    }
                    else
                    {
                        renderer = createItemRenderer();
                        this.updateConstraintRenderer(constraintItem, renderer);
                    }
                    _visibleItemRenderers[uid] = renderer;
                }
            }
            for each (uid in _lockedUIDs)
            {
                renderer = oldRenderers[uid];
                if (renderer)
                {
                    _visibleItemRenderers[uid] = renderer;
                    delete oldRenderers[uid];
                }
            }
            for each (renderer in oldRenderers)
            {
                if (renderer)
                {
                    renderer.visible = false;
                    _freeItemRenderers.push(renderer);
                }
            }
        }

        private function updateItemRenderersPendingResultHandler(data:Object, token:Object=null):void
        {
            this.updateItemRenderers();
        }

        private function updateItemRenderersPendingFailureHandler(data:Object, token:Object=null):void
        {
        }

        private function updateConstraintRenderer(item:ConstraintItem, renderer:DisplayObject):void
        {
            if (renderer is IDataRenderer)
            {
                IDataRenderer(renderer).data = item;
            }
            if (renderer is ISimpleStyleClient)
            {
                ISimpleStyleClient(renderer).styleName = _ganttSheet.itemToStyleName(item);
            }
            if (renderer is IInvalidating)
            {
                IInvalidating(renderer).invalidateDisplayList();
            }
            else if (renderer is IProgrammaticSkin)
			{
				IProgrammaticSkin(renderer).validateDisplayList();
			}
            if (!renderer.visible)
            {
                renderer.visible = true;
            }
        }

        private function getVisibleConstraintItems():Array
        {
            if (!(ganttChart is TaskChart))
            {
                return [];
            }
            var firstVisibleIndex:int = ganttChart.dataGrid.verticalScrollPosition;
            var lastVisibleIndex:int = firstVisibleIndex + ganttChart.dataGrid.rowCount + 1;
            return _ganttSheet.constraintsCache.getInRange(firstVisibleIndex, lastVisibleIndex);
        }

        private function isConstraintInRange(item:ConstraintItem):Boolean
        {
            var taskChart:TaskChart = ganttChart as TaskChart;
            if (!taskChart)
            {
                return false;
            }
            var fromTask:Object = taskChart.getFromTask(item.data);
            if (fromTask == null)
            {
                return false;
            }
            var toTask:Object = taskChart.getToTask(item.data);
            if (toTask == null)
            {
                return false;
            }
            var indexFrom:int = taskChart.rowController.getItemIndex(fromTask);
            if (indexFrom < 0)
            {
                return false;
            }
            var indexTo:int = taskChart.rowController.getItemIndex(toTask);
            if (indexTo < 0)
            {
                return false;
            }
            var firstVisibleIndex:int = ganttChart.dataGrid.verticalScrollPosition;
            var lastVisibleIndex:int = firstVisibleIndex + ganttChart.dataGrid.rowCount + 1;
            var minConstraintIndex:int = indexFrom < indexTo ? indexFrom : indexTo;
            var maxConstraintIndex:int = indexFrom < indexTo ? indexTo : indexFrom;
            return minConstraintIndex <= lastVisibleIndex && maxConstraintIndex >= firstVisibleIndex;
        }

        public function getConstraintInfo(item:ConstraintItem):ConstraintInfo
        {
            if (!item)
            {
                return null;
            }
            var uid:String = _ganttSheet.itemToUID(item.data);
            var r:* = this._constraintToInfo[uid];
            if (r !== undefined)
            {
                return ConstraintInfo(r);
            }
            this.computeConstraintPathAndArrowDirection(item, uid);
            return ConstraintInfo(this._constraintToInfo[uid]);
        }

        private function computeConstraintPathAndArrowDirection(item:ConstraintItem, uid:String):void
        {
            var x0:Number;
            var y0:Number;
            var x1:Number;
            var y1:Number;
            var x2:Number;
            var y2:Number;
            this._constraintToInfo[uid] = null;
            var fromTask:Object = item.fromTask;
            if (fromTask == null)
            {
                return;
            }
            var toTask:Object = item.toTask;
            if (toTask == null)
            {
                return;
            }
            var fromBounds:Rectangle = _ganttSheet.getConnectionBounds(fromTask);
            if (fromBounds == null)
            {
                return;
            }
            var toBounds:Rectangle = _ganttSheet.getConnectionBounds(toTask);
            if (toBounds == null)
            {
                return;
            }
            var arrowDirection:String;
            y0 = (fromBounds.top + fromBounds.bottom) / 2;
            y1 = (toBounds.top + toBounds.bottom) / 2;
            var xOffset:Number = 10;
            var yOffset:Number = 2;
            var path:Array;
            switch (item.kind)
            {
                case ConstraintKind.END_TO_END:
                    x0 = fromBounds.right;
                    x1 = toBounds.right;
                    arrowDirection = "left";
                    path = new Array(4);
                    path[0] = new Point(x0, y0);
                    x2 = Math.max((x0 + xOffset), (x1 + xOffset));
                    path[1] = new Point(x2, y0);
                    path[2] = new Point(x2, y1);
                    path[3] = new Point(x1, y1);
                    break;
                case ConstraintKind.END_TO_START:
                    x0 = fromBounds.right;
                    x1 = toBounds.left;
                    arrowDirection = "right";
                    if (y0 < y1 && x0 < x1)
                    {
                        y1 = toBounds.y;
                        arrowDirection = "bottom";
                        path = new Array(3);
                        path[0] = new Point(x0, y0);
                        x1 = Math.max((x0 + xOffset), x1);
                        path[1] = new Point(x1, y0);
                        path[2] = new Point(x1, y1);
                    }
                    else if (y0 < y1)
					{
						y2 = (toBounds.y - yOffset);
						path = new Array(6);
						path[0] = new Point(x0, y0);
						path[1] = new Point((x0 + xOffset), y0);
						path[2] = new Point((x0 + xOffset), y2);
						path[3] = new Point((x1 - xOffset), y2);
						path[4] = new Point((x1 - xOffset), y1);
						path[5] = new Point(x1, y1);
					}
					else if ((x0 + xOffset) > (x1 - xOffset))
					{
						y2 = (toBounds.bottom + yOffset);
						path = new Array(6);
						path[0] = new Point(x0, y0);
						path[1] = new Point((x0 + xOffset), y0);
						path[2] = new Point((x0 + xOffset), y2);
						path[3] = new Point((x1 - xOffset), y2);
						path[4] = new Point((x1 - xOffset), y1);
						path[5] = new Point(x1, y1);
					}
					else
					{
						path = new Array(4);
						path[0] = new Point(x0, y0);
						path[1] = new Point((x0 + xOffset), y0);
						path[2] = new Point((x0 + xOffset), y1);
						path[3] = new Point(x1, y1);
					}
                    break;
                case ConstraintKind.START_TO_END:
                    x0 = fromBounds.left;
                    x1 = toBounds.right;
                    arrowDirection = "left";
                    if ((x0 - xOffset) < (x1 + xOffset))
                    {
                        y2 = y0 < y1 ? (toBounds.y - yOffset) : (toBounds.bottom + yOffset);
                        path = new Array(6);
                        path[0] = new Point(x0, y0);
                        path[1] = new Point((x0 - xOffset), y0);
                        path[2] = new Point((x0 - xOffset), y2);
                        path[3] = new Point((x1 + xOffset), y2);
                        path[4] = new Point((x1 + xOffset), y1);
                        path[5] = new Point(x1, y1);
                    }
                    else
                    {
                        path = new Array(4);
                        path[0] = new Point(x0, y0);
                        path[1] = new Point((x0 - xOffset), y0);
                        path[2] = new Point((x0 - xOffset), y1);
                        path[3] = new Point(x1, y1);
                    }
                    break;
                case ConstraintKind.START_TO_START:
                    x0 = fromBounds.left;
                    x1 = toBounds.left;
                    arrowDirection = "right";
                    path = new Array(4);
                    path[0] = new Point(x0, y0);
                    x2 = Math.min((x0 - xOffset), (x1 - xOffset));
                    path[1] = new Point(x2, y0);
                    path[2] = new Point(x2, y1);
                    path[3] = new Point(x1, y1);
                    break;
            }
            this._constraintToInfo[uid] = new ConstraintInfo(path, arrowDirection);
        }

        public function clearConstraintData():void
        {
            this._constraintToInfo = {};
            this._hiddenUIDs = [];
            this._hiddenUIDMap = {};
        }
    }
}
