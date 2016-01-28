package mokylin.gantt
{
    import mx.core.UIComponent;
    import flash.utils.Dictionary;
    import flash.display.DisplayObject;
    import mx.core.IFactory;
    import mx.core.IUIComponent;
    import mx.core.IDataRenderer;

    [ExcludeClass]
    public class GanttSheetItemContainer extends UIComponent 
    {

        protected var _ganttSheet:GanttSheet;
        protected var _oldStartTime:Date;
        protected var _oldUnscaledWidth:Number;
        protected var _oldUnscaledHeight:Number;
        protected var _oldZoomFactor:Number;
        protected var _visibleTimeRangeChanged:Boolean;
        protected var _sizeChanged:Boolean;
        protected var _itemsSizeChanged:Boolean;
        protected var _itemsPositionChanged:Boolean;
        protected var _freeItemRenderers:Array;
        protected var _visibleItemRenderers:Object;
        protected var _lockedUIDs:Array;
        protected var _layoutOverrideYItemRenderersMap:Dictionary;
        protected var _measuringRenderer:DisplayObject;
        private var _ganttChart:GanttChartBase;
        private var _itemRenderer:IFactory;
        private var _layoutOverrideYItemRenderers:Array;
        private var _lockedItems:Array;
        private var _timeController:TimeController;
        protected var _updateRenderersNeeded:Boolean;

        public function GanttSheetItemContainer(ganttSheet:GanttSheet)
        {
            this._freeItemRenderers = [];
            this._visibleItemRenderers = {};
            this._lockedUIDs = [];
            this._layoutOverrideYItemRenderersMap = new Dictionary();
            super();
            this._ganttSheet = ganttSheet;
        }

        final public function get ganttChart():GanttChartBase
        {
            return this._ganttChart;
        }

        final public function set ganttChart(value:GanttChartBase):void
        {
            this._ganttChart = value;
            invalidateProperties();
            invalidateDisplayList();
        }

        final public function get ganttSheet():GanttSheet
        {
            return this._ganttSheet;
        }

        public function get itemRenderer():IFactory
        {
            return this._itemRenderer;
        }

        public function set itemRenderer(value:IFactory):void
        {
            this._itemRenderer = value;
            this.cleanupItemRenderers();
            this.invalidateItemsSize();
        }

        public function get layoutOverrideYItemRenderers():Array
        {
            return this._layoutOverrideYItemRenderers;
        }

        public function set layoutOverrideYItemRenderers(value:Array):void
        {
            var i:Object;
            this._layoutOverrideYItemRenderers = value;
            this._layoutOverrideYItemRenderersMap = new Dictionary();
            if (value)
            {
                for each (i in value)
                {
                    this._layoutOverrideYItemRenderersMap[i] = i;
                }
            }
        }

        public function get lockedItems():Array
        {
            return this._lockedItems;
        }

        public function set lockedItems(value:Array):void
        {
            var item:Object;
            this._lockedItems = value;
            this._lockedUIDs = [];
            if (value)
            {
                for each (item in value)
                {
                    this._lockedUIDs.push(this.itemToUID(item));
                }
            }
        }

        public function get timeController():TimeController
        {
            return this._timeController;
        }

        public function set timeController(value:TimeController):void
        {
            if (this.timeController == value)
            {
                return;
            }
            if (this._timeController != null)
            {
                this._timeController.removeEventListener(GanttSheetEvent.VISIBLE_TIME_RANGE_CHANGE, this.visibleTimeRangeChangeHandler);
            }
            this._timeController = value;
            this._visibleTimeRangeChanged = true;
            if (this._timeController != null)
            {
                this._timeController.addEventListener(GanttSheetEvent.VISIBLE_TIME_RANGE_CHANGE, this.visibleTimeRangeChangeHandler);
            }
            invalidateProperties();
        }

        public function invalidateItemsSize():void
        {
            this._itemsSizeChanged = true;
            invalidateProperties();
        }

        public function invalidateTaskItemsLayout(items:Array):void
        {
        }

        override protected function commitProperties():void
        {
            super.commitProperties();
            if (this._timeController == null || !this._timeController.configured || this._ganttChart == null || this._ganttChart.rowController == null)
            {
                return;
            }
            if (this._visibleTimeRangeChanged)
            {
                this._visibleTimeRangeChanged = false;
                if (this.timeController.startTime != this._oldStartTime)
                {
                    this._itemsPositionChanged = true;
                    this._oldStartTime = this.timeController.startTime;
                }
                if (this.timeController.zoomFactor != this._oldZoomFactor)
                {
                    this._itemsSizeChanged = true;
                    this._oldZoomFactor = this.timeController.zoomFactor;
                }
                this._updateRenderersNeeded = true;
            }
            if (this._itemsPositionChanged || this._itemsSizeChanged || this._sizeChanged)
            {
                this._updateRenderersNeeded = true;
            }
            if (this._updateRenderersNeeded)
            {
                invalidateDisplayList();
            }
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            this._sizeChanged = unscaledHeight != this._oldUnscaledHeight || unscaledWidth != this._oldUnscaledWidth;
            if (this._sizeChanged)
            {
                this._oldUnscaledWidth = unscaledWidth;
                this._oldUnscaledHeight = unscaledHeight;
            }
            if (this._sizeChanged || this._updateRenderersNeeded)
            {
                this.validateRenderers();
            }
        }

        private function validateRenderers():void
        {
            this.updateItemRenderers();
            this._itemsPositionChanged = false;
            this._itemsSizeChanged = false;
            this._sizeChanged = false;
            this._updateRenderersNeeded = false;
        }

        protected function updateItemRenderers():void
        {
        }

        public function createItemRenderer():DisplayObject
        {
            var renderer:DisplayObject;
            if (this._freeItemRenderers.length > 0)
            {
                renderer = this._freeItemRenderers.pop() as DisplayObject;
            }
            else
            {
                renderer = this.itemRenderer.newInstance() as DisplayObject;
                if (renderer is IUIComponent)
                {
                    IUIComponent(renderer).includeInLayout = false;
                }
                addChild(renderer);
            }
            return renderer;
        }

        public function cleanupItemRenderers():void
        {
            var d:Object;
            for each (d in this._freeItemRenderers)
            {
                removeChild(DisplayObject(d));
            }
            this._freeItemRenderers = [];
            for each (d in this._visibleItemRenderers)
            {
                removeChild(DisplayObject(d));
            }
            this._visibleItemRenderers = {};
            if (this._measuringRenderer != null)
            {
                removeChild(this._measuringRenderer);
            }
            this._measuringRenderer = null;
        }

        public function recycleRenderer(renderer:DisplayObject, uid:String=null):void
        {
            if (renderer && !this.isLocked(uid))
            {
                renderer.visible = false;
                if (uid != null)
                {
                    delete this._visibleItemRenderers[uid];
                }
                if (renderer is IDataRenderer)
                {
                    IDataRenderer(renderer).data = null;
                }
                this._freeItemRenderers.push(renderer);
            }
        }

        public function itemToItemRenderer(item:Object):Object
        {
            return this._visibleItemRenderers[this.itemToUID(item)];
        }

        protected function isLocked(uid:String):Boolean
        {
            return this._lockedUIDs.indexOf(uid) >= 0;
        }

        protected function isYLayoutOverride(itemRenderer:Object):Boolean
        {
            return this._layoutOverrideYItemRenderersMap[itemRenderer] != null;
        }

        public function rowChangedHandler():void
        {
            this._itemsPositionChanged = true;
            invalidateProperties();
        }

        private function visibleTimeRangeChangeHandler(event:GanttSheetEvent):void
        {
            this._visibleTimeRangeChanged = true;
            invalidateProperties();
        }

        final protected function itemToUID(item:Object):String
        {
            return this.ganttSheet.itemToUID(item);
        }
    }
}
