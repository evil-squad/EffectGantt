package mokylin.gantt
{
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.events.Event;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    
    import mx.core.IFactory;
    import mx.graphics.IFill;
    import mx.graphics.SolidColor;
    
    import mokylin.utils.DataUtil;
    import mokylin.utils.TimeUnit;
    import mokylin.utils.WorkCalendar;

    public class WorkingTimesGrid extends GanttSheetGridBase 
    {

        private var _wortingTimesRendererContainer:GanttSheetGridRendererContainer;
        private var _nonworkingTimesRendererContainer:GanttSheetGridRendererContainer;
        private var _clip:Rectangle;
        private var _currentWorkingTimesFill:IFill;
        private var _currentNonworkingTimesFill:IFill;
        private var _registeredWorkCalendars:Dictionary;
        private var _workingTimesSkin:IFactory;
        private var _workingTimesSkinChanged:Boolean;
        private var _nonWorkingTimesSkin:IFactory;
        private var _nonWorkingTimesSkinChanged:Boolean;
        private var _minNonWorkingTimesSize:Number = 20;
        private var _minNonWorkingTimesSizeChanged:Boolean;
        private var _workingTimesFill:IFill;
        private var _workingTimesFillChanged:Boolean;
        private var _nonWorkingTimesFill:IFill;
        private var _nonWorkingTimesFillChanged:Boolean;
        private var _workCalendarField:String;
        private var _workCalendarFieldChanged:Boolean;
        private var _workCalendarFunction:Function;
        private var _workCalendarFunctionChanged:Boolean;
        private var _explicitWorkCalendar:WorkCalendar;
        private var _workCalendarChanged:Boolean;

        public function WorkingTimesGrid()
        {
            this._registeredWorkCalendars = new Dictionary();
            super();
        }

        public function get workingTimesSkin():IFactory
        {
            return this._workingTimesSkin;
        }

        public function set workingTimesSkin(value:IFactory):void
        {
            if (this._workingTimesSkin == value)
            {
                return;
            }
            this._workingTimesSkin = value;
            this._workingTimesSkinChanged = true;
            invalidateProperties();
        }

        public function get nonWorkingTimesSkin():IFactory
        {
            return this._nonWorkingTimesSkin;
        }

        public function set nonWorkingTimesSkin(value:IFactory):void
        {
            if (this._nonWorkingTimesSkin == value)
            {
                return;
            }
            this._nonWorkingTimesSkin = value;
            this._nonWorkingTimesSkinChanged = true;
            invalidateProperties();
        }

        public function get minNonWorkingTimesSize():Number
        {
            return this._minNonWorkingTimesSize;
        }

        public function set minNonWorkingTimesSize(value:Number):void
        {
            if (this._minNonWorkingTimesSize == value)
            {
                return;
            }
            this._minNonWorkingTimesSize = value;
            this._minNonWorkingTimesSizeChanged = true;
            invalidateProperties();
        }

        public function get workingTimesFill():IFill
        {
            return this._workingTimesFill;
        }

        public function set workingTimesFill(value:IFill):void
        {
            if (this._workingTimesFill == value)
            {
                return;
            }
            this._workingTimesFill = value;
            this._workingTimesFillChanged = true;
            invalidateProperties();
        }

        public function get nonWorkingTimesFill():IFill
        {
            return this._nonWorkingTimesFill;
        }

        public function set nonWorkingTimesFill(value:IFill):void
        {
            if (this._nonWorkingTimesFill == value)
            {
                return;
            }
            this._nonWorkingTimesFill = value;
            this._nonWorkingTimesFillChanged = true;
            invalidateProperties();
        }

        public function get workCalendarField():String
        {
            return this._workCalendarField;
        }

        public function set workCalendarField(value:String):void
        {
            if (this._workCalendarField == value)
            {
                return;
            }
            this._workCalendarField = value;
            this._workCalendarFieldChanged = true;
            invalidateProperties();
        }

        public function get workCalendarFunction():Function
        {
            return this._workCalendarFunction;
        }

        public function set workCalendarFunction(value:Function):void
        {
            if (this._workCalendarFunction == value)
            {
                return;
            }
            this._workCalendarFunction = value;
            this._workCalendarFunctionChanged = true;
            invalidateProperties();
        }

        public function get workCalendar():WorkCalendar
        {
            if (this._explicitWorkCalendar != null)
            {
                return this._explicitWorkCalendar;
            }
            if (_ganttSheet != null)
            {
                return _ganttSheet.workCalendar;
            }
            return null;
        }

        public function set workCalendar(value:WorkCalendar):void
        {
            if (this._explicitWorkCalendar == value)
            {
                return;
            }
            if (this._explicitWorkCalendar != null)
            {
                this._explicitWorkCalendar.removeEventListener(Event.CHANGE, this.workCalendarChangeHandler);
            }
            this._explicitWorkCalendar = value;
            this._workCalendarChanged = true;
            if (this._explicitWorkCalendar != null)
            {
                this._explicitWorkCalendar.addEventListener(Event.CHANGE, this.workCalendarChangeHandler, false, 0, true);
            }
            invalidateProperties();
        }

        override public function clone():GanttSheetGridBase
        {
            var grid:WorkingTimesGrid = new WorkingTimesGrid();
            grid.drawPerRow = drawPerRow;
            grid.drawToBottom = drawToBottom;
            grid.minNonWorkingTimesSize = this.minNonWorkingTimesSize;
            grid.workingTimesFill = this.workingTimesFill;
            grid.nonWorkingTimesFill = this.nonWorkingTimesFill;
            grid.workCalendar = this.workCalendar.clone();
            grid.workCalendarField = this.workCalendarField;
            grid.workCalendarFunction = this.workCalendarFunction;
            grid.workingTimesSkin = this.workingTimesSkin;
            grid.nonWorkingTimesSkin = this.nonWorkingTimesSkin;
            return grid;
        }

        override protected function commitProperties():void
        {
            super.commitProperties();
            if (this._workCalendarChanged)
            {
                this._workCalendarChanged = false;
                invalidateDisplayList();
            }
            if (this._workCalendarFieldChanged || this._workCalendarFunctionChanged)
            {
                this._workCalendarFieldChanged = this._workCalendarFunctionChanged = false;
                invalidateDisplayList();
            }
            if (this._workingTimesFillChanged || this._nonWorkingTimesFillChanged)
            {
                this._workingTimesFillChanged = this._nonWorkingTimesFillChanged = false;
                invalidateDisplayList();
            }
            if (this._minNonWorkingTimesSizeChanged)
            {
                this._minNonWorkingTimesSizeChanged = false;
                invalidateDisplayList();
            }
            if (this._workingTimesSkinChanged)
            {
                this._workingTimesSkinChanged = false;
                this.invalidateWorkingTimesContainer();
                invalidateDisplayList();
            }
            if (this._nonWorkingTimesSkinChanged)
            {
                this._nonWorkingTimesSkinChanged = false;
                this.invalidateNonWorkingTimesContainer();
                invalidateDisplayList();
            }
        }

        private function invalidateWorkingTimesContainer():void
        {
            if (this._wortingTimesRendererContainer != null)
            {
                removeChild(this._wortingTimesRendererContainer);
                this._wortingTimesRendererContainer = null;
            }
        }

        private function invalidateNonWorkingTimesContainer():void
        {
            if (this._nonworkingTimesRendererContainer != null)
            {
                removeChild(this._nonworkingTimesRendererContainer);
                this._nonworkingTimesRendererContainer = null;
            }
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            this.unregisterWorkCalendars();
            if (this._wortingTimesRendererContainer != null)
            {
                this._wortingTimesRendererContainer.startRendering();
            }
            if (this._nonworkingTimesRendererContainer != null)
            {
                this._nonworkingTimesRendererContainer.startRendering();
            }
            this._currentWorkingTimesFill = this._workingTimesFill;
            if (this._currentWorkingTimesFill == null)
            {
                this._currentWorkingTimesFill = this.createFill("working");
            }
            this._currentNonworkingTimesFill = this._nonWorkingTimesFill;
            if (this._currentNonworkingTimesFill == null)
            {
                this._currentNonworkingTimesFill = this.createFill("nonWorking");
            }
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            if (this._wortingTimesRendererContainer != null)
            {
                this._wortingTimesRendererContainer.stopRendering();
            }
            if (this._nonworkingTimesRendererContainer != null)
            {
                this._nonworkingTimesRendererContainer.stopRendering();
            }
        }

        private function createFill(name:String):IFill
        {
            var color:uint;
            var alpha:Number;
            var fill:IFill = getStyle(name + "Fill") as IFill;
            if (fill != null)
            {
                return fill;
            }
            if (getStyle(name + "Color") !== undefined)
            {
                color = getStyle(name + "Color");
                alpha = getStyle(name + "Alpha");
                if (isNaN(alpha))
                {
                    alpha = 1;
                }
                return new SolidColor(color, alpha);
            }
            return null;
        }

        protected function getWorkCalendar(data:Object):WorkCalendar
        {
            if (this.workCalendarFunction != null || (this.workCalendarField != null && data != null))
            {
                return DataUtil.getFieldValue(data, this.workCalendarField, null, this.workCalendarFunction) as WorkCalendar;
            }
            return this.workCalendar;
        }

        override protected function updateGridDisplayList(r:Rectangle, rowIndex:int, data:Object):void
        {
            if (timeController == null || !timeController.configured)
            {
                return;
            }
            var wc:WorkCalendar = this.getWorkCalendar(data);
            this.registerWorkCalendar(wc);
            //unresolved jump
            //  @50 jump @54
           // new Rectangle(0, 0, unscaledWidth, unscaledHeight)._clip = r;
            this.fillGrid(wc, r, data);
            return;
            //not popped:
//            this
            
        }

        private function computeMinStripeSize(daySize:Number):Number
        {
            return this._minNonWorkingTimesSize;
        }

        private function fillGrid(calendar:WorkCalendar, r:Rectangle, data:Object):void
        {
            var tmp:Number;
            var currentX:Number;
            var nextDate:Date;
            var nextDateX:Number;
            var size:Number;
            var fillWT:Boolean = this._currentWorkingTimesFill != null || this.workingTimesSkin != null;
            var fillNWT:Boolean = this._currentNonworkingTimesFill != null || this.nonWorkingTimesSkin != null;
            if (!fillWT && !fillNWT)
            {
                return;
            }
            if (calendar == null || (timeController.isHidingNonworkingTimes && timeController.workCalendar == calendar))
            {
                this.fillWorkingTimes(r, data);
                return;
            }
            var tc:TimeController = timeController;
            var daySize:Number = tc.getSizeOf(TimeUnit.DAY.milliseconds);
            if (daySize == 0)
            {
                return;
            }
            var maxWidth:Number = r.width;
            var refSize:Number = this.computeMinStripeSize(daySize);
            var days:Number = (refSize - 1) / daySize;
            var daysSize:Number = tc.getSizeOf((days * TimeUnit.DAY.milliseconds));
            var x0:Number = -1;
            var x1:Number = -1;
            var workingTimeX0:Number = -1;
            var workingTimeX1:Number = -1;
            var start:Date = calendar.previousWorkingTime(tc.startTime);
            var end:Date = calendar.nextWorkingTime(tc.endTime);
            var current:Date = calendar.nextNonWorkingTime(start);
            while (start < end)
            {
                currentX = tc.getCoordinate(current);
                if (fillWT)
                {
                    x0 = x1!=-1 ? x1 : x0 = Math.min(maxWidth, Math.max(0, tc.getCoordinate(start)));
                    x1 = Math.min(maxWidth, Math.max(0, currentX));
                    if (x0 > x1)
                    {
                        tmp = x0;
                        x0 = x1;
                        x1 = tmp;
                    }
                    if (workingTimeX0 != -1 && workingTimeX1 != x0)
                    {
                        if ((workingTimeX1 - workingTimeX0) >= 1)
                        {
                            r.left = workingTimeX0;
                            r.right = workingTimeX1;
                            this.fillWorkingTimes(r, data);
                        }
                    }
                    if (workingTimeX0 == -1 || workingTimeX1 != x0)
                    {
                        workingTimeX0 = x0;
                    }
                    workingTimeX1 = x1;
                }
                else
                {
                    x1 = -1;
                }
                if (current >= end)
                {
                    break;
                }
                nextDate = calendar.nextWorkingTime(current);
                if (nextDate > end)
                {
                    nextDate.time = end.time;
                }
                start.time = nextDate.time;
                nextDateX = tc.getCoordinate(nextDate);
                size = nextDateX - currentX;
                if (size >= (refSize + 1))
                {
                    x0 = x1!=-1 ? x1 : Math.min(maxWidth, Math.max(0, currentX));
                    x1 = Math.min(maxWidth, Math.max(0, nextDateX));
                    if (x0 > x1)
                    {
                        tmp = x0;
                        x0 = x1;
                        x1 = tmp;
                    }
                    if (fillWT && workingTimeX0 != -1 && workingTimeX1 - workingTimeX0 >= 1)
                    {
                        r.left = workingTimeX0;
                        r.right = workingTimeX1;
                        this.fillWorkingTimes(r, data);
                    }
                    if (fillNWT && (x1 - x0) >= 1)
                    {
                        r.left = x0;
                        r.right = x1;
                        this.fillNonWorkingTimes(r, data);
                    }
                    workingTimeX1 = -1;
                    workingTimeX0 = workingTimeX1;
                }
                else
                {
                    if (fillWT)
                    {
                        x0 = x1!=-1 ? x1 : Math.min(maxWidth, Math.max(0, currentX));
                        x1 = Math.min(maxWidth, Math.max(0, nextDateX));
                        if (x0 > x1)
                        {
                            tmp = x0;
                            x0 = x1;
                            x1 = tmp;
                        }
                        if (workingTimeX0 != -1 && workingTimeX1 != x0 && (workingTimeX1 - workingTimeX0) >= 1)
                        {
                            r.left = workingTimeX0;
                            r.right = workingTimeX1;
                            this.fillWorkingTimes(r, data);
                        }
                        if (workingTimeX0 == -1 || workingTimeX1 != x0)
                        {
                            workingTimeX0 = x0;
                        }
                        workingTimeX1 = x1;
                    }
                }
                if (days >= 1 && daysSize < refSize)
                {
                    nextDate = new Date(nextDate.time);
                    nextDate.date = (nextDate.date + Math.floor(days));
                    nextDate = calendar.previousWorkingTime(nextDate);
                }
                current = calendar.hasNextNonWorkingTime(nextDate) ? calendar.nextNonWorkingTime(nextDate) : end;
            }
            if (fillWT && workingTimeX0 != -1)
            {
                r.left = workingTimeX0;
                r.right = workingTimeX1;
                this.fillWorkingTimes(r, data);
            }
        }

        private function updateWorkingTimesRenderer(r:Rectangle, data:Object):DisplayObject
        {
            if (this._wortingTimesRendererContainer == null)
            {
                this._wortingTimesRendererContainer = new GanttSheetGridRendererContainer();
                this._wortingTimesRendererContainer.itemSkin = this._workingTimesSkin;
                addChild(this._wortingTimesRendererContainer);
            }
            var renderer:DisplayObject = this._wortingTimesRendererContainer.useRenderer(data);
            renderer.x = r.x;
            renderer.y = r.y;
            renderer.height = r.height;
            renderer.width = r.width;
            return renderer;
        }

        private function updateNonWorkingTimesRenderer(r:Rectangle, data:Object):DisplayObject
        {
            if (this._nonworkingTimesRendererContainer == null)
            {
                this._nonworkingTimesRendererContainer = new GanttSheetGridRendererContainer();
                this._nonworkingTimesRendererContainer.itemSkin = this._nonWorkingTimesSkin;
                addChild(this._nonworkingTimesRendererContainer);
            }
            var renderer:DisplayObject = this._nonworkingTimesRendererContainer.useRenderer(data);
            renderer.x = r.x;
            renderer.y = r.y;
            renderer.height = r.height;
            renderer.width = r.width;
            return renderer;
        }

        protected function fillNonWorkingTimes(r:Rectangle, data:Object):void
        {
            if (this._nonWorkingTimesSkin != null)
            {
                this.updateNonWorkingTimesRenderer(r, data);
            }
            else if (this._currentNonworkingTimesFill != null)
			{
				this.fillRect(graphics, this._currentNonworkingTimesFill, r);
			}
        }

        protected function fillWorkingTimes(r:Rectangle, data:Object):void
        {
            if (this._workingTimesSkin != null)
            {
                this.updateWorkingTimesRenderer(r, data);
            }
            else if (this._currentWorkingTimesFill != null)
			{
				this.fillRect(graphics, this._currentWorkingTimesFill, r);
			}
        }

        private function fillRect(graphics:Graphics, fill:IFill, r:Rectangle):void
        {
            fill.begin(graphics, this._clip, null);
            graphics.drawRect(r.x, r.y, r.width, r.height);
            fill.end(graphics);
        }

        private function unregisterWorkCalendars():void
        {
            var wc:WorkCalendar;
            for each (wc in this._registeredWorkCalendars)
            {
                wc.removeEventListener(Event.CHANGE, this.workCalendarChangeHandler);
            }
            this._registeredWorkCalendars = new Dictionary();
        }

        private function registerWorkCalendar(wc:WorkCalendar):void
        {
            if (wc != null && !(this._registeredWorkCalendars[wc] === undefined))
            {
                wc.addEventListener(Event.CHANGE, this.workCalendarChangeHandler);
                this._registeredWorkCalendars[wc] = wc;
            }
        }

        private function workCalendarChangeHandler(event:Event):void
        {
            invalidateDisplayList();
        }
    }
}