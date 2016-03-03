package mokylin.gantt
{
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.ui.Keyboard;
    import flash.utils.Timer;
    
    import mx.collections.ICollectionView;
    import mx.collections.IHierarchicalCollectionView;
    import mx.collections.IViewCursor;
    import mx.collections.errors.ItemPendingError;
    import mx.core.ClassFactory;
    import mx.core.EventPriority;
    import mx.core.FlexShape;
    import mx.core.IDataRenderer;
    import mx.core.IFactory;
    import mx.core.IFlexModuleFactory;
    import mx.core.IInvalidating;
    import mx.core.IProgrammaticSkin;
    import mx.core.IPropertyChangeNotifier;
    import mx.core.IToolTip;
    import mx.core.IUIComponent;
    import mx.core.ScrollPolicy;
    import mx.core.UIComponent;
    import mx.core.mx_internal;
    import mx.effects.easing.Linear;
    import mx.events.CollectionEvent;
    import mx.events.CollectionEventKind;
    import mx.events.FlexEvent;
    import mx.events.PropertyChangeEvent;
    import mx.events.ResizeEvent;
    import mx.events.SandboxMouseEvent;
    import mx.graphics.SolidColorStroke;
    import mx.managers.CursorManagerPriority;
    import mx.managers.ToolTipManager;
    import mx.resources.IResourceManager;
    import mx.resources.ResourceManager;
    import mx.styles.CSSStyleDeclaration;
    import mx.utils.StringUtil;
    import mx.utils.UIDUtil;
    
    import spark.components.Group;
    import spark.components.HScrollBar;
    import spark.components.VScrollBar;
    import spark.events.TrackBaseEvent;
    import spark.primitives.Line;
    
    import __AS3__.vec.Vector;
    
    import mokylin.SelectionMode;
    import mokylin.core.DataItem;
    import mokylin.gantt.supportClasses.PendingToolTipInfo;
    import mokylin.utils.AssetsUtil;
    import mokylin.utils.CSSUtil;
    import mokylin.utils.Cursor;
    import mokylin.utils.DataUtil;
    import mokylin.utils.EventUtil;
    import mokylin.utils.TimeComputer;
    import mokylin.utils.TimeUnit;
    import mokylin.utils.TimeUtil;

    [ResourceBundle("mokylingantt")]
    [Event(name="autoScroll", type="mokylin.gantt.GanttSheetEvent")]
    [Event(name="change", type="mokylin.gantt.GanttSheetEvent")]
    [Event(name="itemClick", type="mokylin.gantt.GanttSheetEvent")]
    [Event(name="itemDoubleClick", type="mokylin.gantt.GanttSheetEvent")]
    [Event(name="itemEditBegin", type="mokylin.gantt.GanttSheetEvent")]
    [Event(name="itemEditDrag", type="mokylin.gantt.GanttSheetEvent")]
    [Event(name="itemEditEnd", type="mokylin.gantt.GanttSheetEvent")]
    [Event(name="itemEditMove", type="mokylin.gantt.GanttSheetEvent")]
    [Event(name="itemEditReassign", type="mokylin.gantt.GanttSheetEvent")]
    [Event(name="itemEditResize", type="mokylin.gantt.GanttSheetEvent")]
    [Event(name="itemEditConstraint", type="mokylin.gantt.GanttSheetEvent")]
    [Event(name="itemRollOut", type="mokylin.gantt.GanttSheetEvent")]
    [Event(name="itemRollOver", type="mokylin.gantt.GanttSheetEvent")]
    [Event(name="visibleTimeRangeChange", type="mokylin.gantt.GanttSheetEvent")]
    [Event(name="dataTipCreate", type="mx.events.ToolTipEvent")]
    [Style(name="scrollMargin", type="Number", format="Length", inherit="no")]
    [Style(name="dataTipShowDelay", type="Number", format="Time", inherit="no")]
    [Style(name="editingTipShowDelay", type="Number", format="Time", inherit="no")]
    [Style(name="animationDuration", type="Number", format="Time", inherit="no")]
    [Style(name="easingFunction", type="Function", inherit="no")]
    [Style(name="invalidReassignCursor", type="Class", inherit="no")]
    [Style(name="invalidReassignCursorOffset", type="Array", arrayType="int", inherit="no")]
    [Style(name="createConstraintCursor", type="Class", inherit="no")]
    [Style(name="createConstraintCursorOffset", type="Array", arrayType="int", inherit="no")]
    [Style(name="moveCursor", type="Class", inherit="no")]
    [Style(name="moveCursorOffset", type="Array", arrayType="int", inherit="no")]
    [Style(name="moveReassignCursor", type="Class", inherit="no")]
    [Style(name="moveReassignCursorOffset", type="Array", arrayType="int", inherit="no")]
    [Style(name="panCursor", type="Class", inherit="no")]
    [Style(name="reassignCursor", type="Class", inherit="no")]
    [Style(name="reassignCursorOffset", type="Array", arrayType="int", inherit="no")]
    [Style(name="resizeEndCursor", type="Class", inherit="no")]
    [Style(name="resizeEndCursorOffset", type="Array", arrayType="int", inherit="no")]
    [Style(name="resizeStartCursor", type="Class", inherit="no")]
    [Style(name="resizeStartCursorOffset", type="Array", arrayType="int", inherit="no")]
    [Style(name="useRollOver", type="Boolean", inherit="no")]
    [Style(name="alternatingItemColors", type="Array", arrayType="uint", format="Color", inherit="yes")]
    [Style(name="horizontalGridLineColor", type="uint", format="Color", inherit="yes")]
    [Style(name="nonWorkingAlpha", type="Number", inherit="yes")]
    [Style(name="nonWorkingColor", type="uint", format="Color", inherit="yes")]
    [Style(name="workingAlpha", type="Number", inherit="yes")]
    [Style(name="workingColor", type="uint", format="Color", inherit="yes")]
    [Style(name="timeGridAlpha", type="Number", inherit="yes")]
    [Style(name="timeGridColor", type="uint", format="Color", inherit="yes")]
    [Style(name="paddingBottom", type="Number", format="Length", inherit="no")]
    [Style(name="paddingTop", type="Number", format="Length", inherit="no")]
    [Style(name="rowPadding", type="Number", format="Length", inherit="no", deprecatedReplacement="paddingTop", deprecatedSince="IBM&#160;ILOG&#160;Elixir&#160;Enterprise 3.5")]
    [Style(name="verticalGap", type="Number", format="Length", inherit="no")]
    [Style(name="percentOverlap", type="Number", inherit="no")]
    [Style(name="cancelMoveYThreshold", type="Number", inherit="no")]
    [Style(name="reassignXThreshold", type="Number", inherit="no")]
    [Style(name="createConstraintLineColor", type="uint", format="Color", inherit="yes")]
    [Style(name="createConstraintLineThickness", type="Number", inherit="no")]
    [Style(name="wheelZoomFactor", type="Number", inherit="no")]
    [Style(name="autoScrollRepeatInterval", type="Number", inherit="no")]
    [Style(name="autoScrollXThreshold", type="Number", inherit="no")]
    [Style(name="autoScrollYThreshold", type="Number", inherit="no")]
    [Style(name="autoScrollXMaximum", type="Number", inherit="no")]
    [Style(name="autoScrollYMaximum", type="Number", inherit="no")]
	/**
	 *  
	 */	
    public class GanttSheet extends UIComponent 
    {
		[Embed(source="assets/GanttSheet_CREATE_CONSTRAINT_CURSOR.png")]
        private static const CREATE_CONSTRAINT_CURSOR:Class;
        private static const CLIPPING_RENDERER_MARGIN:Number = 2000;
        private static const AUTOSCROLL_REPEAT_INTERVAL:Number = 100;
        private static const AUTOSCROLL_X_MAX:Number = 40;
        private static const AUTOSCROLL_X_THRESHOLD:Number = 20;
        private static const AUTOSCROLL_Y_MAX:Number = 20;
        private static const AUTOSCROLL_Y_THRESHOLD:Number = 10;
        private static const EDIT_BEGIN_DRAG_X_THRESHOLD:Number = 4;
        private static const EDIT_BEGIN_DRAG_Y_THRESHOLD:Number = 10;
        private static const EDIT_DRAG_TARGET_Y_THRESHOLD:Number = 6;
        private static const EXTREMITY_AREA_X_EXTENT:Number = 10;//n. 极端-区域-X-n. 程度；范围；长度
        private static const PANNING_THRESHOLD:Number = 3;
        private static const TOOLTIP_Y_OFFSET:Number = 4;
        private static const TOOLTIP_X_OFFSET:Number = 4;
        private static const BAR_MOVE_REASSIGN:String = TaskItemArea.BAR + "movereassign";
        private static const BAR_MOVE:String = TaskItemArea.BAR + "move";
        private static const BAR_REASSIGN:String = TaskItemArea.BAR + "reassign";
        private static const BAR_CREATE_CONSTRAINT:String = TaskItemArea.BAR + "createconstraint";

        protected static var precisionScale:Array = [
		{
            "unit":TimeUnit.MILLISECOND,
            "steps":1
        }, 
		{
            "unit":TimeUnit.MILLISECOND,
            "steps":5
        },
		{
            "unit":TimeUnit.MILLISECOND,
            "steps":10
        }, 
		{
            "unit":TimeUnit.MILLISECOND,
            "steps":25
        }, 
		{
            "unit":TimeUnit.MILLISECOND,
            "steps":50
        }, 
		{
            "unit":TimeUnit.MILLISECOND,
            "steps":100
        }, 
		{
            "unit":TimeUnit.MILLISECOND,
            "steps":150
        }, 
		{
            "unit":TimeUnit.MILLISECOND,
            "steps":200
        }, 
		{
            "unit":TimeUnit.MILLISECOND,
            "steps":250
        },
		{
            "unit":TimeUnit.MILLISECOND,
            "steps":500
        }, 
		{
            "unit":TimeUnit.SECOND,
            "steps":1
        },
		{
            "unit":TimeUnit.SECOND,
            "steps":5
        }, 
		{
            "unit":TimeUnit.SECOND,
            "steps":10
        }, 
		{
            "unit":TimeUnit.SECOND,
            "steps":15
        }, 
		{
            "unit":TimeUnit.SECOND,
            "steps":20
        }, 
		{
            "unit":TimeUnit.SECOND,
            "steps":30
        }];

        private var _pendingToolTipInfo:PendingToolTipInfo;
        private var _updatingHorizontalScrollBar:Boolean;
        private var _draggingHorizontalScrollBar:Boolean;
        private var _updatingVerticalScrollBar:Boolean;
        private var _draggingVerticalScrollBar:Boolean;
        private var _tasksIntervalStart:Number;
        private var _tasksIntervalEnd:Number;
        private var _rowHeightChanged:Boolean;
        private var _autoScrollOffset:Point;
        private var _autoScrollPoint:Point;
        private var _autoScrollVertical:Boolean;
        private var _autoScrollHorizontal:Boolean;
        private var _gridsChanged:Boolean;
		public var _content:UIComponent;
        protected var horizontalScrollBar:HScrollBar;
        protected var verticalScrollBar:VScrollBar;
        private var _constraintCreationLayer:Group;
        private var _constraintCreationLine:Line;
		public var _backGridsContent:UIComponent;
		public var _frontGridsContent:UIComponent;
        private var _maskShape:FlexShape;
        private var _taskItems:Object;
        private var _constraintItems:Object;
        private var _highlightUID:String;
        private var _useRollOver:Boolean;
        private var _selectedUIDs:Object;
        private var _isMouseDown:Boolean;
        private var _isCtrlMouseDown:Boolean;
        private var _mouseDownVerticalOffset:Number;
        private var _mouseDownTime:Number;
        private var _isDragging:Boolean;
        private var _isCreatingConstraint:Boolean;
        private var _isDraggingSet:Boolean;
        private var _isDraggingX:Boolean;
        private var _isDraggingY:Boolean;
        private var _isPanning:Boolean;
        private var _hitTestItemArea:String;
        private var _hitTestItem:Object;
        private var _editingCursor:Cursor;
        private var _mouseDownPoint:Point;
        private var _mouseDownItemRenderer:IDataRenderer;
        private var _mouseDownItem:Object;
        private var _editedTaskItem:TaskItem;
        private var _originalResource:Object;
        private var _targetResource:Object;
        private var _sourceTask:Object;
        private var _targetTask:Object;
        private var _mouseDownItemSelected:Boolean;
        private var _autoScrollTimer:Timer;
        private var _computedSnappingTimePrecision:Object;
        private var _dragInitialItemMousePoint:Point;
        private var _dragInitialStartX:Number;
        private var _dragInitialEndX:Number;
        private var _editingToolTip:IToolTip;
        private var _currentDataTip:IToolTip;
//        private var _toolTipDateFormatter:CLDRDateFormatter;
        private var _minorTimeScalePrecisionChanged:Boolean;
        private var _visibleTimeRangeChanged:Boolean;
		private var _visibleNowTimeChanged:Boolean;
        private var _inStopDragging:Boolean;
        private var _tooltipTaskFormat:String;
        private var _tooltipMilestoneFormat:String;
        private var _tooltipConstraintFormat:String;
        private var _tooltipConstraintEndToEndText:String;
        private var _tooltipConstraintEndToStartText:String;
        private var _tooltipConstraintStartToEndText:String;
        private var _tooltipConstraintStartToStartText:String;
        private var _tooltipConstraintUnknownText:String;
        private var _tooltipDateFormat:String;
        private var _resourcesChanged:Boolean;
        private var _tooltipDurationDayText:String;
        private var _tooltipDurationHourText:String;
        private var _tooltipDurationMinuteText:String;
        private var _tooltipDurationSecondText:String;
        private var _tooltipDurationMillisecondText:String;
        private var _tooltipDurationZeroText:String;
        private var _animatedRenderers:Array;
        private var _lastPanningPosition:Point;
        private var _timeBeforePanning:Number;
        private var _verticalScrollBarValueBeforePanning:Number;
        private var _verticalScrollRemainder:Number = 0;
        private var _constraintsCache:ConstraintsCache;
        private var _taskSummaries:Array;
        private var _resizingTaskSummaryDepth:int;
        private var _panCursor:Cursor;
        private var _createConstraintCursor:Cursor;
        private var _invalidReassignCursor:Cursor;
        private var _itemAreaInfo:Object;
        private var _oldUnscaledWidth:Number;
        private var _oldUnscaledHeight:Number;
        private var _oldTimeRectangle:Rectangle;
        private var _styleInitialized:Boolean = false;
        private var _taskVisibleTimeRangeStartFunction:Function;
        private var _taskVisibleTimeRangeEndFunction:Function;
        private var _allowMultipleSelection:Boolean;
        private var _selectionMode:String = "single";
        private var _linkSelectionMinThickness:Number = 3;
        private var _scrollModifierKey:String = "ctrl";
        private var _usePredefinedKeyboardActions:Boolean = true;
        private var _keyboardNavigationModifierKey:String = "none";
        private var _enableKeyboardNavigation:Boolean = true;
        private var _allowWheelZoom:Boolean = true;
        private var _allowWheelScroll:Boolean = true;
        private var _wheelZoomModifierKey:String = "ctrl";
        private var _wheelScrollModifierKey:String = "none";
        private var _reassignModifierKey:String = "none";
        private var _autoResizeSummary:Boolean;
        private var _autoScrollEnabled:Boolean = true;
//        private var _calendar:GregorianCalendar;
		private var _timeComputer:TimeComputer;
        private var _calendarChanged:Boolean;
        private var _commitItemFunction:Function;
        private var _constraintCollection:ICollectionView;
        private var _constraintItemContainer:GanttSheetConstraintContainer;
        private var _constraintItemRenderer:IFactory;
        private var _dataTipField:String = null;
        private var _dataTipFunction:Function = null;
        private var _editKind:String;
        private var _editingTipFunction:Function = null;
        private var _hideNonworkingTimes:Boolean;
        private var _horizontalScrollPolicy:String = "on";
        private var _horizontalScrollPolicyChanged:Boolean;
        private var _verticalScrollPolicy:String = "auto";
        private var _verticalScrollPolicyChanged:Boolean;
        private var _itemStyleNameFunction:Function;
        private var _ganttChart:GanttChartBase;
        private var _ganttChartChanged:Boolean;
        private var _taskItemContainer:GanttSheetTaskContainer;
        public var liveScrolling:Boolean = true;
        private var _minScrollTime:Number=0;
		private var _maxScrollTime:Number=TimeUnit.HOUR.milliseconds;
        private var _timeBoundsChanged:Boolean;
        
        private var _explicitMaxVisibleTime:Number;
        private var _explicitMaxVisibleTimeChanged:Boolean;
		private var _explicitMinZoomFactor:Number;
        private var _explicitMaxZoomFactor:Number;
        private var _explicitMinVisibleTime:Number;
        private var _explicitMinVisibleTimeChanged:Boolean;
		
		private var _explicitVisibleTimeRangeEnd:Number;
		private var _explicitVisibleTimeRangeEndChanged:Boolean;
		private var _explicitVisibleTimeRangeStart:Number;
		private var _explicitVisibleTimeRangeStartChanged:Boolean;
		private var _explicitZoomFactor:Number;
		private var _explicitZoomFactorChanged:Boolean;
        
        private var _panMode:String = "verticalAndHorizontal";
        private var _panModifierKey:String = "none";
        private var _moveEnabled:Boolean = true;
        private var _moveEnabledFunction:Function = null;
        private var _reassignEnabled:Boolean = true;
        private var _reassignEnabledFunction:Function = null;
        private var _createConstraintEnabled:Boolean = false;
        private var _createConstraintEnabledFunction:Function = null;
        private var _createConstraintFunction:Function = null;
        private var _resizeEnabled:Boolean = true;
        private var _resizeEnabledFunction:Function = null;
        private var _resourceChart:ResourceChart;
        private var _resourceChartChanged:Boolean;
        private var _rowController:IRowController;
        private var _backGrids:Vector.<GanttSheetGridBase>;
        private var _frontGrids:Vector.<GanttSheetGridBase>;
        private var _allGrids:Vector.<GanttSheetGridBase>;
        private var _backgroundGrid:BackgroundGrid;
        private var _selectedItems:Array;
        private var _showBackgroundGrid:Boolean = true;
        private var _showDataTips:Boolean = true;
        private var _showEditingTips:Boolean = true;
        private var _showHorizontalGridLines:Boolean;
        private var _showTimeGrid:Boolean = true;
        private var _showWorkingTimesGrid:Boolean = false;
        private var _explicitSnappingTimePrecision:Object;
        private var _taskChart:TaskChart;
        private var _taskCollection:ICollectionView;
        private var _tasksIntervalInvalid:Boolean;
        private var _taskItemRenderer:IFactory;
        private var _taskBackToFrontCompareFunction:Function = null;
        private var _taskBackToFrontSortFunction:Function = null;
        private var _taskLayout:TaskLayout;
        private var _timeController:TimeController;
        private var _timeControllerChanged:Boolean;
        private var _timeGrid:TimeGrid;
        private var _timeScale:TimeScale;
		private var _thumbLine:Sprite;
		
        private var _timeRectangle:Rectangle;
        private var _timeRectangleChanged:Boolean;
        private var _reassignAllowedWhileDragging:Boolean;

        public function GanttSheet()
        {
            this._tasksIntervalStart = TimeUtil.MINIMUM_DATE;
            this._tasksIntervalEnd = TimeUtil.MINIMUM_DATE;
            this._taskItems = {};
            this._constraintItems = {};
            this._selectedUIDs = {};
            this._constraintItemRenderer = new ClassFactory(ConstraintItemRenderer);
            this._selectedItems = [];
            this._taskItemRenderer = new ClassFactory(TaskItemRenderer);
            super();
            this.timeController = new TimeController();
			
            this.initializeDefaultGrids();
            this._itemAreaInfo = this.initItemAreaInfo();
            this._panCursor = new Cursor(this, "panCursor");
            this._createConstraintCursor = new Cursor(this, "createConstraintCursor");
            this._invalidReassignCursor = new Cursor(this, "invalidReassignCursor", "invalidReassignCursorOffset");
            /*this._toolTipDateFormatter = new CLDRDateFormatter();
            this._toolTipDateFormatter.formatString = this._tooltipDateFormat;*/
            this._taskLayout = new TaskLayout();
            this._taskLayout.ganttSheet = this;
            doubleClickEnabled = true;
            addEventListener(ResizeEvent.RESIZE, this.resizeHandler);
            addEventListener(GanttSheetEvent.ITEM_EDIT_DRAG, this.itemEditDragHandler, false, EventPriority.DEFAULT_HANDLER);
            addEventListener(GanttSheetEvent.ITEM_EDIT_MOVE, this.itemEditMoveHandler, false, EventPriority.DEFAULT_HANDLER);
            addEventListener(GanttSheetEvent.ITEM_EDIT_RESIZE, this.itemEditResizeHandler, false, EventPriority.DEFAULT_HANDLER);
            addEventListener(GanttSheetEvent.ITEM_EDIT_REASSIGN, this.itemEditReassignHandler, false, EventPriority.DEFAULT_HANDLER);
            addEventListener(GanttSheetEvent.ITEM_EDIT_END, this.itemEditEndHandler, false, EventPriority.DEFAULT_HANDLER);
            addEventListener(GanttSheetEvent.AUTO_SCROLL, this.autoScrollHandler, false, EventPriority.DEFAULT_HANDLER);
        }

        override public function set initialized(value:Boolean):void
        {
            if (value)
            {
                this.configureInitialVisibleTimeRange();
            }
            super.initialized = value;
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
            var styleDeclaration:CSSStyleDeclaration = CSSUtil.createSelector("GanttSheet", "mokylin.gantt", styleManager);
            styleDeclaration.defaultFactory = function ():void
            {
                this.alternatingItemColors = [0xF7F7F7, 0xFFFFFF];
                this.animationDuration = 500;
                this.autoScrollRepeatInterval = AUTOSCROLL_REPEAT_INTERVAL;
                this.autoScrollXThreshold = AUTOSCROLL_X_THRESHOLD;
                this.autoScrollYThreshold = AUTOSCROLL_Y_THRESHOLD;
                this.autoScrollXMaximum = AUTOSCROLL_X_MAX;
                this.autoScrollYMaximum = AUTOSCROLL_Y_MAX;
                this.cancelMoveYThreshold = 50;
                this.createConstraintCursor = GanttSheet.CREATE_CONSTRAINT_CURSOR;
                this.createConstraintLineColor = 0;
                this.createConstraintLineThickness = 1;
                this.easingFunction = Linear.easeIn;
                this.horizontalGridLineColor = 0xC9C9C9;
                this.invalidReassignCursor = AssetsUtil.INVALID_ACTION_CURSOR;
                this.moveCursor = AssetsUtil.MOVE_ITEM_HORIZONTAL_CURSOR;
                this.moveCursorOffset = undefined;
                this.moveReassignCursor = AssetsUtil.MOVE_ITEM_CURSOR;
                this.moveReassignCursorOffset = undefined;
                this.nonWorkingAlpha = 0.6;
                this.nonWorkingColor = 0xF0F0F0;
                this.paddingBottom = 2;
                this.paddingTop = 2;
                this.panCursor = AssetsUtil.PAN_CURSOR;
                this.percentOverlap = 60;
                this.reassignCursor = AssetsUtil.MOVE_ITEM_VERTICAL_CURSOR;
                this.reassignCursorOffset = undefined;
                this.reassignXThreshold = 30;
                this.resizeEndCursor = AssetsUtil.RESIZE_ITEM_HORIZONTAL_CURSOR;
                this.resizeEndCursorOffset = undefined;
                this.resizeStartCursor = AssetsUtil.RESIZE_ITEM_HORIZONTAL_CURSOR;
                this.resizeStartCursorOffset = undefined;
                this.rowPadding = undefined;
                this.scrollMargin = 20;
                this.timeGridAlpha = 1;
                this.timeGridColor = 0xC9C9C9;
                this.useRollOver = true;
                this.verticalGap = 1;
                this.wheelZoomFactor = 2;
                this.workingAlpha = 0.6;
                this.workingColor = undefined;
            }
            var taskChartDeclaration:CSSStyleDeclaration = CSSUtil.createSelector(".taskChartGanttSheet", null, styleManager);
            taskChartDeclaration.defaultFactory = function ():void
            {
                this.paddingBottom = 4;
                this.paddingTop = 4;
            }
            var resourceChartDeclaration:CSSStyleDeclaration = CSSUtil.createSelector(".resourceChartGanttSheet", null, styleManager);
            resourceChartDeclaration.defaultFactory = function ():void
            {
                this.paddingBottom = 1;
                this.paddingTop = 1;
            }
        }

        [Bindable("taskVisibleTimeRangeStartFunctionChanged")]
        [Inspectable(category="Data", defaultValue="null")]
        public function get taskVisibleTimeRangeStartFunction():Function
        {
            return this._taskVisibleTimeRangeStartFunction;
        }

        public function set taskVisibleTimeRangeStartFunction(value:Function):void
        {
            if (this._taskVisibleTimeRangeStartFunction != value)
            {
                this._taskVisibleTimeRangeStartFunction = value;
                this.invalidateItemsSize();
                this.invalidateTasksInterval();
                dispatchEvent(new Event("taskVisibleTimeRangeStartFunctionChanged"));
            }
        }

        [Bindable("taskVisibleTimeRangeEndFunctionChanged")]
        [Inspectable(category="Data", defaultValue="null")]
        public function get taskVisibleTimeRangeEndFunction():Function
        {
            return this._taskVisibleTimeRangeEndFunction;
        }

        public function set taskVisibleTimeRangeEndFunction(value:Function):void
        {
            if (this._taskVisibleTimeRangeEndFunction != value)
            {
                this._taskVisibleTimeRangeEndFunction = value;
                this.invalidateItemsSize();
                this.invalidateTasksInterval();
                dispatchEvent(new Event("taskVisibleTimeRangeEndFunctionChanged"));
            }
        }

        [Bindable("allowMultipleSelectionChanged")]
        [Inspectable(category="General", defaultValue="false")]
        [Deprecated(replacement="selectionMode", since="ILOG Elixir 3.0")]
        public function get allowMultipleSelection():Boolean
        {
            return this.selectionMode == SelectionMode.MULTIPLE;
        }

        public function set allowMultipleSelection(value:Boolean):void
        {
            this.selectionMode = value ? SelectionMode.MULTIPLE : SelectionMode.SINGLE;
        }

        [Bindable("selectionModeChanged")]
        [Inspectable(category="General", defaultValue="single", enumeration="none,single,multiple")]
        public function get selectionMode():String
        {
            return this._selectionMode;
        }

        public function set selectionMode(value:String):void
        {
            if (this._selectionMode != value)
            {
                this._selectionMode = value;
                dispatchEvent(new Event("selectionModeChanged"));
            }
        }

        [Bindable("linkSelectionMinThicknessChanged")]
        [Inspectable(category="General", type="Number", format="Length", defaultValue="3")]
        public function get linkSelectionMinThickness():Number
        {
            return this._linkSelectionMinThickness;
        }

        public function set linkSelectionMinThickness(value:Number):void
        {
            if (this._linkSelectionMinThickness == value)
            {
                return;
            }
            this._linkSelectionMinThickness = value;
            if (this._constraintItemContainer)
            {
                this._constraintItemContainer.invalidateItemsSize();
            }
            dispatchEvent(new Event("linkSelectionMinThicknessChanged"));
        }

        [Inspectable(category="General", defaultValue="ctrl", enumeration="none,ctrl,alt,shift")]
        public function get scrollModifierKey():String
        {
            return this._scrollModifierKey;
        }

        public function set scrollModifierKey(value:String):void
        {
            this._scrollModifierKey = value;
        }

        [Bindable("usePredefinedKeyboardActionsChanged")]
        [Inspectable(category="General", defaultValue="true")]
        public function get usePredefinedKeyboardActions():Boolean
        {
            return this._usePredefinedKeyboardActions;
        }

        public function set usePredefinedKeyboardActions(value:Boolean):void
        {
            if (this._usePredefinedKeyboardActions != value)
            {
                this._usePredefinedKeyboardActions = value;
                dispatchEvent(new Event("usePredefinedKeyboardActionsChanged"));
            }
        }

        [Inspectable(category="General", defaultValue="none", enumeration="none,ctrl,alt,shift")]
        public function get keyboardNavigationModifierKey():String
        {
            return this._keyboardNavigationModifierKey;
        }

        public function set keyboardNavigationModifierKey(value:String):void
        {
            this._keyboardNavigationModifierKey = value;
        }

        [Inspectable(category="General", defaultValue="true")]
        public function get keyboardNavigationEnabled():Boolean
        {
            return this._enableKeyboardNavigation;
        }

        public function set keyboardNavigationEnabled(value:Boolean):void
        {
            if (this._enableKeyboardNavigation != value)
            {
                this._enableKeyboardNavigation = value;
            }
        }

        [Bindable("allowWheelZoomChanged")]
        [Inspectable(category="General", defaultValue="true")]
        public function get allowWheelZoom():Boolean
        {
            return this._allowWheelZoom;
        }

        public function set allowWheelZoom(value:Boolean):void
        {
            if (this._allowWheelZoom != value)
            {
                this._allowWheelZoom = value;
                dispatchEvent(new Event("allowWheelZoomChanged"));
            }
        }

        [Bindable("allowWheelScrollChanged")]
        [Inspectable(category="General", defaultValue="true")]
        public function get allowWheelScroll():Boolean
        {
            return this._allowWheelScroll;
        }

        public function set allowWheelScroll(value:Boolean):void
        {
            if (this._allowWheelScroll != value)
            {
                this._allowWheelScroll = value;
                dispatchEvent(new Event("allowWheelScrollChanged"));
            }
        }

        [Bindable("wheelZoomModifierKeyChanged")]
        [Inspectable(category="General", defaultValue="ctrl", enumeration="none,ctrl,alt,shift")]
        public function get wheelZoomModifierKey():String
        {
            return this._wheelZoomModifierKey;
        }

        public function set wheelZoomModifierKey(value:String):void
        {
            if (this._wheelZoomModifierKey != value)
            {
                this._wheelZoomModifierKey = value;
                dispatchEvent(new Event("wheelZoomModifierKeyChanged"));
            }
        }

        [Bindable("wheelScrollModifierKeyChanged")]
        [Inspectable(category="General", defaultValue="none", enumeration="none,ctrl,alt,shift")]
        public function get wheelScrollModifierKey():String
        {
            return this._wheelScrollModifierKey;
        }

        public function set wheelScrollModifierKey(value:String):void
        {
            if (this._wheelScrollModifierKey != value)
            {
                this._wheelScrollModifierKey = value;
                dispatchEvent(new Event("wheelScrollModifierKeyChanged"));
            }
        }

        [Bindable("reassignModifierKeyChanged")]
        [Inspectable(category="General", defaultValue="none", enumeration="none,ctrl,alt,shift")]
        public function get reassignModifierKey():String
        {
            return this._reassignModifierKey;
        }

        public function set reassignModifierKey(value:String):void
        {
            if (this._reassignModifierKey != value)
            {
                this._reassignModifierKey = value;
                dispatchEvent(new Event("reassignModifierKeyChanged"));
            }
        }

		public function set autoResizeSummary(value:Boolean):void
        {
            this._autoResizeSummary = value;
            if (this._autoResizeSummary)
            {
                if (this._editKind)
                {
                    this._taskSummaries = this.taskChart.getTaskSummaries(this._mouseDownItem);
                    this.updateTaskSummaries(this._taskSummaries, true);
                }
                else
                {
                    this.resizeSummaryTasks();
                }
            }
            else if (!this._autoResizeSummary)
			{
				this._taskSummaries = null;
			}
        }

        [Bindable("autoScrollEnabledChanged")]
        [Inspectable(category="General", defaultValue="true")]
        public function get autoScrollEnabled():Boolean
        {
            return this._autoScrollEnabled;
        }

        public function set autoScrollEnabled(value:Boolean):void
        {
            if (this._autoScrollEnabled != value)
            {
                this._autoScrollEnabled = value;
                dispatchEvent(new Event("autoScrollEnabledChanged"));
            }
        }

        public function get timeComputer():TimeComputer
        {
            if (!this._timeComputer)
            {
                this.setTimeComputer(new TimeComputer());
            }
            return this._timeComputer;
        }

		public function setTimeComputer(value:TimeComputer):void
        {
            if (!value)
            {
                value = new TimeComputer();
            }
            if (value == this._timeComputer)
            {
                return;
            }
			this._timeComputer = value;
            /*if (this._timeComputer != null)
            {
                this._timeComputer.removeEventListener(Event.CHANGE, this.calendar_changeHandler);
            }
            this._timeComputer = value;
            if (this._timeComputer != null)
            {
                this._timeComputer.addEventListener(Event.CHANGE, this.calendar_changeHandler, false, 0, true);
            }
            this._calendarChanged = true;*/
            invalidateProperties();
        }

        public function get commitItemFunction():Function
        {
            return this._commitItemFunction;
        }

        public function set commitItemFunction(value:Function):void
        {
            this._commitItemFunction = value;
        }

		public function get constraintsCache():ConstraintsCache
        {
            if (!this._constraintsCache)
            {
                this._constraintsCache = new ConstraintsCache();
                this._constraintsCache.taskChart = this.taskChart;
            }
            return this._constraintsCache;
        }

        public function get constraintClipRectangle():Rectangle
        {
            if (!this._constraintItemContainer)
            {
                return null;
            }
            return this._constraintItemContainer.clipRectangle;
        }

		public function get constraintCollection():ICollectionView
        {
            return this._constraintCollection;
        }

		public function set constraintCollection(value:ICollectionView):void
        {
            this.stopDragging(GanttSheetEventReason.OTHER);
            if (this._constraintCollection)
            {
                this._constraintCollection.removeEventListener(CollectionEvent.COLLECTION_CHANGE, this.constraintCollection_collectionChangeHandler);
            }
            this._constraintCollection = value;
            if (this._constraintCollection)
            {
                this._constraintCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE, this.constraintCollection_collectionChangeHandler, false, 0, true);
            }
            this.clearConstraintData();
            var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
            event.kind = CollectionEventKind.RESET;
            this.constraintCollection_collectionChangeHandler(event);
            dispatchEvent(event);
            this.invalidateItemsSize();
            invalidateProperties();
            invalidateSize();
            invalidateDisplayList();
        }

        private function get constraintItemContainer():GanttSheetConstraintContainer
        {
            return this._constraintItemContainer;
        }

        [Bindable("constraintItemRendererChanged")]
        [Inspectable(category="Data")]
        public function get constraintItemRenderer():IFactory
        {
            return this._constraintItemRenderer;
        }

        public function set constraintItemRenderer(value:IFactory):void
        {
            if (this._constraintItemRenderer == value)
            {
                return;
            }
            this._constraintItemRenderer = value;
            if (this._constraintItemContainer)
            {
                this._constraintItemContainer.itemRenderer = this._constraintItemRenderer;
            }
            dispatchEvent(new Event("constraintItemRendererChanged"));
        }

        [Bindable("dataTipFieldChanged")]
        [Inspectable(category="Data", defaultValue="null")]
        public function get dataTipField():String
        {
            return this._dataTipField;
        }

        public function set dataTipField(value:String):void
        {
            this._dataTipField = value;
            this.invalidateItemsSize();
            dispatchEvent(new Event("dataTipFieldChanged"));
        }

        [Bindable("dataTipFunctionChanged")]
        [Inspectable(category="Data", defaultValue="null")]
        public function get dataTipFunction():Function
        {
            return this._dataTipFunction;
        }

        public function set dataTipFunction(value:Function):void
        {
            this._dataTipFunction = value;
            this.invalidateItemsSize();
            dispatchEvent(new Event("dataTipFunctionChanged"));
        }

        public function get editKind():String
        {
            return this._editKind;
        }

        [Bindable("editingTipFunctionChanged")]
        [Inspectable(category="Data", defaultValue="null")]
        public function get editingTipFunction():Function
        {
            return this._editingTipFunction;
        }

        public function set editingTipFunction(value:Function):void
        {
            this._editingTipFunction = value;
            dispatchEvent(new Event("editingTipFunctionChanged"));
        }

        override public function set enabled(value:Boolean):void
        {
            if (!value)
            {
                this.stopDragging(GanttSheetEventReason.OTHER);
            }
            super.enabled = value;
            if (this.horizontalScrollBar)
            {
                this.horizontalScrollBar.enabled = value;
            }
            if (this.verticalScrollBar)
            {
                this.verticalScrollBar.enabled = value;
            }
        }

       /* [Bindable("hideNonworkingTimesChanged")]
        [Inspectable(category="General")]
        public function get hideNonworkingTimes():Boolean
        {
            if (this.timeController != null)
            {
                return this.timeController.hideNonworkingTimes;
            }
            return this._hideNonworkingTimes;
        }

        public function set hideNonworkingTimes(value:Boolean):void
        {
            if (this.hideNonworkingTimes == value)
            {
                return;
            }
            this._hideNonworkingTimes = value;
            if (this.timeController != null)
            {
                this.timeController.hideNonworkingTimes = value;
            }
            dispatchEvent(new Event("hideNonworkingTimesChanged"));
        }*/

        [Bindable("horizontalScrollPolicyChanged")]
        [Inspectable(enumeration="off,on", defaultValue="on")]
        public function get horizontalScrollPolicy():String
        {
            return this._horizontalScrollPolicy;
        }

        public function set horizontalScrollPolicy(value:String):void
        {
            if (this._horizontalScrollPolicy != value)
            {
                this._horizontalScrollPolicy = value;
                this._horizontalScrollPolicyChanged = true;
                this.invalidateTimeRectangle();
                dispatchEvent(new Event("horizontalScrollPolicyChanged"));
            }
        }

        [Bindable("verticalScrollPolicyChanged")]
        [Inspectable(enumeration="off,on,auto", defaultValue="auto")]
        public function get verticalScrollPolicy():String
        {
            return this._verticalScrollPolicy;
        }

        public function set verticalScrollPolicy(value:String):void
        {
            if (this._verticalScrollPolicy != value)
            {
                this._verticalScrollPolicy = value;
                this._verticalScrollPolicyChanged = true;
                this.invalidateTimeRectangle();
                dispatchEvent(new Event("verticalScrollPolicyChanged"));
            }
        }

        public function get itemStyleNameFunction():Function
        {
            return this._itemStyleNameFunction;
        }

        public function set itemStyleNameFunction(value:Function):void
        {
            this._itemStyleNameFunction = value;
            if (this._taskItemContainer)
            {
                this._taskItemContainer.cleanupItemRenderers();
                this._taskItemContainer.invalidateProperties();
            }
            if (this._constraintItemContainer)
            {
                this._constraintItemContainer.invalidateItemsSize();
            }
        }

        public function get ganttChart():GanttChartBase
        {
            return this._ganttChart;
        }

		public function setGanttChart(value:GanttChartBase):void
        {
            if (value == this._ganttChart)
            {
                return;
            }
            this._ganttChart = value;
            this._ganttChartChanged = true;
            invalidateProperties();
        }

		public function get taskItemContainer():GanttSheetTaskContainer
        {
            return this._taskItemContainer;
        }

        public function get liveTaskLayout():Boolean
        {
            return this._taskLayout.liveTaskLayout;
        }

        public function set liveTaskLayout(value:Boolean):void
        {
            this._taskLayout.liveTaskLayout = value;
        }

        [Bindable("minScrollTimeChanged")]
        [Inspectable(category="General")]
        public function get minScrollTime():Number
        {
            this.validateTasksInterval();
            return this._minScrollTime != 0 ? this._minScrollTime : this._tasksIntervalStart;
        }

        public function set minScrollTime(value:Number):void
        {
            if((value != 0 && this._minScrollTime != 0 && value == this._minScrollTime) || (value == 0 && this._minScrollTime == 0))
            {
                return;
            }
            this._minScrollTime = value;
            this.invalidateTimeBounds();
            dispatchEvent(new Event("minScrollTimeChanged"));
        }

        [Bindable("maxScrollTimeChanged")]
        [Inspectable(category="General")]
        public function get maxScrollTime():Number
        {
            this.validateTasksInterval();
            return this._maxScrollTime != 0 ? this._maxScrollTime : this._tasksIntervalEnd;
        }

        public function set maxScrollTime(value:Number):void
        {
            if ((value != 0 && this._maxScrollTime != 0 && value == this._maxScrollTime) || (value == 0 && this._maxScrollTime == 0))
            {
                return;
            }
            this._maxScrollTime = value;
            this.invalidateTimeBounds();
            dispatchEvent(new Event("maxScrollTimeChanged"));
        }

        [Bindable("maxVisibleTimeChanged")]
        [Inspectable(category="General")]
        public function get maxVisibleTime():Number
        {
            if (this._explicitMaxVisibleTimeChanged)
            {
                return this._explicitMaxVisibleTime;
            }
            if (this._timeController)
            {
                return this._timeController.maximumTime;
            }
            return TimeUtil.MAXIMUM_DATE;
        }

        public function set maxVisibleTime(value:Number):void
        {
            this._explicitMaxVisibleTime = value;
            this._explicitMaxVisibleTimeChanged = true;
            invalidateProperties();
        }

        [Bindable("maxZoomFactorChanged")]
        [Inspectable(category="General")]
        public function get maxZoomFactor():Number
        {
            if (this._timeController)
            {
                return this._timeController.maximumZoomFactor;
            }
            return this._explicitMaxZoomFactor;
        }

        public function set maxZoomFactor(value:Number):void
        {
            this._explicitMaxZoomFactor = value;
            if (this._timeController)
            {
                this._timeController.maximumZoomFactor = value;
            }
            dispatchEvent(new Event("maxZoomFactorChanged"));
        }

        [Bindable("minVisibleTimeChanged")]
        [Inspectable(category="General")]
        public function get minVisibleTime():Number
        {
            if (this._explicitMinVisibleTimeChanged)
            {
                return this._explicitMinVisibleTime;
            }
            if (this._timeController)
            {
                return this._timeController.minimumTime;
            }
            return TimeUtil.MINIMUM_DATE;
        }

        public function set minVisibleTime(value:Number):void
        {
            this._explicitMinVisibleTime = value;
            this._explicitMinVisibleTimeChanged = true;
            invalidateProperties();
        }

        [Bindable("minZoomFactorChanged")]
        [Inspectable(category="General")]
        public function get minZoomFactor():Number
        {
            if (this._timeController)
            {
                return this._timeController.minimumZoomFactor;
            }
            return this._explicitMinZoomFactor;
        }

        public function set minZoomFactor(value:Number):void
        {
            this._explicitMinZoomFactor = value;
            if (this._timeController)
            {
                this._timeController.minimumZoomFactor = value;
            }
            dispatchEvent(new Event("minZoomFactorChanged"));
        }

        [Inspectable(category="General", enumeration="none,vertical,horizontal,verticalAndHorizontal", defaultValue="verticalAndHorizontal")]
        public function get panMode():String
        {
            return this._panMode;
        }

        public function set panMode(value:String):void
        {
            this._panMode = value;
        }

        [Bindable("panModifierKeyChanged")]
        [Inspectable(category="General", defaultValue="none", enumeration="none,ctrl,alt,shift")]
        public function get panModifierKey():String
        {
            return this._panModifierKey;
        }

        public function set panModifierKey(value:String):void
        {
            if (this._panModifierKey != value)
            {
                this._panModifierKey = value;
                dispatchEvent(new Event("panModifierKeyChanged"));
            }
        }

        [Inspectable(category="General", defaultValue="true")]
        public function get moveEnabled():Boolean
        {
            return this._moveEnabled;
        }

        public function set moveEnabled(value:Boolean):void
        {
            this._moveEnabled = value;
        }

        [Bindable("moveEnabledFunctionChanged")]
        [Inspectable(category="General", defaultValue="null")]
        public function get moveEnabledFunction():Function
        {
            return this._moveEnabledFunction;
        }

        public function set moveEnabledFunction(value:Function):void
        {
            this._moveEnabledFunction = value;
            dispatchEvent(new Event("moveEnabledFunctionChanged"));
        }

        [Inspectable(category="General", defaultValue="true")]
        public function get reassignEnabled():Boolean
        {
            return this._reassignEnabled;
        }

        public function set reassignEnabled(value:Boolean):void
        {
            this._reassignEnabled = value;
        }

        [Bindable("reassignEnabledFunctionChanged")]
        [Inspectable(category="General", defaultValue="null")]
        public function get reassignEnabledFunction():Function
        {
            return this._reassignEnabledFunction;
        }

        public function set reassignEnabledFunction(value:Function):void
        {
            this._reassignEnabledFunction = value;
            dispatchEvent(new Event("reassignEnabledFunctionChanged"));
        }

        [Inspectable(category="General", defaultValue="false")]
        public function get createConstraintEnabled():Boolean
        {
            return this._createConstraintEnabled;
        }

        public function set createConstraintEnabled(value:Boolean):void
        {
            this._createConstraintEnabled = value;
        }

        [Bindable("createConstraintEnabledFunctionChanged")]
        [Inspectable(category="General", defaultValue="null")]
        public function get createConstraintEnabledFunction():Function
        {
            return this._createConstraintEnabledFunction;
        }

        public function set createConstraintEnabledFunction(value:Function):void
        {
            this._createConstraintEnabledFunction = value;
            dispatchEvent(new Event("createConstraintEnabledFunctionChanged"));
        }

        [Bindable("createConstraintFunctionChanged")]
        [Inspectable(category="General", defaultValue="null")]
        public function get createConstraintFunction():Function
        {
            return this._createConstraintFunction;
        }

        public function set createConstraintFunction(value:Function):void
        {
            this._createConstraintFunction = value;
            dispatchEvent(new Event("createConstraintFunctionChanged"));
        }

        [Inspectable(category="General", defaultValue="true")]
        public function get resizeEnabled():Boolean
        {
            return this._resizeEnabled;
        }

        public function set resizeEnabled(value:Boolean):void
        {
            this._resizeEnabled = value;
        }

        [Bindable("resizeEnabledFunctionChanged")]
        [Inspectable(category="General", defaultValue="null")]
        public function get resizeEnabledFunction():Function
        {
            return this._resizeEnabledFunction;
        }

        public function set resizeEnabledFunction(value:Function):void
        {
            this._resizeEnabledFunction = value;
            dispatchEvent(new Event("resizeEnabledFunctionChanged"));
        }

        private function get resizingTaskSummaries():Boolean
        {
            return this._resizingTaskSummaryDepth > 0;
        }

        [Inspectable(environment="none")]
        public function get resourceChart():ResourceChart
        {
            return this._resourceChart;
        }

		public function set rowController(value:IRowController):void
        {
            this._rowController = value;
        }

		public function get rowController():IRowController
        {
            return this._rowController;
        }

        [Bindable("backGridsChanged")]
        [Inspectable(category="Other")]
        public function get backGrids():Vector.<GanttSheetGridBase>
        {
            return this._backGrids != null ? this._backGrids.slice() : null;
        }

        public function set backGrids(value:Vector.<GanttSheetGridBase>):void
        {
            if (this._backGrids != null)
            {
                this.disconnectGrids(this._backGrids);
            }
            this._backGrids = value != null ? value.slice() : null;
            if (this._backGrids != null)
            {
                this.connectGrids(this._backGrids);
            }
            this.invalidateGrids();
            dispatchEvent(new Event("backGridsChanged"));
        }

        [Bindable("frontGridsChanged")]
        [Inspectable(category="Other")]
        public function get frontGrids():Vector.<GanttSheetGridBase>
        {
            return this._frontGrids != null ? this._frontGrids.slice() : null;
        }

        public function set frontGrids(value:Vector.<GanttSheetGridBase>):void
        {
            if (this._frontGrids != null)
            {
                this.disconnectGrids(this._frontGrids);
            }
            this._frontGrids = value != null ? value.slice() : null;
            if (this._frontGrids != null)
            {
                this.connectGrids(this._frontGrids);
            }
            this.invalidateGrids();
            dispatchEvent(new Event("frontGridsChanged"));
        }

		public function get allGrids():Vector.<GanttSheetGridBase>
        {
            var backgrid:GanttSheetGridBase;
            var frontgrid:GanttSheetGridBase;
            if (this._allGrids == null)
            {
                this._allGrids = new Vector.<GanttSheetGridBase>();
                if (this._showBackgroundGrid)
                {
                    this._allGrids.push(this.backgroundGrid);
                }
                /*if (this._showWorkingTimesGrid)
                {
                    this._allGrids.push(this.workingTimesGrid);
                }*/
                if (this._showTimeGrid)
                {
                    this._allGrids.push(this.timeGrid);
                }
                if (this._backGrids != null)
                {
                    for each (backgrid in this._backGrids)
                    {
                        this._allGrids.push(backgrid);
                    }
                }
                if (this._frontGrids != null)
                {
                    for each (frontgrid in this._frontGrids)
                    {
                        this._allGrids.push(frontgrid);
                    }
                }
            }
            return this._allGrids;
        }

        [Bindable("backgroundGridChanged")]
        [Inspectable(category="Other")]
        public function get backgroundGrid():BackgroundGrid
        {
            return this._backgroundGrid;
        }

        public function set backgroundGrid(value:BackgroundGrid):void
        {
            if (this._backgroundGrid == value)
            {
                return;
            }
            if (this._backgroundGrid != null)
            {
                this.disconnectGrid(this._backgroundGrid);
            }
            this._backgroundGrid = value != null ? value : this.createDefaultBackgroundGrid();
            if (this._backgroundGrid != null)
            {
                this.connectGrid(this._backgroundGrid);
            }
            if (this._showBackgroundGrid)
            {
                this.invalidateGrids();
            }
            dispatchEvent(new Event("backgroundGridChanged"));
        }

        [Inspectable(category="General", defaultValue="true")]
        [Deprecated(replacement="selectionMode", since="ILOG Elixir 3.0")]
        public function get selectable():Boolean
        {
            return this.selectionMode != SelectionMode.NONE;
        }

        public function set selectable(value:Boolean):void
        {
            this.selectionMode = value ? SelectionMode.SINGLE : SelectionMode.NONE;
        }

        [Bindable("change")]
        [Bindable("valueCommit")]
        [Inspectable(environment="none")]
        public function get selectedItem():Object
        {
            return this._selectedItems.length > 0 ? this._selectedItems[(this._selectedItems.length - 1)] : null;
        }

        public function set selectedItem(item:Object):void
        {
            this.commitSelectedItems([item]);
        }

        [Bindable("change")]
        [Bindable("valueCommit")]
        [Inspectable(environment="none")]
        public function get selectedItems():Array
        {
            return this._selectedItems.concat();
        }

        public function set selectedItems(items:Array):void
        {
            this.commitSelectedItems(items);
        }

        [Bindable("showBackgroundGridChanged")]
        [Inspectable(category="General", defaultValue="true")]
        public function get showBackgroundGrid():Boolean
        {
            return this._showBackgroundGrid;
        }

        public function set showBackgroundGrid(value:Boolean):void
        {
            if (this._showBackgroundGrid == value)
            {
                return;
            }
            this._showBackgroundGrid = value;
            this.invalidateGrids();
            dispatchEvent(new Event("showBackgroundGridChanged"));
        }

        [Bindable("showDataTipsChanged")]
        [Inspectable(category="Data", defaultValue="true")]
        public function get showDataTips():Boolean
        {
            return this._showDataTips;
        }

        public function set showDataTips(value:Boolean):void
        {
            this._showDataTips = value;
            this.invalidateItemsSize();
            dispatchEvent(new Event("showDataTipsChanged"));
        }

        [Bindable("showEditingTipsChanged")]
        [Inspectable(category="Data", defaultValue="true")]
        public function get showEditingTips():Boolean
        {
            return this._showEditingTips;
        }

        public function set showEditingTips(value:Boolean):void
        {
            this._showEditingTips = value;
            this.invalidateItemsSize();
            dispatchEvent(new Event("showEditingTipsChanged"));
        }

        [Bindable("showHorizontalGridLinesChanged")]
        [Inspectable(category="Other", defaultValue="false")]
        public function get showHorizontalGridLines():Boolean
        {
            return this._showHorizontalGridLines;
        }

        public function set showHorizontalGridLines(value:Boolean):void
        {
            if (this._showHorizontalGridLines == value)
            {
                return;
            }
            this._showHorizontalGridLines = value;
            if (this._backgroundGrid != null)
            {
                this._backgroundGrid.showHorizontalGridLines = this._showHorizontalGridLines;
            }
            dispatchEvent(new Event("showHorizontalGridLinesChanged"));
        }

        [Bindable("showTimeGridChanged")]
        [Inspectable(category="Other", defaultValue="true")]
        public function get showTimeGrid():Boolean
        {
            return this._showTimeGrid;
        }

        public function set showTimeGrid(value:Boolean):void
        {
            if (this._showTimeGrid == value)
            {
                return;
            }
            this._showTimeGrid = value;
            this.invalidateGrids();
            dispatchEvent(new Event("showTimeGridChanged"));
        }

        [Bindable("showWorkingTimesGridChanged")]
        [Inspectable(category="Other", defaultValue="true")]
        public function get showWorkingTimesGrid():Boolean
        {
            return this._showWorkingTimesGrid;
        }

        public function set showWorkingTimesGrid(value:Boolean):void
        {
            if (this._showWorkingTimesGrid == value)
            {
                return;
            }
            this._showWorkingTimesGrid = value;
            this.invalidateGrids();
            dispatchEvent(new Event("showWorkingTimesGridChanged"));
        }

        [Bindable("snappingTimePrecisionChanged")]
        [Inspectable(category="General", defaultValue="null")]
        public function get snappingTimePrecision():Object
        {
            if (this._explicitSnappingTimePrecision)
            {
                return this._explicitSnappingTimePrecision;
            }
            if (!this._computedSnappingTimePrecision)
            {
                this._computedSnappingTimePrecision = this.computeTimePrecision();
            }
            return this._computedSnappingTimePrecision;
        }

        public function set snappingTimePrecision(value:Object):void
        {
            this._explicitSnappingTimePrecision = value;
            dispatchEvent(new Event("snappingTimePrecisionChanged"));
        }

        public function snapTime(value:Number):Number
        {
            return this.timeComputer.round(value, this.snappingTimePrecision.unit, this.snappingTimePrecision.steps);
        }

        [Inspectable(environment="none")]
        public function get taskChart():TaskChart
        {
            return this._taskChart;
        }

		public function get taskCollection():ICollectionView
        {
            return this._taskCollection;
        }

		public function set taskCollection(value:ICollectionView):void
        {
            this.stopDragging(GanttSheetEventReason.OTHER);
            if (this._taskCollection)
            {
                this._taskCollection.removeEventListener(CollectionEvent.COLLECTION_CHANGE, this.taskCollection_collectionChangeHandler);
            }
            this._taskCollection = value;
            if (this._taskCollection)
            {
                this._taskCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE, this.taskCollection_collectionChangeHandler, false, 0, true);
            }
            this.clearTaskData();
			
            var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
            event.kind = CollectionEventKind.RESET;
            this.taskCollection_collectionChangeHandler(event);
            dispatchEvent(event);
			
            this.invalidateItemsSize();
            invalidateProperties();
            invalidateSize();
            invalidateDisplayList();
        }

        [Bindable("taskItemRendererChanged")]
        [Inspectable(category="Data")]
        public function get taskItemRenderer():IFactory
        {
            return this._taskItemRenderer;
        }

        public function set taskItemRenderer(value:IFactory):void
        {
            if (this._taskItemRenderer == value)
            {
                return;
            }
            this._taskItemRenderer = value;
            if (this._taskItemContainer)
            {
                this._taskItemContainer.itemRenderer = this._taskItemRenderer;
            }
            if (this._constraintItemContainer)
            {
                this._constraintItemContainer.invalidateItemsSize();
            }
            this.invalidateRowItemsSize();
            dispatchEvent(new Event("taskItemRendererChanged"));
        }

        [Inspectable(category="Data")]
        public function get taskBackToFrontCompareFunction():Function
        {
            return this._taskBackToFrontCompareFunction;
        }

        public function set taskBackToFrontCompareFunction(value:Function):void
        {
            if (this._taskBackToFrontCompareFunction == value)
            {
                return;
            }
            this._taskBackToFrontCompareFunction = value;
            this.invalidateItemsSize();
        }

        [Deprecated(replacement="taskBackToFrontCompareFunction", since="IBM ILOG Elixir Enterprise 3.5")]
        [Inspectable(category="Data")]
        public function get taskBackToFrontSortFunction():Function
        {
            return this._taskBackToFrontSortFunction;
        }

        public function set taskBackToFrontSortFunction(value:Function):void
        {
            if (this._taskBackToFrontSortFunction == value)
            {
                return;
            }
            this._taskBackToFrontSortFunction = value;
            this.invalidateItemsSize();
        }

		public function get taskLayout():TaskLayout
        {
            return this._taskLayout;
        }

		public function set taskLayout(value:TaskLayout):void
        {
            if (this._taskLayout == value)
            {
                return;
            }
            this._taskLayout = value;
            this.invalidateItemsSize();
        }

		public function get timeController():TimeController
        {
            return this._timeController;
        }

		public function set timeController(value:TimeController):void
        {
            if (this._timeController == value)
            {
                return;
            }
            if (this._timeController)
            {
				this._timeController.removeEventListener(GanttSheetEvent.VISIBLE_NOW_TIME_CHANGE, this.timeController_visibleNowTimeChangeHandler);
                this._timeController.removeEventListener(GanttSheetEvent.VISIBLE_TIME_RANGE_CHANGE, this.timeController_visibleTimeRangeChangeHandler);
            }
            this._timeController = value;
            if (this._timeController)
            {
                if (this._explicitMinZoomFactor)
                {
                    this._timeController.minimumZoomFactor = this._explicitMinZoomFactor;
                }
                if (this._explicitMaxZoomFactor)
                {
                    this._timeController.maximumZoomFactor = this._explicitMaxZoomFactor;
                }
                if (this._explicitMinVisibleTime && this._explicitMaxVisibleTime)
                {
                    this._timeController.setTimeBounds(this._explicitMinVisibleTime, this._explicitMaxVisibleTime);
                }
                else if (this._explicitMinVisibleTime)
				{
					this._timeController.setTimeBounds(this._explicitMinVisibleTime, this._timeController.maximumTime);
				}
				else if (this._explicitMaxVisibleTime)
				{
					this._timeController.setTimeBounds(this._timeController.minimumTime, this._explicitMaxVisibleTime);
				}
                this._timeController.addEventListener(GanttSheetEvent.VISIBLE_TIME_RANGE_CHANGE, this.timeController_visibleTimeRangeChangeHandler);
				this._timeController.addEventListener(GanttSheetEvent.VISIBLE_NOW_TIME_CHANGE, this.timeController_visibleNowTimeChangeHandler);
            }
            this._timeControllerChanged = true;
            invalidateProperties();
        }

        [Bindable("timeGridChanged")]
        [Inspectable(category="Other")]
        public function get timeGrid():TimeGrid
        {
            return this._timeGrid;
        }

        public function set timeGrid(value:TimeGrid):void
        {
            if (this._timeGrid == value)
            {
                return;
            }
            if (this._timeGrid != null)
            {
                this.disconnectGrid(this._timeGrid);
            }
            this._timeGrid = value != null ? value : this.createDefaultTimeGrid();
            if (this._timeGrid != null)
            {
                this.connectGrid(this._timeGrid);
            }
            if (this._showTimeGrid)
            {
                this.invalidateGrids();
            }
            dispatchEvent(new Event("timeGridChanged"));
        }

		public function get timeScale():TimeScale
        {
            return this._timeScale;
        }

		public function set timeScale(value:TimeScale):void
        {
            this.stopListeningOnTimeScaleChanges();
            this._timeScale = value;
            if (this._timeScale)
            {
				this._thumbLine.visible = this._timeScale.showThumb;
                if (this._timeScale.initialized)
                {
                    this.startListeningOnTimeScaleChanges();
                }
                else
                {
                    this._timeScale.addEventListener(FlexEvent.CREATION_COMPLETE, this.timeScale_creationCompleteHandler);
                }
            }
        }

        [Bindable("visibleTimeRangeChange")]
        [Inspectable(category="General")]
        public function get visibleTimeRangeEnd():Number
        {
            if (this._timeController && this._timeController.configured)
            {
                return this._timeController.endTime;
            }
            if (this._explicitVisibleTimeRangeEndChanged)
            {
                return this._explicitVisibleTimeRangeEnd;
            }
            return this.maxVisibleTime;
        }

        public function set visibleTimeRangeEnd(value:Number):void
        {
            if (value == 0 || value == this.visibleTimeRangeEnd)
            {
                return;
            }
            this._explicitVisibleTimeRangeEnd = value;
            this._explicitVisibleTimeRangeEndChanged = true;
            invalidateProperties();
        }

        [Bindable("visibleTimeRangeChange")]
        [Inspectable(category="General")]
        public function get visibleTimeRangeStart():Number
        {
            if (this._timeController && this._timeController.configured)
            {
                return this._timeController.startTime;
            }
            if (this._explicitVisibleTimeRangeStartChanged)
            {
                return this._explicitVisibleTimeRangeStart;
            }
            return this.minVisibleTime;
        }

        public function set visibleTimeRangeStart(value:Number):void
        {
            if (value == 0)
            {
                return;
            }
            this._explicitVisibleTimeRangeStart = value;
            this._explicitVisibleTimeRangeStartChanged = true;
            invalidateProperties();
        }

        [Bindable("visibleTimeRangeChange")]
        [Inspectable(category="General")]
        public function get zoomFactor():Number
        {
            if (this._timeController && this._timeController.configured)
            {
                return this._timeController.zoomFactor;
            }
            if (this._explicitZoomFactorChanged)
            {
                return this._explicitZoomFactor;
            }
            return NaN;
        }

        public function set zoomFactor(value:Number):void
        {
            this._explicitZoomFactor = value;
            this._explicitZoomFactorChanged = true;
            invalidateProperties();
        }

		public function isClippedCoordinate(x:Number):Boolean
        {
            var min:Number = -CLIPPING_RENDERER_MARGIN;
            var max:Number = width + CLIPPING_RENDERER_MARGIN;
            return x == min || x == max;
        }

        public function getClippedCoordinate(time:Number):Number
        {
            if (!initialized)
            {
                return -1;
            }
            var min:Number = -CLIPPING_RENDERER_MARGIN;
            var max:Number = width + CLIPPING_RENDERER_MARGIN;
            var x0:Number = this._timeController.getCoordinate(time);
            if (x0 < min)
            {
                x0 = min;
            }
            else if (x0 > max)
			{
				x0 = max;
			}
            return x0;
        }

        public function getCoordinate(time:Number):Number
        {
            return initialized ? this._timeController.getCoordinate(time) : -1;
        }

		/**
		 * 根据坐标获得对应的时间值 
		 * @param x
		 * @return 
		 * 
		 */		
        public function getTime(x:Number):Number
        {
            return initialized ? this._timeController.getTime(x) : 0;
        }

        public function moveTo(time:Number, animate:Boolean=false):void
        {
            if (initialized)
            {
                this._timeController.moveTo(time, animate);
            }
        }

        private function shiftByCoordinate(delta:Number, animate:Boolean=false):void
        {
            if (initialized)
            {
                this._timeController.shiftByCoordinate(delta, animate);
            }
        }

        private function shiftByProjectedTime(delta:Number, animate:Boolean=false):void
        {
            if (initialized)
            {
                this._timeController.shiftByProjectedTime(delta, animate);
            }
        }

        public function showAll(margin:Number=-1, animate:Boolean=false):void
        {
            this.showTimeRange(this.minScrollTime, this.maxScrollTime, margin, animate);
        }

        public function showTimeRange(start:Number, end:Number, margin:Number=-1, animate:Boolean=false):void
        {
            if (initialized)
            {
                if (margin < 0)
                {
                    margin = getStyle("scrollMargin");
                }
                this._timeController.configure(start, end, this.timeRectangle.width, margin, animate);
            }
        }

		public function getTaskTimeRange():Object
        {
            var range:Object;
            try
            {
                range = this.getFlatTaskCollectionTimeRange(this._taskCollection as ICollectionView);
            }
            catch(e:ItemPendingError)
            {
            }
            return range;
        }

		public function isTaskItemVisible(taskItem:TaskItem, start:Number, end:Number):Boolean
        {
            var itemStart:Number = this.getVisibleStartTime(taskItem);
            var itemEnd:Number = this.getVisibleEndTime(taskItem);
            return itemStart < end && itemEnd > start;
        }

		public function getVisibleStartTime(taskItem:TaskItem):Number
        {
            return this._taskVisibleTimeRangeStartFunction != null ? this._taskVisibleTimeRangeStartFunction(taskItem) : taskItem.startTime;
        }

		public function getVisibleEndTime(taskItem:TaskItem):Number
        {
            return this._taskVisibleTimeRangeEndFunction != null ? this._taskVisibleTimeRangeEndFunction(taskItem) : taskItem.endTime;
        }

		/**
		 * 取得 整个任务集合中最小的开始时间和最大的结束时间
		 * @param tasks
		 * @return 
		 * 
		 */		
        private function getFlatTaskCollectionTimeRange(tasks:ICollectionView):Object
        {
            var rangeStart:Number;
            var rangeEnd:Number;
            var taskItem:TaskItem;
            var taskItemStart:Number;
            var taskItemEnd:Number;
            if (!tasks)
            {
                return null;
            }
            var first:Boolean = true;
            var cursor:IViewCursor = tasks.createCursor();
            while (!cursor.afterLast)
            {
                taskItem = this.itemToTaskItem(cursor.current);
                taskItemStart = this.getVisibleStartTime(taskItem);
                taskItemEnd = this.getVisibleEndTime(taskItem);
                if (isNaN(taskItemStart) || isNaN(taskItemEnd))
                {
                }
                else
                {
                    if (first)
                    {
                        first = false;
                        rangeStart = taskItemStart;
                        rangeEnd = taskItemEnd;
                    }
                    else
                    {
                        if (taskItemStart < rangeStart)
                        {
                            rangeStart = taskItemStart;
                        }
                        if (taskItemEnd > rangeEnd)
                        {
                            rangeEnd = taskItemEnd;
                        }
                    }
                }
                cursor.moveNext();
            }
            if (isNaN(rangeStart) || isNaN(rangeEnd))
            {
                return null;
            }
            return ({
                "start":new Date(rangeStart),
                "end":new Date(rangeEnd)
            });
        }

        public function zoom(ratio:Number, time:Number=0, animate:Boolean=false):void
        {
            if (initialized)
            {
                this._timeController.zoomAndCenter(ratio, time, animate);
            }
        }

        public function scrollToItem(item:Object, margin:Number=10):void
        {
            var taskItem:TaskItem;
            var constraintItem:ConstraintItem;
            var fromTaskItem:TaskItem;
            var toTaskItem:TaskItem;
            var start:Number;
            var end:Number;
            if (!(initialized))
            {
                return;
            }
            var dataItem:DataItem = this.itemToDataItem(item);
            if (dataItem is TaskItem)
            {
                taskItem = TaskItem(dataItem);
                this.ensureRangeVisible(taskItem.startTime, taskItem.endTime, margin);
            }
            else if (dataItem is ConstraintItem)
			{
				constraintItem = ConstraintItem(dataItem);
				fromTaskItem = this.itemToTaskItem(constraintItem.fromTask);
				toTaskItem = this.itemToTaskItem(constraintItem.toTask);
				start = fromTaskItem.startTime;
				if (toTaskItem.startTime < start)
				{
					start = toTaskItem.startTime;
				}
				end = fromTaskItem.endTime;
				if (toTaskItem.endTime > end)
				{
					end = toTaskItem.endTime;
				}
				this.ensureRangeVisible(start, end, margin);
			}
        }

        private function ensureRangeVisible(start:Number, end:Number, margin:Number=10):void
        {
            var visibleStart:Number = this._timeController.startTime;
            var visibleEnd:Number = this._timeController.endTime;
            var visibleCenter:Number = (visibleStart + visibleEnd) / 2;
            var center:Number = (start + end) / 2;
            var visibleDuration:Number = visibleEnd - visibleStart;
            var animate:Boolean = Math.abs(visibleCenter - center) < (2 * visibleDuration);
            var marginDuration:Number = margin * this._timeController.zoomFactor;
            if ((end - start) < (visibleDuration - (2 * marginDuration)))
            {
                if (start < (visibleStart + marginDuration))
                {
                    this._timeController.moveTo((start - marginDuration), animate);
                }
                else if (end > (visibleEnd - marginDuration))
				{
					this._timeController.moveTo((visibleStart + end - visibleEnd + marginDuration), animate);
				}
            }
            else
            {
                this._timeController.configure(start, end, this._timeController.width, margin, animate);
            }
        }

        public function isItemConstraintTarget(item:Object):Boolean
        {
            return item == this._targetTask;
        }

        public function isItemConstraintSource(item:Object):Boolean
        {
            return item == this._sourceTask;
        }

        public function isItemHighlighted(item:Object):Boolean
        {
            if (item == null)
            {
                return false;
            }
            return this.itemToUID(item) == this._highlightUID;
        }

        public function isItemSelected(item:Object):Boolean
        {
            if (item == null)
            {
                return false;
            }
            return this._selectedUIDs[this.itemToUID(item)] != undefined;
        }

        protected function commitSelectedItems(items:Array):void
        {
            var item:Object;
            var oldSelectedItems:Array = this._selectedItems;
            this._selectedItems = items.concat();
            this._selectedUIDs = {};
            for each (item in items)
            {
                this._selectedUIDs[this.itemToUID(item)] = item;
            }
            this.invalidateItemsDisplayList(oldSelectedItems);
            this.invalidateItemsDisplayList(items);
            dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
        }

        private function selectItem(item:Object):void
        {
            this.selectedItems = [item];
        }

        private function toggleSelection(item:Object):void
        {
            var selection:Array = this._selectedItems;
            var index:int = selection.indexOf(item);
            if (index != -1)
            {
                selection.splice(index, 1);
            }
            else
            {
                selection.push(item);
            }
            this.selectedItems = selection;
        }

        private function clearSelection():void
        {
            this.selectedItems = [];
        }

        private function initializeDefaultGrids():void
        {
            this._backgroundGrid = this.createDefaultBackgroundGrid();
            this.connectGrid(this._backgroundGrid);
//            this._workingTimesGrid = this.createDefaultWorkingTimesGrid();
//            this.connectGrid(this._workingTimesGrid);
            this._timeGrid = this.createDefaultTimeGrid();
            this.connectGrid(this._timeGrid);
        }

        private function invalidateGrids():void
        {
            this._gridsChanged = true;
            this._allGrids = null;
            invalidateProperties();
        }

        private function updateGridsInContainer(container:UIComponent, newgrids:Vector.<GanttSheetGridBase>):void
        {
            var grid:GanttSheetGridBase;
            var grid1:GanttSheetGridBase;
            while (container.numChildren != 0)
            {
                grid = (container.getChildAt(0) as GanttSheetGridBase);
                container.removeChildAt(0);
            }
            if (newgrids != null)
            {
                for each (grid1 in newgrids)
                {
                    container.addChild(grid1);
                }
            }
        }

        private function disconnectGrid(grid:GanttSheetGridBase):void
        {
            grid.setGanttSheet(null);
        }

        private function connectGrid(grid:GanttSheetGridBase):void
        {
            grid.setGanttSheet(this);
        }

        private function connectGrids(grids:Vector.<GanttSheetGridBase>):void
        {
            var grid:GanttSheetGridBase;
            for each (grid in grids)
            {
                this.connectGrid(grid);
            }
        }

        private function disconnectGrids(grids:Vector.<GanttSheetGridBase>):void
        {
            var grid:GanttSheetGridBase;
            for each (grid in grids)
            {
                this.disconnectGrid(grid);
            }
        }

        private function updateGrids():void
        {
            var grid:GanttSheetGridBase;
            if (this._backGridsContent == null)
            {
                return;
            }
            var backGrids:Vector.<GanttSheetGridBase> = new Vector.<GanttSheetGridBase>();
            if (this._showBackgroundGrid)
            {
                backGrids.push(this.backgroundGrid);
            }
            /*if (this._showWorkingTimesGrid)
            {
                backGrids.push(this.workingTimesGrid);
            }*/
            if (this._backGrids != null)
            {
                for each (grid in this._backGrids)
                {
                    backGrids.push(grid);
                }
            }
            if (this._showTimeGrid)
            {
                backGrids.push(this.timeGrid);
            }
            this.updateGridsInContainer(this._backGridsContent, backGrids);
            this.updateGridsInContainer(this._frontGridsContent, this._frontGrids);
        }

        public function itemToUID(item:Object):String
        {
            if (item == null)
            {
                return "null";
            }
            return UIDUtil.getUID(item);
        }

        private function getDataItem(item:Object):Object
        {
            return item is DataItem ? DataItem(item).data : item;
        }

        private function mouseEventToItemRenderer(event:MouseEvent):Object
        {
            if (event == null)
            {
                return null;
            }
            return this.displayObjectToItemRenderer(DisplayObject(event.target));
        }

        private function displayObjectToItemRenderer(object:DisplayObject):Object
        {
            while (object && object.parent != this._content)
            {
                if (object.parent == this._taskItemContainer || object.parent == this._constraintItemContainer)
                {
                    if (object.visible)
                    {
                        return object;
                    }
                    return null;
                }
                if (object is IUIComponent)
                {
                    object = IUIComponent(object).owner;
                }
                else
                {
                    object = object.parent;
                }
            }
            return null;
        }

        public function itemToItemRenderer(item:Object):IDataRenderer
        {
            var renderer:Object;
            if (this._taskItemContainer)
            {
                renderer = this._taskItemContainer.itemToItemRenderer(item);
            }
            if (!renderer && this._constraintItemContainer)
            {
                renderer = this._constraintItemContainer.itemToItemRenderer(item);
            }
            return IDataRenderer(renderer);
        }

		public function getConnectionBounds(task:Object):Rectangle
        {
            if (this._taskItemContainer)
            {
                return this._taskItemContainer.getConnectionBounds(task);
            }
            return null;
        }

        public function isItemVisible(item:Object):Boolean
        {
            return this.itemToItemRenderer(item) != null;
        }

        public function hasOverlappingSiblings(item:Object):Boolean
        {
            var task:Object;
            var other:TaskItem;
            if (this.taskChart != null)
            {
                return false;
            }
            var taskItem:TaskItem = this.itemToTaskItem(item);
            var rowItem:Object = this.taskItemToRowItem(taskItem);
            var rowLayoutInfo:RowLayoutInfo = this._taskLayout.getRowLayoutInfo(rowItem, null, false);
            if (rowLayoutInfo != null && rowLayoutInfo.laneCount == 0)
            {
                return false;
            }
            var taskLayoutInfo:TaskLayoutInfo = this._taskLayout.getTaskLayoutInfo(item, taskItem.uid, false);
            if (taskLayoutInfo != null && taskLayoutInfo.laneIndex > 0)
            {
                return true;
            }
            var siblings:Array = this.ganttChart.rowItemToTasks(rowItem);
            var start:Number = taskItem.startTime;
            var end:Number = taskItem.endTime;
            for each (task in siblings)
            {
                other = this.itemToTaskItem(task);
                if (other && other != taskItem && other.startTime < end && other.endTime > start)
                {
                    return true;
                }
            }
            return false;
        }

		public function itemToStyleName(item:DataItem):Object
        {
            var taskItem:TaskItem;
            if (!item)
            {
                return null;
            }
            var styleName:Object;
            if (this._itemStyleNameFunction != null)
            {
                styleName = this._itemStyleNameFunction(item);
            }
            else
            {
                if (item is TaskItem)
                {
                    taskItem = TaskItem(item);
                    if (taskItem.isMilestone)
                    {
                        styleName = this._ganttChart.getStyle("milestoneItemStyleName");
                    }
                    else if (taskItem.isSummary)
					{
						styleName = this._ganttChart.getStyle("summaryItemStyleName");
					}
                    else
                    {
                        styleName = this._ganttChart.getStyle("taskItemStyleName");
                    }
                }
                else if (item is ConstraintItem)
				{
					styleName = this._ganttChart.getStyle("constraintItemStyleName");
				}
            }
            if (styleName is String && String(styleName).length != 0)
            {
                return styleManager.getStyleDeclaration("." + styleName);
            }
            return null;
        }

        public function itemToDataTip(item:Object):String
        {
            var value:Object;
            if (!item)
            {
                return null;
            }
            var dataItem:DataItem = this.itemToDataItem(item);
            if (this.dataTipFunction != null)
            {
                return this.dataTipFunction(dataItem);
            }
            if (this.dataTipField != null)
            {
                value = DataUtil.getFieldValue(dataItem, this.dataTipField);
                return value != null ? String(value) : null;
            }
            return this.dataItemToDefaultToolTip(dataItem);
        }

        public function itemToEditingTip(item:Object):String
        {
            if (item == null)
            {
                return null;
            }
            var dataItem:DataItem = this.itemToDataItem(item);
            if (this.editingTipFunction != null)
            {
                return this.editingTipFunction(dataItem);
            }
            return this.dataItemToDefaultToolTip(dataItem);
        }

        private function dataItemToDefaultToolTip(dataItem:DataItem):String
        {
            if (dataItem is TaskItem)
            {
                return this.taskItemToDefaultToolTip(TaskItem(dataItem));
            }
            if (dataItem is ConstraintItem)
            {
                return this.constraintItemToDefaultToolTip(ConstraintItem(dataItem));
            }
            return null;
        }

        private function taskItemToDefaultToolTip(taskItem:TaskItem):String
        {
            var durationValue:Number;
            var durationText:String;
            var itemText:String = taskItem.label!=null ? taskItem.label : "";
            var format:String = taskItem.isMilestone ? this._tooltipMilestoneFormat : this._tooltipTaskFormat;
            var durationZero:Boolean;
            var duration:Number = taskItem.endTime - taskItem.startTime;
            if (duration >= TimeUnit.DAY.milliseconds)
            {
                durationValue = Math.ceil(duration / TimeUnit.DAY.milliseconds);
                durationText = this._tooltipDurationDayText;
            }
            else if (duration >= TimeUnit.HOUR.milliseconds)
			{
				durationValue = Math.ceil(duration / TimeUnit.HOUR.milliseconds);
				durationText = this._tooltipDurationHourText;
			}
			else if (duration >= TimeUnit.MINUTE.milliseconds)
			{
				durationValue = Math.ceil(duration / TimeUnit.MINUTE.milliseconds);
				durationText = this._tooltipDurationMinuteText;
			}
			else if (duration >= TimeUnit.SECOND.milliseconds)
			{
				durationValue = Math.ceil(duration / TimeUnit.SECOND.milliseconds);
				durationText = this._tooltipDurationSecondText;
			}
			else if (duration > 0)
			{
				durationValue = Math.ceil(duration / TimeUnit.MILLISECOND.milliseconds);
				durationText = this._tooltipDurationMillisecondText;
			}
			else
			{
				durationZero = true;
				durationValue = 0;
				durationText = this._tooltipDurationZeroText;
			}
            return StringUtil.substitute(format, itemText, /*this._toolTipDateFormatter.format(*/taskItem.startTime/*)*/, durationZero ? durationText : durationValue, durationZero ? "" : durationText, /*this._toolTipDateFormatter.format(*/taskItem.endTime/*)*/);
        }

        private function constraintItemToDefaultToolTip(constraintItem:ConstraintItem):String
        {
            var fromTaskItem:TaskItem = this.itemToTaskItem(constraintItem.fromTask);
            var toTaskItem:TaskItem = this.itemToTaskItem(constraintItem.toTask);
            var fromTaskLabel:String = "";
            if (fromTaskItem && fromTaskItem.label != null)
            {
                fromTaskLabel = fromTaskItem.label;
            }
            var toTaskLabel:String = "";
            if (toTaskItem && toTaskItem.label != null)
            {
                toTaskLabel = toTaskItem.label;
            }
            var kindText:String = "";
            switch (constraintItem.kind)
            {
                case ConstraintKind.END_TO_END:
                    kindText = this._tooltipConstraintEndToEndText;
                    break;
                case ConstraintKind.END_TO_START:
                    kindText = this._tooltipConstraintEndToStartText;
                    break;
                case ConstraintKind.START_TO_END:
                    kindText = this._tooltipConstraintStartToEndText;
                    break;
                case ConstraintKind.START_TO_START:
                    kindText = this._tooltipConstraintStartToStartText;
                    break;
                default:
                    kindText = this._tooltipConstraintUnknownText;
            }
            return StringUtil.substitute(this._tooltipConstraintFormat, kindText, fromTaskLabel, toTaskLabel);
        }

        private function isItemMoveEnabledInternal(item:Object):Boolean
        {
            var dataItem:DataItem;
            if (!this._moveEnabled || item == null)
            {
                return false;
            }
            if (this._moveEnabledFunction != null)
            {
                dataItem = this.itemToDataItem(item);
                return dataItem != null && this._moveEnabledFunction(dataItem);
            }
            return this.isItemMoveEnabled(item);
        }

