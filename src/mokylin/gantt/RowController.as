package mokylin.gantt
{
    import mokylin.gantt.GanttDataGrid;
    import mx.collections.ICollectionView;
    import mokylin.gantt.GanttSheet;
    import mokylin.gantt.TimeScale;
    import mx.events.CollectionEvent;
    import mokylin.gantt.supportClasses.MessageUtil;
    import mx.logging.LogEventLevel;
    import mokylin.gantt.supportClasses.GanttProperties;
    import mx.events.AdvancedDataGridEvent;
    import mx.events.ScrollEvent;
    import flash.events.Event;
    import mx.events.ScrollEventDirection;
	/**
	 * 每一行数据的控制，包括数据展开，组件位置变化同步等，所有因为每行数据变化引起的变化，同步都在这里处理 
	 * @author NEIL
	 * 
	 */
    [ExcludeClass]
    public class RowController implements IRowController 
    {

        private static const DATA_GRID:String = "dataGrid";
        private static const TIME_SCALE:String = "timeScale";

        private var _lastSet:String;
        private var _dataGrid:GanttDataGrid;
        private var _dataGridCollection:ICollectionView;
        private var _ganttArea:GanttArea;
        private var _ganttSheet:GanttSheet;
        private var _synchronizedHeaderHeight:Number;
        private var _timeScale:TimeScale;
        private var _invalidHeaderSize:Boolean;
        private var _oldDataGridExplicitHeaderHeight:Number;
        private var _oldTimeScaleExplicitHeight:Number;


        public function set dataGrid(value:GanttDataGrid):void
        {
            if (this._dataGrid == value)
            {
                return;
            }
            if (this._dataGrid)
            {
                this.removeDataGridListeners(this._dataGrid);
            }
            this._dataGrid = value;
            if (this._dataGrid)
            {
                this.addDataGridListeners(this._dataGrid);
                this._lastSet = DATA_GRID;
            }
            this.invalidateHeaderSize();
        }

        public function get dataGrid():GanttDataGrid
        {
            return this._dataGrid;
        }

        public function set dataGridCollection(value:ICollectionView):void
        {
            if (value == this._dataGridCollection)
            {
                return;
            }
            if (this._dataGridCollection)
            {
                this._dataGridCollection.removeEventListener(CollectionEvent.COLLECTION_CHANGE, this.dataGridCollectionChangedHandler);
            }
            this._dataGridCollection = value;
            if (this._dataGridCollection)
            {
                this._dataGridCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE, this.dataGridCollectionChangedHandler, false, 0, true);
            }
        }

        public function set ganttArea(value:GanttArea):void
        {
            this._ganttArea = value;
        }

        public function get ganttArea():GanttArea
        {
            return this._ganttArea;
        }

        public function set ganttSheet(value:GanttSheet):void
        {
            this._ganttSheet = value;
        }

        public function get ganttSheet():GanttSheet
        {
            return this._ganttSheet;
        }

        private function set synchronizedHeaderHeight(value:Number):void
        {
            this._synchronizedHeaderHeight = value;
            if (this._ganttArea)
            {
                this._ganttArea.timeScaleHeight = this._synchronizedHeaderHeight;
            }
            if (this._dataGrid)
            {
                this._dataGrid.setActualTotalHeaderHeight(this._synchronizedHeaderHeight);
            }
        }

        public function set timeScale(value:TimeScale):void
        {
            if (value == this._timeScale)
            {
                return;
            }
            if (this._timeScale)
            {
                this._timeScale.removeEventListener("heightChanged", this.timeScaleHeightChangedHandler);
                this._timeScale.removeEventListener("measuredHeightChanged", this.timeScaleMeasuredHeightChangedHandler);
                this._timeScale.removeEventListener("measuredMinHeightChanged", this.timeScaleMeasuredMinHeightChangedHandler);
            }
            this._timeScale = value;
            if (this._timeScale)
            {
                this._timeScale.addEventListener("heightChanged", this.timeScaleHeightChangedHandler);
                this._timeScale.addEventListener("measuredHeightChanged", this.timeScaleMeasuredHeightChangedHandler);
                this._timeScale.addEventListener("measuredMinHeightChanged", this.timeScaleMeasuredMinHeightChangedHandler);
                this._lastSet = TIME_SCALE;
            }
            this.invalidateHeaderSize();
        }

        public function get timeScale():TimeScale
        {
            return this._timeScale;
        }

        public function getItemAt(y:Number):Object
        {
            return this._dataGrid.getRowItemAtPosition(y);
        }

        public function getItemIndex(item:Object):int
        {
            return this._dataGrid.getItemIndex(item);
        }

        public function getItemCount():uint
        {
            return this._dataGrid.getItemCount();
        }

        public function calculateGanttSheetRowHeight(item:Object):Number
        {
            if (this._ganttSheet.taskLayout != null)
            {
                return this._ganttSheet.taskLayout.calculateMinRowHeight(item);
            }
            return NaN;
        }

        public function getRowHeight(item:Object):Number
        {
            return this._dataGrid.getItemHeight(item);
        }

        public function getRowPosition(item:Object):Number
        {
            return this._dataGrid.getRowPosition(item);
        }

        public function getVisibleItems():Array
        {
            return this._dataGrid.getVisibleItems();
        }

        public function isItemVisible(item:Object):Boolean
        {
            return this._dataGrid.itemToItemRenderer(item) != null;
        }

        public function invalidateItemsSize():void
        {
            if (this._dataGrid != null)
            {
                this._dataGrid.invalidateList();
            }
        }

        public function scroll(delta:Number, unit:String):Number
        {
            if (unit == "pixel")
            {
                return this._dataGrid.scrollVerticallyByPixels(delta);
            }
            if (unit == "row")
            {
                return this._dataGrid.scrollVerticallyByRows(delta);
            }
			throw new (MessageUtil.log(RowController, LogEventLevel.ERROR, GanttProperties.ELIXIR_GANTT_BUNDLE, GanttProperties.INVALID_ARGUMENT_MESSAGE, ["RowController.scroll", "unit"]))();
        }

        public function get variableRowHeight():Boolean
        {
            return this._dataGrid.variableRowHeight;
        }

        public function invalidateHeaderSize():void
        {
            this._invalidHeaderSize = true;
            if (this.dataGrid != null)
            {
                this.dataGrid.invalidateDisplayList();
            }
            if (this.ganttArea != null)
            {
                this.ganttArea.invalidateDisplayList();
            }
        }

        public function validateHeaderSize():void
        {
            var value:Number;
            if (!this.dataGrid || !this.timeScale)
            {
                return;
            }
            var explicitHeaderSize:Number = this.getExplicitHeaderSize();
            if (!isNaN(explicitHeaderSize))
            {
                value = explicitHeaderSize;
            }
            else
            {
                value = this.getPreferredHeaderSize();
            }
            if (!isNaN(value))
            {
                this._invalidHeaderSize = false;
            }
            this.synchronizedHeaderHeight = value;
        }

        private function getExplicitHeaderSize():Number
        {
            var value:Number;
            if (this.dataGrid != null)
            {
                this.dataGrid.validateSize();
            }
            if (this.timeScale != null)
            {
                this.dataGrid.validateSize();
            }
            var dataGridExplicitValue:Number = this.dataGrid ? this.dataGrid.explicitTotalHeaderHeight : NaN;
            var timeScaleExplicitValue:Number = this.timeScale ? this.timeScale.explicitHeight : NaN;
            if (this._lastSet == DATA_GRID && !isNaN(dataGridExplicitValue))
            {
                value = dataGridExplicitValue;
            }
            else if (this._lastSet == TIME_SCALE && !isNaN(timeScaleExplicitValue))
			{
				value = timeScaleExplicitValue;
			}
			else if (!isNaN(dataGridExplicitValue))
			{
				value = dataGridExplicitValue;
			}
			else if (!isNaN(timeScaleExplicitValue))
			{
				value = timeScaleExplicitValue;
			}
            return value;
        }
		/**
		 * 获得更理想的头部高度值， 
		 * @return 
		 * 
		 */
        private function getPreferredHeaderSize():Number
        {
            var timeScalePreferredValue:Number;
            var dataGridPreferredValue:Number;
            var value:Number;
            var minTimeScaleHeaderHeight:Number;
            if (this.dataGrid != null)
            {
                this.dataGrid.validateSize();
            }
            if (this.timeScale != null)
            {
                this.dataGrid.validateSize();
            }
            if (this._timeScale != null)
            {
                timeScalePreferredValue = this._timeScale.getExplicitOrMeasuredHeight();
                minTimeScaleHeaderHeight = isNaN(this._timeScale.explicitMinHeight) ? this._timeScale.measuredMinHeight : this._timeScale.explicitMinHeight;
                if (timeScalePreferredValue < minTimeScaleHeaderHeight)
                {
                    timeScalePreferredValue = minTimeScaleHeaderHeight;
                }
                if (timeScalePreferredValue > this._timeScale.maxHeight)
                {
                    timeScalePreferredValue = this._timeScale.maxHeight;
                }
            }
            if (this._dataGrid != null)
            {
                dataGridPreferredValue = this._dataGrid.measuredTotalHeaderHeight;
            }
            if (!isNaN(timeScalePreferredValue) && !isNaN(dataGridPreferredValue))
            {
                value = Math.max(timeScalePreferredValue, dataGridPreferredValue);
            }
            else if (!isNaN(timeScalePreferredValue))
			{
				value = timeScalePreferredValue;
			}
			else if (!isNaN(dataGridPreferredValue))
			{
				value = dataGridPreferredValue;
			}
            return value;
        }

        private function checkDataGridExplicitHeaderHeightChange():void
        {
            if (this.dataGrid != null && this.dataGrid.explicitTotalHeaderHeight != this._oldDataGridExplicitHeaderHeight)
            {
                this._oldDataGridExplicitHeaderHeight = this.dataGrid.explicitHeaderHeight;
                this._lastSet = DATA_GRID;
            }
        }

        private function checkTimeScaleExplicitHeightChanged():void
        {
            if (this.timeScale != null && this.timeScale.explicitHeight != this._oldTimeScaleExplicitHeight)
            {
                this._oldTimeScaleExplicitHeight = this.timeScale.explicitHeight;
                this._lastSet = TIME_SCALE;
            }
        }

        private function removeDataGridListeners(dataGrid:GanttDataGrid):void
        {
            dataGrid.removeEventListener(AdvancedDataGridEvent.ITEM_OPEN, this.dataGridItemExpandCollapseHandler);
            dataGrid.removeEventListener(AdvancedDataGridEvent.ITEM_CLOSE, this.dataGridItemExpandCollapseHandler);
            dataGrid.removeEventListener(AdvancedDataGridEvent.HEADER_RELEASE, this.dataGridHeaderReleasedHandler);
            dataGrid.removeEventListener(ScrollEvent.SCROLL, this.dataGridScrolledHandler);
            dataGrid.removeEventListener(GanttDataGrid.ROW_HEIGHT_CHANGED, this.dataGridRowHeightChangedHandler);
            dataGrid.removeEventListener(GanttDataGrid.VARIABLE_ROW_HEIGHT_CHANGED, this.dataGridRowHeightChangedHandler);
            dataGrid.removeEventListener(GanttDataGrid.LIST_INVALIDATED, this.dataGridRowHeightChangedHandler);
            dataGrid.removeEventListener(ItemExpandEvent.START, this.itemExpandHandler);
            dataGrid.removeEventListener(ItemExpandEvent.STEP, this.itemExpandHandler);
            dataGrid.removeEventListener(ItemExpandEvent.END, this.itemExpandHandler);
            dataGrid.removeEventListener("viewChanged", this.dataGridViewChangedHandler);
            dataGrid.removeEventListener("showHeadersChanged", this.dataGridShowHeadersChangedHandler);
            dataGrid.removeEventListener("itemsSizeChanged", this.dataGridItemsSizeChangedHandler);
            dataGrid.removeEventListener("measuredTotalHeaderHeightChanged", this.dataGridMeasuredTotalHeaderHeightChangedHandler);
            dataGrid.removeEventListener("explicitTotalHeaderHeightChanged", this.dataGridExplicitotalHeaderHeightChangedHandler);
        }

        private function addDataGridListeners(dataGrid:GanttDataGrid):void
        {
            dataGrid.addEventListener(AdvancedDataGridEvent.ITEM_OPEN, this.dataGridItemExpandCollapseHandler);
            dataGrid.addEventListener(AdvancedDataGridEvent.ITEM_CLOSE, this.dataGridItemExpandCollapseHandler);
            dataGrid.addEventListener(AdvancedDataGridEvent.HEADER_RELEASE, this.dataGridHeaderReleasedHandler);
            dataGrid.addEventListener(ScrollEvent.SCROLL, this.dataGridScrolledHandler);
            dataGrid.addEventListener(GanttDataGrid.ROW_HEIGHT_CHANGED, this.dataGridRowHeightChangedHandler);
            dataGrid.addEventListener(GanttDataGrid.VARIABLE_ROW_HEIGHT_CHANGED, this.dataGridRowHeightChangedHandler);
            dataGrid.addEventListener(GanttDataGrid.LIST_INVALIDATED, this.dataGridListInvalidatedHandler);
            dataGrid.addEventListener(ItemExpandEvent.START, this.itemExpandHandler);
            dataGrid.addEventListener(ItemExpandEvent.STEP, this.itemExpandHandler);
            dataGrid.addEventListener(ItemExpandEvent.END, this.itemExpandHandler);
            dataGrid.addEventListener("viewChanged", this.dataGridViewChangedHandler);
            dataGrid.addEventListener("showHeadersChanged", this.dataGridShowHeadersChangedHandler);
            dataGrid.addEventListener("itemsSizeChanged", this.dataGridItemsSizeChangedHandler);
            dataGrid.addEventListener("measuredTotalHeaderHeightChanged", this.dataGridMeasuredTotalHeaderHeightChangedHandler);
            dataGrid.addEventListener("explicitTotalHeaderHeightChanged", this.dataGridExplicitotalHeaderHeightChangedHandler);
        }

        private function dataGridItemsSizeChangedHandler(event:Event):void
        {
            this.checkDataGridExplicitHeaderHeightChange();
            this.invalidateHeaderSize();
        }

        private function dataGridMeasuredTotalHeaderHeightChangedHandler(event:Event):void
        {
            this.checkDataGridExplicitHeaderHeightChange();
            this.invalidateHeaderSize();
        }

        private function dataGridExplicitotalHeaderHeightChangedHandler(event:Event):void
        {
            this.checkDataGridExplicitHeaderHeightChange();
            this.invalidateHeaderSize();
        }

        private function dataGridShowHeadersChangedHandler(event:Event):void
        {
            if (this._dataGrid && this._ganttArea)
            {
                this._ganttArea.showTimeScale = this._dataGrid.showHeaders;
            }
        }

        private function dataGridListInvalidatedHandler(event:Event):void
        {
            if (this._ganttSheet)
            {
                this._ganttSheet.rowHeightChangedHandler();
            }
        }

        private function dataGridRowHeightChangedHandler(event:Event):void
        {
            if (this._ganttSheet)
            {
                this._ganttSheet.rowHeightChangedHandler();
            }
        }

        private function dataGridScrolledHandler(event:ScrollEvent):void
        {
            if (this._ganttSheet && event.direction == ScrollEventDirection.VERTICAL && event.delta != 0)
            {
                this._ganttSheet.rowChangedHandler();
            }
        }

        private function dataGridViewChangedHandler(event:Event):void
        {
            if (this._ganttSheet)
            {
                this._ganttSheet.rowChangedHandler();
            }
        }

        private function dataGridHeaderReleasedHandler(event:AdvancedDataGridEvent):void
        {
            if (this._ganttSheet)
            {
                this._ganttSheet.rowChangedHandler();
            }
        }

        private function dataGridItemExpandCollapseHandler(event:AdvancedDataGridEvent):void
        {
            if (this._ganttSheet)
            {
                this._ganttSheet.rowExpandCollapseHandler();
            }
        }

        private function timeScaleHeightChangedHandler(event:Event):void
        {
            this.checkTimeScaleExplicitHeightChanged();
            this.invalidateHeaderSize();
        }

        private function timeScaleMeasuredHeightChangedHandler(event:Event):void
        {
            this.invalidateHeaderSize();
        }

        private function timeScaleMeasuredMinHeightChangedHandler(event:Event):void
        {
            this.invalidateHeaderSize();
        }

        private function itemExpandHandler(event:ItemExpandEvent):void
        {
            if (this._ganttSheet)
            {
                this._ganttSheet.itemExpandHandler(event);
            }
        }

		/**
		 * 当左边的表格数据有变化时，相应的右边的显示组件也会做相应的同步处理。 
		 * @param event
		 * 
		 */		
        private function dataGridCollectionChangedHandler(event:CollectionEvent):void
        {
            if (this._ganttSheet)
            {
                this._ganttSheet.rowChangedHandler();
            }
        }
    }
}
