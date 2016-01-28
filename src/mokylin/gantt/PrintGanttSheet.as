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
        private var _explicitPrintTimeRangeStart:Date;
        private var _explicitPrintTimeRangeEnd:Date;

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
            calendar.firstDayOfWeek = value.calendar.firstDayOfWeek;
            calendar.minimalDaysInFirstWeek = value.calendar.minimalDaysInFirstWeek;
            constraintItemRenderer = value.constraintItemRenderer;
            taskItemRenderer = value.taskItemRenderer;
            itemStyleNameFunction = value.itemStyleNameFunction;
            minVisibleTime = new Date(value.minVisibleTime.time);
            maxVisibleTime = new Date(value.maxVisibleTime.time);
            minZoomFactor = value.minZoomFactor;
            maxZoomFactor = value.maxZoomFactor;
            visibleTimeRangeStart = value.visibleTimeRangeStart;
            visibleTimeRangeEnd = value.visibleTimeRangeEnd;
            showTimeGrid = value.showTimeGrid;
            showWorkingTimesGrid = value.showWorkingTimesGrid;
            showBackgroundGrid = value.showBackgroundGrid;
            workCalendar = value.workCalendar;
            hideNonworkingTimes = value.hideNonworkingTimes;
            setStyle("alternatingItemColors", value.getStyle("alternatingItemColors"));
            this.cloneGrids(value);
            invalidateSize();
            invalidateProperties();
            invalidateDisplayList();
        }

        [Bindable(event="propertyChange")]
        public function get printTimeRangeStart():Date
        {
            return this._explicitPrintTimeRangeStart != null ? new Date(this._explicitPrintTimeRangeStart.time) : null;
        }

        private function set _1017214943printTimeRangeStart(value:Date):void
        {
            this._explicitPrintTimeRangeStart = value != null ? new Date(value.time) : null;
        }

        [Bindable(event="propertyChange")]
        public function get printTimeRangeEnd():Date
        {
            return this._explicitPrintTimeRangeEnd != null ? new Date(this._explicitPrintTimeRangeEnd.time) : null;
        }

        private function set _432474216printTimeRangeEnd(value:Date):void
        {
            this._explicitPrintTimeRangeEnd = value != null ? new Date(value.time) : null;
        }

        public function get printedTimeRangeStart():Date
        {
            var taskRange:Object;
            var date:Date = this._explicitPrintTimeRangeStart;
            if (date == null)
            {
                taskRange = getTaskTimeRange();
                if (taskRange != null)
                {
                    date = taskRange.start as Date;
                }
            }
            if (date == null)
            {
                if (timeController != null && timeController.configured)
                {
                    date = timeController.startTime;
                }
            }
            return date != null ? new Date(date.time) : null;
        }

        public function get printedTimeRangeEnd():Date
        {
            var taskRange:Object;
            var date:Date = this._explicitPrintTimeRangeEnd;
            if (date == null)
            {
                taskRange = getTaskTimeRange();
                if (taskRange != null)
                {
                    date = taskRange.end as Date;
                }
            }
            if (date == null)
            {
                if (timeController != null && timeController.configured)
                {
                    date = timeController.endTime;
                }
            }
            return date != null ? new Date(date.time) : null;
        }

        private function cloneGrids(value:GanttSheet):void
        {
            var backGrid:GanttSheetGridBase;
            var fGrids:Vector.<GanttSheetGridBase>;
            var frontGrid:GanttSheetGridBase;
            backgroundGrid = (value.backgroundGrid.clone() as BackgroundGrid);
            workingTimesGrid = (value.workingTimesGrid.clone() as WorkingTimesGrid);
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
            return visibleTimeRangeEnd.time < this.printedTimeRangeEnd.time;
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

        public function set printTimeRangeEnd(value:Date):void
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

        public function set printTimeRangeStart(value:Date):void
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
