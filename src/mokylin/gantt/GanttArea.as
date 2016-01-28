package mokylin.gantt
{
    import mx.core.Container;
    import mx.managers.IFocusManagerComponent;
    import mx.core.ScrollPolicy;
    import mx.skins.halo.HaloBorder;
    import flash.events.MouseEvent;
    import flash.events.KeyboardEvent;
    import mokylin.gantt.GanttSheet;
    import mokylin.gantt.TimeScale;
    import mx.core.EdgeMetrics;

    [ExcludeClass]
    public class GanttArea extends Container implements IFocusManagerComponent 
    {

        private var _rowController:IRowController;
        private var _showTimeScale:Boolean = true;
        private var _timeScaleHeight:Number;

        public function GanttArea()
        {
            tabFocusEnabled = true;
            verticalScrollPolicy = ScrollPolicy.OFF;
            horizontalScrollPolicy = ScrollPolicy.OFF;
            setStyle("borderStyle", "solid");
            setStyle("borderSkin", HaloBorder);
            setStyle("dropShadowEnabled", false);
            clearStyle("contentBackgroundColor");
            setStyle("contentBackgroundAlpha", 0);
            setStyle("paddingLeft", 0);
            setStyle("paddingRight", 0);
            addEventListener(MouseEvent.MOUSE_WHEEL, this.mouseWheelHandler);
            addEventListener(KeyboardEvent.KEY_DOWN, this.keyDownHandler);
        }

        private function get ganttSheet():GanttSheet
        {
            return getChildByName("ganttSheet") as GanttSheet;
        }

        private function get rowController():IRowController
        {
            return this._rowController;
        }

        private function set rowController(value:IRowController):void
        {
            this._rowController = value;
        }

		public function set showTimeScale(value:Boolean):void
        {
            this._showTimeScale = value;
            invalidateDisplayList();
        }

		public function get showTimeScale():Boolean
        {
            return this._showTimeScale;
        }

        private function get timeScale():TimeScale
        {
            return getChildByName("timeScale") as TimeScale;
        }

		public function set timeScaleHeight(value:Number):void
        {
            this._timeScaleHeight = value;
            invalidateDisplayList();
            if (this.ganttSheet != null && this.ganttSheet.ganttChart != null)
            {
                this.ganttSheet.ganttChart.invalidateSize();
            }
        }

		public function get timeScaleHeight():Number
        {
            return this._timeScaleHeight;
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            var timeScaleHeight:Number;
            var ganttSheetY:Number;
            var ganttSheetHeight:Number;
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            var vm:EdgeMetrics = viewMetrics;
            var contentWidth:Number = unscaledWidth - vm.left - vm.right;
            var contentHeight:Number = unscaledHeight - vm.top - vm.bottom;
            if (this.rowController != null)
            {
                this.rowController.validateHeaderSize();
            }
            var timeScale:TimeScale = this.timeScale;
            var ganttSheet:GanttSheet = this.ganttSheet;
            if (timeScale != null)
            {
                timeScale.move(0, 0);
                timeScaleHeight = this._timeScaleHeight;
                if (isNaN(timeScaleHeight))
                {
                    timeScaleHeight = timeScale.getExplicitOrMeasuredHeight();
                }
                timeScale.setActualSize(contentWidth, timeScaleHeight);
                timeScale.visible = this._showTimeScale;
            }
            if (ganttSheet != null)
            {
                ganttSheetY = (this._showTimeScale && timeScale) ? (timeScale.y + timeScale.height) : 0;
                ganttSheet.move(0, ganttSheetY);
                ganttSheetHeight = Math.max(0, (contentHeight - ganttSheetY));
                ganttSheet.setActualSize(contentWidth, ganttSheetHeight);
            }
        }

        override protected function measure():void
        {
            var timeScale:TimeScale;
            var timeScaleMinWidth:Number;
            var timeScaleHeight:Number;
            var ganttSheet:GanttSheet;
            var ganttSheetMinWidth:Number;
            super.measure();
            var vm:EdgeMetrics = viewMetrics;
            timeScale = this.timeScale;
            var timeScaleMinHeight:Number = timeScale != null ? timeScale.measuredMinHeight : 0;
            timeScaleMinWidth = timeScale != null ? timeScale.measuredMinWidth : 0;
            timeScaleHeight = timeScale != null ? timeScale.getExplicitOrMeasuredHeight() : 0;
            ganttSheet = this.ganttSheet;
            var ganttSheetMinHeight:Number = ganttSheet != null ? ganttSheet.measuredMinHeight : 0;
            ganttSheetMinWidth = ganttSheet != null ? ganttSheet.measuredMinWidth : 0;
            var ganttSheetHeight:Number = ganttSheet != null ? ganttSheet.getExplicitOrMeasuredHeight() : 0;
            measuredMinHeight = timeScaleMinHeight + ganttSheetMinHeight + vm.top + vm.bottom;
            measuredMinWidth = Math.max(timeScaleMinWidth, ganttSheetMinWidth) + vm.left + vm.right;
            measuredHeight = timeScaleHeight + ganttSheetHeight + vm.top + vm.bottom;
            if (timeScale != null && !isNaN(timeScale.explicitWidth) && ganttSheet != null && !isNaN(ganttSheet.explicitWidth))
            {
                measuredWidth = Math.max(timeScale.explicitWidth, ganttSheet.explicitWidth);
            }
            else if (timeScale != null && !isNaN(timeScale.explicitWidth))
			{
				measuredWidth = timeScale.explicitWidth;
			}
			else if (ganttSheet != null && !isNaN(ganttSheet.explicitWidth))
			{
				measuredWidth = ganttSheet.explicitWidth;
			}
			else if (timeScale != null && ganttSheet != null)
			{
				measuredWidth = Math.max(timeScale.measuredWidth, ganttSheet.measuredWidth);
			}
			else if (timeScale != null)
			{
				measuredWidth = timeScale.measuredWidth;
			}
			else if (ganttSheet != null)
			{
				measuredWidth = ganttSheet.measuredWidth;
			}
			else
			{
				measuredWidth = 250;
			}
            measuredWidth = measuredWidth + vm.left + vm.right;
        }

        private function mouseWheelHandler(event:MouseEvent):void
        {
            if (!enabled || event.delta == 0)
            {
                return;
            }
            if (this.ganttSheet.processMouseWheelEvent(event))
            {
                event.stopPropagation();
            }
        }

        override protected function keyDownHandler(event:KeyboardEvent):void
        {
            super.keyDownHandler(event);
            if (!enabled)
            {
                return;
            }
            if (this.ganttSheet.processKeyDownEvent(event))
            {
                event.stopPropagation();
            }
        }
    }
}
