package mokylin.gantt
{
    import flash.events.EventDispatcher;
    
    import mx.effects.Tween;
    import mx.effects.easing.Exponential;
    
    import mokylin.gantt.supportClasses.MessageUtil;
    import mokylin.gantt.supportClasses.TimeControllerState;
    import mokylin.utils.TimeComputer;
    import mokylin.utils.TimeUnit;
    import mokylin.utils.TimeUtil;

	/**
	 * 时间轴的管理类 
	 * @author NEIL
	 * 
	 */	
    [ExcludeClass]
    public class TimeController extends EventDispatcher 
    {
		/**
		 * 最小的时间与像素的单位：1ms == 20px 
		 */
        private static const MINIMUM_ZOOM_FACTOR:Number = TimeUnit.MILLISECOND.milliseconds;

		private var _animationInitialStart:Number;
		private var _animationInitialEnd:Number;
		private var _animationFinalStart:Number;
		private var _animationFinalEnd:Number;
		private var _animationProjectedStartRange:Number;
		private var _animationProjectedEndRange:Number;
        private var _animationTargetTC:TimeController;
        private var _animationTween:Tween;
		private var _animationDuration:Number = 1000;
		private var _easingFunction:Function;
		
        private var _timeComputer:TimeComputer;
        private var _configured:Boolean;
        
        private var _enableEvents:Boolean = true;
		private var _startTime:Number;
        private var _endTime:Number;
		private var _nowTime:Number=0;
        
        private var _maximumTime:Number; 
        private var _minimumTime:Number;
		
        private var _minimumZoomFactor:Number;
		private var _maximumZoomFactor:Number;
        
		private var _maximumDuration:Number;
        private var _width:Number;
        private var _zoomFactor:Number;
        
        private var _nestedVisibleTimeRangeChangeCount:int = 0;
        private var _initialState:TimeControllerState;
        private var _isAdjusting:Boolean;
        private var _visibleTimeRangeChangedWhileAdusting:Boolean;
        private var _previousState:TimeControllerState;

        public function TimeController()
        {
            this._easingFunction = Exponential.easeOut;
            this._maximumTime = TimeUtil.MAXIMUM_TIME;
            this._maximumZoomFactor = (TimeUnit.SECOND.milliseconds * 10) / 50;
            this._minimumTime = 0;
            this._minimumZoomFactor = MINIMUM_ZOOM_FACTOR;
            this._zoomFactor = (TimeUnit.SECOND.milliseconds * 10) / 20;
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

		public function get timeComputer():TimeComputer
        {
            if (!this._timeComputer)
            {
                this.timeComputer = new TimeComputer();
            }
            return this._timeComputer;
        }

		public function set timeComputer(value:TimeComputer):void
        {
            if (!value)
            {
                value = new TimeComputer();
            }
            this._timeComputer = value;
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

        private function get maximumDuration():Number
        {
            if (isNaN(this._maximumDuration))
            {
                this._maximumDuration = this.getProjectedTimeBetweenInMillis(this.minimumTime, this.maximumTime);
            }
            return this._maximumDuration;
        }

        public function get maximumTime():Number
        {
            return this._maximumTime;
        }

        public function set maximumTime(value:Number):void
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

        public function get minimumTime():Number
        {
            return this._minimumTime;
        }

        public function set minimumTime(value:Number):void
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

        public function get startTime():Number
        {
            return this._startTime;
        }

        public function set startTime(value:Number):void
        {
            this.stopAnimation();
            this.beginVisibleTimeRangeChange();
            this.setStartTimeImpl(value);
            this.endVisibleTimeRangeChange();
        }
		
		final private function setStartTimeImpl(value:Number):void
		{
			this._startTime = this.getConstrainedStart(value);
			this._endTime = this.getTime(this.width);
		}
		
		public function get nowTime():Number
		{
			return this._nowTime;
		}
		
		public function set nowTime(value:Number):void
		{
			this.beginVisibleTimeRangeChange();
			this._nowTime = value;
			this.endVisibleTimeRangeChange();
		}
		
		public function get endTime():Number
		{
			return this._endTime;
		}
		
		public function set endTime(value:Number):void
		{
			this.beginVisibleTimeRangeChange();
			this._endTime = value;
			this.endVisibleTimeRangeChange();
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
            if (endTimeInMillis > this.maximumTime)
            {
                startTimeInMillis = this.startTime - endTimeInMillis - this.maximumTime;
                endTimeInMillis = this.maximumTime;
                newZoomFactor = this.zoomFactor;
                if (startTimeInMillis < this.minimumTime)
                {
                    startTimeInMillis = this.minimumTime;
                    endTimeInMillis = this.maximumTime;
                    newZoomFactor = (this.getProjectedTimeBetweenInMillis(this.minimumTime, this.maximumTime) / this.width);
                }
                this._startTime = startTimeInMillis;
                this.zoomFactor = newZoomFactor;
            }
            else
            {
                this._endTime = endTimeInMillis;
            }
            this.endVisibleTimeRangeChange();
        }

        public function get zoomFactor():Number
        {
            return this._zoomFactor;
        }

		/**
		 * 一个像素对应多少毫秒 
		 * @param value
		 * 
		 */		
        public function set zoomFactor(value:Number):void
        {
            this.stopAnimation();
            this.beginVisibleTimeRangeChange();
            this._zoomFactor = this.getConstrainedZoomFactor(value);
            this._endTime = this.getTime(this.width);
            this.endVisibleTimeRangeChange();
        }

        public function configure(start:Number, end:Number, width:Number, margin:Number=0, animate:Boolean=false):void
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

        public function getCoordinate(time:Number, floor:Boolean=true):Number
        {
            var timeOffset:Number;
            timeOffset = time - this.startTime;
            var value:Number = timeOffset / this.zoomFactor;
            return floor ? Math.floor(value) : value;
        }

        public function getTime(coordinate:Number):Number
        {
            return this.getTimeInMillis(coordinate);
        }
		/**
		 * 得到多少个像素 
		 * @param duration
		 * @return 
		 * 
		 */
        public function getSizeOf(duration:Number):Number
        {
            return duration / this.zoomFactor;
        }

        public function getProjectedTimeForUnit(unit:TimeUnit, steps:Number):Number
        {
            return unit.milliseconds * steps;
        }

        private function getTimeInMillis(coordinate:Number):Number
        {
            var projectedTimeOffset:Number = coordinate * this.zoomFactor;
            return this.addProjectedTimeInMillis(this.startTime, projectedTimeOffset);
        }

        private function addProjectedTimeInMillis(time:Number, projectedTime:Number):Number
        {
//			projectedTime = timeComputer.ceil(projectedTime);
            projectedTime = Math.floor(projectedTime);
            
            return time + projectedTime;
        }
		/**
		 * 2个时间相差多少毫秒 
		 * @param t1
		 * @param t2
		 * @return 
		 * 
		 */
        private function getProjectedTimeBetweenInMillis(t1:Number, t2:Number):Number
        {
            return t2 - t1;
        }
		/**
		 * 设置时间轴的起始时间，结束时间，及每个像素表示多少毫秒差
		 * @param min
		 * @param max
		 * 
		 */
        public function setTimeBounds(min:Number, max:Number):void
        {
            this.stopAnimation();
            this.beginVisibleTimeRangeChange();
            this._minimumTime = TimeUtil.bound(min, TimeUtil.MINIMUM_TIME, TimeUtil.MAXIMUM_TIME);
            this._maximumTime = TimeUtil.bound(max, TimeUtil.MINIMUM_TIME, TimeUtil.MAXIMUM_TIME);

            this._maximumDuration = NaN;
            if (this.configured)
            {
                this.setStartTimeImpl(this.startTime);
                if (this.endTime > this.maximumTime && this.startTime == this.minimumTime && this.zoomFactor < this.maximumZoomFactor)
                {
                    this.zoomFactor = Math.min(this.maximumZoomFactor, this.getProjectedTimeBetweenInMillis(this.minimumTime, this.maximumTime) / this.width);
                }
            }
            this.endVisibleTimeRangeChange();
        }

		/**
		 * 变相的改变时间的起始时间 
		 * @param time
		 * @param animate
		 * 
		 */		
        public function moveTo(time:Number, animate:Boolean=false):void
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

        public function shiftByCoordinate(delta:Number, animate:Boolean=false,unit:TimeUnit=null,steps:Number=0):void
        {
			trace("***********************************" + delta);
            var projectedTimeOffset:Number;
			if(unit != null && steps != 0)
			{
				projectedTimeOffset = delta * unit.milliseconds * steps;
			}
			else
			{
				projectedTimeOffset = delta * this.zoomFactor
			}
			
            var newStartInMillis:Number = this.addProjectedTimeInMillis(this.startTime, projectedTimeOffset);
            this.moveTo(newStartInMillis, animate);
        }

        public function shiftByProjectedTime(delta:Number, animate:Boolean=false):void
        {
            var newStartInMillis:Number = this.addProjectedTimeInMillis(this.startTime, delta);
            this.moveTo(newStartInMillis, animate);
        }

        public function zoomAndCenter(ratio:Number, time:Number=0, animate:Boolean=false):void
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

        public function focusOn(time:Number, unit:TimeUnit, steps:Number, animate:Boolean=false):void
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

		protected function configureImpl(start:Number, end:Number, width:Number, margin:Number=0):void
        {
            if (isNaN(start))
            {
                throw MessageUtil.wrongArgument(TimeController, "TimeController.configureImpl", "start");
            }
            if (isNaN(end))
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

        private function configureDefaultImpl(start:Number, end:Number, width:Number, margin:Number):void
        {
            this._width = width;
            var projectedDuration:Number = this.getProjectedTimeBetweenInMillis(start, end);
            var marginsExceedWidth:Boolean = (2 * margin) >= width;
            var zf:Number = marginsExceedWidth ? projectedDuration : projectedDuration / (width - 2 * margin);
            this._zoomFactor = this.getConstrainedZoomFactor(zf);
            if (margin > 0)
            {
                start = this.addProjectedTimeInMillis(start, (-this.zoomFactor * margin));
            }
            this.setStartTimeImpl(start);
            this._configured = true;
        }

        private function reconfigureImpl(start:Number, end:Number, width:Number, margin:Number):void
        {
            var projectedOffsetInMillis:Number;
            this._width = width;
            var projectedDuration:Number = this.getProjectedTimeBetweenInMillis(start, end);
            var rangeCenterTime:Number = this.addProjectedTimeInMillis(start, (projectedDuration / 2));
            var initialRangeCenterPosition:Number = this.getCoordinate(rangeCenterTime);
            var marginsExceedWidth:Boolean = (2 * margin) >= width;
            var zf:Number = marginsExceedWidth ? projectedDuration : projectedDuration / (width - (2 * margin));
            this._zoomFactor = this.getConstrainedZoomFactor(zf);
            if (margin > 0)
            {
                start = this.addProjectedTimeInMillis(start, (-this.zoomFactor * margin));
                end = this.addProjectedTimeInMillis(end, (this.zoomFactor * margin));
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
                this.setStartTimeImpl(this.addProjectedTimeInMillis(this.startTime, projectedOffsetInMillis));
                if (start < this.startTime)
                {
                    this.setStartTimeImpl(start);
                }
                else if (end > this.endTime)
				{
					this.setStartTimeImpl(this.addProjectedTimeInMillis(end, (-this.zoomFactor * width)));
				}
            }
        }

        private function getConstrainedStart(value:Number):Number
        {
            var valueInMillis:Number = Math.max(value, this.minimumTime);
            var projectedDuration:Number = this.width * this.zoomFactor;
            var endTimeInMillis:Number = this.addProjectedTimeInMillis(valueInMillis, projectedDuration);
            if (endTimeInMillis > this.maximumTime && valueInMillis > this.minimumTime)
            {
                valueInMillis = this.addProjectedTimeInMillis(this.maximumTime, -projectedDuration);
                valueInMillis = Math.max(valueInMillis, this.minimumTime);
            }
            return valueInMillis;
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

		protected function focusOnImpl(time:Number, unit:TimeUnit, steps:Number):void
        {
            if (isNaN(time))
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
            var start:Number = this.timeComputer.floor(time, unit, steps);
            var end:Number = this.timeComputer.addUnits(start, unit, steps);
            this.configureImpl(start, end, this.width);
            this.endVisibleTimeRangeChange();
        }

		protected function moveToImpl(time:Number):void
        {
            if (isNaN(time))
            {
                throw MessageUtil.wrongArgument(TimeController, "TimeController.moveToImpl", "time");
            }
            this.beginVisibleTimeRangeChange();
            this.startTime = time;
            this.endVisibleTimeRangeChange();
        }

		protected function zoomAndCenterImpl(ratio:Number, time:Number=0):void
        {
            var centerOnMillis:Number;
            if (isNaN(ratio))
            {
                throw MessageUtil.wrongArgument(TimeController, "TimeController.zoomAndCenterImpl", "ratio");
            }
            if (isNaN(time))
            {
                throw MessageUtil.wrongArgument(TimeController, "TimeController.zoomAndCenterImpl", "time");
            }
            this.beginVisibleTimeRangeChange();
            if (time == 0)
            {
                centerOnMillis = this.getTimeInMillis(this.width / 2);
            }
            else
            {
                centerOnMillis = time;
            }
            this.zoomFactor = this.zoomFactor * ratio;
            this.startTime = this.addProjectedTimeInMillis(centerOnMillis, (-this.width / 2) * this.zoomFactor);
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
            var initialTimeAtCoordinate:Number = this.getTime(coordinate);
            this.zoomFactor = this.zoomFactor * ratio;
            var projectedOffsetInMillis:Number = this.getProjectedTimeBetweenInMillis(this.getTime(coordinate), initialTimeAtCoordinate);
            this.startTime = this.addProjectedTimeInMillis(this.startTime, projectedOffsetInMillis);
            this.endVisibleTimeRangeChange();
        }

        private function prepareAnimationTarget(updateTargetTimeController:Function):void
        {
            if (this._animationTargetTC == null)
            {
                this._animationTargetTC = new TimeController();
            }
            this._animationTargetTC.timeComputer = this.timeComputer;

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
            var start:Number = this.addProjectedTimeInMillis(this._animationInitialStart, Math.floor(this._animationProjectedStartRange / 100) * value);
            var end:Number = this.addProjectedTimeInMillis(this._animationInitialEnd, Math.floor(this._animationProjectedEndRange / 100) * value);
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
				if(!currentState.equalsNowTime(this._initialState))
				{
					this.dispatchVisibleNowTimeChange(currentState);
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
		
		private function dispatchVisibleNowTimeChange(currentState:TimeControllerState):void
		{
			if (!this._enableEvents)
			{
				return;
			}
			var event:GanttSheetEvent = new GanttSheetEvent(GanttSheetEvent.VISIBLE_NOW_TIME_CHANGE);
			event.adjusting = this.isAdjusting;
			event.nowTimeChanged = true;
			dispatchEvent(event);
		}

        private function dispatchVisibleTimeRangeChange(currentState:TimeControllerState):void
        {
            if (!this._enableEvents)
            {
                return;
            }
            var zoomFactorChanged:Boolean = this._previousState == null || currentState.zoomFactor != this._previousState.zoomFactor;
			var nowTimeChanged:Boolean = this._previousState == null || currentState.nowTime != this._previousState.nowTime;
/*			var timeRangeChanged:Boolean = this._previousState == null || currentState.startTime != this._previousState.startTime
											|| currentState.endTime != this._previousState.endTime;*/
			
//			var projectionChanged:Boolean = this._workCalendarChanged || this._previousState == null || currentState.isHidingNonworkingTimes != this._previousState.isHidingNonworkingTimes;
			var event:GanttSheetEvent = new GanttSheetEvent(GanttSheetEvent.VISIBLE_TIME_RANGE_CHANGE);
            event.adjusting = this.isAdjusting;
            event.zoomFactorChanged = zoomFactorChanged;
            event.nowTimeChanged = nowTimeChanged;
//			event.timeRangeChanged = timeRangeChanged;
            dispatchEvent(event);
			
            this._previousState = currentState;
            if (this.isAdjusting)
            {
                this._visibleTimeRangeChangedWhileAdusting = true;
            }
        }

		/**
		 * 主要是监控endTime，startTime,zoomFactor， isHidingNonworkingTimes这4个属性的变化，然后以事件来通知其它模块更新
		 * @return 
		 * 
		 */
        private function getState():TimeControllerState
        {
            return new TimeControllerState(this.nowTime,this.endTime, this.startTime, this.zoomFactor);
        }
    }
}