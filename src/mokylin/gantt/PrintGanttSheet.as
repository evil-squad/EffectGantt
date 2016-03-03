package mokylin.gantt
{
    
    import mx.core.ScrollPolicy;
    import mx.events.PropertyChangeEvent;
    
    import __AS3__.vec.Vector;
    
    import mokylin.SelectionMode;

    [Exclude(name="allowMultipleSelection", kind="property")]
    [Exclude(name="dataTipField", kind="property")]
    [Exclude(name="dataTipFunction", kind="property")]
    [Exclude(name="editingTipFunction", kind="property")]
    [Exclude(name="moveEnabled", kind="property")]
    [Exclude(name="moveEnabledFunction", kind="property")]
    [Exclude(name="reassignEnabled", kind="property")]
    [Exclude(name="reassignEnabledFunction", kind="property")]
    [Exclude(name="resizeEnabled", kind="property")]
    [Exclude(name="resizeEnabledFunction", kind="property")]
    [Exclude(name="selectable", kind="property")]
    [Exclude(name="showDataTips", kind="property")]
    [Exclude(name="snappingTimePrecision", kind="property")]
    [Exclude(name="selectedItem", kind="property")]
    [Exclude(name="selectedItems", kind="property")]
    [Exclude(name="zoomFactor", kind="property")]
    [Exclude(name="visibleTimeRangeStart", kind="property")]
    [Exclude(name="visibleTimeRangeEnd", kind="property")]
    [Exclude(name="animationDuration", kind="style")]
    [Exclude(name="easingFunction", kind="style")]
    [Exclude(name="useRollOver", kind="style")]
    [Exclude(name="change", kind="event")]
    [Exclude(name="itemClick", kind="event")]
    [Exclude(name="itemDoubleClick", kind="event")]
    [Exclude(name="itemEditBegin", kind="event")]
    [Exclude(name="itemEditEnd", kind="event")]
    [Exclude(name="itemEditMove", kind="event")]
    [Exclude(name="itemEditReassign", kind="event")]
    [Exclude(name="itemEditResize", kind="event")]
    [Exclude(name="itemRollOut", kind="event")]
    [Exclude(name="itemRollOver", kind="event")]
    [Exclude(name="visibleTimeRangeChange", kind="event")]
    public class PrintGanttSheet extends GanttSheet 
    {

        private var _printing:Boolean;
        private var _explicitPrintTimeRangeStart:Number;
        private var _explicitPrintTimeRangeEnd:Number;

        public function PrintGanttSheet()
        {
            moveEnabled = false;
            reassignEnabled = false;
            resizeEnabled = false;
            selectionMode = SelectionMode.NONE;
            showDataTips = false;
            horizontalScrollPolicy = ScrollPolicy.OFF;
            verticalScrollPolicy = ScrollPolicy.OFF;
        }

		public function initializeFrom(value:GanttSheet):void
        {
            this._printing = false;
            /*calendar.firstDayOfWeek = value.calendar.firstDayOfWeek;
            calendar.minimalDaysInFirstWeek = value.calendar.minimalDaysInFirstWeek;*/
            constraintItemRenderer = value.constraintItemRenderer;
            taskItemRenderer = value.taskItemRenderer;
            itemStyleNameFunction = value.itemStyleNameFunction;
            minVisibleTime = value.minVisibleTime;
            maxVisibleTime = value.maxVisibleTime;
            minZoomFactor = value.minZoomFactor;
            maxZoomFactor = value.maxZoomFactor;
            visibleTimeRangeStart = value.visibleTimeRangeStart;
            visibleTimeRangeEnd = value.visibleTimeRangeEnd;
            showTimeGrid = value.showTimeGrid;
            showWorkingTimesGrid = value.showWorkingTimesGrid;
            showBackgroundGrid = value.showBackgroundGrid;
            /*workCalendar = value.workCalendar;
            hideNonworkingTimes = value.hideNonworkingTimes;*/
            setStyle("alternatingItemColors", value.getStyle("alternatingItemColors"));
            this.cloneGrids(value);
            invalidateSize();
            invalidateProperties();
            invalidateDisplayList();
        }

        [Bindable(event="propertyChange")]
        public function get printTimeRangeStart():Number
        {
            return this._explicitPrintTimeRangeStart;
        }

        private function set _1017214943printTimeRangeStart(value:Number):void
        {
            this._explicitPrintTimeRangeStart = value;
        }

        [Bindable(event="propertyChange")]
        public function get printTimeRangeEnd():Number
        {
            return this._explicitPrintTimeRangeEnd;
        }

        private function set _432474216printTimeRangeEnd(value:Number):void
        {
            this._explicitPrintTimeRangeEnd = value;
        }

        public function get printedTimeRangeStart():Number
        {
            var taskRange:Object;
            var date:Number = this._explicitPrintTimeRangeStart;
            /*if (date == null)
            {*/
                taskRange = getTaskTimeRange();
                if (taskRange != null)
                {
                    date = taskRange.start;
                }
            /*}
            if (date == null)
            {*/
                if (timeController != null && timeController.configured)
                {
                    date = timeController.startTime;
                }
            /*}*/
            return date;
        }

        public function get printedTimeRangeEnd():Number
        {
            var taskRange:Object;
            var date:Number = this._explicitPrintTimeRangeEnd;
            /*if (date == null)
            {*/
                taskRange = getTaskTimeRange();
                if (taskRange != null)
                {
                    date = taskRange.end;
                }
            /*}
            if (date == null)
            {*/
                if (timeController != null && timeController.configured)
                {
                    date = timeController.endTime;
                }
            /*}*/
            return date;
        }

        private function cloneGrids(value:GanttSheet):void
        {
            var backGrid:GanttSheetGridBase;
            var fGrids:Vector.<GanttSheetGridBase>;
            var frontGrid:GanttSheetGridBase;
            backgroundGrid = (value.backgroundGrid.clone() as BackgroundGrid);
//            workingTimesGrid = (value.workingTimesGrid.clone() as WorkingTimesGrid);
            timeGrid = (value.timeGrid.clone() as TimeGrid);
            var bGrids:Vector.<GanttSheetGridBase> = new Vector.<GanttSheetGridBase>();
            for each (backGrid in value.backGrids)
            {
                bGrids.push(backGrid.clone());
            }
            backGrids = bGrids;
            fGrids = new Vector.<GanttSheetGridBase>();
            for each (frontGrid in value.frontGrids)
            {
                fGrids.push(frontGrid.clone());
            }
            frontGrids = fGrids;
        }

        public function get validNextPage():Boolean
        {
            this.startPrinting();
            return visibleTimeRangeEnd < this.printedTimeRangeEnd;
        }

		public function nextPage():void
        {
            this.startPrinting();
            moveTo(visibleTimeRangeEnd);
        }

		public function carriageReturn():void
        {
            this.startPrinting();
            moveTo(this.printedTimeRangeStart);
        }

        private function startPrinting():void
        {
            if (this._printing)
            {
                return;
            }
            this._printing = true;
            moveTo(this.printedTimeRangeStart);
        }

        public function set printTimeRangeEnd(value:Number):void
        {
            var _local2:Object = this.printTimeRangeEnd;
            if (_local2 !== value)
            {
                this._432474216printTimeRangeEnd = value;
                if (this.hasEventListener("propertyChange"))
                {
                    this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "printTimeRangeEnd", _local2, value));
                }
            }
        }

        public function set printTimeRangeStart(value:Number):void
        {
            var _local2:Object = this.printTimeRangeStart;
            if (_local2 !== value)
            {
                this._1017214943printTimeRangeStart = value;
                if (this.hasEventListener("propertyChange"))
                {
                    this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "printTimeRangeStart", _local2, value));
                }
            }
        }
    }
}