//        [Deprecated(replacement="moveEnabledFunction", since="ILOG Elixir 2.0")]
        protected function isItemMoveEnabled(item:Object):Boolean
        {
            var taskItem:TaskItem;
            var dataItem:DataItem = this.itemToDataItem(item);
            if (dataItem is TaskItem)
            {
                taskItem = TaskItem(dataItem);
                if (taskItem.isSummary && this._autoResizeSummary)
                {
                    return false;
                }
                return true;
            }
            return false;
        }

        private function isItemEditable(item:Object, itemArea:String):Boolean
        {
            if (itemArea == TaskItemArea.START)
            {
                return this.isItemResizeEnabledInternal(item, TaskItemEditKind.RESIZE_START);
            }
            if (itemArea == TaskItemArea.END)
            {
                return this.isItemResizeEnabledInternal(item, TaskItemEditKind.RESIZE_END);
            }
            if (itemArea == TaskItemArea.BAR)
            {
                return this.isItemMoveEnabledInternal(item);
            }
            return false;
        }

        private function isItemResizeEnabledInternal(item:Object, editKind:String):Boolean
        {
            var dataItem:DataItem;
            if (!this._resizeEnabled || item == null)
            {
                return false;
            }
            if (this._resizeEnabledFunction != null)
            {
                dataItem = this.itemToDataItem(item);
                return dataItem != null && this._resizeEnabledFunction(dataItem, editKind);
            }
            return this.isItemResizeEnabled(item, editKind);
        }

