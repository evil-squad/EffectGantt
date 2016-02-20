package mokylin.gantt
{
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    import mx.collections.ICollectionView;
    import mx.containers.HDividedBox;
    import mx.core.EdgeMetrics;
    import mx.core.IBorder;
    import mx.core.IFlexDisplayObject;
    import mx.core.IFlexModuleFactory;
    import mx.core.IInvalidating;
    import mx.core.IUIComponent;
    import mx.core.UIComponent;
    import mx.events.AdvancedDataGridEvent;
    import mx.events.DividerEvent;
    import mx.events.FlexEvent;
    import mx.logging.LogEventLevel;
    import mx.skins.halo.HaloBorder;
    import mx.styles.CSSStyleDeclaration;
    import mx.styles.ISimpleStyleClient;
    
    import mokylin.gantt.supportClasses.GanttProperties;
    import mokylin.gantt.supportClasses.MessageUtil;
    import mokylin.utils.CSSUtil;
    import mokylin.utils.DataUtil;
    import mokylin.utils.GregorianCalendar;
    import mokylin.utils.TimeUtil;

    [Style(name="borderColor", type="uint", format="Color", inherit="no")]
    [Style(name="borderSides", type="String", inherit="no")]
    [Style(name="borderSkin", type="Class", inherit="no")]
    [Style(name="borderStyle", type="String", enumeration="inset,outset,solid,none", inherit="no")]
    [Style(name="borderThickness", type="Number", format="Length", inherit="no")]
    [Style(name="dataGridStyleName", type="String", inherit="no")]
    [Style(name="dropShadowColor", type="uint", format="Color", inherit="yes")]
    [Style(name="dropShadowEnabled", type="Boolean", inherit="no")]
    [Style(name="ganttSheetStyleName", type="String", inherit="no")]
    [Style(name="milestoneItemStyleName", type="String", inherit="no")]
    [Style(name="paddingBottom", type="Number", format="Length", inherit="no")]
    [Style(name="paddingLeft", type="Number", format="Length", inherit="no")]
    [Style(name="paddingRight", type="Number", format="Length", inherit="no")]
    [Style(name="paddingTop", type="Number", format="Length", inherit="no")]
    [Style(name="shadowDirection", type="String", enumeration="left,center,right", inherit="no")]
    [Style(name="shadowDistance", type="Number", format="Length", inherit="no")]
    [Style(name="taskItemStyleName", type="String", inherit="no")]
    [Style(name="timeScaleStyleName", type="String", inherit="no")]
	/**
	 * gantt图的基类，创建基本组成组件 
	 */	
    public class GanttChartBase extends UIComponent 
    {
		/**
		 * 组件的水平分隔box（左右）左边是datagrid数据，右边是图形 
		 */
        protected var _dividedBox:HDividedBox;
		/**
		 * 右边专门装载数据图形的顶级父容器 
		 */		
        protected var _ganttArea:GanttArea;
		/**
		 * 边框类 
		 */		
        private var _border:IFlexDisplayObject;
        protected var _taskFieldChanged:Boolean;
        private var _dividerHasMoved:Boolean = false;
		/**
		 * 是否初始化样式的标识 
		 */		
        private var _styleInitialized:Boolean = false;
        private var _calendar:GregorianCalendar;
        protected var _dataGrid:GanttDataGrid;
        protected var _ganttSheet:GanttSheet;
        private var _minimalDaysInFirstWeek:Object;
        private var minimalDaysInFirstWeekChanged:Boolean;
        private var minimalDaysInFirstWeekOverride:Object;
		/**
		 *  每一行数据的控制类
		 */		
        protected var _rowController:RowController;
        protected var _taskDataProvider:Object;
        protected var _taskCollection:ICollectionView;
		
        private var _taskEndTimeField:String = "endTime";
        private var _taskEndTimeFunction:Function = null;
        private var _taskIsMilestoneField:String = "milestone";
        private var _taskIsMilestoneFunction:Function = null;
        private var _taskLabelField:String = "name";
        private var _taskLabelFunction:Function = null;
        private var _taskStartTimeField:String = "startTime";
        private var _taskStartTimeFunction:Function = null;
		/**
		 * 管理右边图形怎么渲染的控制类
		 */		
        private var _timeController:TimeController;
		/**
		 * 右边图形的时间头组件 
		 */		
        private var _timeScale:TimeScale;

        public function GanttChartBase()
        {
//            var licenseHandlerClass:Class;
            super();
/*            try
            {
                licenseHandlerClass = Class(getDefinitionByName("mokylin.utils.LicenseHandler"));
                if (licenseHandlerClass != null)
                {
                    var _local2:Class = licenseHandlerClass;
                    _local2["displayWatermark"](this);
                }
            }
            catch(e:Error)
            {
            }
            LicenseHandler.addElixirEnterpriseToMenu();*/
            this._timeController = new TimeController();
            this._timeController.calendar = this.calendar;
            this._rowController = new RowController();
            addEventListener(MouseEvent.MOUSE_WHEEL, this.mouseWheelHandler, true);
            hasFocusableChildren = true;
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
            var styleDeclaration:CSSStyleDeclaration = CSSUtil.createSelector("GanttChartBase", "mokylin.gantt", styleManager);
            styleDeclaration.defaultFactory = function ():void
            {
                this.borderColor = 0xFF0000;
                this.borderSides = "left top right bottom";
                this.borderSkin = HaloBorder;
                this.borderStyle = "none";
                this.borderThickness = 0;
                this.dataGridStyleName = undefined;
                this.dropShadowColor = 0;
                this.dropShadowEnabled = true;
                this.ganttSheetStyleName = undefined;
                this.milestoneItemStyleName = "milestoneTask";
                this.paddingBottom = 0;
                this.paddingLeft = 0;
                this.paddingRight = 0;
                this.paddingTop = 0;
                this.taskItemStyleName = undefined;
                this.timeScaleStyleName = undefined;
                this.shadowDirection = "center";
                this.shadowDistance = 2;
            }
        }

        public function get borderMetrics():EdgeMetrics
        {
            return this._border && (this._border is IBorder) ? IBorder(this._border).borderMetrics : EdgeMetrics.EMPTY;
        }

        public function get calendar():GregorianCalendar
        {
            if (this._calendar == null)
            {
                this._calendar = new GregorianCalendar();
            }
            return this._calendar;
        }

        [Inspectable(category="General")]
        public function get dataGrid():GanttDataGrid
        {
            return this._dataGrid;
        }

        public function set dataGrid(value:GanttDataGrid):void
        {
            if (value && this._dataGrid != value)
            {
                this._dataGrid = value;
                this.integrateDataGrid();
                invalidateDisplayList();
            }
        }

        [Inspectable(category="General", defaultValue="true")]
        override public function set enabled(value:Boolean):void
        {
            var ui:IFlexDisplayObject;
            if (enabled != value)
            {
                super.enabled = value;
                ui = (this._border as IFlexDisplayObject);
                if (ui)
                {
                    if (ui is IUIComponent)
                    {
                        IUIComponent(ui).enabled = value;
                    }
                    if (ui is IInvalidating)
                    {
                        IInvalidating(ui).invalidateDisplayList();
                    }
                }
                if (this.dataGrid)
                {
                    this.dataGrid.enabled = value;
                }
                if (this._ganttArea)
                {
                    this._ganttArea.enabled = value;
                }
                if (this.ganttSheet)
                {
                    this.ganttSheet.enabled = value;
                }
                if (this.timeScale)
                {
                    this.timeScale.enabled = value;
                }
                if (this._dividedBox)
                {
                    this._dividedBox.enabled = value;
                }
            }
        }

        [Inspectable(category="General", type="Number", enumeration="0,1,2,3,4,5,6")]
        public function get firstDayOfWeek():Object
        {
            return this.calendar.firstDayOfWeek;
        }

        public function set firstDayOfWeek(value:Object):void
        {
            this.calendar.firstDayOfWeek = value;
        }

        [Inspectable(category="General")]
        public function get ganttSheet():GanttSheet
        {
            return this._ganttSheet;
        }

        public function set ganttSheet(value:GanttSheet):void
        {
            if (value && this._ganttSheet != value)
            {
                this._ganttSheet = value;
                this.integrateGanttSheet();
                if (this._ganttArea)
                {
                    this._ganttArea.invalidateSize();
                    this._ganttArea.invalidateDisplayList();
                }
            }
        }

        [Inspectable(category="General", type="Number", enumeration="1,2,3,4,5,6,7", defaultValue="1")]
        public function get minimalDaysInFirstWeek():Object
        {
            return this.calendar.minimalDaysInFirstWeek;
        }

        public function set minimalDaysInFirstWeek(value:Object):void
        {
            this.calendar.minimalDaysInFirstWeek = value;
        }

		public function get rowController():IRowController
        {
            return this._rowController;
        }

        [Bindable("collectionChange")]
        [Inspectable(category="Data")]
        public function get taskDataProvider():Object
        {
            return this._taskCollection;
        }

        public function set taskDataProvider(value:Object):void
        {
        }

        [Inspectable(category="Data", defaultValue="endTime")]
        public function get taskEndTimeField():String
        {
            return this._taskEndTimeField;
        }

        public function set taskEndTimeField(value:String):void
        {
            if (this._taskEndTimeField != value)
            {
                this._taskEndTimeField = value;
                this._taskFieldChanged = true;
                invalidateProperties();
            }
        }

        [Inspectable(category="Data")]
        public function get taskEndTimeFunction():Function
        {
            return this._taskEndTimeFunction;
        }

        public function set taskEndTimeFunction(value:Function):void
        {
            if (this._taskEndTimeFunction != value)
            {
                this._taskEndTimeFunction = value;
                this._taskFieldChanged = true;
                invalidateProperties();
            }
        }

        [Inspectable(category="Data", defaultValue="milestone")]
        public function get taskIsMilestoneField():String
        {
            return this._taskIsMilestoneField;
        }

        public function set taskIsMilestoneField(value:String):void
        {
            if (this._taskIsMilestoneField != value)
            {
                this._taskIsMilestoneField = value;
                this._taskFieldChanged = true;
                invalidateProperties();
            }
        }

        [Inspectable(category="Data")]
        public function get taskIsMilestoneFunction():Function
        {
            return this._taskIsMilestoneFunction;
        }

        public function set taskIsMilestoneFunction(value:Function):void
        {
            if (this._taskIsMilestoneFunction != value)
            {
                this._taskIsMilestoneFunction = value;
                this._taskFieldChanged = true;
                invalidateProperties();
            }
        }

        [Inspectable(category="Data", defaultValue="name")]
        public function get taskLabelField():String
        {
            return this._taskLabelField;
        }

        public function set taskLabelField(value:String):void
        {
            if (this._taskLabelField != value)
            {
                this._taskLabelField = value;
                this._taskFieldChanged = true;
                invalidateProperties();
            }
        }

        [Inspectable(category="Data")]
        public function get taskLabelFunction():Function
        {
            return this._taskLabelFunction;
        }

        public function set taskLabelFunction(value:Function):void
        {
            if (this._taskLabelFunction != value)
            {
                this._taskLabelFunction = value;
                this._taskFieldChanged = true;
                invalidateProperties();
            }
        }

        [Inspectable(category="Data", defaultValue="startTime")]
        public function get taskStartTimeField():String
        {
            return this._taskStartTimeField;
        }

        public function set taskStartTimeField(value:String):void
        {
            if (this._taskStartTimeField != value)
            {
                this._taskStartTimeField = value;
                this._taskFieldChanged = true;
                invalidateProperties();
            }
        }

        [Inspectable(category="Data")]
        public function get taskStartTimeFunction():Function
        {
            return this._taskStartTimeFunction;
        }

        public function set taskStartTimeFunction(value:Function):void
        {
            if (this._taskStartTimeFunction != value)
            {
                this._taskStartTimeFunction = value;
                this._taskFieldChanged = true;
                invalidateProperties();
            }
        }

		public function get timeController():TimeController
        {
            return this._timeController;
        }

        [Inspectable(category="General")]
        public function get timeScale():TimeScale
        {
            return this._timeScale;
        }

        public function set timeScale(value:TimeScale):void
        {
            if (value && this._timeScale != value)
            {
                this._timeScale = value;
                this.integrateTimeScale();
                if (this._ganttArea)
                {
                    this._ganttArea.invalidateSize();
                    this._ganttArea.invalidateDisplayList();
                }
            }
        }

        private function mouseWheelHandler(event:MouseEvent):void
        {
            if (this.ganttSheet != null && this.ganttSheet.processMouseWheelEvent(event))
            {
                event.stopImmediatePropagation();
            }
        }

        override protected function createChildren():void
        {
            super.createChildren();
            this.createBorder();
            this.createInternalContainers();
            if (this._dataGrid == null)
            {
                this._dataGrid = new GanttDataGrid();
                this.integrateDataGrid();
            }
            if (this._timeScale == null)
            {
                this._timeScale = new TimeScale();
                this.integrateTimeScale();
            }
            if (this._ganttSheet == null)
            {
                this._ganttSheet = new GanttSheet();
                this.integrateGanttSheet();
            }
        }

        override protected function commitProperties():void
        {
            super.commitProperties();
            if (this._taskFieldChanged)
            {
                this._taskFieldChanged = false;
                if (this._taskCollection)
                {
                    this._taskCollection.refresh();
                }
            }
        }

        override protected function measure():void
        {
            super.measure();
            var borderMetrics:EdgeMetrics = this.borderMetrics;
            var borderTotalHeight:int = borderMetrics.top + borderMetrics.bottom;
            var borderTotalWidth:int = borderMetrics.left + borderMetrics.right;
            measuredHeight = (this._dividedBox.measuredHeight + borderTotalHeight);
            measuredWidth = (this._dividedBox.measuredWidth + borderTotalWidth);
            if (this._ganttArea != null && this._dataGrid != null)
            {
                measuredMinHeight = Math.max(this._dataGrid.measuredMinHeight, this._ganttArea.measuredMinHeight) + borderTotalHeight;
            }
            measuredMinWidth = this._dividedBox.measuredMinWidth + borderTotalWidth;
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            this.layoutChrome(unscaledWidth, unscaledHeight);
			
            var paddingLeft:Number = getStyle("paddingLeft");
            var paddingRight:Number = getStyle("paddingRight");
            var paddingTop:Number = getStyle("paddingTop");
            var paddingBottom:Number = getStyle("paddingBottom");
			
            var borderMetrics:EdgeMetrics = this.borderMetrics;
            var contentWidth:Number = unscaledWidth - paddingLeft + paddingRight + borderMetrics.left + borderMetrics.right;
            if (contentWidth < 0)
            {
                contentWidth = 0;
            }
            var contentHeight:Number = unscaledHeight - paddingTop + paddingBottom + borderMetrics.top + borderMetrics.bottom;
            if (contentHeight < 0)
            {
                contentHeight = 0;
            }
            if (this._dividedBox != null)
            {
                this._dividedBox.move((paddingLeft + borderMetrics.left), (paddingTop + borderMetrics.top));
                this._dividedBox.setActualSize(contentWidth, contentHeight);
            }
            if (this._dataGrid != null)
            {
                this._dataGrid.height = contentHeight;//左边内容
            }
            if (this._ganttArea != null)
            {
                this._ganttArea.height = contentHeight;//右边内容
            }
        }

        override public function styleChanged(styleProp:String):void
        {
            super.styleChanged(styleProp);
            if (!styleProp || styleProp == "borderSkin")
            {
                if (this._border)
                {
                    removeChild(DisplayObject(this._border));
                    this._border = null;
                }
                this.createBorder();
            }
            if (!styleProp || styleProp == "taskItemStyleName")
            {
                if (this._ganttSheet)
                {
                    this._ganttSheet.invalidateItemsSize();
                }
            }
            if (!styleProp || styleProp == "milestoneItemStyleName")
            {
                if (this._ganttSheet)
                {
                    this._ganttSheet.invalidateItemsSize();
                }
            }
            if (!styleProp || styleProp == "timeScaleStyleName")
            {
                if (this._timeScale)
                {
                    this._timeScale.styleName = getStyle("timeScaleStyleName");
                }
            }
            if (!styleProp || styleProp == "dataGridStyleName")
            {
                if (this._dataGrid)
                {
                    this._dataGrid.styleName = getStyle("dataGridStyleName");
                }
            }
            if (!styleProp || styleProp == "ganttSheetStyleName")
            {
                if (this._ganttSheet)
                {
                    this._ganttSheet.styleName = getStyle("ganttSheetStyleName");
                }
            }
        }

        public function isTask(item:Object):Boolean
        {
            return false;
        }

        public function scrollToItem(item:Object, margin:Number=10):void
        {
        }

		/**
		 * 供键盘方向键来用的，选中操作 
		 * @param previousItem
		 * @param direction
		 * @return 
		 * 
		 */		
        public function nextItem(previousItem:Object, direction:uint):Object
        {
            return null;
        }

		public function rowSortFunction(item1:Object, item2:Object):Number
        {
            return this.dataGrid.itemRendererToIndex(this.dataGrid.itemToItemRenderer(item1)) - this.dataGrid.itemRendererToIndex(this.dataGrid.itemToItemRenderer(item2));
        }

		public function getVisibleTaskItems(rowItem:Object, start:Date, end:Date):Array
        {
            var item:Object;
            var taskItem:TaskItem;
            var taskItems:Array = [];
            var tasks:Array = this.rowItemToTasks(rowItem);
            for each (item in tasks)
            {
                taskItem = this._ganttSheet.itemToTaskItem(item);
                if (taskItem.startTime < end && taskItem.endTime > start)
                {
                    taskItems.push(taskItem);
                }
            }
            return taskItems;
        }

		public function rowItemToTasks(rowItem:Object):Array
        {
            return null;
        }

		public function taskItemToRowItem(taskItem:TaskItem):Object
        {
            return null;
        }

		public function updateTaskItem(item:TaskItem, property:Object):void
        {
            var value:Object;
            var date:Date;
            if (!property || property == this.taskLabelField || this.taskLabelFunction != null)
            {
                value = DataUtil.getFieldValue(item.data, this.taskLabelField, null, this.taskLabelFunction);
                item.label = value!=null ? String(value) : null;
            }
            if (!property || property == this.taskStartTimeField || this.taskStartTimeFunction != null)
            {
                value = DataUtil.getFieldValue(item.data, this.taskStartTimeField, null, this.taskStartTimeFunction);
                date = TimeUtil.getDate(value);
                item.startTime = date!=null ? new Date(date) : new Date();
            }
            if (!property || property == this.taskEndTimeField || this.taskEndTimeFunction != null)
            {
                value = DataUtil.getFieldValue(item.data, this.taskEndTimeField, null, this.taskEndTimeFunction);
                date = TimeUtil.getDate(value);
                item.endTime = date!=null ? new Date(date) : new Date();
            }
            if (!property || property == this.taskIsMilestoneField || this.taskIsMilestoneFunction != null)
            {
                value = DataUtil.getFieldValue(item.data, this.taskIsMilestoneField, null, this.taskIsMilestoneFunction);
                item.isMilestone = value!=null ? Boolean(value) : false;
            }
        }

		public function commitTaskItem(item:TaskItem):void
        {
            if (this.taskStartTimeField)
            {
                this.setItemField(item.data, this.taskStartTimeField, new Date(item.startTime));
            }
            else
            {
                MessageUtil.log(GanttChartBase, LogEventLevel.WARN, GanttProperties.ELIXIR_GANTT_BUNDLE, GanttProperties.DONT_KNOW_HOW_TO_COMMIT_MESSAGE, ["TaskItem.startTime", "taskStartTimeField"], resourceManager);
            }
            if (this.taskEndTimeField)
            {
                this.setItemField(item.data, this.taskEndTimeField, new Date(item.endTime));
            }
            else
            {
                MessageUtil.log(GanttChartBase, LogEventLevel.WARN, GanttProperties.ELIXIR_GANTT_BUNDLE, GanttProperties.DONT_KNOW_HOW_TO_COMMIT_MESSAGE, ["TaskItem.endTime", "taskEndTimeField"], resourceManager);
            }
        }

        protected function setItemField(item:Object, field:String, value:Object):void
        {
            if (item is XML)
            {
                if (field.charAt(0) != "@")
                {
                    field = "@" + field;
                }
                item[field] = value.toString();
            }
            else
            {
                item[field] = value;
            }
        }

        private function getDataGrid():GanttDataGrid
        {
            return this._dividedBox ? this._dividedBox.getChildByName("dataGrid") as GanttDataGrid : null;
        }

        private function getGanttSheet():GanttSheet
        {
            return this._ganttArea ? this._ganttArea.getChildByName("ganttSheet") as GanttSheet : null;
        }

        private function getTimeScale():TimeScale
        {
            return this._ganttArea ? this._ganttArea.getChildByName("timeScale") as TimeScale : null;
        }

        protected function integrateDataGrid():void
        {
            var oldDataGrid:GanttDataGrid = this.getDataGrid();
            if (oldDataGrid)
            {
                this._dividedBox.removeChild(oldDataGrid);
                oldDataGrid.removeEventListener(AdvancedDataGridEvent.ITEM_OPEN, this.dataGridViewChangeHandler);
            }
            this._dataGrid.name = "dataGrid";
            this._dataGrid.rowController = this._rowController;
            this._dataGrid.enabled = enabled;
            if (!this._dataGrid.styleName)
            {
                this._dataGrid.styleName = getStyle("dataGridStyleName");
            }
            this._dataGrid.addEventListener(AdvancedDataGridEvent.ITEM_OPEN, this.dataGridViewChangeHandler);
            this.createInternalContainers();
            this._dividedBox.addChildAt(this._dataGrid, 0);
            if (this._rowController)
            {
                this._rowController.dataGrid = this._dataGrid;
            }
        }

        protected function dataGridViewChangeHandler(event:AdvancedDataGridEvent):void
        {
        }

        protected function integrateGanttSheet():void
        {
            var oldGanttSheet:GanttSheet = this.getGanttSheet();
            if (oldGanttSheet)
            {
                this._ganttArea.removeChild(oldGanttSheet);
            }
            this._ganttSheet.name = "ganttSheet";
            this._ganttSheet.setGanttChart(this);
            this._ganttSheet.setCalendar(this.calendar);
            this._ganttSheet.rowController = this._rowController;
            this._ganttSheet.timeController = this._timeController;
            this._ganttSheet.timeScale = this._timeScale;
            this._ganttSheet.enabled = enabled;
            if (!this._ganttSheet.styleName)
            {
                this._ganttSheet.styleName = getStyle("ganttSheetStyleName");
            }
            this.createInternalContainers();
            this._ganttArea.addChild(this._ganttSheet);
            if (this._rowController)
            {
                this._rowController.ganttSheet = this._ganttSheet;
            }
        }

        private function integrateTimeScale():void
        {
            var oldTimeScale:TimeScale = this.getTimeScale();
            if (oldTimeScale)
            {
                this._ganttArea.removeChild(oldTimeScale);
            }
            this._timeScale.name = "timeScale";
            this._timeScale.setCalendar(this.calendar);
            this._timeScale.timeController = this._timeController;
            this._timeScale.enabled = enabled;
            if (!this._timeScale.styleName)
            {
                this._timeScale.styleName = getStyle("timeScaleStyleName");
            }
            this.createInternalContainers();
            this._ganttArea.addChild(this._timeScale);
            if (this._rowController)
            {
                this._rowController.timeScale = this._timeScale;
            }
            if (this._ganttSheet)
            {
                this._ganttSheet.timeScale = this._timeScale;
            }
        }

        private function createBorder():void
        {
            var borderClass:Class;
            if (!this._border)
            {
                borderClass = getStyle("borderSkin");
                this._border = new borderClass();
                this._border.name = "border";
                if (this._border is IUIComponent)
                {
                    IUIComponent(this._border).enabled = enabled;
                }
                if (this._border is ISimpleStyleClient)
                {
                    ISimpleStyleClient(this._border).styleName = this;
                }
                addChildAt(DisplayObject(this._border), 0);
            }
        }

        private function layoutChrome(unscaledWidth:Number, unscaledHeight:Number):void
        {
            if (this._border)
            {
                this._border.move(0, 0);
                this._border.setActualSize(unscaledWidth, unscaledHeight);
            }
        }

		/**
		 * 创建左右2个可视化组件容器 
		 * 
		 */		
        private function createInternalContainers():void
        {
            this.createDividedBox();
            this.createGanttArea();
        }

        private function createDividedBox():void
        {
            if (!this._dividedBox)
            {
                this._dividedBox = new HDividedBox();
                this._dividedBox.name = "dividedBox";
                this._dividedBox.setStyle("horizontalGap", 2);
                this._dividedBox.minHeight = 0;
                this._dividedBox.minWidth = 0;
                this._dividedBox.enabled = enabled;
                this._dividedBox.addEventListener(DividerEvent.DIVIDER_RELEASE, this._dividedBox_dividerReleaseHandler);
                this._dividedBox.addEventListener(FlexEvent.UPDATE_COMPLETE, this._dividedBox_updateCompleteHandler);
                addChild(this._dividedBox);
            }
        }

        private function _dividedBox_dividerReleaseHandler(event:Event):void
        {
            this._dividerHasMoved = true;
        }

        private function _dividedBox_updateCompleteHandler(event:Event):void
        {
            if (this._dividerHasMoved)
            {
                this._dividerHasMoved = false;
                this._dataGrid.width = this._dataGrid.width;
            }
        }

		/**
		 * 创建ganttArea 
		 * 
		 */		
        private function createGanttArea():void
        {
            if (!this._ganttArea)
            {
                this._ganttArea = new GanttArea();
                this._ganttArea.name = "ganttArea";
                this._ganttArea.percentWidth = 100;//100%
                this._rowController.ganttArea = this._ganttArea;
                this._dividedBox.addChild(this._ganttArea);
            }
        }
    }
}