package mokylin.gantt
{
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    
    import mx.core.EdgeMetrics;
    import mx.core.EventPriority;
    import mx.core.IFlexDisplayObject;
    import mx.core.IFlexModuleFactory;
    import mx.core.UIComponent;
    import mx.events.SandboxMouseEvent;
    import mx.managers.CursorManagerPriority;
    import mx.styles.CSSStyleDeclaration;
    import mx.styles.ISimpleStyleClient;
    
    import __AS3__.vec.Vector;
    
    import mokylin.gantt.supportClasses.TimeScaleRowContainer;
    import mokylin.utils.CSSUtil;
    import mokylin.utils.Cursor;
    import mokylin.utils.GregorianCalendar;

    [Event(name="scaleChange", type="mokylin.gantt.TimeScaleEvent")]
    [Style(name="backgroundColors", type="Array", arrayType="uint", format="Color", inherit="no")]
    [Style(name="backgroundSkin", type="Class", inherit="no")]
    [Style(name="rollOverAlpha", type="Number", inherit="yes")]
    [Style(name="rollOverColor", type="uint", format="Color", inherit="yes")]
    [Style(name="separatorAlpha", type="Number", inherit="no")]
    [Style(name="separatorColor", type="uint", format="Color", inherit="yes")]
    [Style(name="separatorSkin", type="Class", inherit="no")]
    [Style(name="separatorThickness", type="Number", inherit="no")]
    [Style(name="useRollOver", type="Boolean", inherit="no")]
    [Style(name="panCursor", type="Class", inherit="no")]
    [Style(name="selectRangeCursor", type="Class", inherit="no")]
    [Style(name="selectRangeCursorOffset", type="Array", arrayType="int", inherit="no")]
    [ResourceBundle("mokylingantt")]
    [DefaultProperty("rows")]
    public class TimeScale extends UIComponent 
    {

        private static const _bottomBorderHeight:Number = 1;

        private const PANNING_X_THRESHOLD:Number = 3;
        private const PANNING_Y_THRESHOLD:Number = 3;
        private const ZOOM_OUT_RATIO:Number = 2;

        private var _rowContainer:TimeScaleRowContainer;
        private var _invalidateScale:Boolean = true;
        private var _visibleTimeRangeEvent:GanttSheetEvent;
        private var _panCursor:Cursor;
        private var _selectRangeCursor:Cursor;
        private var _backgroundSkin:IFlexDisplayObject;
        private var _backgroundSkinChanged:Boolean;
        private var _separatorContainer:UIComponent;
        private var _separatorSkinChanged:Boolean;
        private var _selectionLayer:Sprite;
        private var _visibleTimeRangeChanged:Boolean;
        private var _styleInitialized:Boolean = false;
        private var _calendar:GregorianCalendar;
        private var _calendarChanged:Boolean;
        private var _highlightRange:Vector.<Date>;
        private var _rowLayoutInfos:Vector.<TimeScaleRowLayoutInfo>;
        private var _rows:Vector.<TimeScaleRow>;
        private var _rowsChanged:Boolean;
        private var _timeController:TimeController;
        private var _timeControllerChanged:Boolean;
        private var _viewMetrics:EdgeMetrics;
        private var _isMouseOver:Boolean;
        private var _isMouseDown:Boolean;
        private var _isPanning:Boolean;
        private var _isSelectingRange:Boolean;
        private var _mouseDownLocalPoint:Point;
        private var _mouseDownTime:Date;
        private var _lastPanLocalPoint:Point;
        private var _installedRows:Vector.<TimeScaleRow>;
        private var _rowConfigurationPolicy:TimeScaleRowConfigurationPolicy;

        public function TimeScale()
        {
            this._rows = new Vector.<TimeScaleRow>();
            super();
            this._panCursor = new Cursor(this, "panCursor");
            this._selectRangeCursor = new Cursor(this, "selectRangeCursor", "selectRangeCursorOffset");
            addEventListener(MouseEvent.ROLL_OVER, this.rollOverHandler);
            addEventListener(MouseEvent.ROLL_OUT, this.rollOutHandler);
            addEventListener(MouseEvent.MOUSE_MOVE, this.mouseMoveHandler);
            addEventListener(MouseEvent.MOUSE_DOWN, this.mouseDownHandler);
            addEventListener(TimeScaleEvent.SCALE_CHANGE, this.scaleChangeHandler, false, EventPriority.DEFAULT_HANDLER);
        }

        override public function set moduleFactory(factory:IFlexModuleFactory):void
        {
            super.moduleFactory = factory;
            if (!this._styleInitialized)
            {
                this._styleInitialized = true;
                this.initStyles();
            }
        }

        private function initStyles():void
        {
            var styleDeclaration:CSSStyleDeclaration = CSSUtil.createSelector("TimeScale", "mokylin.gantt", styleManager);
            styleDeclaration.defaultFactory = function ():void
            {
                this.backgroundColors = ["0xFFFFFF", "0xFF0000"];
                this.backgroundSkin = TimeScaleBackgroundSkin;
//                this.panCursor = AssetsUtil.PAN_HORIZONTAL_CURSOR;
                this.rollOverAlpha = 1;
                this.selectRangeCursor = undefined;
                this.selectRangeCursorOffset = undefined;
                this.separatorAlpha = 1;
                this.separatorColor = 0xFF0000;
                this.separatorSkin = TimeScaleSeparatorSkin;
                this.separatorThickness = 5;
                this.useRollOver = true;
            };
        }

		/**
		 * 返回当前时间轴头的行实例 
		 * @return 
		 * 
		 */		
        public function get automaticRows():Vector.<TimeScaleRow>
        {
            var row:TimeScaleRow;
            var automaticRows:Vector.<TimeScaleRow> = new Vector.<TimeScaleRow>();
            for each (row in this.rows)
            {
                if (row.autoConfigure)
                {
                    automaticRows.push(row);
                }
            }
            return automaticRows;
        }

        public function get calendar():GregorianCalendar
        {
            if (!this._calendar)
            {
                this.setCalendar(new GregorianCalendar());
            }
            return this._calendar;
        }

		public function setCalendar(value:GregorianCalendar):void
        {
            if (!value)
            {
                value = new GregorianCalendar();
            }
            if (value == this._calendar)
            {
                return;
            }
            this._calendar = value;
            this._calendarChanged = true;
            invalidateProperties();
        }

        private function get highlightRange():Vector.<Date>
        {
            return this._highlightRange;
        }

        private function set highlightRange(value:Vector.<Date>):void
        {
            this._highlightRange = value;
            this.drawHighlightRange();
        }

        private function get rowLayoutInfos():Vector.<TimeScaleRowLayoutInfo>
        {
            var rowCount:int;
            var i:int;
            var info:TimeScaleRowLayoutInfo;
            if (!this._rowLayoutInfos)
            {
                this._rowLayoutInfos = new Vector.<TimeScaleRowLayoutInfo>();
                rowCount = this._rows.length;
                i = 0;
                while (i < rowCount)
                {
                    info = new TimeScaleRowLayoutInfo();
                    info.y = NaN;
                    info.height = NaN;
                    info.row = this._rows[i];
                    this._rowLayoutInfos[i] = info;
                    i++;
                }
            }
            return this._rowLayoutInfos;
        }

        private function invalidateRowLayoutInfos():void
        {
            this._rowLayoutInfos = null;
        }

        [Bindable("rowsChanged")]
        public function get rows():Vector.<TimeScaleRow>
        {
            return this._rows;
        }

        public function set rows(value:Vector.<TimeScaleRow>):void
        {
            if (value == this._rows)
            {
                return;
            }
            if (value == null)
            {
                value = new Vector.<TimeScaleRow>();
            }
            this._rows = value;
            this._rowsChanged = true;
            if (this._rowContainer)
            {
                this._rowContainer.invalidateSize();
                this._rowContainer.invalidateDisplayList();
            }
            invalidateProperties();
            invalidateSize();
            invalidateDisplayList();
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
            if (this._timeController != null)
            {
                this._timeController.addEventListener(GanttSheetEvent.VISIBLE_TIME_RANGE_CHANGE, this.visibleTimeRangeChangeHandler);
            }
            this._timeControllerChanged = true;
            invalidateProperties();
        }

        private function get viewMetrics():EdgeMetrics
        {
            if (!this._viewMetrics)
            {
                this._viewMetrics = new EdgeMetrics(0, 0, 0, _bottomBorderHeight);
            }
            return this._viewMetrics;
        }

        public function get zoomFactor():Number
        {
            if (this._timeController && this._timeController.configured)
            {
                return this._timeController.zoomFactor;
            }
            return NaN;
        }

        override protected function commitProperties():void
        {
            var highlightUpdateNeeded:Boolean;
            var row:TimeScaleRow;
            var row2:TimeScaleRow;
            super.commitProperties();
            if (this._timeControllerChanged)
            {
                this._timeControllerChanged = false;
                for each (row in this.rows)
                {
                    row.timeController = this.timeController;
                }
                if (this.rowConfigurationPolicy != null)
                {
                    this.rowConfigurationPolicy.timeController = this.timeController;
                }
                this.invalidateRowConfigurationPolicyCriteria();
                highlightUpdateNeeded = true;
                invalidateDisplayList();
            }
            if (this._calendarChanged)
            {
                this._calendarChanged = false;
                for each (row2 in this._rows)
                {
                    row2.setCalendar(this.calendar);
                }
                this.invalidateRowConfigurationPolicyCriteria();
                highlightUpdateNeeded = true;
            }
            if (this._rowsChanged)
            {
                this._rowsChanged = false;
                this.uninstallRows();
                this.invalidateRowLayoutInfos();
                this.invalidateSeparators();
                this.installRows();
                this.invalidateRowConfigurationPolicy();
                this._invalidateScale = true;
                invalidateDisplayList();
            }
            if (this._invalidateScale && this._timeController != null && this._timeController.configured)
            {
                this._invalidateScale = false;
                this.dispatchScaleChangeEvent();
                highlightUpdateNeeded = true;
            }
            if (this._visibleTimeRangeChanged)
            {
                this._visibleTimeRangeChanged = false;
                highlightUpdateNeeded = true;
            }
            if (highlightUpdateNeeded)
            {
                this.updateHighlightRange();
            }
        }

        override protected function createChildren():void
        {
            super.createChildren();
            if (this._selectionLayer == null)
            {
                this._selectionLayer = new Sprite();
                this._selectionLayer.name = "selection";
                addChild(this._selectionLayer);
            }
            if (this._rowContainer == null)
            {
                this._rowContainer = new TimeScaleRowContainer();
                this._rowContainer.name = "rows";
                addChild(this._rowContainer);
            }
            this.createDefaultRows();
        }

        private function createDefaultRows():void
        {
            var rows:Vector.<TimeScaleRow>;
            if (this.rows.length == 0)
            {
                rows = new Vector.<TimeScaleRow>();
                rows.push(new TimeScaleRow());
                rows.push(new TimeScaleRow());
                this.rows = rows;
            }
        }

        override protected function measure():void
        {
            var oldMeasuredMinHeight:Number;
            var oldMeasuredHeight:Number = measuredHeight;
            oldMeasuredMinHeight = measuredMinHeight;
            super.measure();
            var vm:EdgeMetrics = this.viewMetrics;
            measuredHeight = this._rowContainer.measuredHeight + vm.top + vm.bottom;
            measuredMinHeight = this._rowContainer.measuredMinHeight + vm.top + vm.bottom;
            measuredWidth = this._rowContainer.measuredWidth + vm.left + vm.right;
            measuredMinWidth = this._rowContainer.measuredMinWidth + vm.left + vm.right;
            if (isNaN(oldMeasuredMinHeight) || oldMeasuredMinHeight != measuredMinHeight)
            {
                dispatchEvent(new Event("measuredMinHeightChanged"));
            }
            if (isNaN(oldMeasuredHeight) || oldMeasuredHeight != measuredHeight)
            {
                dispatchEvent(new Event("measuredHeightChanged"));
            }
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            this.updateRowLayout();
            this.drawBackground();
            this.drawSeparators();
            this.drawHighlightRange();
        }

        override protected function resourcesChanged():void
        {
            super.resourcesChanged();
            this.invalidateRowConfigurationPolicyResources();
        }

        override public function styleChanged(styleProp:String):void
        {
            var allStyles:Boolean = styleProp == null || styleProp == "styleName";
            super.styleChanged(styleProp);
            if (allStyles)
            {
                if (this.rowConfigurationPolicy)
                {
                    this.rowConfigurationPolicy.invalidateCriteria();
                }
                this._invalidateScale = true;
                invalidateProperties();
                invalidateSize();
            }
            if (allStyles || styleProp == "separatorThickness")
            {
                if (this._rowContainer)
                {
                    this._rowContainer.verticalGap = getStyle("separatorThickness");
                }
                invalidateSize();
            }
            if (allStyles || styleProp == "backgroundSkin")
            {
                this._backgroundSkinChanged = true;
                invalidateProperties();
            }
            if (allStyles || styleProp == "separatorSkin")
            {
                this._separatorSkinChanged = true;
                invalidateProperties();
            }
            this._panCursor.styleChanged(styleProp, allStyles);
            this._selectRangeCursor.styleChanged(styleProp, allStyles);
        }

		/**
		 * 更新时间轴头的布局 
		 * 
		 */		
        private function updateRowLayout():void
        {
            var info:TimeScaleRowLayoutInfo;
            var row:TimeScaleRow;
            var vm:EdgeMetrics = this.viewMetrics;
            var contentWidth:Number = unscaledWidth - vm.left - vm.right;
            var contentHeight:Number = unscaledHeight - vm.top - vm.bottom;
            this._rowContainer.move(0, 0);
            this._rowContainer.setActualSize(contentWidth, contentHeight);
            this._rowContainer.validateNow();
            var rowCount:int = this._rows.length;
            var i:int;
            while (i < rowCount)
            {
                info = this.rowLayoutInfos[i];
                row = info.row;
                info.y = row.y;
                info.height = row.height;
                i++;
            }
        }

		/**
		 * 绘制时间轴头的背景 
		 * 
		 */		
        private function drawBackground():void
        {
            var skinClass:Class;
            if (this._backgroundSkinChanged)
            {
                this._backgroundSkinChanged = false;
                if (this._backgroundSkin)
                {
                    removeChild(DisplayObject(this._backgroundSkin));
                    this._backgroundSkin = null;
                }
            }
            if (!this._backgroundSkin)
            {
                skinClass = getStyle("backgroundSkin");
                if (skinClass != null)
                {
                    this._backgroundSkin = new skinClass();
                    if (this._backgroundSkin is ISimpleStyleClient)
                    {
                        ISimpleStyleClient(this._backgroundSkin).styleName = this;
                    }
                    addChildAt(DisplayObject(this._backgroundSkin), 0);
                }
            }
            if (this._backgroundSkin)
            {
                this._backgroundSkin.move(0, 0);
                this._backgroundSkin.setActualSize(unscaledWidth, unscaledHeight);
            }
        }

        private function invalidateSeparators():void
        {
            if (this._separatorContainer == null)
            {
                return;
            }
            removeChild(this._separatorContainer);
            this._separatorContainer = null;
        }

		/**
		 * 绘制时间轴头的每行的分隔线 
		 * 
		 */		
        private function drawSeparators():void
        {
            var skin:IFlexDisplayObject;
            var index:int;
            var skinClass:Class;
            var rowCount:int;
            var i:uint;
            var j:uint;
            var layoutInfo:TimeScaleRowLayoutInfo;
            var measuredSkinHeight:Number;
            var vm:EdgeMetrics = this.viewMetrics;
            var contentWidth:Number = unscaledWidth - vm.left - vm.right;
            var contentHeight:Number = unscaledHeight - vm.top - vm.bottom;
            if (this._separatorSkinChanged)
            {
                this._separatorSkinChanged = false;
                if (this._separatorContainer)
                {
                    removeChild(this._separatorContainer);
                    this._separatorContainer = null;
                }
            }
            if (!this._separatorContainer)
            {
                this._separatorContainer = new UIComponent();
                this._separatorContainer.name = "separators";
                index = this._rowContainer ? getChildIndex(DisplayObject(this._rowContainer)) + 1 : numChildren;
                addChildAt(this._separatorContainer, index);
                skinClass = getStyle("separatorSkin");
                if (skinClass != null)
                {
                    rowCount = this.rows.length;
                    i = 0;
                    while (i < (rowCount - 1))
                    {
                        skin = new skinClass();
                        if (skin is ISimpleStyleClient)
                        {
                            ISimpleStyleClient(skin).styleName = this;
                            ISimpleStyleClient(skin).styleChanged(null);
                        }
                        this._separatorContainer.addChild(DisplayObject(skin));
                        i++;
                    }
                }
            }
            if (this._separatorContainer)
            {
                this._separatorContainer.move(0, 0);
                this._separatorContainer.setActualSize(contentWidth, contentHeight);
                j = 0;
                while (j < this._separatorContainer.numChildren)
                {
                    layoutInfo = this.rowLayoutInfos[j];
                    skin = (this._separatorContainer.getChildAt(j) as IFlexDisplayObject);
                    measuredSkinHeight = skin.measuredHeight;
                    skin.move(0, (layoutInfo.y + layoutInfo.height));
                    skin.setActualSize(contentWidth, measuredSkinHeight);
                    j++;
                }
            }
        }

        private function drawHighlightRange():void
        {
            var g:Graphics = this._selectionLayer.graphics;
            g.clear();
            if (!enabled || !this._isMouseOver || !getStyle("useRollOver") || this._highlightRange == null)
            {
                return;
            }
            if (this._timeController == null || !this._timeController.configured)
            {
                return;
            }
            var vm:EdgeMetrics = this.viewMetrics;
            var contentWidth:Number = unscaledWidth - vm.left - vm.right;
            var contentHeight:Number = unscaledHeight - vm.top - vm.bottom;
            var start:Date = this._highlightRange[0];
            var end:Date = this._highlightRange[1];
            var startX:Number = this.timeController.getCoordinate(start);
            startX = Math.max(vm.left, Math.min(contentWidth - 1, startX));
            var endX:Number = this.timeController.getCoordinate(end);
            endX = Math.max(vm.left, Math.min(contentWidth - 1, endX));
            var width:Number = endX - startX + 1;
            g.beginFill(getStyle("rollOverColor"), getStyle("rollOverAlpha"));
            g.lineStyle(0, 0, 0);
            g.drawRect(startX, vm.top, width, contentHeight);
            g.endFill();
        }

        private function dispatchScaleChangeEvent():void
        {
            var e:TimeScaleEvent = new TimeScaleEvent(TimeScaleEvent.SCALE_CHANGE, false, true);
            if (this._visibleTimeRangeEvent != null)
            {
                e.adjusting = this._visibleTimeRangeEvent.adjusting;
                this._visibleTimeRangeEvent = null;
            }
            dispatchEvent(e);
        }

        private function installPanCursor():void
        {
            this._panCursor.setCursor();
        }

        private function removePanCursor():void
        {
            this._panCursor.removeCursor();
        }

        private function installSelectRangeCursor():void
        {
            this._selectRangeCursor.setCursor(CursorManagerPriority.HIGH);
        }

        private function removeSelectRangeCursor():void
        {
            this._selectRangeCursor.removeCursor();
        }

        private function resetSelectionVariables():void
        {
            this._isSelectingRange = false;
            this._mouseDownLocalPoint = null;
            this._mouseDownTime = null;
        }

        private function resetPanningVariables():void
        {
            this._isPanning = false;
            this._mouseDownLocalPoint = null;
            this._mouseDownTime = null;
            this._lastPanLocalPoint = null;
        }

        private function rollOverHandler(event:MouseEvent):void
        {
            this._isMouseOver = true;
            this.updateHighlightRange();
        }

        private function rollOutHandler(event:MouseEvent):void
        {
            this._isMouseOver = false;
            this.updateHighlightRange();
        }

        private function mouseMoveHandler(event:MouseEvent):void
        {
            var p:Point = new Point(event.stageX, event.stageY);
            p = globalToLocal(p);
            this.mouseMoveHandlerImpl(p, event.buttonDown, event.altKey, event.ctrlKey, event.shiftKey);
        }

        private function mouseMoveSomewhereHandler(event:SandboxMouseEvent):void
        {
            var p:Point = new Point(mouseX, mouseY);
            this.mouseMoveHandlerImpl(p, event.buttonDown, event.altKey, event.ctrlKey, event.shiftKey);
        }

        private function mouseMoveHandlerImpl(p:Point, buttonDown:Boolean, altKey:Boolean, ctrlKey:Boolean, shiftKey:Boolean):void
        {
            var deltaX:Number;
            var deltaY:Number;
            var coordinateDifference:Number;
            if (!enabled)
            {
                return;
            }
            this.updateHighlightRange();
            if (this._isSelectingRange)
            {
                return;
            }
            if (!this._isPanning && this._isMouseDown && buttonDown && !altKey && !ctrlKey && !shiftKey)
            {
                deltaX = Math.abs(this._mouseDownLocalPoint.x - p.x);
                deltaY = Math.abs(this._mouseDownLocalPoint.y - p.y);
                this._isPanning = deltaX > this.PANNING_X_THRESHOLD || deltaY > this.PANNING_Y_THRESHOLD;
                if (this._isPanning)
                {
                    this._timeController.startAdjusting();
                    this._lastPanLocalPoint = this._mouseDownLocalPoint.clone();
                    this.installPanCursor();
                }
            }
            if (this._isPanning && this._isMouseDown && buttonDown)
            {
                coordinateDifference = (this._lastPanLocalPoint.x - p.x);
                if (coordinateDifference != 0)
                {
                    this._timeController.shiftByCoordinate(coordinateDifference);
                    this._lastPanLocalPoint = p.clone();
                }
            }
        }

        private function mouseDownHandler(event:MouseEvent):void
        {
            if (!enabled)
            {
                return;
            }
            this._isMouseDown = true;
            var p:Point = new Point(event.stageX, event.stageY);
            p = globalToLocal(p);
            this._mouseDownLocalPoint = p.clone();
            this._mouseDownTime = this._timeController.getTime(p.x);
            if (event.ctrlKey)
            {
                this._isSelectingRange = true;
                this.installSelectRangeCursor();
            }
            this.updateHighlightRange();
            var sandboxRoot:DisplayObject = systemManager.getSandboxRoot();
            sandboxRoot.addEventListener(MouseEvent.MOUSE_UP, this.mouseUpHandler, true);
            sandboxRoot.addEventListener(MouseEvent.MOUSE_MOVE, this.mouseMoveHandler, true);
            sandboxRoot.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, this.mouseUpSomewhereHandler, true);
            sandboxRoot.addEventListener(SandboxMouseEvent.MOUSE_MOVE_SOMEWHERE, this.mouseMoveSomewhereHandler, true);
            sandboxRoot.addEventListener(MouseEvent.ROLL_OUT, this.stageMouseOutHandler);
            sandboxRoot.addEventListener(MouseEvent.ROLL_OVER, this.stageMouseOverHandler);
            systemManager.deployMouseShields(true);
        }

        private function mouseUpHandler(event:MouseEvent):void
        {
            var p:Point = new Point(event.stageX, event.stageY);
            p = globalToLocal(p);
            this.mouseUpHandlerImpl(p, event.altKey, event.ctrlKey, event.shiftKey);
        }

        private function mouseUpSomewhereHandler(event:SandboxMouseEvent):void
        {
            var p:Point = new Point(mouseX, mouseY);
            this.mouseUpHandlerImpl(p, event.altKey, event.ctrlKey, event.shiftKey);
        }

        private function mouseUpHandlerImpl(p:Point, altKey:Boolean, ctrlKey:Boolean, shiftKey:Boolean):void
        {
            var start:Date;
            var end:Date;
            var tmp:Date;
            if (!enabled)
            {
                return;
            }
            var sandboxRoot:DisplayObject = systemManager.getSandboxRoot();
            sandboxRoot.removeEventListener(MouseEvent.MOUSE_UP, this.mouseUpHandler, true);
            sandboxRoot.removeEventListener(MouseEvent.MOUSE_MOVE, this.mouseMoveHandler, true);
            sandboxRoot.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, this.mouseUpHandler, true);
            sandboxRoot.removeEventListener(SandboxMouseEvent.MOUSE_MOVE_SOMEWHERE, this.mouseMoveHandler, true);
            sandboxRoot.removeEventListener(MouseEvent.ROLL_OUT, this.stageMouseOutHandler);
            sandboxRoot.removeEventListener(MouseEvent.ROLL_OVER, this.stageMouseOverHandler);
            systemManager.deployMouseShields(false);
            if (this._isPanning)
            {
                this._timeController.stopAdjusting();
                this.removePanCursor();
                this.resetPanningVariables();
            }
            else if (this._isSelectingRange)
			{
				this.removeSelectRangeCursor();
				start = this._mouseDownTime;
				end = this._timeController.getTime(p.x);
				if (start.time > end.time)
				{
					tmp = start;
					start = end;
					end = tmp;
				}
				if ((end.time - start.time) > this.zoomFactor)
				{
					this._timeController.configure(start, end, this._timeController.width, 0, true);
				}
				this.resetSelectionVariables();
			}
			else
			{
				if (shiftKey)
				{
					this._timeController.zoomAt(this.ZOOM_OUT_RATIO, p.x, true);
				}
				else
				{
					if (this._highlightRange)
					{
						this._timeController.configure(this._highlightRange[0], this._highlightRange[1], this._timeController.width, 0, true);
					}
				}
			}
            this._isMouseDown = false;
            this.updateHighlightRange();
            invalidateDisplayList();
        }

        private function stageMouseOutHandler(event:MouseEvent):void
        {
            this.removePanCursor();
            this.removeSelectRangeCursor();
        }

        private function stageMouseOverHandler(event:MouseEvent):void
        {
            if (this._panCursor.isInstalled || this._selectRangeCursor.isInstalled)
            {
                return;
            }
            if (this._isPanning)
            {
                if (event.buttonDown)
                {
                    this.installPanCursor();
                }
                else
                {
                    this.resetPanningVariables();
                }
            }
            else if (this._isSelectingRange)
			{
				if (event.buttonDown)
				{
					this.installSelectRangeCursor();
				}
				else
				{
					this.resetSelectionVariables();
				}
			}
        }

        private function updateHighlightRange():void
        {
            var end:Date;
            var range:Vector.<Date>;
            var row:TimeScaleRow;
            if (!this._isMouseOver || this._isPanning)
            {
                this.highlightRange = null;
                return;
            }
            var p:Point = new Point(mouseX, mouseY);
            if (this._isSelectingRange)
            {
                end = this._timeController.getTime(p.x);
                range = new Vector.<Date>(2, true);
                range[0] = this._mouseDownTime;
                range[1] = end;
                this.highlightRange = range;
            }
            else
            {
                row = this.getRowAt(p);
                if (row == null)
                {
                    this.highlightRange = null;
                    return;
                }
                p = localToGlobal(p);
                p = row.globalToLocal(p);
                this.highlightRange = row.getCellRangeAt(p);
            }
        }

		/**
		 * 根据鼠标点的位置，获得鼠标当前是时间轴头的那一行 
		 * @param p
		 * @return 
		 * 
		 */		
        private function getRowAt(p:Point):TimeScaleRow
        {
            var info:TimeScaleRowLayoutInfo;
            if (!this._rowLayoutInfos)
            {
                return null;
            }
            var separatorThickness:Number = getStyle("separatorThickness");
            for each (info in this._rowLayoutInfos)
            {
                if (p.y <= (info.y + info.height) + (separatorThickness / 2))
                {
                    return info.row;
                }
            }
            return null;
        }

        private function visibleTimeRangeChangeHandler(event:GanttSheetEvent):void
        {
            if (event.zoomFactorChanged || event.projectionChanged)
            {
                this._invalidateScale = true;
                this._visibleTimeRangeEvent = event;
            }
            if (event.projectionChanged)
            {
                this.invalidateRowConfigurationPolicyCriteria();
            }
            this._visibleTimeRangeChanged = true;
            invalidateProperties();
        }

        private function scaleChangeHandler(event:TimeScaleEvent):void
        {
            if (!event.isDefaultPrevented())
            {
                this.configureAutomaticRows();
            }
            invalidateDisplayList();
        }

        private function uninstallRows():void
        {
            var row:TimeScaleRow;
            if (this._installedRows == null)
            {
                return;
            }
            for each (row in this._installedRows)
            {
                row.timeController = null;
                row.setCalendar(null);
                if (this._rowContainer)
                {
                    this._rowContainer.removeChild(row);
                }
            }
            this._installedRows = null;
        }

        private function installRows():void
        {
            var row:TimeScaleRow;
            if (this._rows == null)
            {
                return;
            }
            for each (row in this._rows)
            {
                row.timeController = this.timeController;
                row.setCalendar(this.calendar);
                row.styleName = this;
                row.owner = this;
                if (this._rowContainer != null)
                {
                    this._rowContainer.addChild(row);
                }
            }
            this._installedRows = this._rows;
        }
		/**
		 * 次要的行 
		 * @return 
		 * 
		 */
		public function get minorScaleRow():TimeScaleRow
        {
            var rows:Vector.<TimeScaleRow> = this.automaticRows;
            if (rows.length > 1)
            {
                return rows[1];
            }
            return null;
        }

		/**
		 * 配置时间轴头的行信息，根据时间来配置 
		 * 
		 */		
        public function configureAutomaticRows():void
        {
            if (!this._timeController || !this._timeController.configured)
            {
                return;
            }
            var settings:Vector.<TimeScaleRowSetting> = this.computeRowSettings();
            this.applyRowSettings(settings, this.automaticRows);
        }

        private function computeRowSettings():Vector.<TimeScaleRowSetting>
        {
            if (this.rowConfigurationPolicy == null)
            {
                return TimeScaleRowSetting.EMPTY_VECTOR;
            }
            return this.rowConfigurationPolicy.computeRowSettings(this.zoomFactor);
        }

        private function applyRowSettings(settings:Vector.<TimeScaleRowSetting>, rows:Vector.<TimeScaleRow>):void
        {
            var setting:TimeScaleRowSetting;
            var row:TimeScaleRow;
            var settingCount:int = settings.length;
            if (settingCount == 0)
            {
                return;
            }
            var rowCount:int = rows.length;
            var i:int;
            while (i < rowCount)
            {
                setting = i<settingCount ? settings[i] : settings[(settingCount - 1)];
                row = rows[i];
                row.tickUnit = setting.unit;
                row.tickSteps = setting.steps;
                row.formatString = setting.formatString;
                row.subTickUnit = setting.subunit;
                row.subTickSteps = setting.substeps;
                i++;
            }
        }

        private function get rowConfigurationPolicy():TimeScaleRowConfigurationPolicy
        {
            if (this._rowConfigurationPolicy == null)
            {
                this._rowConfigurationPolicy = this.createRowConfigurationPolicy();
                if (this._rowConfigurationPolicy != null)
                {
                    this._rowConfigurationPolicy.resourceManager = resourceManager;
                    this._rowConfigurationPolicy.rows = this.automaticRows;
                    this._rowConfigurationPolicy.timeController = this.timeController;
                }
            }
            return this._rowConfigurationPolicy;
        }
		/**
		 * 创建一套行配置的方针
		 * @return 
		 * 
		 */
        private function createRowConfigurationPolicy():TimeScaleRowConfigurationPolicy
        {
            var policy:TimeScaleRowConfigurationPolicy;
            var automaticRowCount:int = this.automaticRows.length;
            if (automaticRowCount == 0)
            {
                policy = null;
            }
            else
            {
                if (this.automaticRows.length == 1)
                {
                    policy = new TimeScaleConfigurationPolicyForOneRow();
                }
                else
                {
                    policy = new TimeScaleConfigurationPolicyForTwoRows();
                }
            }
            return policy;
        }

		/**
		 * 更新行配置方针 
		 * 
		 */		
		public function invalidateRowConfigurationPolicy():void
        {
            this._rowConfigurationPolicy = null;
            this._invalidateScale = true;
            invalidateProperties();
        }

		public function invalidateRowConfigurationPolicyCriteria():void
        {
            if (this._rowConfigurationPolicy)
            {
                this._rowConfigurationPolicy.invalidateCriteria();
            }
            this._invalidateScale = true;
            invalidateProperties();
        }

        private function invalidateRowConfigurationPolicyResources():void
        {
            if (this._rowConfigurationPolicy)
            {
                this._rowConfigurationPolicy.invalidateResources();
            }
            this._invalidateScale = true;
            invalidateProperties();
        }
    }
}