//        [Deprecated(replacement="resizeEnabledFunction", since="ILOG Elixir 2.0")]
        protected function isItemResizeEnabled(item:Object, editKind:String):Boolean
        {
            var taskItem:TaskItem;
            var dataItem:DataItem = this.itemToDataItem(item);
            if (dataItem is TaskItem)
            {
                taskItem = TaskItem(dataItem);
                if (taskItem.isMilestone || (taskItem.isSummary && this._autoResizeSummary))
                {
                    return false;
                }
                return true;
            }
            return false;
        }

        private function isConstraintCreationEnabledInternal(item:Object, source:Boolean):Boolean
        {
            var dataItem:DataItem;
            if (this.taskChart == null)
            {
                return false;
            }
            if (!this._createConstraintEnabled || item == null)
            {
                return false;
            }
            if (this._createConstraintEnabledFunction != null)
            {
                dataItem = this.itemToDataItem(item);
                return dataItem != null && this._createConstraintEnabledFunction(dataItem, source);
            }
            return true;
        }

        private function isItemReassignEnabledInternal(item:Object):Boolean
        {
            var dataItem:DataItem;
            if (this.taskChart != null)
            {
                return false;
            }
            if (!this._reassignEnabled || item == null)
            {
                return false;
            }
            if (this._reassignEnabledFunction != null)
            {
                dataItem = this.itemToDataItem(item);
                return dataItem != null && this._reassignEnabledFunction(dataItem);
            }
            return this.isItemReassignEnabled(item);
        }

