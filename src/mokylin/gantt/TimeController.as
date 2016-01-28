package mokylin.gantt
{
    import flash.events.EventDispatcher;
    import mokylin.utils.TimeUnit;
    import mx.effects.Tween;
    import mokylin.utils.GregorianCalendar;
    import mokylin.utils.WorkCalendar;
    import mokylin.gantt.supportClasses.TimeControllerState;
    import mx.effects.easing.Exponential;
    import flash.events.Event;
    import mokylin.utils.TimeUtil;
    import mokylin.gantt.supportClasses.MessageUtil;
    import mokylin.gantt.GanttSheetEvent;

    [ExcludeClass]
    public class TimeController extends EventDispatcher 
    {

        private static const MINIMUM_ZOOM_FACTOR:Number = (TimeUnit.MILLISECOND.milliseconds / 1);

        private var _animationTargetTC:TimeController;
        private var _animationTween:Tween;
        private var _workCalendarChanged:Boolean;
        private var _animationDuration:Number = 1000;
        private var _calendar:GregorianCalendar;
        private var _configured:Boolean;
        private var _easingFunction:Function;
        private var _enableEvents:Boolean = true;
        private var _endTime:Date;
        private var _hideNonWorkingTimes:Boolean;
        private var _isHidingNonworkingTimes:Boolean;
        private var _maximumDuration:Number;
        private var _maximumTime:Date;
        private var _maximumWorkingTime:Date;
        private var _maximumZoomFactor:Number;
        private var _minimumTime:Date;
        private var _minimumWorkingTime:Date;
        private var _minimumZoomFactor:Number;
        private var _startTime:Date;
        private var _width:Number;
        private var _workCalendar:WorkCalendar;
        private var _zoomFactor:Number;
        private var _animationInitialStart:Date;
        private var _animationInitialEnd:Date;
        private var _animationFinalStart:Date;
        private var _animationFinalEnd:Date;
        private var _animationProjectedStartRange:Number;
        private var _animationProjectedEndRange:Number;
        private var _nestedVisibleTimeRangeChangeCount:int = 0;
        private var _initialState:TimeControllerState;
        private var _isAdjusting:Boolean;
        private var _visibleTimeRangeChangedWhileAdusting:Boolean;
        private var _previousState:TimeControllerState;

        public function TimeController()
        {
            this._easingFunction = Exponential.easeOut;
            this._maximumTime = new Date(2900, 0);
            this._maximumZoomFactor = (TimeUnit.DECADE.milliseconds / 20);
            this._minimumTime = new Date(1900, 0);
            this._minimumZoomFactor = MINIMUM_ZOOM_FACTOR;
            this._zoomFactor = TimeUnit.DAY.milliseconds / 20;
            super();
        }

		public function get animationDuration():Number
        {
            return this._animationDuration;
        }

		public function set animationDuration(value:Number):void
        {
            this._animationDuration = value;
        }

		public function get calendar():GregorianCalendar
        {
            if (!this._calendar)
            {
                this.calendar = new GregorianCalendar();
            }
            return this._calendar;
        }

		public function set calendar(value:GregorianCalendar):void
        {
            if (!value)
            {
                value = new GregorianCalendar();
            }
            this._calendar = value;
        }

        public function get configured():Boolean
        {
            return this._configured;
        }

		public function get easingFunction():Function
        {
            return this._easingFunction;
        }

		public function set easingFunction(value:Function):void
        {
            this._easingFunction = value;
        }

        public function get enableEvents():Boolean
        {
            return this._enableEvents;
        }

        public function set enableEvents(value:Boolean):void
        {
            this._enableEvents = value;
        }

        public function get endTime():Date
        {
            return this._endTime;
        }

        public function set endTime(value:Date):void
        {
            this.beginVisibleTimeRangeChange();
            this._endTime = value;
            this.endVisibleTimeRangeChange();
        }

        public function get hideNonworkingTimes():Boolean
        {
            return this._hideNonWorkingTimes;
        }

        public function set hideNonworkingTimes(value:Boolean):void
        {
            if (value == this._hideNonWorkingTimes)
            {
                return;
            }
            this._hideNonWorkingTimes = value;
            this.updateIsHidingNonworkingTimes();
        }

        public function get isHidingNonworkingTimes():Boolean
        {
            return this._isHidingNonworkingTimes;
        }

        private function get maximumDuration():Number
        {
            if (isNaN(this._maximumDuration))
            {
                this._maximumDuration = this.getProjectedTimeBetweenInMillis(this.minimumTime, this.maximumTime);
            }
            return this._maximumDuration;
        }

        public function get maximumTime():Date
        {
            if (this.isHidingNonworkingTimes)
            {
                if (this._maximumWorkingTime == null)
                {
                    this._maximumWorkingTime = this.workCalendar.previousWorkingTime(this._maximumTime);
                }
                return this._maximumWorkingTime;
            }
            return this._maximumTime;
        }

        public function set maximumTime(value:Date):void
        {
            this.stopAnimation();
            this.beginVisibleTimeRangeChange();
            this.setTimeBounds(this.minimumTime, value);
            this.endVisibleTimeRangeChange();
        }

        public function get maximumZoomFactor():Number
        {
            return this._maximumZoomFactor;
        }

        public function set maximumZoomFactor(value:Number):void
        {
            this.stopAnimation();
            this.beginVisibleTimeRangeChange();
            this._maximumZoomFactor = value;
            if (this._configured)
            {
                if (this.zoomFactor > this.maximumZoomFactor)
                {
                    this.zoomFactor = this.maximumZoomFactor;
                }
            }
            this.endVisibleTimeRangeChange();
        }

        public function get minimumTime():Date
        {
            if (this.isHidingNonworkingTimes)
            {
                if (this._minimumWorkingTime == null)
                {
                    this._minimumWorkingTime = this.workCalendar.nextWorkingTime(this._minimumTime);
                }
                return this._minimumWorkingTime;
            }
            return this._minimumTime;
        }

        public function set minimumTime(value:Date):void
        {
            this.stopAnimation();
            this.beginVisibleTimeRangeChange();
            this.setTimeBounds(value, this.maximumTime);
            this.endVisibleTimeRangeChange();
        }

        public function get minimumZoomFactor():Number
        {
            return this._minimumZoomFactor;
        }

        public function set minimumZoomFactor(value:Number):void
        {
            this.stopAnimation();
            this.beginVisibleTimeRangeChange();
            if (value < MINIMUM_ZOOM_FACTOR)
            {
                value = MINIMUM_ZOOM_FACTOR;
            }
            this._minimumZoomFactor = value;
            if (this._configured)
            {
                if (this.zoomFactor < this.minimumZoomFactor)
                {
                    this.zoomFactor = this.minimumZoomFactor;
                }
            }
            this.endVisibleTimeRangeChange();
        }

        public function get startTime():Date
        {
            return this._startTime;
        }

        public function set startTime(value:Date):void
        {
            this.stopAnimation();
            this.beginVisibleTimeRangeChange();
            this.setStartTimeImpl(value);
            this.endVisibleTimeRangeChange();
        }

        final private function setStartTimeImpl(value:Date):void
        {
            this._startTime = this.getConstrainedStart(value);
            this._endTime = this.getTime(this.width);
        }

        public function get width():Number
        {
            return this._width;
        }

        public function set width(value:Number):void
        {
            var startTimeInMillis:Number;
            var newZoomFactor:Number;
            this.stopAnimation();
            this.beginVisibleTimeRangeChange();
            this._width = value;
            var endTimeInMillis:Number = this.getTimeInMillis(this.width);
            if (endTimeInMillis > this.maximumTime.time)
            {
                startTimeInMillis = this.startTime.time - endTimeInMillis - this.maximumTime.time;
                endTimeInMillis = this.maximumTime.time;
                newZoomFactor = this.zoomFactor;
                if (startTimeInMillis < this.minimumTime.time)
                {
                    startTimeInMillis = this.minimumTime.time;
                    endTimeInMillis = this.maximumTime.time;
                    newZoomFactor = (this.getProjectedTimeBetweenInMillis(this.minimumTime, this.maximumTime) / this.width);
                }
                this._startTime = new Date(startTimeInMillis);
                this.zoomFactor = newZoomFactor;
            }
            else
            {
                this._endTime = new Date(endTimeInMillis);
            }
            this.endVisibleTimeRangeChange();
        }

        public function get workCalendar():WorkCalendar
        {
            return this._workCalendar;
        }

        public function set workCalendar(value:WorkCalendar):void
        {
            if (this._workCalendar == value)
            {
                return;
            }
            if (this._workCalendar != null)
            {
                this._workCalendar.removeEventListener(Event.CHANGE, this.workCalendar_change);
            }
            this._workCalendar = value;
            if (this._workCalendar != null)
            {
                this._workCalendar.addEventListener(Event.CHANGE, this.workCalendar_change);
            }
            this.updateIsHidingNonworkingTimes();
        }

        private function updateIsHidingNonworkingTimes():void
        {
            var newEndInMillis:Number;
            var oldValue:Boolean = this.isHidingNonworkingTimes;
            var newValue:Boolean = this.workCalendar != null && this.hideNonworkingTimes;
            if (newValue == oldValue)
            {
                return;
            }
            this._isHidingNonworkingTimes = newValue;
            if (this.startTime != null && !isNaN(this.width) && !isNaN(this.zoomFactor))
            {
                newEndInMillis = this.addProjectedTimeInMillis(this.startTime, (this.width * this.zoomFactor));
                this.configure(this.startTime, new Date(newEndInMillis), this.width);
            }
        }

        public function get zoomFactor():Number
        {
            return this._zoomFactor;
        }

        public function set zoomFactor(value:Number):void
        {
            this.stopAnimation();
            this.beginVisibleTimeRangeChange();
            this._zoomFactor = this.getConstrainedZoomFactor(value);
            this._endTime = this.getTime(this.width);
            this.endVisibleTimeRangeChange();
        }

        public function configure(start:Date, end:Date, width:Number, margin:Number=0, animate:Boolean=false):void
        {
            if (animate && this.animationDuration != 0)
            {
                this.startAnimation(function ():void
                {
                    _animationTargetTC.configureImpl(start, end, width, margin);
                });
            }
            else
            {
                this.stopAnimation();
                this.configureImpl(start, end, width, margin);
            }
        }

        public function getCoordinate(time:Date, floor:Boolean=true):Number
        {
            var timeOffset:Number;
            if (this.isHidingNonworkingTimes)
            {
                timeOffset = this.workCalendar.workBetween(this.startTime, time);
            }
            else
            {
                timeOffset = time.time - this.startTime.time;
            }
            var value:Number = (timeOffset / this.zoomFactor);
            return floor ? Math.floor(value) : value;
        }

        public function getTime(coordinate:Number):Date
        {
            return new Date(this.getTimeInMillis(coordinate));
        }

        public function getSizeOf(duration:Number):Number
        {
            return duration / this.zoomFactor;
        }

        public function getProjectedTimeForUnit(unit:TimeUnit, steps:Number):Number
        {
            if (this.isHidingNonworkingTimes)
            {
                return this.workCalendar.getWorkingTimeForUnit(unit, steps);
            }
            return unit.milliseconds * steps;
        }

        private function getTimeInMillis(coordinate:Number):Number
        {
            var projectedTimeOffset:Number = coordinate * this.zoomFactor;
            return this.addProjectedTimeInMillis(this.startTime, projectedTimeOffset);
        }

        private function addProjectedTimeInMillis(time:Date, projectedTime:Number):Number
        {
            projectedTime = Math.floor(projectedTime);
            if (this.isHidingNonworkingTimes)
            {
                if (projectedTime == 0)
                {
                    return time.time;
                }
                if (projectedTime > 0)
                {
                    return this.workCalendar.addWorkingTime(time, projectedTime).time;
                }
                return this.workCalendar.removeWorkingTime(time, -projectedTime).time;
            }
            return time.time + projectedTime;
        }

        private function getProjectedTimeBetweenInMillis(t1:Date, t2:Date):Number
        {
            if (this.isHidingNonworkingTimes)
            {
                return this.workCalendar.workBetween(t1, t2);
            }
            return t2.time - t1.time;
        }

        public function setTimeBounds(min:Date, max:Date):void
        {
            this.stopAnimation();
            this.beginVisibleTimeRangeChange();
            this._minimumTime = TimeUtil.bound(min, TimeUtil.MINIMUM_DATE, TimeUtil.MAXIMUM_DATE);
            this._maximumTime = TimeUtil.bound(max, TimeUtil.MINIMUM_DATE, TimeUtil.MAXIMUM_DATE);
            this._minimumWorkingTime = null;
            this._maximumWorkingTime = null;
            this._maximumDuration = NaN;
            if (this.configured)
            {
                this.setStartTimeImpl(this.startTime);
                if (this.endTime > this.maximumTime && this.startTime.time == this.minimumTime.time && this.zoomFactor < this.maximumZoomFactor)
                {
                    this.zoomFactor = Math.min(this.maximumZoomFactor, this.getProjectedTimeBetweenInMillis(this.minimumTime, this.maximumTime) / this.width);
                }
            }
            this.endVisibleTimeRangeChange();
        }

        public function moveTo(time:Date, animate:Boolean=false):void
        {
            if (animate && this.animationDuration != 0)
            {
                this.startAnimation(function ():void
                {
                    _animationTargetTC.moveToImpl(time);
                });
            }
            else
            {
                this.stopAnimation();
                this.moveToImpl(time);
            }
        }

        public function shiftByCoordinate(delta:Number, animate:Boolean=false):void
        {
            var projectedTimeOffset:Number = delta * this.zoomFactor;
            var newStartInMillis:Number = this.addProjectedTimeInMillis(this.startTime, projectedTimeOffset);
            this.moveTo(new Date(newStartInMillis), animate);
        }

        public function shiftByProjectedTime(delta:Number, animate:Boolean=false):void
        {
            var newStartInMillis:Number = this.addProjectedTimeInMillis(this.startTime, delta);
            this.moveTo(new Date(newStartInMillis), animate);
        }

        public function zoomAndCenter(ratio:Number, time:Date=null, animate:Boolean=false):void
        {
            if (animate && this.animationDuration != 0)
            {
                this.startAnimation(function ():void
                {
                    _animationTargetTC.zoomAndCenterImpl(ratio, time);
                });
            }
            else
            {
                this.stopAnimation();
                this.zoomAndCenterImpl(ratio, time);
            }
        }

        public function zoomAt(ratio:Number, coordinate:Number, animate:Boolean=false):void
        {
            if (animate && this.animationDuration != 0)
            {
                this.startAnimation(function ():void
                {
                    _animationTargetTC.zoomAtImpl(ratio, coordinate);
                });
            }
            else
            {
                this.stopAnimation();
                this.zoomAtImpl(ratio, coordinate);
            }
        }

        public function focusOn(time:Date, unit:TimeUnit, steps:Number, animate:Boolean=false):void
        {
            if (animate && this.animationDuration != 0)
            {
                this.startAnimation(function ():void
                {
                    _animationTargetTC.focusOnImpl(time, unit, steps);
                });
            }
            else
            {
                this.stopAnimation();
                this.focusOnImpl(time, unit, steps);
            }
        }

		protected function configureImpl(start:Date, end:Date, width:Number, margin:Number=0):void
        {
            if (start == null || isNaN(start.time))
            {
                throw MessageUtil.wrongArgument(TimeController, "TimeController.configureImpl", "start");
            }
            if (end == null || isNaN(end.time))
            {
                throw MessageUtil.wrongArgument(TimeController, "TimeController.configureImpl", "end");
            }
            if (isNaN(width))
            {
                throw MessageUtil.wrongArgument(TimeController, "TimeController.configureImpl", "width");
            }
            if (isNaN(margin))
            {
                margin = 0;
            }
            this.beginVisibleTimeRangeChange();
            if (this.configured)
            {
                this.reconfigureImpl(start, end, width, margin);
            }
            else
            {
                this.configureDefaultImpl(start, end, width, margin);
            }
            this._configured = true;
            this.endVisibleTimeRangeChange();
        }

        private function configureDefaultImpl(start:Date, end:Date, width:Number, margin:Number):void
        {
            this._width = width;
            var projectedDuration:Number = this.getProjectedTimeBetweenInMillis(start, end);
            var marginsExceedWidth:Boolean = (2 * margin) >= width;
            var zf:Number = marginsExceedWidth ? projectedDuration : projectedDuration / (width - 2 * margin);
            this._zoomFactor = this.getConstrainedZoomFactor(zf);
            if (margin > 0)
            {
                start = new Date(this.addProjectedTimeInMillis(start, (-(this.zoomFactor) * margin)));
            }
            this.setStartTimeImpl(start);
            this._configured = true;
        }

        private function reconfigureImpl(start:Date, end:Date, width:Number, margin:Number):void
        {
            var projectedOffsetInMillis:Number;
            this._width = width;
            var projectedDuration:Number = this.getProjectedTimeBetweenInMillis(start, end);
            var rangeCenterTime:Date = new Date(this.addProjectedTimeInMillis(start, (projectedDuration / 2)));
            var initialRangeCenterPosition:Number = this.getCoordinate(rangeCenterTime);
            var marginsExceedWidth:Boolean = (2 * margin) >= width;
            var zf:Number = marginsExceedWidth ? projectedDuration : projectedDuration / (width - (2 * margin));
            this._zoomFactor = this.getConstrainedZoomFactor(zf);
            if (margin > 0)
            {
                start = new Date(this.addProjectedTimeInMillis(start, (-this.zoomFactor * margin)));
                end = new Date(this.addProjectedTimeInMillis(end, (this.zoomFactor * margin)));
            }
            var requiredWidth:Number = Math.ceil(projectedDuration / this.zoomFactor + 2 * margin);
            if (requiredWidth >= width)
            {
                this.setStartTimeImpl(start);
            }
            else
            {
                this.setStartTimeImpl(start);
                projectedOffsetInMillis = this.getProjectedTimeBetweenInMillis(this.getTime(initialRangeCenterPosition), rangeCenterTime);
                this.setStartTimeImpl(new Date(this.addProjectedTimeInMillis(this.startTime, projectedOffsetInMillis)));
                if (start < this.startTime)
                {
                    this.setStartTimeImpl(start);
                }
                else if (end > this.endTime)
				{
					this.setStartTimeImpl(new Date(this.addProjectedTimeInMillis(end, (-this.zoomFactor * width))));
				}
            }
        }

        private function getConstrainedStart(value:Date):Date
        {
            if (this.isHidingNonworkingTimes)
            {
                value = this.workCalendar.nextWorkingTime(value);
            }
            var valueInMillis:Number = Math.max(value.time, this.minimumTime.time);
            var projectedDuration:Number = this.width * this.zoomFactor;
            var endTimeInMillis:Number = this.addProjectedTimeInMillis(new Date(valueInMillis), projectedDuration);
            if (endTimeInMillis > this.maximumTime.time && valueInMillis > this.minimumTime.time)
            {
                valueInMillis = this.addProjectedTimeInMillis(this.maximumTime, -projectedDuration);
                valueInMillis = Math.max(valueInMillis, this.minimumTime.time);
            }
            return new Date(valueInMillis);
        }

        private function getConstrainedZoomFactor(value:Number):Number
        {
            if (value < this.minimumZoomFactor)
            {
                value = this.minimumZoomFactor;
            }
            if (!isNaN(this.maximumZoomFactor) && value > this.maximumZoomFactor)
            {
                value = this.maximumZoomFactor;
            }
            var visibleMax:Number = (this.maximumDuration / this.width);
            if (value > visibleMax)
            {
                value = visibleMax;
            }
            return value;
        }

		protected function focusOnImpl(time:Date, unit:TimeUnit, steps:Number):void
        {
            if (time == null || isNaN(time.time))
            {
                throw MessageUtil.wrongArgument(TimeController, "TimeController.focusOnImpl", "time");
            }
            if (unit == null)
            {
                throw MessageUtil.wrongArgument(TimeController, "TimeController.focusOnImpl", "unit");
            }
            if (isNaN(steps))
            {
                steps = 1;
            }
            this.beginVisibleTimeRangeChange();
            var start:Date = this.calendar.floor(time, unit, steps);
            var end:Date = this.calendar.addUnits(start, unit, steps);
            this.configureImpl(start, end, this.width);
            this.endVisibleTimeRangeChange();
        }

		protected function moveToImpl(time:Date):void
        {
            if (time == null || isNaN(time.time))
            {
                throw MessageUtil.wrongArgument(TimeController, "TimeController.moveToImpl", "time");
            }
            this.beginVisibleTimeRangeChange();
            this.startTime = time;
            this.endVisibleTimeRangeChange();
        }

		protected function zoomAndCenterImpl(ratio:Number, time:Date=null):void
        {
            var centerOnMillis:Number;
            if (isNaN(ratio))
            {
                throw MessageUtil.wrongArgument(TimeController, "TimeController.zoomAndCenterImpl", "ratio");
            }
            if (time != null && isNaN(time.time))
            {
                throw MessageUtil.wrongArgument(TimeController, "TimeController.zoomAndCenterImpl", "time");
            }
            this.beginVisibleTimeRangeChange();
            if (time == null)
            {
                centerOnMillis = this.getTimeInMillis(this.width / 2);
            }
            else
            {
                centerOnMillis = time.time;
            }
            this.zoomFactor = this.zoomFactor * ratio;
            this.startTime = new Date(this.addProjectedTimeInMillis(new Date(centerOnMillis), (-this.width / 2) * this.zoomFactor));
            this.endVisibleTimeRangeChange();
        }

		protected function zoomAtImpl(ratio:Number, coordinate:Number):void
        {
            if (isNaN(ratio))
            {
                throw MessageUtil.wrongArgument(TimeController, "TimeController.zoomAtImpl", "ratio");
            }
            if (isNaN(coordinate))
            {
                throw MessageUtil.wrongArgument(TimeController, "TimeController.zoomAtImpl", "coordinate");
            }
            this.beginVisibleTimeRangeChange();
            var initialTimeAtCoordinate:Date = this.getTime(coordinate);
            this.zoomFactor = (this.zoomFactor * ratio);
            var projectedOffsetInMillis:Number = this.getProjectedTimeBetweenInMillis(this.getTime(coordinate), initialTimeAtCoordinate);
            this.startTime = new Date(this.addProjectedTimeInMillis(this.startTime, projectedOffsetInMillis));
            this.endVisibleTimeRangeChange();
        }

        private function prepareAnimationTarget(updateTargetTimeController:Function):void
        {
            if (this._animationTargetTC == null)
            {
                this._animationTargetTC = new TimeController();
            }
            this._animationTargetTC.calendar = this.calendar;
            this._animationTargetTC.workCalendar = this.workCalendar;
            this._animationTargetTC.hideNonworkingTimes = this.hideNonworkingTimes;
            this._animationTargetTC.minimumTime = this.minimumTime;
            this._animationTargetTC.maximumTime = this.maximumTime;
            this._animationTargetTC.minimumZoomFactor = this.minimumZoomFactor;
            this._animationTargetTC.maximumZoomFactor = this.maximumZoomFactor;
            this._animationTargetTC.configureImpl(this.startTime, this.endTime, this.width);
            updateTargetTimeController.call();
        }

        private function startAnimation(updateTargetTimeController:Function):void
        {
            this.stopAnimation();
            this.prepareAnimationTarget(updateTargetTimeController);
            this._animationInitialStart = this.startTime;
            this._animationInitialEnd = this.endTime;
            this._animationFinalStart = this._animationTargetTC.startTime;
            this._animationFinalEnd = this._animationTargetTC.endTime;
            this._animationProjectedStartRange = this.getProjectedTimeBetweenInMillis(this.startTime, this._animationTargetTC.startTime);
            this._animationProjectedEndRange = this.getProjectedTimeBetweenInMillis(this.endTime, this._animationTargetTC.endTime);
            this._animationTween = new Tween(this, 0, 100, this.animationDuration);
            this._animationTween.easingFunction = this.easingFunction;
        }

        private function stopAnimation():void
        {
            var tween:Tween = this._animationTween;
            if (tween)
            {
                tween.endTween();
            }
        }

        public function onTweenUpdate(value:Number):void
        {
            var start:Date = new Date(this.addProjectedTimeInMillis(this._animationInitialStart, Math.floor(this._animationProjectedStartRange / 100) * value));
            var end:Date = new Date(this.addProjectedTimeInMillis(this._animationInitialEnd, Math.floor(this._animationProjectedEndRange / 100) * value));
            this.configureImpl(start, end, this.width);
        }

        public function onTweenEnd(value:Object):void
        {
            this._animationTween = null;
            this.configureImpl(this._animationTargetTC.startTime, this._animationTargetTC.endTime, this.width);
        }

        private function beginVisibleTimeRangeChange():void
        {
            if (this._nestedVisibleTimeRangeChangeCount == 0)
            {
                this._initialState = this.getState();
            }
            this._nestedVisibleTimeRangeChangeCount = this._nestedVisibleTimeRangeChangeCount + 1;
        }

        private function endVisibleTimeRangeChange():void
        {
            var currentState:TimeControllerState;
            this._nestedVisibleTimeRangeChangeCount = this._nestedVisibleTimeRangeChangeCount - 1;
            if (this._nestedVisibleTimeRangeChangeCount == 0)
            {
                currentState = this.getState();
                if (!currentState.equals(this._initialState))
                {
                    this.dispatchVisibleTimeRangeChange(currentState);
                }
            }
        }

		public function startAdjusting():void
        {
            if (!this._isAdjusting)
            {
                this._visibleTimeRangeChangedWhileAdusting = false;
            }
            this._isAdjusting = true;
        }

		public function stopAdjusting():void
        {
            var needEvent:Boolean = this._isAdjusting && this._visibleTimeRangeChangedWhileAdusting;
            this._isAdjusting = false;
            if (needEvent)
            {
                this.dispatchVisibleTimeRangeChange(this.getState());
            }
        }

        private function get isAdjusting():Boolean
        {
            return this._isAdjusting || this._animationTween != null;
        }

        private function dispatchVisibleTimeRangeChange(currentState:TimeControllerState):void
        {
            if (!this._enableEvents)
            {
                return;
            }
            var zoomFactorChanged:Boolean = this._previousState == null || currentState.zoomFactor != this._previousState.zoomFactor;
            var projectionChanged:Boolean = this._workCalendarChanged || this._previousState == null || currentState.isHidingNonworkingTimes != this._previousState.isHidingNonworkingTimes;
           
			var event:GanttSheetEvent = new GanttSheetEvent(GanttSheetEvent.VISIBLE_TIME_RANGE_CHANGE);
            event.adjusting = this.isAdjusting;
            event.zoomFactorChanged = zoomFactorChanged;
            event.projectionChanged = projectionChanged;
            dispatchEvent(event);
			
            this._previousState = currentState;
            this._workCalendarChanged = false;
            if (this.isAdjusting)
            {
                this._visibleTimeRangeChangedWhileAdusting = true;
            }
        }

        private function workCalendar_change(event:Event):void
        {
            var newEndInMillis:Number;
            this._maximumWorkingTime = null;
            this._minimumWorkingTime = null;
            if (!this.hideNonworkingTimes)
            {
                return;
            }
            this._workCalendarChanged = true;
            if (this.startTime != null && !isNaN(this.width) && !isNaN(this.zoomFactor))
            {
                newEndInMillis = this.addProjectedTimeInMillis(this.startTime, (this.width * this.zoomFactor));
                this.configure(this.startTime, new Date(newEndInMillis), this.width);
            }
        }
		/**
		 * 主要是监控endTime，startTime,zoomFactor， isHidingNonworkingTimes这4个属性的变化，然后以事件来通知其它模块更新
		 * @return 
		 * 
		 */
        private function getState():TimeControllerState
        {
            return new TimeControllerState((this.endTime != null ? this.endTime.time : NaN), (this.startTime != null ? this.startTime.time : NaN), this.zoomFactor, this.isHidingNonworkingTimes);
        }
    }
}