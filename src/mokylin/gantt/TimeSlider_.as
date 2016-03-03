package mokylin.gantt
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.core.EventPriority;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	
	import mokylin.utils.TimeUnit;
	
	[Event(name="change")]
	public class TimeSlider_ extends UIComponent
	{
		public static const FRAME_MODE:String = "frame";
		public static const TIME_MODE:String = "time";
		
		private static const MIN_GAP:int = 10;
		private static const TOP_BAR_HEIGHT:Number = 8;
		private static const BOTTOM_BAR_HEIGHT:Number = 16;
		private static const MIDDLE_BAR_HEIGHT:Number = 22;
		private static const MARK_HEIGHT:Number = 3;
		private static const MARK_STEPS:Array = [1,2,5,10,20,50,100,1000];
//		public static const DEFAULT_DURATION:uint = 100000;
		
		public var thumb:Button;
		private var topBar:Sprite;
		private var bottomBar:Sprite;
		private var thumbLine:Sprite;
		private var middleBar:Sprite;
		private var txts:Vector.<TextField>;
		private var txtsContainer:Sprite;
		/*private var startValueTxt:TransparentTextInput;
		private var endValueTxt:TransparentTextInput;*/
		
		private var _duration:uint = 1;
		private var _time:int;
		private var _frameRate:int = 30;
		private var _startTime:int = -3;
		private var _endTime:int = -3;
		private var _mode:String = FRAME_MODE;
		
		private var _thumbDown:Boolean;
		private var _sliderDown:Boolean;
		private var _sliderMove:Boolean;
		private var _mouseDownX:Number;
		
		private var _minValue:Number = 0;
		private var _maxValue:Number;
		private var _startValue:Number;
		private var _endValue:Number;
		private var _totalValue:Number;
		private var _step:Number;
		private var _unit:String = "";//单位
		private var _markStep:int;
		private var _totalMarkValue:Number;
		private var _markCnt:int;
		private var _markGap:Number;
		
		private var _propChanged:Boolean;
		
		private var _showThumb:Boolean = true;
		private var _showThumbChanged:Boolean = false;
		
		private var _timeController:TimeController;
		private var _timeControllerChanged:Boolean;
		private var _invalidateScale:Boolean = true;
		private var _visibleTimeRangeEvent:GanttSheetEvent;
		private var _visibleTimeRangeChanged:Boolean;
		
		public var tickUnit:TimeUnit;
		public var tickSteps:Number;
		
		public function TimeSlider_()
		{
			super();
			addEventListener(TimeScaleEvent.SCALE_CHANGE, this.scaleChangeHandler, false, EventPriority.DEFAULT_HANDLER);
		}
		
		private function scaleChangeHandler(event:TimeScaleEvent):void
		{
			/*if (!event.isDefaultPrevented())
			{
				this.configureAutomaticRows();
			}*/
			invalidateDisplayList();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			topBar = new Sprite();
			this.addChild(topBar);
			bottomBar = new Sprite();
			this.addChild(bottomBar);
			thumbLine = new Sprite();
			thumbLine.mouseEnabled = false;
			this.addChild(thumbLine);
			middleBar = new Sprite();
			this.addChild(middleBar);
			txtsContainer = new Sprite();
			txtsContainer.mouseEnabled = false;
			this.addChild(txtsContainer);
			thumb = new Button();
			thumb.width = 20;
			thumb.height = 20;
			thumb.styleName = "timeScaleThumb";
			thumb.useHandCursor = true;
			thumb.mouseEnabled = true;
			this.addChild(thumb);
			txts = new Vector.<TextField>();
			/*startValueTxt = new TransparentTextInput();
			startValueTxt.width = 60;
			startValueTxt.height = 18;
			this.addChild(startValueTxt);
			endValueTxt = new TransparentTextInput();
			endValueTxt.width = 60;
			endValueTxt.height = 18;
			this.addChild(endValueTxt);
			startValueTxt.addEventListener(FlexEvent.ENTER,onTxtEnter);
			endValueTxt.addEventListener(FlexEvent.ENTER,onTxtEnter);
	
			startValueTxt.addEventListener(MouseEvent.CLICK,onMouseClick);
			endValueTxt.addEventListener(MouseEvent.CLICK,onMouseClick);*/
			this.addEventListener(MouseEvent.CLICK,onMouseClick);
			thumb.addEventListener(MouseEvent.CLICK,onMouseClick);
			middleBar.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			thumb.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			
		}
		
		private function onTxtEnter(e:FlexEvent):void
		{
			/*stage.focus = stage;
			var startValue:Number = Number(startValueTxt.text);
			var endValue:Number = Number(endValueTxt.text);
			if(isNaN(startValue) || isNaN(endValue) || startValue >= endValue || startValue >= _maxValue || endValue <= _minValue)
			{
				setStartEndTxtValue();
				return;
			}
			
			if(startValue < _minValue)
				startValue = _minValue;
			if(endValue > _maxValue)
				endValue = _maxValue;
			
			_startValue = startValue;
			_endValue = endValue;
			
			setStartEndTxtValue();
			calcStartEndTime();
			checkTime();
			invalidateDisplayList();
			callLater(dispatchChangeEvent);*/
		}
		
		private function calcStartEndTime():void
		{
			if(_mode == FRAME_MODE)
			{
				_startTime = Math.round(_startValue * 1000 / _frameRate);
				_endTime = Math.round(_endValue * 1000 / _frameRate);
			}
			else
			{
				_startTime = _startValue * 1000;
				_endTime = _endValue * 1000;
			}
		}
		
		private function checkTime():void
		{
			if(_time < _startTime)
			{
				_time = _startTime;
				this.dispatchEvent(new Event(Event.CHANGE));
			}
			if(_time > _endTime)
			{
				_time = _endTime;
				this.dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		private function dispatchChangeEvent():void
		{
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function onMouseClick(e:MouseEvent):void
		{
			if(e.currentTarget == thumb /*|| e.currentTarget == startValueTxt || e.currentTarget == endValueTxt*/)
			{
				e.stopImmediatePropagation();
				return;
			}
			stage.focus = stage;//让输入文本失去焦点
			if(!_sliderMove)
				onStageMouseMove(e);
			_sliderMove = false;
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			if(e.currentTarget == thumb)
			{
				_thumbDown = true;
			}
			else
			{
				if(_startTime == 0 && _endTime == _duration)
					return;
				_sliderDown = true;
			}
			_mouseDownX = this.mouseX;
			stage.addEventListener(MouseEvent.MOUSE_MOVE,onStageMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP,onStageMouseUp);
		}
		
		private function onStageMouseMove(e:MouseEvent):void
		{
			var x:Number = this.mouseX;
			if(_sliderDown)
			{
				_sliderMove = true;
				var offX:Number = x - _mouseDownX;
				_startValue -= (offX * _totalValue)/unscaledWidth;
				if(_startValue < _minValue)
					_startValue = _minValue;
				_endValue = _startValue + _totalValue;
				if(_endValue > _maxValue)
				{
					_endValue = _maxValue;
					_startValue = _maxValue - _totalValue;
				}
				
				calcStartEndTime();
				setStartEndTxtValue();
				checkTime();
				
				invalidateDisplayList();
				_mouseDownX = x;
				e.updateAfterEvent();
				callLater(dispatchChangeEvent);
			}
			else
			{
				if(x < 0)
					x = 0;
				if(x > this.width)
					x = this.width;
				
				x = Math.round(x/(_markGap/_markStep)) * (_markGap/_markStep);
				thumb.x = x - thumb.width/2;
				thumbLine.x = x - 0.5;
				e.updateAfterEvent();
				_time = _startTime + (thumb.x + thumb.width/2)/unscaledWidth * (_endTime - _startTime);
				this.dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		private function setStartEndTxtValue():void
		{
			/*startValueTxt.text = String(Math.round(_startValue/_step) * _step);
			endValueTxt.text = String(Math.round(_endValue/_step) * _step);*/
		}
		
		private function onStageMouseUp(e:MouseEvent):void
		{
			_sliderDown = _thumbDown = false;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,onStageMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP,onStageMouseUp);
		}
		
		public function set duration(value:uint):void
		{
			_duration = value;
			startTime = 0;
			endTime = _duration;
			_propChanged = true;
			invalidateProperties();
		}
		
		public function get duration():uint
		{
			return _duration;
		}
		
		public function set time(value:int):void
		{
			_time = value;
			setThumbPos();
		}
		
		public function get frameRate():int
		{
			return _frameRate;
		}
		
		public function set frameRate(value:int):void
		{
			_frameRate = value;	
			_propChanged = true;
			invalidateProperties();
		}
		
		public function get mode():String
		{
			return _mode;
		}
		
		public function set mode(value:String):void
		{
			_mode = value;
			_propChanged = true;
			invalidateProperties();
		}
		
		public function get time():int
		{
			return _time;
		}
		
		public function get startTime():int
		{
			return _startTime;
		}
		
		public function set startTime(value:int):void
		{
			_startTime = value;
			if(_startTime < 0)
				_startTime = 0;
			_propChanged = true;
			invalidateProperties();
		}
		
		public function get endTime():int
		{
			return _endTime;
		}
		
		public function set endTime(value:int):void
		{
			_endTime = value;
			if(_endTime < 0)
				_endTime = _duration;
			_propChanged = true;
			invalidateProperties();
		}
		
		public function get markGap():Number
		{
			return _markGap;
		}
		
		public function get showThumb():Boolean
		{
			return _showThumb;
		}
		
		public function set showThumb(value:Boolean):void
		{
			if(_showThumb != value)
			{
				_showThumb = value;
				_showThumbChanged = true;
				invalidateProperties();
			}
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if(_propChanged)
			{
				_propChanged = false;
				if(_startTime == -1)
					_startTime = 0;
				if(_endTime == -1)
					_endTime = _duration;
				if(_endTime > _duration)
					_endTime = _duration;
				
				if(_mode == FRAME_MODE)
				{
					maxValue = Math.round(_duration * _frameRate / 1000);
					startValue = Math.round(_startTime * _frameRate / 1000);
					endValue = Math.round(_endTime * _frameRate / 1000);
					step = 1;
					_unit = "";
				}
				else
				{
					maxValue = Number(Number(_duration/1000).toFixed(2));
					startValue = Number(Number(_startTime/1000).toFixed(2));
					endValue =  Number(Number(_endTime/1000).toFixed(2));
					step = 0.01;
					_unit = "s";
				}
								
				/*startValueTxt.text = String(_startValue);
				endValueTxt.text = String(_endValue);*/
				callLater(dispatchChangeEvent);
			}
			
			if(_showThumbChanged)
			{
				_showThumbChanged = false;
				thumb.visible = thumbLine.visible = _showThumb;
			}
		}
		
		private function set minValue(value:Number):void
		{
			_minValue = value;
			invalidateDisplayList();
		}
		
		public function set maxValue(value:Number):void
		{
			_maxValue = value;
			invalidateDisplayList();
		}
		
		public function get maxValue():Number
		{
			return _maxValue;
		}
		
		private function set startValue(value:Number):void
		{
			_startValue = value;
			invalidateDisplayList();
		}
		
		private function set endValue(value:Number):void
		{
			_endValue = value;
			invalidateDisplayList();
		}
		
		private function set step(value:Number):void
		{
			_step = value;
			invalidateDisplayList();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			topBar.graphics.clear();
			topBar.graphics.lineStyle(1,0x5f5f5f);
			topBar.graphics.beginFill(0x5f5f5f,1);
			topBar.graphics.drawRect(0.5,0.5,unscaledWidth - 0.5,TOP_BAR_HEIGHT - 0.5);
			topBar.graphics.endFill();
			
			bottomBar.y = TOP_BAR_HEIGHT + MIDDLE_BAR_HEIGHT;
			bottomBar.graphics.clear();
			bottomBar.graphics.lineStyle(1,0x5f5f5f);
			bottomBar.graphics.beginFill(0x5f5f5f,1);
			bottomBar.graphics.drawRect(0.5,0.5,unscaledWidth - 0.5,BOTTOM_BAR_HEIGHT - 0.5);
			bottomBar.graphics.endFill();
			
			middleBar.y = TOP_BAR_HEIGHT;
			middleBar.graphics.clear();
			middleBar.graphics.lineStyle(1,0x262626);
			middleBar.graphics.beginFill(0x262626,1);
			middleBar.graphics.drawRect(0.5,0.5,unscaledWidth - 0.5,MIDDLE_BAR_HEIGHT - 0.5);
			middleBar.graphics.endFill();
			
			var markStartValue:Number;
			
			_totalValue = _endValue - _startValue;
			_totalMarkValue = _totalValue/_step;
			for(var i:int = 0; i < MARK_STEPS.length; i++)
			{
				_markStep = MARK_STEPS[i];
				_markCnt = Math.ceil(_totalMarkValue/_markStep);
				_markGap = unscaledWidth/_markCnt;
				if(_markGap >= MIN_GAP)
					break;
			}
			
			if(int(_startValue/_step) % _markStep != 0)
				markStartValue = int(_startValue/_step) + _markStep - int(_startValue/_step) % _markStep;
			else
				markStartValue = int(_startValue/_step);
			
			while(txtsContainer.numChildren)
			{
				txtsContainer.removeChildAt(0);
			}
			
			txtsContainer.y = TOP_BAR_HEIGHT;
			txtsContainer.graphics.clear();
			txtsContainer.graphics.lineStyle(0.5,0x939393);
			var txtIndex:int = 0;
			for(i = 0; i <= _markCnt; i++)
			{
				var markLabelValue:Number =  markStartValue + _markStep * i;
			
				if(markLabelValue % (_markStep * 5) == 0)
				{
					txtsContainer.graphics.moveTo(0.5 + i * _markGap,MIDDLE_BAR_HEIGHT - MARK_HEIGHT - 5);
					txtsContainer.graphics.lineTo(0.5 + i * _markGap,MIDDLE_BAR_HEIGHT + 1);
					
					var txt:TextField;
					if(txts.length == txtIndex)
					{
						txt = new TextField();
						txt.mouseEnabled = false; 
						txt.selectable = false;
						txt.height = 18;
						txt.defaultTextFormat = new TextFormat(null,11,0x939393);
						txts.push(txt);
					}
					else 
					{
						txt = txts[txtIndex];
					}
					txtIndex++;
					var markLabl:String = String(markLabelValue * _step);
					if(markLabl.length > 5)
						markLabl = (markLabelValue * _step).toFixed(2);
					txt.text = markLabl + _unit;
					if(i == 0)
						txt.x = 0;
					else if(i == _markCnt)
						txt.x = i * _markGap - txt.textWidth;
					else
						txt.x = i * _markGap - txt.textWidth/2;
					
					txtsContainer.addChild(txt);
				}
				else
				{
					txtsContainer.graphics.moveTo(0.5 + i * _markGap,MIDDLE_BAR_HEIGHT - MARK_HEIGHT);
					txtsContainer.graphics.lineTo(0.5 + i * _markGap,MIDDLE_BAR_HEIGHT + 1);
				}
			}
			
			thumbLine.graphics.lineStyle(1,0xff0000);
			thumbLine.graphics.moveTo(0.5,0.5);
			thumbLine.graphics.lineTo(0.5,unscaledHeight);
			
			setThumbPos();
			
			/*startValueTxt.x = (unscaledWidth - startValueTxt.width - endValueTxt.width - 20)/2;
			endValueTxt.x = startValueTxt.x + startValueTxt.width + 20;
			startValueTxt.y = endValueTxt.y = MIDDLE_BAR_HEIGHT + TOP_BAR_HEIGHT;*/
		}
		
		private function setThumbPos():void
		{
			thumb.y = MIDDLE_BAR_HEIGHT + TOP_BAR_HEIGHT - thumb.height;
			var timeLineX:Number = (_time - _startTime)/(_endTime - _startTime) * unscaledWidth;
			timeLineX = Math.round(timeLineX/(_markGap/_markStep)) * (_markGap/_markStep);
			thumb.x = timeLineX - thumb.width/2;
			thumbLine.x = timeLineX - 0.5;
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
		private function visibleTimeRangeChangeHandler(event:GanttSheetEvent):void
		{
			if (event.zoomFactorChanged || event.projectionChanged)
			{
				this._invalidateScale = true;
				this._visibleTimeRangeEvent = event;
			}
			if (event.projectionChanged)
			{
				//this.invalidateRowConfigurationPolicyCriteria();
			}
			this._visibleTimeRangeChanged = true;
			invalidateProperties();
		}
	}
}