//        [Deprecated(replacement="reassignEnabledFunction", since="ILOG Elixir 2.0")]
        protected function isItemReassignEnabled(item:Object):Boolean
        {
            return true;
        }

		public function sortTasks(tasks:Array):Array
        {
            var index:int;
            var tmpTasks:Array;
            if (tasks == null)
            {
                return null;
            }
            if (!this.liveTaskLayout && this._editedTaskItem != null)
            {
                index = tasks.indexOf(this._editedTaskItem);
                if (index != -1)
                {
                    tmpTasks = tasks.concat();
                    tmpTasks.splice(index, 1);
                    tmpTasks = this.sortTasksImpl(tmpTasks);
                    tmpTasks.push(this._editedTaskItem);
                    return tmpTasks;
                }
            }
            return this.sortTasksImpl(tasks);
        }

        private function sortTasksImpl(tasks:Array):Array
        {
            if (this._taskBackToFrontSortFunction != null)
            {
                return this._taskBackToFrontSortFunction(tasks);
            }
            if (this._taskBackToFrontCompareFunction != null)
            {
                return tasks.sort(this._taskBackToFrontCompareFunction);
            }
            if (this._taskLayout != null)
            {
                return tasks.sort(this._taskLayout.compareLaneIndexAndStart);
            }
            return tasks;
        }

        override protected function commitProperties():void
        {
            var grid2:GanttSheetGridBase;
            var computedMin:Number;
            var computedMax:Number;
            var tempVisibleTimeStart:Number;
            var tempVisibleTimeEnd:Number;
            var computedStart:Number;
            var computedEnd:Number;
            var row:TimeScaleRow;
            super.commitProperties();
            this.validateTasksInterval();
            var mustUpdateVerticalScrollBar:Boolean = this._timeRectangleChanged || this._verticalScrollPolicyChanged || this._rowHeightChanged;
            var mustUpdateHorizontalScrollBar:Boolean = this._timeRectangleChanged || this._timeControllerChanged || this._visibleTimeRangeChanged || this._timeBoundsChanged || this._horizontalScrollPolicyChanged;
            if (this._gridsChanged)
            {
                this._gridsChanged = false;
                this.updateGrids();
            }
            if (this._ganttChartChanged)
            {
                this._ganttChartChanged = false;
                this._resourceChart = this._ganttChart as ResourceChart;
                this._taskChart = this._ganttChart as TaskChart;
                if (this._taskItemContainer)
                {
                    this._taskItemContainer.ganttChart = this._ganttChart;
                }
                if (this._constraintItemContainer)
                {
                    this._constraintItemContainer.ganttChart = this._ganttChart;
                }
            }
            if (this._timeControllerChanged)
            {
                this._timeControllerChanged = false;
                if (this._timeController)
                {
                    this._timeController.timeComputer = this.timeComputer;
                    /*this._timeController.workCalendar = this._workCalendar;
                    this._timeController.hideNonworkingTimes = this._hideNonworkingTimes;*/
                    this.styleChanged(null);
                }
                for each (grid2 in this.allGrids)
                {
                    grid2.timeControllerChangedInternal();
                }
                if (this._taskItemContainer)
                {
                    this._taskItemContainer.timeController = this.timeController;
                }
                if (this._constraintItemContainer)
                {
                    this._constraintItemContainer.timeController = this.timeController;
                }
            }
            if (this._calendarChanged)
            {
                this._calendarChanged = false;
                this.stopDragging(GanttSheetEventReason.OTHER);
                if (this._timeController)
                {
                    this._timeController.timeComputer = this.timeComputer;
                }
            }
            if (this._resourcesChanged)
            {
                this._resourcesChanged = false;
                /*if (this._toolTipDateFormatter != null)
                {
                    this._toolTipDateFormatter.formatString = this._tooltipDateFormat;
                }*/
            }
            if (this._explicitMinVisibleTimeChanged || this._explicitMaxVisibleTimeChanged)
            {
                computedMin = Math.min(this.minVisibleTime, this.maxVisibleTime);
                computedMax = Math.max(this.maxVisibleTime, this.minVisibleTime);
                this._timeController.setTimeBounds(computedMin, computedMax);
                if (this._explicitMinVisibleTimeChanged)
                {
                    dispatchEvent(new Event("minVisibleTimeChanged"));
                }
                if (this._explicitMaxVisibleTimeChanged)
                {
                    dispatchEvent(new Event("maxVisibleTimeChanged"));
                }
                this._explicitMinVisibleTimeChanged = false;
                this._explicitMaxVisibleTimeChanged = false;
            }
            if (this._explicitVisibleTimeRangeStartChanged || this._explicitVisibleTimeRangeEndChanged)
            {
                if (this._timeController.configured)
                {
                    tempVisibleTimeStart = this._explicitVisibleTimeRangeStartChanged ? this._explicitVisibleTimeRangeStart : this._timeController.startTime;
                    tempVisibleTimeEnd = this._explicitVisibleTimeRangeEndChanged ? this._explicitVisibleTimeRangeEnd : this._timeController.endTime;
                    computedStart = Math.max(Math.min(tempVisibleTimeStart, tempVisibleTimeEnd), this.minVisibleTime);
                    computedEnd = Math.min(Math.max(tempVisibleTimeStart, tempVisibleTimeEnd), this.maxVisibleTime);
                    this._timeController.configure(computedStart, computedEnd, this.timeRectangle.width);
                }
                this._explicitVisibleTimeRangeStartChanged = false;
                this._explicitVisibleTimeRangeEndChanged = false;
            }
            if (this._explicitZoomFactorChanged)
            {
                if (this._timeController.configured)
                {
                    this._timeController.zoomFactor = this._explicitZoomFactor;
                }
                this._explicitZoomFactorChanged = false;
            }
            if (this._visibleTimeRangeChanged)
            {
                this._visibleTimeRangeChanged = false;
                this._computedSnappingTimePrecision = this.computeTimePrecision();
            }
			if(_visibleNowTimeChanged)
			{
				_visibleNowTimeChanged = false;
				invalidateDisplayList();
			}
            if (this._minorTimeScalePrecisionChanged)
            {
				this._minorTimeScalePrecisionChanged = false;
				row = this.timeScale ? this.timeScale.minorScaleRow : null;
				if (row != null)
				{
					this.synchronizeTimeGridsWithTimeScaleRow(row);
				}
            }
            if (mustUpdateVerticalScrollBar)
            {
                this._verticalScrollPolicyChanged = false;
                this._rowHeightChanged = false;
                this.updateVerticalScrollBar();
            }
            if (this._timeRectangleChanged)
            {
                this._timeRectangleChanged = false;
                this._timeRectangle = null;
                if (this._timeController.configured)
                {
                    this._timeController.width = this.timeRectangle.width;
                }
                invalidateDisplayList();
            }
            if (mustUpdateHorizontalScrollBar)
            {
                this._timeBoundsChanged = false;
                this._horizontalScrollPolicyChanged = false;
                this.updateHorizontalScrollBar();
            }
        }

        private function invalidateTimeBounds():void
        {
            this._timeBoundsChanged = true;
            invalidateProperties();
        }

        private function synchronizeTimeGridsWithTimeScaleRow(row:TimeScaleRow):void
        {
			var grid:GanttSheetGridBase;
			for each (grid in this.allGrids)
			{
				if (grid is TimeGrid)
				{
					TimeGrid(grid).setTimeScaleUnit(row.tickUnit, row.tickSteps);
				}
			}
        }

        private function createDefaultBackgroundGrid():BackgroundGrid
        {
            var rowGrid:BackgroundGrid = new BackgroundGrid();
            rowGrid.name = "rowGrid";
            rowGrid.showHorizontalGridLines = this._showHorizontalGridLines;
            rowGrid.mouseEnabled = false;
            return rowGrid;
        }

        private function createDefaultTimeGrid():TimeGrid
        {
            var timeGrid:TimeGrid = new TimeGrid();
            timeGrid.name = "timeGrid";
            timeGrid.mouseEnabled = false;
            return timeGrid;
        }

        override protected function createChildren():void
        {
            var g:Graphics;
            var horizontalScrollBarStyleName:String;
            var verticalScrollBarStyleName:String;
            super.createChildren();
            if (!this._maskShape)
            {
                this._maskShape = new FlexShape();
                this._maskShape.name = "mask";
                g = this._maskShape.graphics;
                g.beginFill(0xFFFFFF);
                g.drawRect(0, 0, 10, 10);
                g.endFill();
                addChild(this._maskShape);
            }
            this._maskShape.visible = false;
			
            if (!this.horizontalScrollBar)
            {
                this.horizontalScrollBar = new HScrollBar();
                this.horizontalScrollBar.enabled = enabled;
                this.horizontalScrollBar.name = "hScrollBar";
                horizontalScrollBarStyleName = getStyle("horizontalScrollBarStyleName");
                this.horizontalScrollBar.styleName = horizontalScrollBarStyleName;
                this.horizontalScrollBar.addEventListener(TrackBaseEvent.THUMB_PRESS, this.horizontalScrollBar_thumbPressHandler);
                this.horizontalScrollBar.addEventListener(TrackBaseEvent.THUMB_RELEASE, this.horizontalScrollBar_thumbReleaseHandler);
                this.horizontalScrollBar.addEventListener(FlexEvent.VALUE_COMMIT, this.horizontalScrollBar_valueCommitHandler);
                this.horizontalScrollBar.addEventListener(FlexEvent.CREATION_COMPLETE, this.horizontalScrollBar_creationCompleteHandler);
                this.horizontalScrollBar.setStyle("smoothScrolling", false);
                addChild(this.horizontalScrollBar);
            }
            if (!this.verticalScrollBar)
            {
                this.verticalScrollBar = new VScrollBar();
                this.verticalScrollBar.enabled = enabled;
                this.verticalScrollBar.name = "vScrollBar";
                verticalScrollBarStyleName = getStyle("verticalScrollBarStyleName");
                this.verticalScrollBar.styleName = verticalScrollBarStyleName;
                this.verticalScrollBar.addEventListener(FlexEvent.VALUE_COMMIT, this.verticalScrollBar_valueCommitHandler);
                this.verticalScrollBar.addEventListener(TrackBaseEvent.THUMB_PRESS, this.verticalScrollBar_thumbPressHandler);
                this.verticalScrollBar.addEventListener(TrackBaseEvent.THUMB_RELEASE, this.verticalScrollBar_thumbReleaseHandler);
                addChild(this.verticalScrollBar);
            }
            if (!this._content)
            {
                this._content = new UIComponent();
                this._content.name = "content";
                this._content.mask = this._maskShape;
                this._content.addEventListener(MouseEvent.MOUSE_OVER, this.content_mouseOverHandler);
                this._content.addEventListener(MouseEvent.MOUSE_OUT, this.content_mouseOutHandler);
                this._content.addEventListener(MouseEvent.CLICK, this.content_clickHandler);
                this._content.addEventListener(MouseEvent.DOUBLE_CLICK, this.content_doubleClickHandler);
                this._content.addEventListener(MouseEvent.MOUSE_DOWN, this.content_mouseDownHandler);
                this._content.addEventListener(MouseEvent.MOUSE_MOVE, this.content_mouseMoveHandler);
                this._content.addEventListener(MouseEvent.ROLL_OUT, this.content_rollOutHandler);
                addChild(this._content);
            }
            if (!this._backGridsContent)
            {
                this._backGridsContent = new UIComponent();
                this._backGridsContent.name = "backGridsContent";
                this._backGridsContent.mouseEnabled = false;
                this._content.addChild(this._backGridsContent);
            }
            if (!this._taskItemContainer)
            {
                this._taskItemContainer = new GanttSheetTaskContainer(this);
                this._taskItemContainer.name = "itemContainer";
                this._taskItemContainer.ganttChart = this._ganttChart;
                this._taskItemContainer.styleName = this;
                this._taskItemContainer.timeController = this.timeController;
                this._taskItemContainer.itemRenderer = this._taskItemRenderer;
                this._content.addChild(this._taskItemContainer);
            }
            if (!this._constraintItemContainer)
            {
                this._constraintItemContainer = new GanttSheetConstraintContainer(this);
                this._constraintItemContainer.name = "constraintContainer";
                this._constraintItemContainer.ganttChart = this._ganttChart;
                this._constraintItemContainer.styleName = this;
                this._constraintItemContainer.timeController = this.timeController;
                this._constraintItemContainer.itemRenderer = this._constraintItemRenderer;
                this._content.addChild(this._constraintItemContainer);
            }
            if (!this._frontGridsContent)
            {
                this._frontGridsContent = new UIComponent();
                this._frontGridsContent.name = "frontGridsContent";
                this._frontGridsContent.mouseEnabled = false;
                this._content.addChild(this._frontGridsContent);
            }
			if(!this._thumbLine)
			{
				_thumbLine = new Sprite();
				_thumbLine.mouseEnabled = false;
				this.addChild(_thumbLine);
			}
			this._thumbLine.visible = false;
            this._minorTimeScalePrecisionChanged = true;
            this._gridsChanged = true;
            this._timeBoundsChanged = true;
            invalidateProperties();
        }

        override protected function measure():void
        {
            super.measure();
            measuredWidth = 250;
            measuredHeight = 150;
            if (this.horizontalScrollBar != null)
            {
                measuredMinHeight = this.horizontalScrollBar.measuredMinHeight;
            }
            if (this.verticalScrollBar != null)
            {
                measuredMinWidth = this.verticalScrollBar.measuredMinWidth;
            }
        }

        override protected function resourcesChanged():void
        {
            super.resourcesChanged();
            var resourceManager:IResourceManager = ResourceManager.getInstance();
            this._tooltipTaskFormat = resourceManager.getString("mokylingantt", "tooltip.task.format");
            this._tooltipMilestoneFormat = resourceManager.getString("mokylingantt", "tooltip.milestone.format");
            this._tooltipConstraintFormat = resourceManager.getString("mokylingantt", "tooltip.constraint.format");
            this._tooltipConstraintEndToEndText = resourceManager.getString("mokylingantt", "tooltip.constraint.end.to.end.text");
            this._tooltipConstraintEndToStartText = resourceManager.getString("mokylingantt", "tooltip.constraint.end.to.start.text");
            this._tooltipConstraintStartToEndText = resourceManager.getString("mokylingantt", "tooltip.constraint.start.to.end.text");
            this._tooltipConstraintStartToStartText = resourceManager.getString("mokylingantt", "tooltip.constraint.start.to.start.text");
            this._tooltipConstraintUnknownText = resourceManager.getString("mokylingantt", "tooltip.constraint.unknown.text");
//            this._tooltipDateFormat = resourceManager.getString("mokylingantt", "tooltip.date.format");
            this._tooltipDurationDayText = resourceManager.getString("mokylingantt", "tooltip.duration.day.text");
            this._tooltipDurationHourText = resourceManager.getString("mokylingantt", "tooltip.duration.hour.text");
            this._tooltipDurationMinuteText = resourceManager.getString("mokylingantt", "tooltip.duration.minute.text");
            this._tooltipDurationSecondText = resourceManager.getString("mokylingantt", "tooltip.duration.second.text");
            this._tooltipDurationMillisecondText = resourceManager.getString("mokylingantt", "tooltip.duration.millisecond.text");
            this._tooltipDurationZeroText = resourceManager.getString("mokylingantt", "tooltip.duration.zero.text");
            this._resourcesChanged = true;
            invalidateProperties();
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            if (this._maskShape)
            {
                this._maskShape.x = this.timeRectangle.x;
                this._maskShape.y = this.timeRectangle.y;
                this._maskShape.width = this.timeRectangle.width;
                this._maskShape.height = this.timeRectangle.height;
            }
			if(this._thumbLine)
			{
				_thumbLine.graphics.lineStyle(1,0xff0000);
				_thumbLine.graphics.moveTo(0.5,0.5);
				_thumbLine.graphics.lineTo(0.5,unscaledHeight);
				_thumbLine.x = this.timeController.getCoordinate(this.timeController.nowTime);
			}
            var sizeChanged:Boolean = unscaledWidth != this._oldUnscaledWidth || unscaledHeight != this._oldUnscaledHeight;
            if (sizeChanged)
            {
                this._oldUnscaledHeight = unscaledHeight;
                this._oldUnscaledWidth = unscaledWidth;
            }
            var timeRectangleChanged:Boolean = this._oldTimeRectangle == null 
												|| this.timeRectangle.x != this._oldTimeRectangle.x 
												|| this.timeRectangle.y != this._oldTimeRectangle.y 
												|| this.timeRectangle.width != this._oldTimeRectangle.width 
												|| this.timeRectangle.height != this._oldTimeRectangle.height;
            if (timeRectangleChanged)
            {
                this._oldTimeRectangle = this.timeRectangle.clone();
            }
            if (sizeChanged || timeRectangleChanged)
            {
                this.layoutChildren();
            }
        }

        private function layoutChildren():void
        {
            var grid:GanttSheetGridBase;
            var g:Graphics;
            if (this._content != null)
            {
                this._content.move(this.timeRectangle.x, this.timeRectangle.y);
                this._content.setActualSize(this.timeRectangle.width, this.timeRectangle.height);
                g = this._content.graphics;
                g.clear();
                g.beginFill(0, 0);
                g.drawRect(this.timeRectangle.x, this.timeRectangle.y, this.timeRectangle.width, this.timeRectangle.height);
                g.endFill();
            }
            if (this.horizontalScrollBar != null && this.horizontalScrollBar.visible)
            {
                this.horizontalScrollBar.move(0, this.timeRectangle.height);
                this.horizontalScrollBar.setActualSize(this.timeRectangle.width, this.horizontalScrollBarHeight);
            }
            if (this.verticalScrollBar != null && this.verticalScrollBar.visible)
            {
                this.verticalScrollBar.move(this.timeRectangle.width, 0);
                this.verticalScrollBar.setActualSize(this.verticalScrollBarWidth, this.timeRectangle.height);
            }
            if (this._backGridsContent != null)
            {
                this._backGridsContent.move(0, 0);
                this._backGridsContent.setActualSize(this._content.width, this._content.height);
            }
            if (this._frontGridsContent != null)
            {
                this._frontGridsContent.move(0, 0);
                this._frontGridsContent.setActualSize(this._content.width, this._content.height);
            }
            for each (grid in this.allGrids)
            {
                grid.move(0, 0);
                grid.setActualSize(this._content.width, this._content.height);
            }
            if (this._taskItemContainer != null)
            {
                this._taskItemContainer.move(0, 0);
                this._taskItemContainer.setActualSize(this._content.width, this._content.height);
            }
            if (this._constraintItemContainer != null)
            {
                this._constraintItemContainer.move(0, 0);
                this._constraintItemContainer.setActualSize(this._content.width, this._content.height);
            }
        }

        override public function styleChanged(styleProp:String):void
        {
            var rowAndTaskLayoutChanged:Boolean;
            var rowPadding:*;
            var allStyles:Boolean = styleProp == null || styleProp == "styleName";
            super.styleChanged(styleProp);
            if (allStyles || styleProp == "useRollOver")
            {
                this._useRollOver = (getStyle("useRollOver") as Boolean);
                this.invalidateItemsDisplayList([this._highlightUID]);
            }
            if (allStyles || styleProp == "animationDuration")
            {
                if (this._timeController)
                {
                    this._timeController.animationDuration = (getStyle("animationDuration") as Number);
                }
            }
            if (allStyles || styleProp == "easingFunction")
            {
                if (this._timeController)
                {
                    this._timeController.easingFunction = (getStyle("easingFunction") as Function);
                }
            }
            if (allStyles || styleProp == "scrollMargin")
            {
                this.invalidateTimeBounds();
            }
            if (allStyles || styleProp == "paddingTop")
            {
                this._taskLayout.paddingTop = (getStyle("paddingTop") as Number);
                rowAndTaskLayoutChanged = true;
            }
            if (allStyles || styleProp == "paddingBottom")
            {
                this._taskLayout.paddingBottom = (getStyle("paddingBottom") as Number);
                rowAndTaskLayoutChanged = true;
            }
            if (allStyles || styleProp == "rowPadding")
            {
                rowPadding = getStyle("rowPadding");
                if (styleManager.isValidStyleValue(rowPadding))
                {
                    this._taskLayout.paddingTop = (rowPadding as Number);
                    this._taskLayout.paddingBottom = (rowPadding as Number);
                    rowAndTaskLayoutChanged = true;
                }
            }
            if (allStyles || styleProp == "verticalGap")
            {
                this._taskLayout.verticalGap = (getStyle("verticalGap") as Number);
                rowAndTaskLayoutChanged = true;
            }
            if (allStyles || styleProp == "percentOverlap")
            {
                this._taskLayout.percentOverlap = (getStyle("percentOverlap") as Number);
                rowAndTaskLayoutChanged = true;
            }
            if ((allStyles || styleProp == "horizontalScrollBarStyleName") && this.horizontalScrollBar != null)
            {
                this.horizontalScrollBar.styleName = getStyle("horizontalScrollBarStyleName");
            }
            if ((allStyles || styleProp == "verticalScrollBarStyleName") && this.verticalScrollBar != null)
            {
                this.verticalScrollBar.styleName = getStyle("verticalScrollBarStyleName");
            }
            this._panCursor.styleChanged(styleProp, allStyles);
            this._createConstraintCursor.styleChanged(styleProp, allStyles);
            this._invalidReassignCursor.styleChanged(styleProp, allStyles);
            var cursor:Cursor = Cursor(this._itemAreaInfo[BAR_MOVE_REASSIGN].cursor);
            cursor.styleChanged(styleProp, allStyles);
            cursor = Cursor(this._itemAreaInfo[BAR_MOVE].cursor);
            cursor.styleChanged(styleProp, allStyles);
            cursor = Cursor(this._itemAreaInfo[BAR_REASSIGN].cursor);
            cursor.styleChanged(styleProp, allStyles);
            cursor = Cursor(this._itemAreaInfo[TaskItemArea.END].cursor);
            cursor.styleChanged(styleProp, allStyles);
            cursor = Cursor(this._itemAreaInfo[TaskItemArea.START].cursor);
            cursor.styleChanged(styleProp, allStyles);
            if (rowAndTaskLayoutChanged)
            {
                this.invalidateRowItemsSize();
                this.invalidateItemsSize();
            }
        }

        private function get timeRectangle():Rectangle
        {
            if (this._timeRectangle == null)
            {
                this._timeRectangle = new Rectangle(0, 0, Math.max(0, unscaledWidth - this.verticalScrollBarWidth), Math.max(0, unscaledHeight - this.horizontalScrollBarHeight));
            }
            return this._timeRectangle;
        }

        private function invalidateTimeRectangle():void
        {
            this._timeRectangle = null;
            this._timeRectangleChanged = true;
            invalidateProperties();
        }

        private function get useUnboundedScrollBar():Boolean
        {
            if (this.minScrollTime == this.maxScrollTime)
            {
                return true;
            }
            if (this.minScrollTime > this.visibleTimeRangeStart && this.maxScrollTime < this.visibleTimeRangeEnd)
            {
                return true;
            }
            return false;
        }

        private function get marginInPixels():Number
        {
            return getStyle("scrollMargin");
        }

        private function get minScrollTimeWithMargin():Number
        {
            var time:Number = this.getTime(this.marginInPixels) - this.getTime(0);
            return this.minScrollTime - time;
        }

        private function get maxScrollTimeWithMargin():Number
        {
            var time:Number = this.getTime(this.marginInPixels) - this.getTime(0);
            return this.maxScrollTime + time;
        }

        private function get isHorizontalScrollBarVisible():Boolean
        {
            return this._horizontalScrollPolicy != ScrollPolicy.OFF;
        }

        private function get horizontalScrollBarHeight():Number
        {
            if (!this.isHorizontalScrollBarVisible)
            {
                return 0;
            }
            return this.horizontalScrollBar != null ? this.horizontalScrollBar.minHeight : 16;
        }

        private function updateHorizontalScrollBar():void
        {
            var min:Number;
            var max:Number;
            var value:Number;
            if (this._updatingHorizontalScrollBar || !this._timeController.configured || !initialized || this.horizontalScrollPolicy != ScrollPolicy.ON)
            {
                return;
            }
            this._updatingHorizontalScrollBar = true;
            if (this.useUnboundedScrollBar)
            {
                this.horizontalScrollBar.minimum = 0;
                this.horizontalScrollBar.maximum = 1;
                this.horizontalScrollBar.pageSize = 10000;
                this.horizontalScrollBar.value = 0;
            }
            else
            {
                min = this.minScrollTimeWithMargin < this.visibleTimeRangeStart ? this.minScrollTimeWithMargin : this.visibleTimeRangeStart;
                max = this.maxScrollTimeWithMargin > this.visibleTimeRangeEnd ? this.maxScrollTimeWithMargin : this.visibleTimeRangeEnd;
                this.horizontalScrollBar.minimum = 0;
                this.horizontalScrollBar.maximum = Math.max(0, this.getCoordinate(max) - this.getCoordinate(min) - this.timeRectangle.width);
                value = this.getCoordinate(this.visibleTimeRangeStart) - this.getCoordinate(min);
                if (value < this.horizontalScrollBar.minimum)
                {
                    value = this.horizontalScrollBar.minimum;
                }
                else if (value > this.horizontalScrollBar.maximum)
				{
					value = this.horizontalScrollBar.maximum;
				}
                this.horizontalScrollBar.value = value;
                this.horizontalScrollBar.pageSize = this.timeRectangle.width;
            }
            this.horizontalScrollBar.stepSize = 0;
            this.horizontalScrollBar.validateProperties();
            this.horizontalScrollBar.track.mouseEnabled = !(this.useUnboundedScrollBar);
            this.horizontalScrollBar.thumb.mouseEnabled = !(this.useUnboundedScrollBar);
            this._updatingHorizontalScrollBar = false;
        }

        private function updateTimeControllerFromScrollBar():void
        {
            if (this._updatingHorizontalScrollBar || !this._timeController.configured)
            {
                return;
            }
            this._updatingHorizontalScrollBar = true;
            var min:Number = this.minScrollTimeWithMargin < this.visibleTimeRangeStart ? this.minScrollTimeWithMargin : this.visibleTimeRangeStart;
            var time:Number = this.getTime(this.getCoordinate(min) + Math.floor(this.horizontalScrollBar.value));
            this.moveTo(time);
            this._updatingHorizontalScrollBar = false;
        }

        private function horizontalScrollBarButton_clickHandler(event:Event):void
        {
            this.scrollHorizontally((event.currentTarget == this.horizontalScrollBar.incrementButton), false);
        }

		public function scrollHorizontally(increment:Boolean, animate:Boolean=true):void
        {
			var timeOffset:Number;
			var coordinateOffset:Number;
			var row:TimeScaleRow = this.timeScale != null ? this.timeScale.minorScaleRow : null;
			if (row != null && row.tickUnit != null)
			{
				timeOffset = row.tickUnit.milliseconds * row.tickSteps;
				if (!increment)
				{
					timeOffset = -timeOffset;
				}
				this.shiftByProjectedTime(timeOffset, animate);
			}
			else
			{
				coordinateOffset = this.timeRectangle.width / 10;
				if (!increment)
				{
					coordinateOffset = -coordinateOffset;
				}
				this.shiftByCoordinate(coordinateOffset, animate);
			}
        }

        private function horizontalScrollBar_thumbPressHandler(event:TrackBaseEvent):void
        {
            this._draggingHorizontalScrollBar = true;
        }

        private function horizontalScrollBar_thumbReleaseHandler(event:TrackBaseEvent):void
        {
            this._draggingHorizontalScrollBar = false;
            this.updateTimeControllerFromScrollBar();
        }

        private function horizontalScrollBar_valueCommitHandler(event:Event):void
        {
            if (!this.liveScrolling && this._draggingHorizontalScrollBar)
            {
                return;
            }
            this.updateTimeControllerFromScrollBar();
        }

        private function horizontalScrollBar_creationCompleteHandler(event:Event):void
        {
            this.horizontalScrollBar.incrementButton.addEventListener(FlexEvent.BUTTON_DOWN, this.horizontalScrollBarButton_clickHandler);
            this.horizontalScrollBar.decrementButton.addEventListener(FlexEvent.BUTTON_DOWN, this.horizontalScrollBarButton_clickHandler);
            this.horizontalScrollBar.incrementButton.setStyle("repeatInterval", getStyle("autoScrollRepeatInterval"));
            this.horizontalScrollBar.decrementButton.setStyle("repeatInterval", getStyle("autoScrollRepeatInterval"));
        }

        private function isVerticalScrollBarNeeded():Boolean
        {
            return this.ganttChart == null || this.ganttChart.dataGrid == null ? false : this.ganttChart.dataGrid.verticalTotalRows > this.ganttChart.dataGrid.verticalVisibleRows;
        }

        private function getRowHeight():Number
        {
            var meanRowHeight:Number = this.ganttChart.dataGrid.meanRowHeight;
            return meanRowHeight == 0 ? 20 : meanRowHeight;
        }

        private function get verticalScrollBarWidth():Number
        {
            if (this.verticalScrollBar == null || !this.verticalScrollBar.visible)
            {
                return 0;
            }
            return this.verticalScrollBar != null ? this.verticalScrollBar.minWidth : 16;
        }

        private function updateVerticalScrollBar():void
        {
            if (this.verticalScrollBar == null || this._updatingVerticalScrollBar || this.ganttChart == null || this.ganttChart.dataGrid == null)
            {
                return;
            }
            this._updatingVerticalScrollBar = true;
            this.updateScrollBarVisibility();
            this.verticalScrollBar.minimum = 0;
            this.verticalScrollBar.maximum = (this.ganttChart.dataGrid.maxVerticalScrollPosition * this.getRowHeight());
            this.verticalScrollBar.value = (this.ganttChart.dataGrid.verticalScrollPosition * this.getRowHeight());
            this.verticalScrollBar.pageSize = this.verticalScrollBar.track.height;
            this.verticalScrollBar.stepSize = this.getRowHeight();
            this._updatingVerticalScrollBar = false;
        }

        private function updateFirstVisibleRowFromScrollBar():void
        {
            if (this.verticalScrollBar == null || this._updatingVerticalScrollBar || this.ganttChart == null || this.ganttChart.dataGrid == null)
            {
                return;
            }
            this._updatingVerticalScrollBar = true;
            var dataGrid:GanttDataGrid = this.ganttChart.dataGrid;
            var newVerticalScrollPosition:Number = Math.floor((this.verticalScrollBar.value / this.getRowHeight()));
            if (!isNaN(newVerticalScrollPosition))
            {
                if (dataGrid.verticalScrollPosition != newVerticalScrollPosition)
                {
                    dataGrid.verticalScrollPosition = newVerticalScrollPosition;
                    validateNow();
                }
            }
            this._updatingVerticalScrollBar = false;
        }

        private function verticalScrollBar_thumbPressHandler(event:TrackBaseEvent):void
        {
            this._draggingVerticalScrollBar = true;
        }

        private function verticalScrollBar_thumbReleaseHandler(event:TrackBaseEvent):void
        {
            this._draggingVerticalScrollBar = false;
            this.updateFirstVisibleRowFromScrollBar();
        }

        private function verticalScrollBar_valueCommitHandler(event:Event):void
        {
            if (this._draggingVerticalScrollBar && !this.liveScrolling)
            {
                return;
            }
            this.updateFirstVisibleRowFromScrollBar();
        }

        private function updateScrollBarVisibility():void
        {
            if (this.verticalScrollBar == null)
            {
                return;
            }
            var vVisible:Boolean = this.verticalScrollBar.visible;
            var hVisible:Boolean = this.horizontalScrollBar.visible;
            var showHorizontal:Boolean = this.isHorizontalScrollBarVisible && this.timeRectangle.width >= this.horizontalScrollBar.minWidth;
            var showVertical:Boolean = this.verticalScrollPolicy==ScrollPolicy.AUTO ? this.isVerticalScrollBarNeeded() : this.verticalScrollPolicy == ScrollPolicy.ON;
            if (showVertical)
            {
                showVertical = this.timeRectangle.height >= this.verticalScrollBar.minHeight;
            }
            if (vVisible != showVertical || hVisible != showHorizontal)
            {
                this.verticalScrollBar.visible = showVertical;
                this.horizontalScrollBar.visible = showHorizontal;
                this.invalidateTimeRectangle();
            }
        }

		public function invalidateItemsSize():void
        {
            if (this._taskItemContainer)
            {
                this._taskItemContainer.invalidateItemsSize();
            }
            if (this._constraintItemContainer)
            {
                this._constraintItemContainer.invalidateItemsSize();
            }
        }

		public function invalidateRowItemsSize():void
        {
            if (this.rowController != null)
            {
                this.rowController.invalidateItemsSize();
            }
        }

        private function invalidateItemsDisplayList(items:Array):void
        {
            var item:Object;
            var renderer:Object;
            for each (item in items)
            {
                renderer = this.itemToItemRenderer(item);
                if (renderer is IInvalidating)
                {
                    IInvalidating(renderer).invalidateDisplayList();
                }
                else if (renderer is IProgrammaticSkin)
				{
					IProgrammaticSkin(renderer).validateDisplayList();
				}
            }
        }

        public function invalidateTaskItemRenderer(taskItem:TaskItem):void
        {
            if (taskItem == null)
            {
                return;
            }
            this.invalidateTaskItemsLayout([taskItem.data]);
        }

		public function invalidateTaskItemsLayout(items:Array):void
        {
            if (this._taskItemContainer != null)
            {
                this._taskItemContainer.invalidateTaskItemsLayout(items);
            }
            if (this._constraintItemContainer != null)
            {
                this._constraintItemContainer.invalidateTaskItemsLayout(items);
            }
        }

        private function invalidateConstraintItemsLayout(items:Array):void
        {
            if (this._constraintItemContainer == null)
            {
                return;
            }
            this._constraintItemContainer.invalidateConstraintItemsLayout(items);
        }

        private function invalidateLayoutOfTasksInRows(items:Array):void
        {
            if (this._taskItemContainer == null)
            {
                return;
            }
            this._taskItemContainer.invalidateLayoutOfTasksInRows(items);
        }

        public function itemToDataItem(item:Object):DataItem
        {
            if (this.resourceChart)
            {
                return this.itemToTaskItem(item);
            }
            var dataItem:DataItem = this.itemToTaskItem(item, false);
            if (dataItem)
            {
                return dataItem;
            }
            dataItem = this.itemToConstraintItem(item, false);
            if (dataItem)
            {
                return dataItem;
            }
            if (this.taskChart && this.taskChart.isTask(item))
            {
                return this.itemToTaskItem(item);
            }
            if (this.taskChart && this.taskChart.isConstraint(item))
            {
                return this.itemToConstraintItem(item);
            }
            return null;
        }

		/**
		 * 把task的对象转化为TaskItem对象 
		 * 并存在数组里
		 * @param item
		 * @param create
		 * @return 
		 * 
		 */		
        public function itemToTaskItem(item:Object, create:Boolean=true):TaskItem
        {
            var taskItem:TaskItem;
            if (!item)
            {
                return null;
            }
            var uid:String = this.itemToUID(item);
            var r:* = this._taskItems[uid];
            if (r !== undefined)
            {
                return TaskItem(r);
            }
            if (create)
            {
                taskItem = new TaskItem(this, item);
                this.updateTaskItem(taskItem, null);
                this._taskItems[uid] = taskItem;
                return taskItem;
            }
            return null;
        }

        public function itemToConstraintItem(item:Object, create:Boolean=true):ConstraintItem
        {
            var constraintItem:ConstraintItem;
            if (!item)
            {
                return null;
            };
            var uid:String = this.itemToUID(item);
            var r:* = this._constraintItems[uid];
            if (r !== undefined)
            {
                return ConstraintItem(r);
            }
            if (create)
            {
                constraintItem = new ConstraintItem(this, item);
                this.updateConstraintItem(constraintItem, null);
                this._constraintItems[uid] = constraintItem;
                return constraintItem;
            }
            return null;
        }

        private function initItemAreaInfo():Object
        {
            var itemAreaInfo:Object = {};
            itemAreaInfo[BAR_CREATE_CONSTRAINT] = {
                "editKind":TaskItemEditKind.CREATE_CONSTRAINT,
                "dragEventType":GanttSheetEvent.ITEM_EDIT_CONSTRAINT,
                "cursor":new Cursor(this, "createConstraintCursor", "createConstraintCursorOffset")
            }
            itemAreaInfo[BAR_MOVE_REASSIGN] = {
                "editKind":TaskItemEditKind.MOVE_REASSIGN,
                "dragEventType":GanttSheetEvent.ITEM_EDIT_MOVE,
                "cursor":new Cursor(this, "moveReassignCursor", "moveReassignCursorOffset")
            }
            itemAreaInfo[BAR_MOVE] = {
                "editKind":TaskItemEditKind.MOVE,
                "dragEventType":GanttSheetEvent.ITEM_EDIT_MOVE,
                "cursor":new Cursor(this, "moveCursor", "moveCursorOffset")
            }
            itemAreaInfo[BAR_REASSIGN] = {
                "editKind":TaskItemEditKind.REASSIGN,
                "dragEventType":GanttSheetEvent.ITEM_EDIT_MOVE,
                "cursor":new Cursor(this, "reassignCursor", "reassignCursorOffset")
            }
            itemAreaInfo[TaskItemArea.END] = {
                "editKind":TaskItemEditKind.RESIZE_END,
                "dragEventType":GanttSheetEvent.ITEM_EDIT_RESIZE,
                "cursor":new Cursor(this, "resizeEndCursor", "resizeEndCursorOffset")
            }
            itemAreaInfo[TaskItemArea.START] = {
                "editKind":TaskItemEditKind.RESIZE_START,
                "dragEventType":GanttSheetEvent.ITEM_EDIT_RESIZE,
                "cursor":new Cursor(this, "resizeStartCursor", "resizeStartCursorOffset")
            }
            return itemAreaInfo;
        }

        private function getItemAreaInfo(itemArea:String, item:Object):Object
        {
            var moveEnabled:Boolean;
            var reassignEnabled:Boolean;
            var editKind:String;
            var resizeEnabled:Boolean;
            if (itemArea == TaskItemArea.BAR)
            {
                moveEnabled = this.isItemMoveEnabledInternal(item);
                reassignEnabled = this.isItemReassignEnabledInternal(item);
                if (moveEnabled && reassignEnabled)
                {
                    itemArea = BAR_MOVE_REASSIGN;
                }
                else
                {
                    if (moveEnabled)
                    {
                        itemArea = BAR_MOVE;
                    }
                    else
                    {
                        if (reassignEnabled)
                        {
                            itemArea = BAR_REASSIGN;
                        }
                        else
                        {
                            if (this.isConstraintCreationEnabledInternal(item, true))
                            {
                                itemArea = BAR_CREATE_CONSTRAINT;
                            }
                            else
                            {
                                itemArea = null;
                            }
                        }
                    }
                }
            }
            else
            {
                if (itemArea == TaskItemArea.START || itemArea == TaskItemArea.END)
                {
                    editKind = itemArea == TaskItemArea.START ? TaskItemEditKind.RESIZE_START : TaskItemEditKind.RESIZE_END;
                    resizeEnabled = this.isItemResizeEnabledInternal(item, editKind);
                    if (!resizeEnabled)
                    {
                        itemArea = this.isConstraintCreationEnabledInternal(item, true) ? BAR_CREATE_CONSTRAINT : null;
                    }
                }
            }
            return itemArea ? this._itemAreaInfo[itemArea] : null;
        }

		public function getVisibleTaskItems(rowItem:Object, start:Number, end:Number):Array
        {
            var index:int;
            var taskItems:Array = this.ganttChart.getVisibleTaskItems(rowItem, start, end);
            if (this._editedTaskItem == null)
            {
                return taskItems;
            }
            if (!this._inStopDragging && this._targetResource != this._originalResource)
            {
                if (rowItem == this._originalResource)
                {
                    index = taskItems.indexOf(this._editedTaskItem);
                    if (index != -1)
                    {
                        taskItems.splice(index, 1);
                    }
                }
                else
                {
                    if (rowItem == this._targetResource)
                    {
                        index = taskItems.indexOf(this._editedTaskItem);
                        if (index == -1)
                        {
                            taskItems.push(this._editedTaskItem);
                        }
                    }
                }
            }
            return taskItems;
        }

		public function rowItemToTasks(rowItem:Object):Array
        {
            var index:int;
            var tasks:Array = this.ganttChart.rowItemToTasks(rowItem);
            if (tasks == null)
            {
                tasks = [];
            }
            else
            {
                tasks = tasks.concat();
            }
            if (this._editedTaskItem == null)
            {
                return tasks;
            }
            if (!this._inStopDragging && this._targetResource != this._originalResource)
            {
                if (rowItem == this._originalResource)
                {
                    index = tasks.indexOf(this._editedTaskItem.data);
                    if (index != -1)
                    {
                        tasks.splice(index, 1);
                    }
                }
                else if (rowItem == this._targetResource)
				{
					index = tasks.indexOf(this._editedTaskItem.data);
					if (index == -1)
					{
						tasks.push(this._editedTaskItem.data);
					}
				}
            }
            return tasks;
        }

		public function taskItemToRowItem(taskItem:TaskItem):Object
        {
            if (this._editedTaskItem != null 
				&& !this._inStopDragging 
				&& taskItem == this._editedTaskItem 
				&& this.resourceChart != null 
				&& this._originalResource != this._targetResource)
            {
                return this._targetResource;
            }
            return this.ganttChart.taskItemToRowItem(taskItem);
        }

        private function timeScale_creationCompleteHandler(event:FlexEvent):void
        {
            this._timeScale.removeEventListener(FlexEvent.CREATION_COMPLETE, this.timeScale_creationCompleteHandler);
            this.startListeningOnTimeScaleChanges();
        }

		private function startListeningOnTimeScaleChanges():void
		{
			if (this._timeScale && this._timeScale.minorScaleRow)
			{
				this._timeScale.minorScaleRow.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, this.precisionChangedHandler);
				this._minorTimeScalePrecisionChanged = true;
				invalidateProperties();
			}
		}
		
		private function stopListeningOnTimeScaleChanges():void
		{
			if (this._timeScale && this._timeScale.minorScaleRow)
			{
				this._timeScale.minorScaleRow.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, this.precisionChangedHandler);
			}
		}

        private function precisionChangedHandler(event:PropertyChangeEvent):void
        {
            this._minorTimeScalePrecisionChanged = true;
            invalidateProperties();
        }

        private function content_clickHandler(event:MouseEvent):void
        {
            var e:GanttSheetEvent;
            if (!enabled)
            {
                return;
            }
            var p:Point = new Point(event.stageX, event.stageY);
            p = this.globalToLocal(p);
            if (this._mouseDownPoint && p.subtract(this._mouseDownPoint).length > 3)
            {
                return;
            }
            this.updateHitTest(event);
            var itemRenderer:IDataRenderer = this.itemToItemRenderer(this._hitTestItem);
            if (itemRenderer)
            {
                e = new GanttSheetEvent(GanttSheetEvent.ITEM_CLICK);
                e.triggerEvent = event;
                e.item = this.getDataItem(itemRenderer.data);
                e.itemRenderer = itemRenderer;
                e.itemArea = this._hitTestItemArea;
                dispatchEvent(e);
            }
        }

        private function content_doubleClickHandler(event:MouseEvent):void
        {
            var e:GanttSheetEvent;
            if (!enabled || !doubleClickEnabled)
            {
                return;
            }
            this.updateHitTest(event);
            var itemRenderer:IDataRenderer = this.itemToItemRenderer(this._hitTestItem);
            if (itemRenderer)
            {
                e = new GanttSheetEvent(GanttSheetEvent.ITEM_DOUBLE_CLICK);
                e.triggerEvent = event;
                e.item = this.getDataItem(itemRenderer.data);
                e.itemRenderer = itemRenderer;
                e.itemArea = this._hitTestItemArea;
                dispatchEvent(e);
            }
        }

		public function processMouseWheelEvent(event:MouseEvent):Boolean
        {
            var p:Point;
            if (this._isDragging)
            {
                return false;
            }
            var canZoom:Boolean = this.allowWheelZoom && (this.wheelZoomModifierKey == null || EventUtil.isMatching(event, this.wheelZoomModifierKey));
            var canScroll:Boolean = this.allowWheelScroll && (this.wheelScrollModifierKey == null || EventUtil.isMatching(event, this.wheelScrollModifierKey));
            if (canZoom)
            {
                p = new Point(event.stageX, event.stageY);
                p = globalToLocal(p);
                this.zoomHorizontally((event.delta > 0), p);
                return true;
            }
            if (canScroll)
            {
                this.rowController.scroll(-event.delta, "row");
                return true;
            }
            return false;
        }

		public function processKeyDownEvent(event:KeyboardEvent):Boolean
        {
            if (this._isDragging || (!this.usePredefinedKeyboardActions && !this.keyboardNavigationEnabled))
            {
                return false;
            }
            var keyCode:uint = mx_internal::mapKeycodeForLayoutDirection(event);
            var handled:Boolean;
            if (EventUtil.isMatching(event, this.scrollModifierKey))
            {
                switch (keyCode)
                {
                    case Keyboard.LEFT:
                        this.scrollHorizontally(false, false);
                        handled = true;
                        break;
                    case Keyboard.RIGHT:
                        this.scrollHorizontally(true, false);
                        handled = true;
                        break;
                    case Keyboard.UP:
                        this.scrollVertically(-1, "row");
                        handled = true;
                        break;
                    case Keyboard.DOWN:
                        this.scrollVertically(1, "row");
                        handled = true;
                        break;
                }
            }
            switch (keyCode)
            {
                case 187:
                case Keyboard.NUMPAD_ADD:
                    this.zoomHorizontally(true);
                    handled = true;
                    break;
                case 189:
                case Keyboard.NUMPAD_SUBTRACT:
                    this.zoomHorizontally(false);
                    handled = true;
                    break;
            }
            if (!handled && EventUtil.isMatching(event, this.keyboardNavigationModifierKey))
            {
                handled = true;
                switch (keyCode)
                {
                    case Keyboard.LEFT:
                    case Keyboard.RIGHT:
                    case Keyboard.UP:
                    case Keyboard.DOWN:
                        this.selectedItem = this.ganttChart.nextItem(this.selectedItem, keyCode);
                        if (this.selectedItem != null)
                        {
                            this.ganttChart.scrollToItem(this.selectedItem);
                        }
                        break;
                    default:
                        handled = false;
                }
            }
            return handled;
        }

		public function zoomHorizontally(zoom:Boolean, p:Point=null, animate:Boolean=true):void
        {
            var zoomRatio:Number = getStyle("wheelZoomFactor");
            if (zoom)
            {
                zoomRatio = 1 / zoomRatio;
            }
            if (p != null)
            {
                this.timeController.zoomAt(zoomRatio, p.x, animate);
            }
            else
            {
                this.timeController.zoomAndCenter(zoomRatio, 0, animate);
            }
        }

        private function content_mouseDownHandler(event:MouseEvent):void
        {
            var dataItem:DataItem;
            var taskItem:TaskItem;
            var dispatchChange:Boolean;
            if (this._isMouseDown)
            {
                this.mouseUpHandler(event);
            }
            if (!enabled)
            {
                return;
            }
            this.hideDataTip();
            var p:Point = new Point(event.stageX, event.stageY);
            this._mouseDownPoint = globalToLocal(p);
            this._isMouseDown = true;
            this._isCtrlMouseDown = event.ctrlKey;
            this._mouseDownVerticalOffset = this.verticalScrollBar.value;
            this._mouseDownTime = this.getTime(this._mouseDownPoint.x);
            this.updateHitTest(event);
            var itemRenderer:IDataRenderer = this.itemToItemRenderer(this._hitTestItem);
            var item:Object = itemRenderer ? this.getDataItem(itemRenderer.data) : null;
            this._mouseDownItemRenderer = itemRenderer;
            this._mouseDownItem = item;
            this._mouseDownItemSelected = this.isItemSelected(item);
            if (this._mouseDownItemRenderer != null)
            {
                this._dragInitialItemMousePoint = DisplayObject(this._mouseDownItemRenderer).globalToLocal(p);
                dataItem = this.itemToDataItem(item);
                if (dataItem is TaskItem)
                {
                    taskItem = TaskItem(dataItem);
                    this._dragInitialStartX = this._timeController.getCoordinate(taskItem.startTime);
                    this._dragInitialEndX = this._timeController.getCoordinate(taskItem.endTime);
                    if (this.isItemEditable(item, this._hitTestItemArea))
                    {
                        this.createEditingToolTip(item, (this._mouseDownItemRenderer as DisplayObject));
                    }
                }
            }
            if (this.selectionMode != SelectionMode.NONE)
            {
                dispatchChange = true;
                if (item == null)
                {
                    if (this._isCtrlMouseDown)
                    {
                        dispatchChange = false;
                    }
                    else
                    {
                        if (this.selectedItems.length > 0)
                        {
                            this.clearSelection();
                        }
                        else
                        {
                            dispatchChange = false;
                        }
                    }
                }
                else
                {
                    if (this._mouseDownItemSelected)
                    {
                        dispatchChange = false;
                    }
                    else
                    {
                        if (this.selectionMode == SelectionMode.MULTIPLE && this._isCtrlMouseDown)
                        {
                            this.toggleSelection(item);
                        }
                        else
                        {
                            this.selectItem(item);
                        }
                    }
                }
                if (dispatchChange)
                {
                    this.dispatchChangeEvent(event, this._mouseDownItem, this._mouseDownItemRenderer);
                }
            }
            var sandboxRoot:DisplayObject = systemManager.getSandboxRoot();
            sandboxRoot.addEventListener(MouseEvent.MOUSE_UP, this.mouseUpHandler, true);
            sandboxRoot.addEventListener(MouseEvent.MOUSE_MOVE, this.content_mouseMoveHandler, true);
            sandboxRoot.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, this.mouseUpHandler, true);
            sandboxRoot.addEventListener(SandboxMouseEvent.MOUSE_MOVE_SOMEWHERE, this.content_mouseMoveHandler, true);
            sandboxRoot.addEventListener(MouseEvent.ROLL_OUT, this.stage_mouseOutHandler);
            sandboxRoot.addEventListener(MouseEvent.ROLL_OVER, this.stage_mouseOverHandler);
            addEventListener(KeyboardEvent.KEY_DOWN, this.keyDownHandler);
            addEventListener(KeyboardEvent.KEY_UP, this.keyUpHandler);
            sandboxRoot.addEventListener(KeyboardEvent.KEY_DOWN, this.keyDownHandler);
            sandboxRoot.addEventListener(KeyboardEvent.KEY_UP, this.keyUpHandler);
            systemManager.deployMouseShields(true);
        }

        private function mouseUpHandler(event:Event):void
        {
            var dispatchChange:Boolean;
            var items:Array;
            if (!enabled)
            {
                return;
            }
            this.hideEditingTip();
            if (this._isDragging)
            {
                this.stopDragging(GanttSheetEventReason.COMPLETED, event);
                return;
            }
            if (this._isPanning)
            {
                this.stopPanning(true);
                return;
            }
            if (!this._isDragging && this._mouseDownItem && this._mouseDownItemSelected && !this._isDraggingX && !this._isDraggingY)
            {
                dispatchChange = true;
                if (this.selectionMode == SelectionMode.MULTIPLE)
                {
                    if (this._isCtrlMouseDown)
                    {
                        this.toggleSelection(this._mouseDownItem);
                    }
                    else
                    {
                        this.selectItem(this._mouseDownItem);
                    }
                }
                else
                {
                    if (this._isCtrlMouseDown)
                    {
                        this.clearSelection();
                    }
                    else
                    {
                        dispatchChange = false;
                    }
                }
                if (dispatchChange)
                {
                    this.dispatchChangeEvent(event, this._mouseDownItem, this._mouseDownItemRenderer);
                }
                items = this._selectedItems.concat();
                items.push(this._mouseDownItem);
                this.invalidateItemsDisplayList(items);
                if (event is MouseEvent || event is SandboxMouseEvent)
                {
                    this.updateHitTest(event);
                }
            }
            this.terminateMouseDownUp();
        }

        private function content_mouseOverHandler(event:MouseEvent):void
        {
            if (!enabled || event.buttonDown)
            {
                return;
            }
            if (this.editKind != null || this._isDraggingX || this._isDraggingY)
            {
                return;
            }
            if (event.target == this._taskItemContainer)
            {
                return;
            }
            if (event.target == this._constraintItemContainer)
            {
                return;
            }
            var itemRenderer:Object = this.mouseEventToItemRenderer(event);
            var item:Object = itemRenderer is IDataRenderer ? this.getDataItem(IDataRenderer(itemRenderer).data) : null;
            if (item == null)
            {
                return;
            }
            var oldHighlightUID:String = this._highlightUID;
            this._highlightUID = this.itemToUID(item);
            if (this._useRollOver)
            {
                this.invalidateItemsDisplayList([oldHighlightUID, this._highlightUID]);
            }
            var e:GanttSheetEvent = new GanttSheetEvent(GanttSheetEvent.ITEM_ROLL_OVER);
            e.triggerEvent = event;
            e.item = item;
            e.itemRenderer = (itemRenderer as IDataRenderer);
            dispatchEvent(e);
            this.createDataTip(item, DisplayObject(itemRenderer));
        }

        private function content_mouseOutHandler(event:MouseEvent):void
        {
            if (!enabled || event.buttonDown)
            {
                return;
            }
            if (this.editKind != null)
            {
                return;
            }
            if (event.target == this._taskItemContainer)
            {
                return;
            }
            if (event.target == this._constraintItemContainer)
            {
                return;
            }
            var itemRenderer:Object = this.mouseEventToItemRenderer(event);
            var item:Object = itemRenderer is IDataRenderer ? this.getDataItem(IDataRenderer(itemRenderer).data) : null;
            var oldHighlightUID:String = this._highlightUID;
            this._highlightUID = null;
            if (this._useRollOver)
            {
                this.invalidateItemsDisplayList([oldHighlightUID]);
            }
            this.hideDataTip();
            if (item == null)
            {
                return;
            }
            var e:GanttSheetEvent = new GanttSheetEvent(GanttSheetEvent.ITEM_ROLL_OUT);
            e.triggerEvent = event;
            e.item = item;
            e.itemRenderer = (itemRenderer as IDataRenderer);
            dispatchEvent(e);
        }

        private function content_mouseMoveHandler(event:Event):void
        {
            if (!enabled)
            {
                return;
            }
            if (this._isMouseDown)
            {
                event.stopPropagation(); 
                if (this._mouseDownItemRenderer)
                {
                    this.itemMouseDragHandler(event);
                }
                else
                {
                    this.ganttSheetMouseDragHandler(event);
                }
            }
            else
            {
                if (event.currentTarget == this._content && !this.isMouseButtonDown(event))
                {
                    this.updateHitTest(event);
                }
            }
        }

        private function isMouseButtonDown(event:Event):Boolean
        {
            if (event is MouseEvent)
            {
                return MouseEvent(event).buttonDown;
            }
            if (event is SandboxMouseEvent)
            {
                return SandboxMouseEvent(event).buttonDown;
            }
            return false;
        }

        private function ganttSheetMouseDragHandler(event:Event):void
        {
            var deltaX:Number;
            var deltaY:Number;
            var xOffset:Number;
            var yOffset:Number;
            if ((!enabled || this.panMode == GanttSheetPanMode.NONE) || (this.panModifierKey != null && !EventUtil.isMatching(event, this.panModifierKey)))
            {
                return;
            }
            this.stopAutoScroll();
            var p:Point = this.getMousePosition(event);
            if (!this._isPanning)
            {
                deltaX = (this._mouseDownPoint.x - p.x);
                deltaY = (this._mouseDownPoint.y - p.y);
                if (Math.abs(deltaX) > PANNING_THRESHOLD || Math.abs(deltaY) > PANNING_THRESHOLD)
                {
                    this.startPanning(this._mouseDownPoint.clone());
                }
            }
            if (this._isPanning)
            {
                xOffset = (this._lastPanningPosition.x - p.x);
                yOffset = (this._lastPanningPosition.y - p.y);
                if (xOffset != 0 && this._panMode != GanttSheetPanMode.VERTICAL)
                {
                    this.shiftByCoordinate(xOffset);
                    this._lastPanningPosition.x = p.x;
                }
                if (yOffset != 0 && this._panMode != GanttSheetPanMode.HORIZONTAL)
                {
                    this.scrollVertically(yOffset, "pixel");
                    this._lastPanningPosition.y = p.y;
                }
            }
        }

        private function itemMouseDragHandler(event:Event):void
        {
            if (!enabled || !this._mouseDownItemRenderer)
            {
                return;
            }
            var p:Point = this.getMousePosition(event);
            var kind:String = this._hitTestItemArea == TaskItemArea.START ? TaskItemEditKind.RESIZE_START : TaskItemEditKind.RESIZE_END;
            var deltaX:Number = (p.x - this._mouseDownPoint.x);
            if (!this._isDraggingX && (this.isItemMoveEnabledInternal(this._mouseDownItem) || this.isItemResizeEnabledInternal(this._mouseDownItem, kind)))
            {
                this._isDraggingX = Math.abs(deltaX) > EDIT_BEGIN_DRAG_X_THRESHOLD;
            }
            var deltaY:Number = p.y - this._mouseDownPoint.y;
            if (!this._isDraggingY && (this.isItemReassignEnabledInternal(this._mouseDownItem) || this.isConstraintCreationEnabledInternal(this._mouseDownItem, true)))
            {
                this._isDraggingY = Math.abs(deltaY) > EDIT_BEGIN_DRAG_Y_THRESHOLD;
            }
            if (!this._isDraggingSet && (this._isDraggingX || this._isDraggingY))
            {
                this._isDraggingSet = true;
                this.startDragging(event, deltaX, deltaY);
            }
            if (this._isDragging)
            {
                this.dragItem(event, p.x, p.y);
                if (this.autoScrollEnabled)
                {
                    this.startAutoScroll(p);
                }
            }
        }

        private function dispatchChangeEvent(event:Event, item:Object, itemRenderer:IDataRenderer):void
        {
            var e:GanttSheetEvent = new GanttSheetEvent(GanttSheetEvent.CHANGE);
            e.triggerEvent = event;
            e.item = item;
            e.itemRenderer = itemRenderer;
            dispatchEvent(e);
        }

        private function getMousePosition(event:Event=null):Point
        {
            var mouseEvent:MouseEvent;
            var p:Point;
            if (event is MouseEvent)
            {
                mouseEvent = MouseEvent(event);
                p = new Point(mouseEvent.stageX, mouseEvent.stageY);
                return globalToLocal(p);
            }
            return new Point(mouseX, mouseY);
        }

        private function updateHitTest(event:Event):void
        {
            var renderer:Object;
            var x1:Number;
            var x2:Number;
            var width:Number;
            var d:Number;
            var p:Point = this.getMousePosition(event);
            var globalPoint:Point = this._content.localToGlobal(p);
            if (!(this._content.hitTestPoint(globalPoint.x, globalPoint.y)))
            {
                this.setHitTestItem(null, null);
                return;
            }
            if (event is MouseEvent)
            {
                renderer = this.mouseEventToItemRenderer(MouseEvent(event));
            }
            if (!(renderer is IDataRenderer))
            {
                this.setHitTestItem(null, null);
                return;
            }
            var itemArea:String;
            var taskItem:TaskItem = (IDataRenderer(renderer).data as TaskItem);
            if (taskItem)
            {
                x1 = this._timeController.getCoordinate(taskItem.startTime);
                x2 = this._timeController.getCoordinate(taskItem.endTime);
                width = ((x2 - x1) + 1);
                d = (width - EXTREMITY_AREA_X_EXTENT) / 2;
                d = Math.max(1, Math.min(EXTREMITY_AREA_X_EXTENT, d));
                if (Math.abs(x1 - p.x) < d)
                {
                    itemArea = TaskItemArea.START;
                }
                else if (Math.abs(x2 - p.x) < d)
				{
					itemArea = TaskItemArea.END;
				}
				else
				{
					itemArea = TaskItemArea.BAR;
				}
                this.setHitTestItem(this.getDataItem(taskItem), itemArea);
                return;
            }
            var constraintItem:ConstraintItem = (IDataRenderer(renderer).data as ConstraintItem);
            if (constraintItem)
            {
                this.setHitTestItem(this.getDataItem(constraintItem), null);
                return;
            }
            this.setHitTestItem(null, null);
        }

        private function setHitTestItem(item:Object, itemArea:String):void
        {
            var changed:Boolean = this._hitTestItem != item || this._hitTestItemArea != itemArea;
            this._hitTestItem = item;
            this._hitTestItemArea = itemArea;
            if (changed)
            {
                this.installEditingCursor();
            }
        }

        private function updateReassignAllowed(event:Event):void
        {
            this._reassignAllowedWhileDragging =this.reassignModifierKey == null || EventUtil.isMatching(event, this.reassignModifierKey);
        }

        private function startDragging(event:Event, xOffset:Number, yOffset:Number):void
        {
            var areaInfo:Object = this.getItemAreaInfo(this._hitTestItemArea, this._mouseDownItem);
            if (areaInfo == null)
            {
                return;
            }
            this._editKind = areaInfo.editKind;
            if (this._editKind == TaskItemEditKind.MOVE_REASSIGN)
            {
                this.updateReassignAllowed(event);
                if (this._reassignAllowedWhileDragging)
                {
                    if (Math.abs(yOffset) > (Math.abs(xOffset) * 2))
                    {
                        this._editKind = TaskItemEditKind.REASSIGN;
                    }
                }
                else
                {
                    this._editKind = TaskItemEditKind.MOVE;
                }
            }
            else if (this._editKind == TaskItemEditKind.MOVE)
			{
				if (this.isConstraintCreationEnabledInternal(this._mouseDownItem, true) && Math.abs(yOffset) > (Math.abs(xOffset) * 2))
				{
					this._editKind = TaskItemEditKind.CREATE_CONSTRAINT;
				}
			}
            this._editedTaskItem = (this._mouseDownItemRenderer.data as TaskItem);
            if (this.resourceChart)
            {
                this._originalResource = this._editedTaskItem.resource;
                this._targetResource = this._originalResource;
            }
            var e:GanttSheetEvent = new GanttSheetEvent(GanttSheetEvent.ITEM_EDIT_BEGIN, false, false);
            e.targetResource = this._targetResource;
            e.sourceResource = this._originalResource;
            e.item = this._mouseDownItem;
            e.itemRenderer = this._mouseDownItemRenderer;
            e.itemArea = this._hitTestItemArea;
            e.editKind = this._editKind;
            e.triggerEvent = event;
            e.offset = new Point(xOffset, yOffset);
            dispatchEvent(e);
            this._editKind = e.editKind;
            if (this._editKind == null)
            {
                this.cancelInteraction();
                return;
            }
            this._isDragging = true;
            if (this.taskChart && this._autoResizeSummary)
            {
                this._taskSummaries = this.taskChart.getTaskSummaries(this._mouseDownItem);
            }
            if (this._editKind != TaskItemEditKind.CREATE_CONSTRAINT)
            {
                this.showEditingToolTipHandler(null);
                this._taskItemContainer.lockedItems = [this._mouseDownItem];
                if (!this.liveTaskLayout)
                {
                    this._taskLayout.lockedRow = this.ganttChart.taskItemToRowItem(this._editedTaskItem);
                    this._taskLayout.taskIgnoredWhenDistributing = this._editedTaskItem.data;
                    if (this._editKind == TaskItemEditKind.MOVE 
						|| this._editKind == TaskItemEditKind.MOVE_REASSIGN 
						|| this._editKind == TaskItemEditKind.RESIZE_START 
						|| this._editKind == TaskItemEditKind.RESIZE_END)
                    {
                        this._taskLayout.lockedTask = this._editedTaskItem.data;
                    }
                }
            }
        }

        public function cancelInteraction():void
        {
            if (this._isDragging && this._editKind != null)
            {
                this.stopDragging(GanttSheetEventReason.CANCELLED);
            }
            else
            {
                if (this._isPanning)
                {
                    this.stopPanning(false);
                }
                else
                {
                    this.terminateMouseDownUp();
                }
            }
        }

        public function validateInteraction():void
        {
            if (this._isDragging && this._editKind != null)
            {
                this.stopDragging(GanttSheetEventReason.COMPLETED);
            }
            else
            {
                if (this._isPanning)
                {
                    this.stopPanning(true);
                }
                else
                {
                    this.terminateMouseDownUp();
                }
            }
        }

        private function startPanning(point:Point):void
        {
            this._isPanning = true;
            this._timeBeforePanning = this.visibleTimeRangeStart;
            this._verticalScrollBarValueBeforePanning = this.verticalScrollBar.value;
            this._lastPanningPosition = point;
            this._timeController.startAdjusting();
            this.installPanningCursor();
            this.scrollVertically(0, "pixel", true);
        }

        private function stopPanning(validate:Boolean):void
        {
            if (!validate)
            {
                this.moveTo(this._timeBeforePanning);
                if (this._verticalScrollBarValueBeforePanning >= this.verticalScrollBar.minimum && this._verticalScrollBarValueBeforePanning <= this.verticalScrollBar.maximum)
                {
                    this.verticalScrollBar.value = this._verticalScrollBarValueBeforePanning;
                }
            }
            this.terminateMouseDownUp();
        }

        private function stopDragging(reason:String, event:Event=null):void
        {
            var e:GanttSheetEvent;
            var lockedRow:Object;
            var summary:TaskItem;
            if (this._editKind != TaskItemEditKind.NONE && this._editKind != null)
            {
                this._inStopDragging = true;
				if (reason != GanttSheetEventReason.CANCELLED 
					&& (this._editKind == TaskItemEditKind.MOVE_REASSIGN || this._editKind == TaskItemEditKind.REASSIGN) 
					&& this._originalResource != null 
					&& this._targetResource == null)
				{
					reason = GanttSheetEventReason.CANCELLED;
				}

                e = new GanttSheetEvent(GanttSheetEvent.ITEM_EDIT_END, false, true);
                e.sourceResource = this._originalResource;
                e.targetResource = this._targetResource;
                e.sourceTask = this._sourceTask;
                e.targetTask = this._targetTask;
                e.item = this._mouseDownItem;
                e.itemRenderer = this._mouseDownItemRenderer;
                e.itemArea = this._hitTestItemArea;
                e.editKind = this._editKind;
                e.triggerEvent = event;
                e.reason = reason;
                dispatchEvent(e);
                lockedRow = this._taskLayout.lockedRow;
                this._taskItemContainer.lockedItems = [];
                this._taskItemContainer.layoutOverrideYItemRenderers = [];
                this._taskLayout.lockedRow = null;
                this._taskLayout.lockedTask = null;
                this._taskLayout.taskIgnoredWhenDistributing = null;
                if (lockedRow != null)
                {
                    this.invalidateLayoutOfTasksInRows([lockedRow]);
                }
                if (reason == GanttSheetEventReason.COMPLETED)
                {
                    if (!(this._mouseDownItem is IPropertyChangeNotifier))
                    {
                        this._taskCollection.itemUpdated(this._mouseDownItem);
                    }
                    if (this._taskSummaries && this._autoResizeSummary)
                    {
                        for each (summary in this._taskSummaries)
                        {
                            this.commitItem(summary);
                            if (!(summary.data is IPropertyChangeNotifier))
                            {
                                this._taskCollection.itemUpdated(summary.data);
                            }
                        }
                    }
                }
                this.updateTaskItemsAndLayout([this.itemToTaskItem(this._mouseDownItem)]);
                if (this._taskSummaries && this._autoResizeSummary)
                {
                    this.updateTaskItemsAndLayout(this._taskSummaries);
                }
                this._taskSummaries = null;
                this._editKind = null;
                this._inStopDragging = false;
            }
            this.terminateMouseDownUp();
        }

        private function updateTaskItemsAndLayout(taskItems:Array):void
        {
            var taskItem:TaskItem;
            var items:Array = [];
            for each (taskItem in taskItems)
            {
                this.updateTaskItem(taskItem, null);
                items.push(taskItem.data);
            }
            this.invalidateTaskItemsLayout(items);
        }

        private function terminateMouseDownUp():void
        {
            if (!this._isMouseDown)
            {
                return;
            }
            this.removeConstraintPath();
            this.stopAutoScroll();
            this.hideEditingTip();
            var sandboxRoot:DisplayObject = systemManager.getSandboxRoot();
            sandboxRoot.removeEventListener(MouseEvent.MOUSE_UP, this.mouseUpHandler, true);
            sandboxRoot.removeEventListener(MouseEvent.MOUSE_MOVE, this.content_mouseMoveHandler, true);
            sandboxRoot.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, this.mouseUpHandler, true);
            sandboxRoot.removeEventListener(SandboxMouseEvent.MOUSE_MOVE_SOMEWHERE, this.content_mouseMoveHandler, true);
            sandboxRoot.removeEventListener(MouseEvent.ROLL_OUT, this.stage_mouseOutHandler);
            sandboxRoot.removeEventListener(MouseEvent.ROLL_OVER, this.stage_mouseOverHandler);
            removeEventListener(KeyboardEvent.KEY_DOWN, this.keyDownHandler);
            removeEventListener(KeyboardEvent.KEY_UP, this.keyUpHandler);
            sandboxRoot.removeEventListener(KeyboardEvent.KEY_DOWN, this.keyDownHandler);
            sandboxRoot.removeEventListener(KeyboardEvent.KEY_UP, this.keyUpHandler);
            systemManager.deployMouseShields(false);
            this._timeController.stopAdjusting();
            this._isMouseDown = false;
            this._isCtrlMouseDown = false;
            this._isDragging = false;
            this._isCreatingConstraint = false;
            this._isDraggingSet = false;
            this._isDraggingX = false;
            this._isDraggingY = false;
            this._isPanning = false;
            this._editedTaskItem = null;
            this._mouseDownItemRenderer = null;
            this._mouseDownItem = null;
            this._timeBeforePanning = 0;
            this._originalResource = null;
            this._targetResource = null;
            this._sourceTask = null;
            this._targetTask = null;
            this.removeCreateConstraintCursor();
            this.removePanningCursor();
            this.removeInvalidReassignCursor();
            this.setHitTestItem(null, null);
        }

        public function startAutoScroll(p:Point):void
        {
            var xScrollMax:Number;
            var xOffset:Number;
            var yScrollMax:Number;
            var yOffset:Number;
            var delay:Number;
            var r:Rectangle = this.timeRectangle.clone();
            var xThreshold:Number = getStyle("autoScrollXThreshold");
            var yThreshold:Number = (this.reassignEnabled || this.createConstraintEnabled) ? getStyle("autoScrollYThreshold") : 0;
            r.inflate(-xThreshold, -yThreshold);
            if (!r.containsPoint(p))
            {
                this._autoScrollPoint = p.clone();
                xScrollMax = getStyle("autoScrollXMaximum");
                if (xThreshold == 0 || xScrollMax == 0)
                {
                    xOffset = 0;
                }
                else
                {
                    if (p.x < r.x)
                    {
                        xOffset = (-Math.min(r.x - p.x, xThreshold) / xThreshold) * xScrollMax;
                    }
                    else
                    {
                        if (p.x > r.right)
                        {
                            xOffset = (Math.min(p.x - r.right, xThreshold) / xThreshold) * xScrollMax;
                        }
                        else
                        {
                            xOffset = 0;
                        }
                    }
                }
                yScrollMax = getStyle("autoScrollYMaximum");
                if (yThreshold == 0 || yScrollMax == 0)
                {
                    yOffset = 0;
                }
                else
                {
                    if (p.y < r.y)
                    {
                        yOffset = (-Math.min(r.y - p.y, yThreshold) / yThreshold) * yScrollMax;
                    }
                    else
                    {
                        if (p.y > r.bottom)
                        {
                            yOffset = (Math.min(p.y - r.bottom, yThreshold) / yThreshold) * yScrollMax;
                        }
                        else
                        {
                            yOffset = 0;
                        }
                    }
                }
                delay = getStyle("autoScrollRepeatInterval");
                this.startAutoScrollInternal(xOffset, yOffset, delay);
            }
            else
            {
                this.stopAutoScroll();
            }
        }

		public function startAutoScrollInternal(dx:Number, dy:Number, delay:Number):void
        {
            this._autoScrollOffset = new Point(dx, dy);
            if (this._autoScrollTimer == null)
            {
                this._autoScrollTimer = new Timer(delay, 0);
                this._autoScrollTimer.addEventListener(TimerEvent.TIMER, this.autoScrollTimerHandler);
            }
            this.scrollVertically(0, "pixel", true);
            this._autoScrollTimer.start();
            this._timeController.startAdjusting();
        }

        public function stopAutoScroll():void
        {
            if (this._autoScrollTimer == null)
            {
                return;
            }
            this._autoScrollTimer.stop();
            this._autoScrollTimer = null;
            this._timeController.stopAdjusting();
        }

        private function content_rollOutHandler(event:MouseEvent):void
        {
            if (!enabled || event.target != this._content)
            {
                return;
            }
            if (!this._isMouseDown)
            {
                this.setHitTestItem(null, null);
            }
        }

        private function stage_mouseOutHandler(event:MouseEvent):void
        {
            if (this._isPanning)
            {
                this.removePanningCursor();
            }
            else if (this._isDragging)
			{
				this.removeEditingCursor();
			}
        }

        private function stage_mouseOverHandler(event:MouseEvent):void
        {
            if (this._isMouseDown && !this.isMouseButtonDown(event))
            {
                this.mouseUpHandler(event);
                return;
            }
            if (this._isPanning)
            {
                this.installPanningCursor();
            }
            else if (this._isDragging)
			{
				this.installEditingCursor();
			}
        }

        override protected function keyDownHandler(event:KeyboardEvent):void
        {
            super.keyDownHandler(event);
            if (!enabled)
            {
                return;
            }
            if (event.keyCode == Keyboard.ESCAPE && (this._isDragging || this._isPanning))
            {
                this.cancelInteraction();
                event.stopPropagation();
            }
            else if (this._isDragging)
			{
				this.updateReassignAllowed(event);
			}
        }

        override protected function keyUpHandler(event:KeyboardEvent):void
        {
            super.keyUpHandler(event);
            if (!enabled)
            {
                return;
            }
            if (this._isDragging)
            {
                this.updateReassignAllowed(event);
            }
        }

        private function autoScrollTimerHandler(event:TimerEvent):void
        {
            if (!enabled)
            {
                return;
            }
            var e:GanttSheetEvent = new GanttSheetEvent(GanttSheetEvent.AUTO_SCROLL, false, true);
            e.sourceResource = this._originalResource;
            e.targetResource = this._targetResource;
            e.triggerEvent = event;
            e.editKind = this._editKind;
            e.item = this._mouseDownItem;
            e.itemRenderer = this._mouseDownItemRenderer;
            e.itemArea = this._hitTestItemArea;
            dispatchEvent(e);
        }

        private function autoScrollHandler(event:GanttSheetEvent):void
        {
            if (event.isDefaultPrevented())
            {
                return;
            }
            if (this._autoScrollOffset.x != 0)
            {
                this._timeController.shiftByCoordinate(this._autoScrollOffset.x);
            }
            if (this._isDragging && (this._editKind == TaskItemEditKind.MOVE_REASSIGN || this._editKind == TaskItemEditKind.REASSIGN || this._editKind == TaskItemEditKind.CREATE_CONSTRAINT))
            {
                if (this._autoScrollOffset.y != 0)
                {
                    this.scrollVertically(this._autoScrollOffset.y, "pixel");
                }
            }
            if (this._isDragging && this._autoScrollPoint != null)
            {
                this.dragItem(event, this._autoScrollPoint.x, this._autoScrollPoint.y);
            }
        }

        private function itemEditDragHandler(event:GanttSheetEvent):void
        {
            var mouseEvent:MouseEvent;
            var yThreshold:Number;
            var renderer:Object;
            var cancelMove:Boolean;
            var reassigning:Boolean;
            var reassignIsEnabled:Boolean;
            var xThreshold:Number;
            if (event.isDefaultPrevented())
            {
                return;
            }
            if (this.taskChart != null)
            {
                if (event.editKind == TaskItemEditKind.CREATE_CONSTRAINT)
                {
                    return;
                }
                if (event.editKind == TaskItemEditKind.MOVE || event.editKind == TaskItemEditKind.NONE)
                {
                    mouseEvent = (event.triggerEvent as MouseEvent);
                    if (mouseEvent)
                    {
                        yThreshold = getStyle("cancelMoveYThreshold");
                        renderer = this.mouseEventToItemRenderer(mouseEvent);
                        cancelMove = true;
                        if (renderer != null && renderer != event.itemRenderer && DisplayObject(renderer).parent == this._taskItemContainer 
							&& this.isConstraintCreationEnabledInternal(this._mouseDownItem, true))
                        {
                            event.editKind = TaskItemEditKind.CREATE_CONSTRAINT;
                        }
                        else
                        {
                            if (Math.abs(event.offset.y) > yThreshold)
                            {
                                event.editKind = TaskItemEditKind.NONE;
                            }
                            else
                            {
                                cancelMove = false;
                                event.editKind = TaskItemEditKind.MOVE;
                            }
                        }
                        if (cancelMove)
                        {
                            this._taskItemContainer.lockedItems = [];
                            this._taskItemContainer.layoutOverrideYItemRenderers = [];
                            this._taskLayout.lockedRow = null;
                            this._taskLayout.lockedTask = null;
                            this._taskLayout.taskIgnoredWhenDistributing = null;
                            this.updateTaskItemsAndLayout([event.taskItem]);
                            if (this._taskSummaries && this._autoResizeSummary)
                            {
                                this.updateTaskItemsAndLayout(this._taskSummaries);
                            }
                        }
                    }
                }
            }
            else
            {
                reassigning = event.editKind == TaskItemEditKind.MOVE_REASSIGN || event.editKind == TaskItemEditKind.REASSIGN;
                reassignIsEnabled = this.isItemReassignEnabledInternal(event.item);
                if ((event.editKind == TaskItemEditKind.MOVE || reassigning) && reassignIsEnabled)
                {
                    if (reassigning != this._reassignAllowedWhileDragging)
                    {
                        event.editKind = reassigning ? TaskItemEditKind.MOVE : TaskItemEditKind.REASSIGN;
                    }
                    if (event.editKind == TaskItemEditKind.REASSIGN)
                    {
                        xThreshold = getStyle("reassignXThreshold");
                        if (xThreshold >= 0 && Math.abs(event.offset.x) > xThreshold)
                        {
                            event.editKind = TaskItemEditKind.MOVE_REASSIGN;
                        }
                    }
                }
            }
        }

        private function itemEditMoveHandler(event:GanttSheetEvent):void
        {
            if (event.isDefaultPrevented())
            {
                return;
            }
            event.editTime = event.taskItem.startTime;
            event.editTime = this.snapTime(event.editTime);
            event.moveTask();
        }

        private function itemEditReassignHandler(event:GanttSheetEvent):void
        {
            if (event.isDefaultPrevented())
            {
                return;
            }
            event.reassignTask();
        }

        private function itemEditResizeHandler(event:GanttSheetEvent):void
        {
            if (event.isDefaultPrevented())
            {
                return;
            }
            event.editTime = event.editKind == TaskItemEditKind.RESIZE_START ? event.taskItem.startTime : event.taskItem.endTime;
            event.editTime = this.snapTime(event.editTime);
            event.resizeTask();
        }

        private function itemEditEndHandler(event:GanttSheetEvent):void
        {
            if (event.isDefaultPrevented())
            {
                return;
            }
            if (event.reason == GanttSheetEventReason.COMPLETED)
            {
                if (event.editKind == TaskItemEditKind.CREATE_CONSTRAINT)
                {
                    this.createConstraint(event.sourceTask, event.targetTask);
                }
                else
                {
                    this.commitItem(event.taskItem);
                }
            }
        }
		
		private function timeController_visibleNowTimeChangeHandler(event:GanttSheetEvent):void
		{
			_visibleNowTimeChanged = true;
			invalidateProperties();
		}

        private function timeController_visibleTimeRangeChangeHandler(event:GanttSheetEvent):void
        {
            var grid:GanttSheetGridBase;
            this._visibleTimeRangeChanged = true;
            invalidateProperties();
            for each (grid in this.allGrids)
            {
                grid.timeControllerChangedInternal();
            }
            dispatchEvent(event);
        }

        private function resizeHandler(event:ResizeEvent):void
        {
            this.invalidateTimeRectangle();
        }

		/**
		 * 数据有变化时，会被回调 
		 * @param event
		 * 
		 */		
        private function taskCollection_collectionChangeHandler(event:Event):void
        {
            var item:Object;
            var items:Array;
            var taskItem:TaskItem;
            var uid:String;
            var summaries:Array;
            var p:PropertyChangeEvent;
            var unselect:Object;
            var select:Array;
            var change:Boolean;
            var keepSelection:Boolean;
            var oldSelectedItems:Array;
            var ce:CollectionEvent = event as CollectionEvent;
            if (ce == null)
            {
                return;
            }
            if (ce.kind == CollectionEventKind.UPDATE)
            {
                items = [];
                for each (p in ce.items)
                {
                    item = p.source;
                    taskItem = this.itemToTaskItem(item);
                    if (!(this._inStopDragging && (this._mouseDownItem == item || (this._taskSummaries != null && this._taskSummaries.indexOf(taskItem) >= 0))))
                    {
                        this.updateTaskItem(taskItem, p.property);
                        if (!this.resizingTaskSummaries && this._autoResizeSummary)
                        {
                            summaries = this.getTaskSummaries(item);
                            if (taskItem.isSummary)
                            {
                                summaries.push(taskItem);
                            }
                            this.updateTaskSummaries(summaries, true);
                        }
                    }
                    items.push(item);
                }
                this.invalidateTaskItemsLayout(items);
            }
            else if (ce.kind == CollectionEventKind.ADD)
			{
				if (this._autoResizeSummary)
				{
					if (ce.items == null || ce.items.length == 0)
					{
						this.resizeSummaryTasks();
					}
					else
					{
						for each (item in ce.items)
						{
							if (!this.resizingTaskSummaries && this._autoResizeSummary && item)
							{
								summaries = this.getTaskSummaries(item);
								taskItem = this.itemToTaskItem(item);
								if (taskItem.isSummary)
								{
									summaries.push(taskItem);
								}
								this.updateTaskSummaries(summaries, true);
							}
						}
					}
				}
				this.invalidateItemsSize();
				if (this._constraintsCache)
				{
					this._constraintsCache.invalidate();
				}
			}
			else if (ce.kind == CollectionEventKind.REMOVE)
			{
				unselect = {};
				for each (item in ce.items)
				{
					uid = this.itemToUID(item);
					delete this._taskItems[uid];
					if (this._highlightUID == uid)
					{
						this._highlightUID = null;
					}
					if (this.isItemSelected(uid))
					{
						unselect[uid] = item;
					}
				}
				select = [];
				for (item in this._selectedItems)
				{
					if (unselect[this.itemToUID(item)] === undefined)
					{
						change = true;
						select.push(item);
					}
				}
				if (change)
				{
					this.commitSelectedItems(select);
				}
				if (!this.resizingTaskSummaries && this._autoResizeSummary)
				{
					this.resizeSummaryTasks();
				}
				if (this._constraintsCache)
				{
					this._constraintsCache.invalidate();
				}
				this.invalidateItemsSize();
			}
			else  if (ce.kind == CollectionEventKind.RESET || ce.kind == CollectionEventKind.REFRESH)
			{
				keepSelection = (ce.kind == CollectionEventKind.REFRESH);
				if (keepSelection)
				{
					oldSelectedItems = this.selectedItems;
				}
				this.clearTaskData();
				if (this._autoResizeSummary)
				{
					this.resizeSummaryTasks();
				}
				this.invalidateItemsSize();
				if (keepSelection)
				{
					this.selectedItems = oldSelectedItems;
				}
			}
            this.invalidateTasksInterval();
        }

        private function invalidateTasksInterval():void
        {
            this._tasksIntervalInvalid = true;
            invalidateProperties();
        }

        private function validateTasksInterval():void
        {
            if (this._tasksIntervalInvalid)
            {
                this._tasksIntervalInvalid = false;
                this.computeTasksInterval();
            }
        }

        private function computeTasksInterval():void
        {
            if (this._minScrollTime != 0 && this._maxScrollTime != 0)
            {
                return;
            }
            var oldStart:Number = this._tasksIntervalStart;
            var oldEnd:Number = this._tasksIntervalEnd;
            var range:Object = this._taskCollection != null ? this.getFlatTaskCollectionTimeRange(this._taskCollection) : null;
            this._tasksIntervalStart = range != null ? range.start : 0;
            this._tasksIntervalEnd = range != null ? range.end : this._tasksIntervalStart;
            if (oldStart == 0 || oldStart != this._tasksIntervalStart)
            {
                this._timeBoundsChanged = true;
                dispatchEvent(new Event("minScrollTimeChanged"));
            }
            if (oldEnd == 0 || oldEnd != this._tasksIntervalEnd)
            {
                this._timeBoundsChanged = true;
                dispatchEvent(new Event("maxScrollTimeChanged"));
            }
        }

		public function constraintCollection_collectionChangeHandler(event:Event):void
        {
            var item:Object;
            var ce:CollectionEvent;
            var items:Array;
            var p:PropertyChangeEvent;
            var unselect:Object;
            var select:Array;
            var change:Boolean;
            var uid:String;
            var keepSelection:Boolean;
            var oldSelectedItems:Array;
            if (event is CollectionEvent)
            {
                ce = CollectionEvent(event);
                if (ce.kind == CollectionEventKind.UPDATE)
                {
                    items = [];
                    for each (p in ce.items)
                    {
                        this.updateConstraintItem(this.itemToConstraintItem(p.source), p.property);
                        items.push(p.source);
                    }
                    this.invalidateConstraintItemsLayout(items);
                }
                else if (ce.kind == CollectionEventKind.ADD)
				{
					for each (item in ce.items)
					{
						this.constraintsCache.add(item);
					}
					this.invalidateConstraintItemsLayout(ce.items);
				}
				else if (ce.kind == CollectionEventKind.REMOVE)
				{
					unselect = {};
					for each (item in ce.items)
					{
						this.constraintsCache.remove(item);
						uid = this.itemToUID(item);
						delete this._constraintItems[uid];
						if (this._highlightUID == uid)
						{
							this._highlightUID = null;
						}
						if (this.isItemSelected(uid))
						{
							unselect[uid] = item;
						}
					}
					select = [];
					for (item in this._selectedItems)
					{
						if (unselect[this.itemToUID(item)] === undefined)
						{
							change = true;
							select.push(item);
						}
					}
					if (change)
					{
						this.commitSelectedItems(select);
					}
					this.invalidateItemsSize();
				}
				else if (ce.kind == CollectionEventKind.RESET || ce.kind == CollectionEventKind.REFRESH)
				{
					keepSelection = (ce.kind == CollectionEventKind.REFRESH);
					oldSelectedItems = this.selectedItems;
					if (keepSelection)
					{
						oldSelectedItems = this.selectedItems;
					}
					this.clearConstraintData();
					this.invalidateItemsSize();
					if (keepSelection)
					{
						this.selectedItems = oldSelectedItems;
					}
				}
            }
        }

        private function calendar_changeHandler(event:Event):void
        {
            this._calendarChanged = true;
            invalidateProperties();
        }

		/**
		 * 拖拽的过程中 
		 * @param event
		 * @param newMouseX
		 * @param newMouseY
		 * 
		 */		
        private function dragItem(event:Event, newMouseX:Number, newMouseY:Number):void
        {
            newMouseY = (newMouseY - this._dragInitialItemMousePoint.y);
            var initialX:Number = (this._hitTestItemArea == TaskItemArea.BAR || this._hitTestItemArea == TaskItemArea.START) ? this._dragInitialStartX : this._dragInitialEndX;
            var newTime:Number = this._timeController.getTime(initialX + newMouseX - this._mouseDownPoint.x);
            var offset:Point = new Point((newMouseX - this._mouseDownPoint.x), (newMouseY - this._mouseDownPoint.y));
            var newRowItem:Object = this.getRowItemInSnapRange(newMouseY);
            var taskItem:TaskItem = this.itemToTaskItem(this._mouseDownItem);
            var e:GanttSheetEvent = new GanttSheetEvent(GanttSheetEvent.ITEM_EDIT_DRAG, false, true);
            e.sourceResource = this._originalResource;
            e.targetResource = newRowItem;
            e.editTime = newTime;
            e.triggerEvent = event;
            e.editKind = this._editKind;
            e.item = this._mouseDownItem;
            e.offset = offset;
            e.itemRenderer = this._mouseDownItemRenderer;
            e.itemArea = this._hitTestItemArea;
            dispatchEvent(e);
            if (this._editKind == null)
            {
                return;
            }
            if (e.editKind == null)
            {
                this.cancelInteraction();
                return;
            }
            this._editKind = e.editKind;
            if (this._editKind == TaskItemEditKind.CREATE_CONSTRAINT)
            {
                this.updateConstraintTargetTask((event as MouseEvent), newTime, offset);
                return;
            }
            this.removeConstraintPath();
            if (this.isMoving())
            {
                this.moveOrResizeItem(GanttSheetEvent.ITEM_EDIT_MOVE, event, taskItem, newTime, newRowItem, offset);
            }
            else if (this.isResizing())
			{
				this.moveOrResizeItem(GanttSheetEvent.ITEM_EDIT_RESIZE, event, taskItem, newTime, newRowItem, offset);
			}
            if (this.isReassigning())
            {
                this.reassignItem(event, taskItem, newMouseY, newRowItem, offset);
            }
            this.updateEditingToolTip(this._mouseDownItem, (this._mouseDownItemRenderer as DisplayObject));
        }

        private function moveOrResizeItem(eventType:String, event:Event, taskItem:TaskItem, newTime:Number, newRowItem:Object, offset:Point):void
        {
            var e:GanttSheetEvent = new GanttSheetEvent(eventType, false, true);
            e.sourceResource = this._originalResource;
            e.targetResource = newRowItem;
            e.editTime = newTime;
            e.triggerEvent = event;
            e.editKind = this._editKind;
            e.item = this._mouseDownItem;
            e.offset = offset;
            e.itemRenderer = this._mouseDownItemRenderer;
            e.itemArea = this._hitTestItemArea;
            if (eventType == GanttSheetEvent.ITEM_EDIT_MOVE)
            {
                e.moveTask();
            }
            else
            {
                e.resizeTask();
            }
            dispatchEvent(e);
            if (this._editKind == null)
            {
                return;
            }
            if (e.editKind == null)
            {
                this.cancelInteraction();
                return;
            }
            this._editKind = e.editKind;
            if (this._taskSummaries && this._autoResizeSummary)
            {
                this.updateTaskSummaries(this._taskSummaries, false);
            }
            this.invalidateTaskItemsLayout([this._mouseDownItem]);
        }

        private function reassignItem(event:Event, taskItem:TaskItem, newY:Number, newRowItem:Object, offset:Point):void
        {
            var oldRowItem:Object = taskItem.resource;
            if (this._targetResource != null && oldRowItem == newRowItem)
            {
                return;
            }
            var e:GanttSheetEvent = new GanttSheetEvent(GanttSheetEvent.ITEM_EDIT_REASSIGN, false, true);
            e.editKind = this._editKind;
            e.sourceResource = this._originalResource;
            e.targetResource = newRowItem;
            e.triggerEvent = event;
            e.item = this._mouseDownItem;
            e.offset = offset;
            e.itemRenderer = this._mouseDownItemRenderer;
            e.itemArea = this._hitTestItemArea;
            dispatchEvent(e);
            if (this._editKind == null)
            {
                return;
            }
            if (e.editKind == null)
            {
                this.cancelInteraction();
                return;
            }
            this._editKind = e.editKind;
            this._targetResource = taskItem.resource == e.targetResource ? e.targetResource : null;
            this._taskLayout.lockedTask = null;
            if (this._targetResource != null)
            {
                this.removeInvalidReassignCursor();
                this.snapDraggedTaskToRow();
                this.showEditingToolTip();
            }
            else
            {
                this.installInvalidReassignCursor();
                this.unsnapDraggedTaskFromRow(newY);
                this.hideEditingTip();
            }
            this.invalidateTaskItemsLayout([this._mouseDownItem]);
            if (oldRowItem != this._targetResource)
            {
                this.invalidateLayoutOfTasksInRows([oldRowItem]);
            }
        }

        private function snapDraggedTaskToRow():void
        {
            this._taskItemContainer.layoutOverrideYItemRenderers = [];
        }

        private function unsnapDraggedTaskFromRow(y:Number):void
        {
            this._taskItemContainer.layoutOverrideYItemRenderers = [this._mouseDownItemRenderer];
            this._taskItemContainer.layoutFreeRenderer(DisplayObject(this._mouseDownItemRenderer), y);
        }

        private function getRowItemInSnapRange(newItemY:Number):Object
        {
            var p:Point = new Point(0, (newItemY + this._dragInitialItemMousePoint.y));
            p = localToGlobal(p);
            return this.rowController.getItemAt(p.y);
        }

        public function updateTaskSummaries(summaries:Array, commit:Boolean):void
        {
            var t:TaskItem;
            if (!summaries)
            {
                return;
            }
            var collection:IHierarchicalCollectionView = (this._taskCollection as IHierarchicalCollectionView);
            if (!collection)
            {
                return;
            }
            var items:Array = [];
            for each (t in summaries)
            {
                this.resizeSummaryTask(t, collection, commit);
                items.push(t.data);
            }
            this.invalidateTaskItemsLayout(items);
        }

        private function isReassigning():Boolean
        {
            return (this._editKind == TaskItemEditKind.MOVE_REASSIGN || this._editKind == TaskItemEditKind.REASSIGN) && this.isItemReassignEnabledInternal(this._mouseDownItem);
        }

        private function isMoving():Boolean
        {
            return (this._editKind == TaskItemEditKind.MOVE_REASSIGN || this._editKind == TaskItemEditKind.MOVE) && this.isItemMoveEnabledInternal(this._mouseDownItem);
        }

        private function isResizing():Boolean
        {
            return (this._editKind == TaskItemEditKind.RESIZE_END || this._editKind == TaskItemEditKind.RESIZE_START) && this.isItemResizeEnabledInternal(this._mouseDownItem, this._editKind);
        }

        private function updateConstraintTargetTask(event:MouseEvent, newTime:Number, offset:Point):void
        {
            var array:Array;
            if (!this._isCreatingConstraint)
            {
                this.hideEditingTip();
                this._isCreatingConstraint = true;
                this.installCreateConstraintCursor();
                this._sourceTask = (this._mouseDownItemRenderer.data as TaskItem).data;
                this.invalidateItemsDisplayList([this._sourceTask]);
                this._constraintCreationLayer = new Group();
                this._constraintCreationLayer.mouseEnabled = false;
                this._constraintCreationLine = new Line();
                this._constraintCreationLine.stroke = new SolidColorStroke(getStyle("createConstraintLineColor"), getStyle("createConstraintLineThickness"));
                this._constraintCreationLayer.addElement(this._constraintCreationLine);
                this._content.addChild(this._constraintCreationLayer);
            }
            var renderer:Object = this.mouseEventToItemRenderer(event);
            var targetTask:Object = renderer is IDataRenderer ? this.getDataItem(IDataRenderer(renderer).data) : null;
            if (targetTask != null && !this.isConstraintCreationEnabledInternal(targetTask, false))
            {
                targetTask = null;
            }
            var e:GanttSheetEvent = new GanttSheetEvent(GanttSheetEvent.ITEM_EDIT_CONSTRAINT, false, true);
            e.sourceTask = this._sourceTask;
            e.targetTask = targetTask;
            e.editTime = newTime;
            e.triggerEvent = event;
            e.editKind = this._editKind;
            e.item = this._mouseDownItem;
            e.offset = offset;
            e.itemRenderer = this._mouseDownItemRenderer;
            e.itemArea = this._hitTestItemArea;
            dispatchEvent(e);
            if (this._editKind == null)
            {
                return;
            }
            if (e.editKind == null)
            {
                this.cancelInteraction();
                return;
            }
            targetTask = e.targetTask;
            if (this._targetTask != targetTask)
            {
                array = [];
                if (this._targetTask != null)
                {
                    array.push(this._targetTask);
                }
                this._targetTask = (((targetTask == this._sourceTask)) ? (null) : (targetTask));
                if (this._targetTask != null)
                {
                    array.push(this._targetTask);
                }
                this.invalidateItemsDisplayList(array);
            }
            var p:Point = this.getMousePosition(e);
            this._constraintCreationLine.xFrom = this.getCoordinate(this._mouseDownTime);
            this._constraintCreationLine.yFrom = ((this._mouseDownPoint.y + this._mouseDownVerticalOffset) - this.verticalScrollBar.value);
            this._constraintCreationLine.xTo = p.x;
            this._constraintCreationLine.yTo = p.y;
            this._constraintCreationLine.invalidateSize();
        }

        private function removeConstraintPath():void
        {
            if (!this._isCreatingConstraint)
            {
                return;
            }
            this._isCreatingConstraint = false;
            this.removeCreateConstraintCursor();
            var array:Array = [];
            if (this._sourceTask != null)
            {
                array.push(this._sourceTask);
            }
            if (this._targetTask != null)
            {
                array.push(this._targetTask);
            }
            this._sourceTask = (this._targetTask = null);
            this.invalidateItemsDisplayList(array);
            this._content.removeChild(this._constraintCreationLayer);
            this._constraintCreationLayer = null;
            this._constraintCreationLine = null;
        }

		public function clearTaskData():void
        {
            this._highlightUID = null;
            this._selectedUIDs = {};
            this._selectedItems = [];
            this._taskItems = {};
            if (this._taskItemContainer)
            {
                this._taskItemContainer.clearTaskData();
            }
            if (this._constraintsCache)
            {
                this._constraintsCache.invalidate();
            }
        }

		public function clearConstraintData():void
        {
            this._highlightUID = null;
            this._selectedUIDs = {};
            this._selectedItems = [];
            this._constraintItems = {};
            if (this._constraintItemContainer)
            {
                this._constraintItemContainer.clearConstraintData();
            }
            if (this._constraintsCache)
            {
                this._constraintsCache.invalidate();
            }
        }

        private function updateTaskItem(taskItem:TaskItem, property:Object):void
        {
            this.ganttChart.updateTaskItem(taskItem, property);
        }

        private function updateConstraintItem(constraintItem:ConstraintItem, property:Object):void
        {
            this.taskChart.updateConstraintItem(constraintItem, property);
        }

        public function commitItem(item:DataItem):void
        {
            if (this._commitItemFunction != null)
            {
                this._commitItemFunction(item);
            }
            else
            {
                if (item is TaskItem)
                {
                    this.ganttChart.commitTaskItem(TaskItem(item));
                }
                else if (item is ConstraintItem)
				{
					this.taskChart.commitConstraintItem(ConstraintItem(item));
				}
            }
        }

        private function createConstraint(fromTask:Object, toTask:Object):void
        {
            if (this._createConstraintFunction != null && fromTask != null && toTask != null)
            {
                this._createConstraintFunction(fromTask, toTask);
            }
        }

		public function getTaskSummaries(task:Object):Array
        {
            var taskItem:TaskItem;
            var collection:IHierarchicalCollectionView = (this._taskCollection as IHierarchicalCollectionView);
            if (!collection)
            {
                return null;
            }
            var parents:Array = [];
            var parent:Object = collection.getParentItem(task);
            while (parent != null)
            {
                taskItem = this.itemToTaskItem(parent);
                if (taskItem && taskItem.isSummary)
                {
                    parents.push(taskItem);
                }
                parent = collection.getParentItem(parent);
            }
            return parents;
        }

		public function resizeSummaryTasks():void
        {
            var t:TaskItem;
            var collection:IHierarchicalCollectionView = (this._taskCollection as IHierarchicalCollectionView);
            if (!collection)
            {
                return;
            }
            var summaryTasks:Array = this.getSummaryTasks(collection);
            for each (t in summaryTasks)
            {
                this.resizeSummaryTask(t, collection, true);
            }
        }

		/**
		 * 把所有的树状结构的数据转化为数组 
		 * @param collection
		 * @return 
		 * 
		 */		
        private function getSummaryTasks(collection:IHierarchicalCollectionView):Array
        {
            var tasks:Array = [];
            this.collectSummaryTasks(collection.source.getRoot(), collection, tasks);
            tasks.reverse();
            return tasks;
        }
		/**
		 * 递归树状结构数据 
		 * @param items
		 * @param collection
		 * @param tasks
		 * 
		 */
        private function collectSummaryTasks(items:*, collection:IHierarchicalCollectionView, tasks:Array):void
        {
            var i:Object;
            var taskItem:TaskItem;
            for each (i in items)
            {
                taskItem = this.itemToTaskItem(i);
                if (taskItem.isSummary)
                {
                    tasks.push(taskItem);
                }
                this.collectSummaryTasks(collection.getChildren(i), collection, tasks);
            }
        }

		public function resizeSummaryTask(summary:TaskItem, collection:IHierarchicalCollectionView, commit:Boolean):void
        {
            var range:Object;
            this._resizingTaskSummaryDepth = this._resizingTaskSummaryDepth + 1;
            var children:ICollectionView = collection.getChildren(summary.data);
            try
            {
                range = this.getFlatTaskCollectionTimeRange(children);
            }
            catch(e:ItemPendingError)
            {
            }
            if (!range)
            {
                if (!(!isNaN(summary.startTime) && !isNaN(summary.endTime)))
                {
                    summary.startTime = 0;
                    summary.endTime = summary.startTime;
                }
            }
            else
            {
                summary.startTime = range.start;
                summary.endTime = range.end;
            }
            if (commit)
            {
                this.commitItem(summary);
            }
            this._resizingTaskSummaryDepth = this._resizingTaskSummaryDepth - 1;
        }
		/**
		 * 初始化鼠标样式 
		 * 
		 */
        private function installEditingCursor():void
        {
            var cursor:Cursor;
            var areaInfo:Object;
            if (this._isCreatingConstraint)
            {
                cursor = this._createConstraintCursor;
            }
            else
            {
                areaInfo = this.getItemAreaInfo(this._hitTestItemArea, this._hitTestItem);
                cursor = areaInfo ? areaInfo.cursor : null;
            }
            if (cursor == this._editingCursor)
            {
                return;
            }
            this.removeEditingCursor();
            if (cursor)
            {
                cursor.setCursor();
                this._editingCursor = cursor;
            }
        }

        private function removeEditingCursor():void
        {
            if (this._editingCursor)
            {
                this._editingCursor.removeCursor();
                this._editingCursor = null;
            }
        }

        private function installPanningCursor():void
        {
            this._panCursor.setCursor();
        }

        private function removePanningCursor():void
        {
            this._panCursor.removeCursor();
        }

        private function installCreateConstraintCursor():void
        {
            this._createConstraintCursor.setCursor(CursorManagerPriority.HIGH);
        }

        private function removeCreateConstraintCursor():void
        {
            this._createConstraintCursor.removeCursor();
        }

        private function installInvalidReassignCursor():void
        {
            this._invalidReassignCursor.setCursor(CursorManagerPriority.HIGH);
        }

        private function removeInvalidReassignCursor():void
        {
            this._invalidReassignCursor.removeCursor();
        }

        private function cancelPendingToolTip():void
        {
            if (this._pendingToolTipInfo != null)
            {
                this._pendingToolTipInfo.timer.stop();
                this._pendingToolTipInfo = null;
            }
        }

        private function createDataTip(item:Object, itemRenderer:DisplayObject):void
        {
            if (this._editKind || !this.showDataTips)
            {
                return;
            }
            var text:String = this.itemToDataTip(item);
            if (text == null)
            {
                return;
            }
            this.cancelPendingToolTip();
            var time:Number = getStyle("dataTipShowDelay");
            if (isNaN(time))
            {
                time = ToolTipManager.showDelay;
            }
            var timer:Timer = new Timer(time);
            timer.addEventListener(TimerEvent.TIMER, this.showDataTipHandler);
            this._pendingToolTipInfo = new PendingToolTipInfo(timer, itemRenderer, text);
            timer.start();
        }

        public function hideDataTip():void
        {
            if (this._currentDataTip != null)
            {
                ToolTipManager.destroyToolTip(this._currentDataTip);
                this._currentDataTip = null;
            }
            this.cancelPendingToolTip();
        }

        private function showDataTipHandler(event:Event):void
        {
            if (this._pendingToolTipInfo == null)
            {
                return;
            }
            this._pendingToolTipInfo.timer.stop();
            var p:Point = localToGlobal(this.getMousePosition(event));
            this._currentDataTip = ToolTipManager.createToolTip(this._pendingToolTipInfo.text, p.x, p.y, null, this);
            var renderer:DisplayObject = this._pendingToolTipInfo.renderer;
            if (renderer is IDataRenderer)
            {
                if ((IDataRenderer(renderer).data is TaskItem))
                {
                    this.layoutTaskDataTip(this._currentDataTip, renderer);
                }
                else if ((IDataRenderer(renderer).data is ConstraintItem))
				{
					this.layoutConstraintDataTip(this._currentDataTip, renderer);
				}
            }
            this._pendingToolTipInfo = null;
        }

        private function layoutDataTip(toolTip:IToolTip, p:Point, height:Number):void
        {
            var screen:Rectangle;
            if ((p.x + 10) > this.width)
            {
                p.x = (this.width - 10);
            }
            if (p.x < 0)
            {
                p.x = 0;
            }
            if (p.y + height + TOOLTIP_Y_OFFSET + toolTip.height > this.height)
            {
                p.y = p.y - TOOLTIP_Y_OFFSET - toolTip.height;
            }
            else
            {
                p.y = p.y + height + TOOLTIP_Y_OFFSET;
            }
            if (p.y < 0)
            {
                p.y = 0;
            }
            if ((p.y + toolTip.height) > this.height)
            {
                p.y = (this.height - toolTip.height);
            }
            screen = systemManager.screen;
            p = this.localToGlobal(p);
            p = systemManager.getSandboxRoot().globalToLocal(p);
            if ((p.x + toolTip.width) > (screen.x + screen.width))
            {
                p.x = ((screen.x + screen.width) - toolTip.width);
            }
            if (p.x < screen.x)
            {
                p.x = screen.x;
            }
            if ((p.y + toolTip.height) > (screen.y + screen.height))
            {
                p.y = ((screen.y + screen.height) - toolTip.height);
            }
            if (p.y < screen.y)
            {
                p.y = screen.y;
            }
            toolTip.move(p.x, p.y);
        }

        private function layoutConstraintDataTip(toolTip:IToolTip, itemRenderer:DisplayObject):void
        {
            var gp:Point;
            var p:Point;
            gp = localToGlobal(this.getMousePosition());
            p = new Point(0, 0);
            p = itemRenderer.localToGlobal(p);
            p.x = gp.x;
            p = this.globalToLocal(p);
            this.layoutDataTip(toolTip, p, 30);
        }

        private function layoutTaskDataTip(toolTip:IToolTip, itemRenderer:DisplayObject):void
        {
            var gp:Point;
            var p:Point;
            gp = localToGlobal(this.getMousePosition());
            p = new Point(0, 0);
            p = itemRenderer.localToGlobal(p);
            p.x = gp.x;
            p = this.globalToLocal(p);
            this.layoutDataTip(toolTip, p, itemRenderer.height);
        }

        private function createEditingToolTip(item:Object, itemRenderer:DisplayObject):void
        {
            var text:String;
            var time:Number;
            var timer:Timer;
            if (!this.showEditingTips)
            {
                return;
            }
            text = this.itemToEditingTip(item);
            if (text == null)
            {
                return;
            }
            this.hideDataTip();
            time = getStyle("editingTipShowDelay");
            if (isNaN(time))
            {
                time = ToolTipManager.showDelay;
            }
            timer = new Timer(time);
            timer.addEventListener(TimerEvent.TIMER, this.showEditingToolTipHandler);
            this._pendingToolTipInfo = new PendingToolTipInfo(timer, itemRenderer, text);
            timer.start();
        }

        private function hideEditingTip():void
        {
            if (this._editingToolTip != null)
            {
                ToolTipManager.destroyToolTip(this._editingToolTip);
                this._editingToolTip = null;
            }
            this.cancelPendingToolTip();
        }

        private function showEditingToolTip():void
        {
            if (this._hitTestItem == null || this._editingToolTip != null)
            {
                return;
            }
            if (this._pendingToolTipInfo == null)
            {
                this.createEditingToolTip(this._hitTestItem, (this.itemToItemRenderer(this._hitTestItem) as DisplayObject));
            }
            this.showEditingToolTipHandler(null);
        }

        private function showEditingToolTipHandler(event:Event):void
        {
            var p:Point;
            if (this._pendingToolTipInfo == null)
            {
                return;
            }
            this._pendingToolTipInfo.timer.stop();
            p = localToGlobal(this.getMousePosition());
            this._editingToolTip = ToolTipManager.createToolTip(this._pendingToolTipInfo.text, p.x, p.y, null, this);
            this.layoutEditingTooltip(this._editingToolTip, this._pendingToolTipInfo.renderer);
            this._pendingToolTipInfo = null;
        }

        private function updateEditingToolTip(item:Object, itemRenderer:DisplayObject):void
        {
            if (this._editingToolTip == null)
            {
                return;
            }
            this._editingToolTip.text = this.itemToEditingTip(item);
            this.layoutEditingTooltip(this._editingToolTip, itemRenderer, true);
        }

        private function itemRendererToTaskItem(renderer:Object):TaskItem
        {
            if (renderer is IDataRenderer)
            {
                return IDataRenderer(renderer).data as TaskItem;
            }
            return null;
        }

        private function layoutEditingTooltip(toolTip:IToolTip, itemRenderer:DisplayObject, keepXFixed:Boolean=false):void
        {
            var rowPosition:Number;
            var taskItem:TaskItem;
            var p:Point;
            var mousePosition:Point;
            var screen:Rectangle;
            var row:Object;
            taskItem = this.itemRendererToTaskItem(itemRenderer);
            if (taskItem != null)
            {
                row = this.taskItemToRowItem(taskItem);
                if (row != null)
                {
                    rowPosition = this.rowController.getRowPosition(row);
                }
            }
            if (isNaN(rowPosition))
            {
                p = new Point(0, 0);
            }
            else
            {
                p = new Point(0, rowPosition);
                p = localToGlobal(p);
                p = itemRenderer.globalToLocal(p);
                p.x = 0;
            }
            p = itemRenderer.localToGlobal(p);
            mousePosition = localToGlobal(this.getMousePosition());
            p.x = ((mousePosition.x - toolTip.width) - TOOLTIP_X_OFFSET);
            p.y = ((p.y - toolTip.height) - TOOLTIP_Y_OFFSET);
            p = systemManager.getSandboxRoot().globalToLocal(p);
            screen = systemManager.screen;
            if (keepXFixed)
            {
                p.x = toolTip.x;
            }
            else
            {
                if ((p.x + toolTip.width) > (screen.x + screen.width))
                {
                    p.x = ((screen.x + screen.width) - toolTip.width);
                }
                else
                {
                    if (p.x < screen.x)
                    {
                        p.x = screen.x;
                    }
                }
            }
            if ((p.y + toolTip.height) > (screen.y + screen.height))
            {
                p.y = ((screen.y + screen.height) - toolTip.height);
            }
            else
            {
                if (p.y < screen.y)
                {
                    p.y = screen.y;
                }
            }
            toolTip.move(p.x, p.y);
        }

        protected function computeTimePrecision():Object
        {
            var zf:Number;
            var unit:TimeUnit;
            var steps:Number;
            var p:Object;
            zf = this.timeController.zoomFactor * 8;
            unit = precisionScale[0].unit;
            steps = precisionScale[0].steps;
            for each (p in precisionScale)
            {
                if (zf < TimeUnit(p.unit).milliseconds * p.steps)
                {
                    break;
                }
                unit = p.unit;
                steps = p.steps;
            }
            return ({
                "unit":unit,
                "steps":steps
            });
        }

		public function itemExpandHandler(event:ItemExpandEvent):void
        {
            if (!initialized)
            {
                return;
            }
            if (event.type == ItemExpandEvent.START)
            {
                this.updateItemRenderers();
                this.maskItemRenderers(event.item, event.itemChildren, event.open);
            }
            else if (event.type == ItemExpandEvent.STEP)
			{
				this.updateItemRenderers();
			}
			else if (event.type == ItemExpandEvent.END)
			{
				this.unmaskItemRenderers();
			}
        }

        private function maskItemRenderers(parentRowItem:Object, rowItems:Array, open:Boolean):void
        {
            var maskHeight:Number;
            var rowItem:Object;
            var maskY:Number;
            var renderer:DisplayObject;
            var rowHeight:Number;
            var tmpMask:DisplayObject;
            var constraints:Array;
            this._animatedRenderers = this.getAnimatedRenderers(parentRowItem, rowItems, open);
            maskHeight = 0;
            for each (rowItem in rowItems)
            {
                rowHeight = this.rowController.getRowHeight(rowItem);
                if (!isNaN(rowHeight))
                {
                    maskHeight = maskHeight + rowHeight;
                }
            }
            maskY = (this.rowController.getRowPosition(parentRowItem) + this.rowController.getRowHeight(parentRowItem));
            if (isNaN(maskY))
            {
                maskY = 0;
            }
            for each (renderer in this._animatedRenderers)
            {
                tmpMask = this.createMask();
                tmpMask.x = 0;
                tmpMask.y = maskY;
                tmpMask.width = width;
                tmpMask.height = maskHeight;
                renderer.mask = tmpMask;
                renderer.parent.addChild(tmpMask);
            }
            if (this._constraintItemContainer)
            {
                constraints = this.getConstraintOverBoundaries(parentRowItem, rowItems);
                this._constraintItemContainer.hiddenUIDs = constraints.map(this.getConstraintItemUIDCallback);
            }
        }

        private function getConstraintItemUIDCallback(item:*, index:int, array:Array):String
        {
            var c:ConstraintItem;
            c = item as ConstraintItem;
            return this.itemToUID(c.data);
        }

        private function unmaskItemRenderers():void
        {
            var renderer:DisplayObject;
            for each (renderer in this._animatedRenderers)
            {
                if (renderer.mask)
                {
                    renderer.parent.removeChild(renderer.mask);
                    renderer.mask = null;
                }
            }
            this._animatedRenderers = null;
            if (this._constraintItemContainer)
            {
                this._constraintItemContainer.hiddenUIDs = [];
            }
        }

        private function updateItemRenderers():void
        {
            this.rowHeightChangedHandler();
            this._taskItemContainer.validateNow();
            this._constraintItemContainer.validateNow();
        }

        private function getAnimatedRenderers(parentRowItem:Object, rowItems:Array, open:Boolean):Array
        {
            var renderers:Array;
            var renderer:Object;
            var rowItem:Object;
            var tasks:Array;
            var t:Object;
            var firstRow:int;
            var lastRow:int;
            var constraints:Array;
            var c:ConstraintItem;
            renderers = [];
            if (this._taskItemContainer)
            {
                for each (rowItem in rowItems)
                {
                    tasks = this.ganttChart.rowItemToTasks(rowItem);
                    if (tasks && tasks.length > 0)
                    {
                        for each (t in tasks)
                        {
                            renderer = this._taskItemContainer.itemToItemRenderer(t);
                            if (renderer)
                            {
                                renderers.push(renderer);
                            }
                        }
                    }
                }
            }
            if (open && this._constraintsCache)
            {
                this._constraintsCache.invalidate();
            }
            if (this._constraintItemContainer && this._constraintsCache && rowItems.length > 0)
            {
                try
                {
                    firstRow = this.rowController.getItemIndex(parentRowItem) + 1;
                    lastRow = firstRow + rowItems.length - 1;
                    constraints = this.constraintsCache.getInRangeStrict(firstRow, lastRow);
                    if (constraints && constraints.length > 0)
                    {
                        for each (c in constraints)
                        {
                            renderer = this._constraintItemContainer.itemToItemRenderer(c.data);
                            if (renderer)
                            {
                                renderers.push(renderer);
                            }
                        }
                    }
                }
                catch(error:ItemPendingError)
                {
                }
            }
            return renderers;
        }

        private function getConstraintOverBoundaries(parentRowItem:Object, rowItems:Array):Array
        {
            var items:Array;
            var firstRow:int;
            var lastRow:int;
            var constraints:Array;
            items = [];
            if (this._constraintItemContainer && this._constraintsCache && rowItems.length > 0)
            {
                try
                {
                    firstRow = this.rowController.getItemIndex(parentRowItem) + 1;
                    lastRow = firstRow + rowItems.length - 1;
                    constraints = this.constraintsCache.getOverRangeBoundaries(firstRow, lastRow);
                    if (constraints && constraints.length > 0)
                    {
                        items = items.concat(constraints);
                    }
                }
                catch(error:ItemPendingError)
                {
                }
            }
            return items;
        }

        private function createMask():DisplayObject
        {
            var tmpMask:FlexShape;
            var g:Graphics;
            tmpMask = new FlexShape();
            tmpMask.name = "mask";
            g = tmpMask.graphics;
            g.beginFill(0xFFFFFF);
            g.moveTo(0, 0);
            g.lineTo(0, 10);
            g.lineTo(10, 10);
            g.lineTo(10, 0);
            g.lineTo(0, 0);
            g.endFill();
            return tmpMask;
        }

		public function rowExpandCollapseHandler():void
        {
            if (this._constraintsCache)
            {
                this._constraintsCache.invalidate();
            }
            this.rowChangedHandler();
        }

		/**
		 * 行数据变化的回调 
		 * 
		 */		
		public function rowChangedHandler():void
        {
            var grid:GanttSheetGridBase;
            if (this._taskItemContainer)
            {
                this._taskItemContainer.rowChangedHandler();
            }
            if (this._constraintItemContainer)
            {
                this._constraintItemContainer.rowChangedHandler();
            }
            for each (grid in this.allGrids)
            {
                grid.rowControllerChangedInternal();
            }
            this._rowHeightChanged = true;
            invalidateProperties();
        }

		public function rowHeightChangedHandler():void
        {
            var grid:GanttSheetGridBase;
            this._rowHeightChanged = true;
            invalidateProperties();
            this.invalidateItemsSize();
            for each (grid in this.allGrids)
            {
                grid.rowControllerChangedInternal();
            }
        }

        public function getConstraintInfo(item:ConstraintItem):ConstraintInfo
        {
            if (!this._constraintItemContainer)
            {
                return null;
            }
            return this._constraintItemContainer.getConstraintInfo(item);
        }

		public function scrollVertically(delta:Number, unit:String, reset:Boolean=false):void
        {
            var actual:Number;
            if (reset)
            {
                this._verticalScrollRemainder = 0;
            }
            if (unit == "pixel")
            {
                actual = this.rowController.scroll(this._verticalScrollRemainder + delta, unit);
                this._verticalScrollRemainder = this._verticalScrollRemainder + delta - actual;
            }
            else
            {
                this.rowController.scroll(delta, unit);
            }
        }

        private function configureInitialVisibleTimeRange():void
        {
            var margin:Number;
            var start:Number;
            var end:Number;
            var taskRange:Object;
            var now:Number;
            var initialHideNonworkingTimes:Boolean;
            margin = 10;
            now = 0;
            
            if (this._explicitVisibleTimeRangeStart && this._explicitVisibleTimeRangeEnd)
            {
                start = this._explicitVisibleTimeRangeStart;
                end = this._explicitVisibleTimeRangeEnd;
            }
            else
            {
                if (!isNaN(this._explicitZoomFactor) && this._explicitVisibleTimeRangeStart)
                {
                    start = this._explicitVisibleTimeRangeStart;
                    end = start + (width * this._explicitZoomFactor);
                }
                else if (!isNaN(this._explicitZoomFactor) && this._explicitVisibleTimeRangeEnd)
				{
					end = this._explicitVisibleTimeRangeEnd;
					start = end - (width * this._explicitZoomFactor);
				}
				else if (!isNaN(this._explicitZoomFactor))
				{
					taskRange = this.getTaskTimeRange();
					if (taskRange)
					{
						start = taskRange.start - (20 * this._explicitZoomFactor);
						end = start + ((width - 20) * this._explicitZoomFactor);
					}
					else
					{
						start = now - ((width / 5) * this._explicitZoomFactor);
						end = now + (((width * 4) / 5) * this._explicitZoomFactor);
					}
				}
				else if (this._explicitVisibleTimeRangeStart)
				{
					start = this._explicitVisibleTimeRangeStart;
					taskRange = this.getTaskTimeRange();
					if (taskRange && taskRange.end > start)
					{
						end = taskRange.end;
					}
					else
					{
						end = this.timeComputer.addUnits(start, TimeUnit.MINUTE, 5);
					}
				}
				else if (this._explicitVisibleTimeRangeEnd)
				{
					end = this._explicitVisibleTimeRangeEnd;
					taskRange = this.getTaskTimeRange();
					if (taskRange && taskRange.start < end)
					{
						start = taskRange.start;
					}
					else
					{
						start = this.timeComputer.addUnits(end, TimeUnit.MINUTE, -5);
					}
				}
				else
				{
					taskRange = this.getTaskTimeRange();
					if (taskRange)
					{
						start = taskRange.start;
						end = taskRange.end;
						margin = 20;
					}
					else
					{
						now = this.timeComputer.floor(0, TimeUnit.MINUTE, 1);
						start = this.timeComputer.addUnits(now, TimeUnit.MINUTE, 0);
						end = this.timeComputer.addUnits(now, TimeUnit.HOUR, 1);
					}
				}
            }
            this.timeController.configure(start, end, this.timeRectangle.width, margin);
        }
    }
}