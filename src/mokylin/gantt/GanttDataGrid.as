package mokylin.gantt
{
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.utils.Dictionary;
    
    import mx.collections.ArrayCollection;
    import mx.collections.ICollectionView;
    import mx.collections.IHierarchicalCollectionView;
    import mx.controls.AdvancedDataGrid;
    import mx.controls.listClasses.IListItemRenderer;
    import mx.controls.listClasses.ListRowInfo;
    import mx.controls.scrollClasses.ScrollBar;
    import mx.core.IDataRenderer;
    import mx.core.ScrollPolicy;
    import mx.core.mx_internal;
    import mx.events.TweenEvent;
    
    import mokylin.utils.LRUCache;

	use namespace mx_internal;
    public class GanttDataGrid extends AdvancedDataGrid 
    {

		public static const ITEMS_SIZE_CHANGED:String = "itemsSizeChanged";
		public static const ROW_HEIGHT_CHANGED:String = "rowHeightChanged";
		public static const VARIABLE_ROW_HEIGHT_CHANGED:String = "variableRowHeightChanged";
		public static const LIST_INVALIDATED:String = "listInvalidated";

        private var _verticalTotalRows:int;
        private var _verticalVisibleRows:int;
        private var _animatedDataItemsAll:Array;
        private var _animatedDataItemsChildren:Array;
        private var _animatedRowInfoAll:Array;
        private var _animatedRowInfoMap:Dictionary;
        private var _itemExpanding:Object;
        private var _itemExpandOpening:Boolean;
        private var _indexCache:IndexCache;
        private var _dataProviderChanged:Boolean;
        private var _explicitHeaderHeightValue:Number;
        private var _explicitTotalHeaderHeight:Number;
        private var _headerHeightChanged:Boolean;
        private var _measuredTotalHeaderHeight:Number;
        private var _rowController:IRowController;
        private var rowHeightMean:Number = 0;
        private var rowHeightN:Number = 0;
        private var rowHeightCache:LRUCache;

        public function GanttDataGrid()
        {
            this._indexCache = new IndexCache();
            this.rowHeightCache = new LRUCache(128);
            super();
            verticalScrollPolicy = ScrollPolicy.OFF;
            horizontalScrollPolicy = ScrollPolicy.OFF;
        }

		public function get hScrollBar():ScrollBar
        {
            return horizontalScrollBar;
        }

		public function get vScrollBar():ScrollBar
        {
            return verticalScrollBar;
        }

        override public function set dataProvider(value:Object):void
        {
            super.dataProvider = value;
            this._dataProviderChanged = true;
            invalidateProperties();
        }

		public function get explicitHeaderHeight():Number
        {
            return this._explicitHeaderHeightValue;
        }

		public function get explicitTotalHeaderHeight():Number
        {
            return this._explicitTotalHeaderHeight;
        }

		public function set explicitTotalHeaderHeight(value:Number):void
        {
            this._explicitTotalHeaderHeight = value;
        }

        override public function set headerHeight(value:Number):void
        {
            this._explicitHeaderHeightValue = value;
            this._headerHeightChanged = true;
            if (value == headerHeight)
            {
                return;
            }
            if (groupedColumns && value <= 2)
            {
                return;
            }
            super.headerHeight = value;
        }

		public function get headerHeightChanged():Boolean
        {
            return this._headerHeightChanged;
        }

		public function set measuredTotalHeaderHeight(value:Number):void
        {
            if (value == this._measuredTotalHeaderHeight)
            {
                return;
            }
            this._measuredTotalHeaderHeight = value;
        }

		public function get measuredTotalHeaderHeight():Number
        {
            return this._measuredTotalHeaderHeight;
        }

		public function set rowController(value:IRowController):void
        {
            this._rowController = value;
        }

		public function get rowController():IRowController
        {
            return this._rowController;
        }

        override public function set verticalScrollPosition(value:Number):void
        {
            if (verticalScrollPosition == value)
            {
                return;
            }
            super.verticalScrollPosition = value;
        }

		public function get verticalTotalRows():int
        {
            if (invalidateDisplayListFlag)
            {
                validateDisplayList();
            }
//			invalidateDisplayList();
            return this._verticalTotalRows;
        }

		public function get verticalVisibleRows():int
        {
            if (invalidateDisplayListFlag)
            {
                validateDisplayList();
            }
//			invalidateDisplayList();
            return this._verticalVisibleRows;
        }

		public function get meanRowHeight():Number
        {
            if (variableRowHeight)
            {
                return Math.floor(this.rowHeightMean);
            }
            return rowHeight;
        }

        private function updateMeanRowHeight():void
        {
            var info:ListRowInfo;
            var value:Number;
            var oldValue:Object;
            if (!variableRowHeight)
            {
                return;
            }
            if (rowInfo == null || rowInfo.length == 0)
            {
                return;
            }
            var count:uint = rowInfo.length;
            var n:Number = this.rowHeightN;
            var mean:Number = this.rowHeightMean;
            var i:uint;
            while (i < count)
            {
                info = (rowInfo[i] as ListRowInfo);
                value = info.height;
                oldValue = this.rowHeightCache.getData(info.uid);
                if (oldValue != value)
                {
                    if (oldValue != null)
                    {
                        if (n <= 1)
                        {
                            mean = 0;
                            n = 0;
                        }
                        else
                        {
                            n = n - 1;
                            mean = ((n + 1) / n) * mean - (Number(oldValue) / n);
                        }
                    }
                    if (!(isNaN(value)))
                    {
                        n = n + 1;
                        mean = mean + (value - mean) / n;
                        this.rowHeightCache.add(info.uid, value);
                    }
                }
                i++;
            }
            this.rowHeightN = n;
            this.rowHeightMean = mean;
        }

        override protected function commitProperties():void
        {
            super.commitProperties();
            if (this._dataProviderChanged)
            {
                this._dataProviderChanged = false;
                this._indexCache.collection = collection;
            }
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            if (itemsSizeChanged)
            {
                this.measureTotalHeaderHeight();
                dispatchEvent(new Event(ITEMS_SIZE_CHANGED));
                this._headerHeightChanged = false;
            }
            if (this.rowController)
            {
                this.rowController.validateHeaderSize();
            }
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            this.updateMeanRowHeight();
        }

        public function getRowItemAtPosition(y:Number):Object
        {
            var c:int;
            if (rowInfo.length == 0)
            {
                return null;
            }
            var p:Point = new Point(0, y);
            y = globalToLocal(p).y;
            if (y < 0 || y >= height)
            {
                return null;
            }
            var a:int;
            var b:int = rowInfo.length;
            while (true)
            {
                c = (a + b) / 2;
                if (y < rowInfo[c].y)
                {
                    if (b == c)
                    {
                        return null;
                    }
                    b = c;
                }
                else if (y > (rowInfo[c].y + rowInfo[c].height))
				{
					if (a == c)
					{
						return null;
					}
					a = c;
				}
				else
				{
					break;
				}
            }
            var renderer:IListItemRenderer = indexToItemRenderer(c + verticalScrollPosition);
            return renderer ? renderer.data : null;
        }

        override protected function setScrollBarProperties(totalColumns:int, visibleColumns:int, totalRows:int, visibleRows:int):void
        {
            super.setScrollBarProperties(totalColumns, visibleColumns, totalRows, visibleRows);
            this._verticalTotalRows = totalRows;
            this._verticalVisibleRows = visibleRows;
        }

        override public function expandItem(item:Object, open:Boolean, animate:Boolean=false, dispatchEvent:Boolean=false, cause:Event=null):void
        {
            if (animate)
            {
                this._itemExpanding = item;
                this._itemExpandOpening = open;
                if (open)
                {
                    this._indexCache.invalidate();
                }
                if (!(open))
                {
                    this.captureAnimationInformation();
                }
            }
            super.expandItem(item, open, animate, dispatchEvent, cause);
            if (tween)
            {
                if (open)
                {
                    this.captureAnimationInformation();
                }
                else
                {
                    this.captureAnimationInformationForNewRows();
                }
                tween.addEventListener(TweenEvent.TWEEN_START, this.tweenStartHandler, false, 0, true);
                tween.addEventListener(TweenEvent.TWEEN_UPDATE, this.tweenUpdateHandler, false, 0, true);
                tween.addEventListener(TweenEvent.TWEEN_END, this.tweenEndHandler, false, 0, true);
            }
            else
            {
                this.cleanupAnimationInformation();
            }
            this._indexCache.invalidate();
        }

        override public function expandAll():void
        {
            super.expandAll();
            this._indexCache.invalidate();
        }

        override public function collapseAll():void
        {
            super.collapseAll();
            this._indexCache.invalidate();
        }

        override public function invalidateList():void
        {
            super.invalidateList();
            dispatchEvent(new Event(LIST_INVALIDATED));
        }

        override protected function calculateRowHeight(data:Object, hh:Number, skipVisible:Boolean=false):Number
        {
            hh = super.calculateRowHeight(data, hh, skipVisible);
            var minRowHeight:Number = this.rowController.calculateGanttSheetRowHeight(data);
            if (!isNaN(minRowHeight))
            {
                hh = Math.max(hh, minRowHeight);
            }
            return hh;
        }

        override protected function configureScrollBars():void
        {
            super.configureScrollBars();
            if ((verticalScrollBar == null || !verticalScrollBar.visible) && this._verticalVisibleRows >= this._verticalTotalRows)
            {
                maxVerticalScrollPosition = 0;
            }
        }

		public function getVisibleItems():Array
        {
            var uid:String;
            var r:Object;
            var visibleItems:Array = [];
            var i:uint;
            while (i < rowInfo.length)
            {
                uid = ListRowInfo(rowInfo[i]).uid;
                r = visibleData[uid];
                if (r is DisplayObject && (r as DisplayObject).visible && r is IDataRenderer)
                {
                    visibleItems.push((r as IDataRenderer).data);
                }
                i++;
            }
            return visibleItems;
        }

		public function getRowPosition(item:Object):Number
        {
            var rowInformation:ListRowInfo;
            if (this._itemExpanding && this._animatedRowInfoMap)
            {
                rowInformation = this._animatedRowInfoMap[itemToUID(item)];
                if (rowInformation)
                {
                    return rowInformation.y;
                }
            }
            return this.getRowPositionImpl(item);
        }

        private function getRowPositionImpl(item:Object, itemIndex:int=-1):Number
        {
            var index:Number = itemIndex!=-1 ? itemIndex : this.getVisibleRowIndexForItem(item);
            return index >= 0 && rowInfo && rowInfo.length >= index ? rowInfo[index].y - rowInfo[0].y : NaN;
        }

		public function getItemHeight(item:Object):Number
        {
            var rowInformation:ListRowInfo;
            if (this._itemExpanding && this._animatedRowInfoMap)
            {
                rowInformation = this._animatedRowInfoMap[itemToUID(item)];
                if (rowInformation)
                {
                    return rowInformation.height;
                }
            }
            return this.getItemHeightImpl(item);
        }

        private function getItemHeightImpl(item:Object, itemIndex:int=-1):Number
        {
            var index:Number = itemIndex!=-1 ? itemIndex : this.getVisibleRowIndexForItem(item);
            return index >= 0 && rowInfo && rowInfo.length >= index ? rowInfo[index].height : NaN;
        }

		public function getItemIndex(item:Object):int
        {
            if (item == null)
            {
                return -1;
            }
            return this._indexCache.getIndex(item);
        }

		public function getItemCount():uint
        {
            if (!collection)
            {
                return 0;
            }
            var count:int = collection.length;
            if (count >= 0)
            {
                return uint(count);
            }
            return this._indexCache.getCount();
        }

		public function getVisibleRowIndexForItem(item:Object):Number
        {
            var itemRenderer:IListItemRenderer = itemToItemRenderer(item);
            return itemRenderer ? itemRendererToIndex(itemRenderer) - verticalScrollPosition : -1;
        }

		public function getRowInfo():Array
        {
            return this.rowInfo;
        }

		public function getListItems():Array
        {
            return this.listItems;
        }

		public function scrollVerticallyByRows(delta:Number):Number
        {
            var initial:Number = verticalScrollPosition;
            var possible:Number = Math.max((initial + delta), 0);
            possible = Math.min(possible, maxVerticalScrollPosition);
            this.verticalScrollPosition = possible;
            return initial - possible;
        }

		public function scrollVerticallyByPixels(delta:Number):Number
        {
            var i:int;
            if (delta == 0)
            {
                return 0;
            }
            var currentVerticalScrollPosition:Number = verticalScrollPosition;
            var amountScrolled:Number = 0;
            var indicesScrolled:Number = 0;
            var tempRowHeight:Number = rowHeight;
            var tempMaxVerticalScrollPosition:Number = maxVerticalScrollPosition;
            if (delta > 0)
            {
                i = currentVerticalScrollPosition;
                while (i < tempMaxVerticalScrollPosition && i < collection.length)
                {
                    tempRowHeight = this.computeRowHeight(currentVerticalScrollPosition + indicesScrolled);
                    if ((amountScrolled + tempRowHeight) > delta)
                    {
                        break;
                    }
                    amountScrolled = (amountScrolled + tempRowHeight);
                    indicesScrolled++;
                    i++;
                }
            }
            else
            {
                delta = -delta;
                i = (currentVerticalScrollPosition - 1);
                while (i >= 0)
                {
                    if ((amountScrolled + tempRowHeight) > delta)
                    {
                        break;
                    }
                    amountScrolled = amountScrolled + tempRowHeight;
                    indicesScrolled++;
                    i--;
                }
                amountScrolled = -amountScrolled;
                indicesScrolled = -indicesScrolled;
            }
            if (indicesScrolled != 0)
            {
                this.verticalScrollPosition = (verticalScrollPosition + indicesScrolled);
            }
            return amountScrolled;
        }

        private function computeRowHeight(index:Number):Number
        {
            if (!variableRowHeight)
            {
                return rowHeight;
            }
            var itemRenderer:IListItemRenderer = indexToItemRenderer(index);
            return itemRenderer ? itemRenderer.getExplicitOrMeasuredHeight() : rowHeight;
        }

        private function captureAnimationInformation():void
        {
            var animatedDataItem:Object;
            var animatedDataItemUID:String;
            this._animatedRowInfoMap = new Dictionary();
            this._animatedRowInfoAll = new Array();
            this._animatedDataItemsChildren = new Array();
            this._animatedDataItemsAll = new Array();
            var tempVerticalScrollPosition:Number = verticalScrollPosition;
            var renderer:IListItemRenderer = itemToItemRenderer(this._itemExpanding);
            if (!renderer)
            {
                return;
            }
            var indexAfterItemExpanding:int = itemRendererToIndex(renderer) + 1 - tempVerticalScrollPosition;
            var i:int = indexAfterItemExpanding;
            while (i < rowInfo.length && rowInfo[i].uid)
            {
                if (rowInfo[i].y < this.height)
                {
                    this._animatedDataItemsAll[this._animatedDataItemsAll.length] = indexToItemRenderer((i + tempVerticalScrollPosition)).data;
                }
                i++;
            }
            this._animatedDataItemsChildren = this.getAllChildrenDataItems(this._itemExpanding);
            i = 0;
            while (i < this._animatedDataItemsAll.length)
            {
                animatedDataItem = this._animatedDataItemsAll[i];
                animatedDataItemUID = itemToUID(animatedDataItem);
                this._animatedRowInfoAll[i] = new ListRowInfo(this.getRowPositionImpl(animatedDataItem, (indexAfterItemExpanding + i)), this.getItemHeightImpl(animatedDataItem, (indexAfterItemExpanding + i)), animatedDataItemUID, animatedDataItem);
                this._animatedRowInfoAll[i].itemOldY = this._animatedRowInfoAll[i].y;
                this._animatedRowInfoMap[animatedDataItemUID] = this._animatedRowInfoAll[i];
                i++;
            }
        }

        private function captureAnimationInformationForNewRows():void
        {
            var uid:String;
            var data:Object;
            var nextIndex:Number;
            var lastKnownRendererPosition:Number = this._animatedRowInfoAll[(this._animatedRowInfoAll.length - 1)].y;
            var firstRowPosition:Number = rowInfo.length>0 ? rowInfo[0].y : 0;
            var i:int;
            while (i < rowInfo.length && rowInfo[i].uid)
            {
                uid = ListRowInfo(rowInfo[i]).uid;
                if (!this._animatedRowInfoMap[uid] && (rowInfo[i].y - firstRowPosition) > lastKnownRendererPosition)
                {
                    data = ListRowInfo(rowInfo[i]).data;
                    nextIndex = this._animatedDataItemsAll.length;
                    this._animatedDataItemsAll[nextIndex] = data;
                    this._animatedRowInfoAll[nextIndex] = new ListRowInfo(this.getRowPositionImpl(data, i), this.getItemHeightImpl(data, i), uid, data);
                    this._animatedRowInfoAll[nextIndex].itemOldY = this._animatedRowInfoAll[nextIndex].y;
                    this._animatedRowInfoMap[uid] = this._animatedRowInfoAll[nextIndex];
                }
                i++;
            }
        }

        private function getAllChildrenDataItems(item:Object):Array
        {
            var childrenProcessing:ICollectionView;
            var i:int;
            var curChild:Object;
            var curChildChildren:ICollectionView;
            var j:int;
            var childrenAll:Array = new Array();
            var childrenToProcess:Array = new Array();
            if (isBranch(item))
            {
                childrenProcessing = getChildren(item, iterator.view);
                while (childrenProcessing)
                {
                    i = 0;
                    while (i < childrenProcessing.length)
                    {
                        curChild = childrenProcessing[i];
                        childrenAll.push(curChild);
                        curChildChildren = getChildren(curChild, iterator.view);
                        if (curChildChildren)
                        {
                            j = 0;
                            while (j < curChildChildren.length)
                            {
                                childrenToProcess.push(curChildChildren[j]);
                                j++;
                            }
                        }
                        i++;
                    }
                    if (childrenToProcess.length > 0)
                    {
                        childrenProcessing = new ArrayCollection(childrenToProcess);
                        childrenToProcess = new Array();
                    }
                    else
                    {
                        childrenProcessing = null;
                    }
                }
            }
            return childrenAll;
        }

        private function getChildren(item:Object, view:Object):ICollectionView
        {
            var children:ICollectionView = IHierarchicalCollectionView(collection).getChildren(item);
            return children;
        }

        private function tweenEndHandler(event:Object):void
        {
            var offset:Number = (event.value as Number);
            this.updateAnimationInformation(offset);
            var itemExpandEvent:ItemExpandEvent = new ItemExpandEvent(ItemExpandEvent.END, false, false, this._itemExpanding, this._animatedDataItemsChildren, offset, this._itemExpandOpening);
            this.dispatchEvent(itemExpandEvent);
            this.cleanupAnimationInformation();
            if (tween)
            {
                tween.removeEventListener(TweenEvent.TWEEN_START, this.tweenStartHandler, false);
                tween.removeEventListener(TweenEvent.TWEEN_UPDATE, this.tweenUpdateHandler, false);
                tween.removeEventListener(TweenEvent.TWEEN_END, this.tweenEndHandler, false);
            }
        }

        private function tweenStartHandler(event:TweenEvent):void
        {
            var itemExpandEvent:ItemExpandEvent = new ItemExpandEvent(ItemExpandEvent.START, false, false, this._itemExpanding, this._animatedDataItemsChildren, 0, this._itemExpandOpening);
            this.dispatchEvent(itemExpandEvent);
        }

        private function tweenUpdateHandler(event:TweenEvent):void
        {
            var offset:Number = (event.value as Number);
            this.updateAnimationInformation(offset);
            var itemExpandEvent:ItemExpandEvent = new ItemExpandEvent(ItemExpandEvent.STEP, false, false, this._itemExpanding, this._animatedDataItemsChildren, offset, this._itemExpandOpening);
            this.dispatchEvent(itemExpandEvent);
        }

        private function updateAnimationInformation(value:Object):void
        {
            var i:int;
            while (i < this._animatedRowInfoAll.length)
            {
                this._animatedRowInfoAll[i].y = (this._animatedRowInfoAll[i].itemOldY + value);
                i++;
            }
        }

        private function cleanupAnimationInformation():void
        {
            this._animatedDataItemsAll = null;
            this._animatedDataItemsChildren = null;
            this._animatedRowInfoAll = null;
            this._animatedRowInfoMap = null;
            this._itemExpanding = null;
            this._itemExpandOpening = false;
        }

		public function setActualTotalHeaderHeight(value:Number):void
        {
            if (groupedColumns)
            {
                value = value / headerRowInfo.length;
            }
            if (groupedColumns && value <= 2)
            {
                return;
            }
            super.headerHeight = value;
        }

		private function measureTotalHeaderHeight():void
		{
			var backup_explicitHeaderHeight:Boolean;
			var backup_headerHeight:Number;
			var oldMeasuredTotalHeaderHeight:Number = this.measuredTotalHeaderHeight;
			var oldExplicitTotalHeaderHeight:Number = this.explicitTotalHeaderHeight;
			if (isNaN(this._explicitHeaderHeightValue))
			{
				backup_explicitHeaderHeight = _explicitHeaderHeight;
				backup_headerHeight = _headerHeight;
				_explicitHeaderHeight = false;
				calculateHeaderHeight();
				_explicitHeaderHeight = backup_explicitHeaderHeight;
				_headerHeight = backup_headerHeight;
				this.measuredTotalHeaderHeight = this.getTotalHeaderHeight();
				this.explicitTotalHeaderHeight = NaN;
			}
			else
			{
				calculateHeaderHeight();
				this.measuredTotalHeaderHeight = this.getTotalHeaderHeight();
				this.explicitTotalHeaderHeight = this._measuredTotalHeaderHeight;
			}
			if (isNaN(oldMeasuredTotalHeaderHeight) || oldMeasuredTotalHeaderHeight != this.measuredTotalHeaderHeight)
			{
				dispatchEvent(new Event("measuredTotalHeaderHeightChanged"));
			}
			if (isNaN(oldExplicitTotalHeaderHeight) || oldExplicitTotalHeaderHeight != this.explicitTotalHeaderHeight)
			{
				dispatchEvent(new Event("explicitTotalHeaderHeightChanged"));
			}
		}

        private function getTotalHeaderHeight():Number
        {
            if (!showHeaders)
            {
                return 0;
            }
            return groupedColumns ? ListRowInfo(headerRowInfo[0]).height : headerHeight;
        }
    }
}
