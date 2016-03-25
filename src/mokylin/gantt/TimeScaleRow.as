﻿package mokylin.gantt
{
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.core.ClassFactory;
	import mx.core.FlexShape;
	import mx.core.IFactory;
	import mx.core.IFlexDisplayObject;
	import mx.core.IFlexModuleFactory;
	import mx.core.IInvalidating;
	import mx.core.IProgrammaticSkin;
	import mx.core.IUITextField;
	import mx.core.UIComponent;
	import mx.core.UITextField;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	import mx.managers.ILayoutManagerClient;
	import mx.managers.LayoutManager;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.ISimpleStyleClient;
	
	import __AS3__.vec.Vector;
	
	import flashx.textLayout.formats.VerticalAlign;
	
	import mokylin.core.elixir_internal;
	import mokylin.gantt.supportClasses.RendererLayer;
	import mokylin.utils.CSSUtil;
	import mokylin.utils.TimeComputer;
	import mokylin.utils.TimeIterator;
	import mokylin.utils.TimeSampler;
	import mokylin.utils.TimeUnit;
	
	[Style(name="paddingBottom", type="Number", format="Length", inherit="no")]
	[Style(name="paddingTop", type="Number", format="Length", inherit="no")]
	[Style(name="rollOverAlpha", type="Number", inherit="yes")]
	[Style(name="rollOverColor", type="uint", format="Color", inherit="yes")]
	[Style(name="labelStyleName", type="String", inherit="no")]
	[Style(name="labelPosition", type="String", inherit="no", enum="afterTick,centeredInCell,centeredOnTick")]
	[Style(name="verticalAlign", type="String", inherit="no", enum="top,middle,bottom,justify")]
	[Style(name="labelTop", type="Number", format="Length", inherit="no")]
	[Style(name="labelBottom", type="Number", format="Length", inherit="no")]
	[Style(name="subTickAlpha", type="Number", inherit="no")]
	[Style(name="subTickColor", type="uint", format="Color", inherit="no")]
	[Style(name="subTickTop", type="Number", format="Length", inherit="no")]
	[Style(name="subTickBottom", type="Number", format="Length", inherit="no")]
	[Style(name="subTickSkin", type="Class", inherit="no")]
	[Style(name="subTickThickness", type="Number", inherit="no")]
	[Style(name="textFieldClass", type="Class", inherit="no")]
	[Style(name="tickAlpha", type="Number", inherit="no")]
	[Style(name="tickColor", type="uint", format="Color", inherit="no")]
	[Style(name="tickTop", type="Number", format="Length", inherit="no")]
	[Style(name="tickBottom", type="Number", format="Length", inherit="no")]
	[Style(name="tickSkin", type="Class", inherit="no")]
	[Style(name="tickThickness", type="Number", inherit="no")]
	public class TimeScaleRow extends UIComponent 
	{
		
		private static const DEFAULT_PADDING_BOTTOM:Number = 2;
		private static const DEFAULT_PADDING_TOP:Number = 2;
		private static const DEFAULT_LABEL_POSITION:String = TimeScaleLabelPosition.AFTER_TICK;
		private static const _stringForHeight:String = "1s";
		
		private var _unusedTickItemPool:Vector.<TimeScaleTickItem>;
		private var _tickItems:Vector.<TimeScaleTickItem>;
		private var _subTickItems:Vector.<TimeScaleTickItem>;
		private var _cellItems:Vector.<TimeScaleCellItem>;
		private var _tickTimes:Vector.<Number>;
		private var _subTickTimes:Vector.<Number>;
		private var _maskShape:FlexShape;
		private var _cellLayer:RendererLayer;
		private var _tickLayer:RendererLayer;
		private var _subTickLayer:RendererLayer;
		private var _labelLayer:RendererLayer;
//		private var _timeFormatter:CLDRDateFormatter;
		private var _labelPosition:String;
		private var _paddingTop:Number;
		private var _paddingBottom:Number;
		private var _visibleTimeRangeChanged:Boolean;
		private var _tickSkinChanged:Boolean;
		private var _subTickSkinChanged:Boolean;
		private var _rowConfigurationPolicyCriteriaChanged:Boolean;
		private var _styleInitialized:Boolean = false;
		private var _autoConfigure:Boolean = true;
		private var _timeComputer:TimeComputer;
		private var _timeComputerChanged:Boolean;
		private var _cellRenderer:IFactory;
		private var _cellRendererChanged:Boolean;
		private var _formatString:String = "dd";
		private var _formatStringChanged:Boolean;
		private var _labelFunction:Function;
		private var _labelFunctionChanged:Boolean;
		private var _labelRenderer:IFactory;
		private var _labelRendererChanged:Boolean;
		private var _labelRendererField:String = "text";
		private var _labelRendererFieldChanged:Boolean;
	
		private var _showCells:Boolean = true;
		private var _showLabels:Boolean = true;
		private var _showLabelsChanged:Boolean;
		private var _showSubTicks:Boolean = false;
		private var _showSubTicksChanged:Boolean;
		private var _showTicks:Boolean = true;
		private var _showTicksChanged:Boolean;
		/*private var _startOfYear:Number;
		private var _startOfYearChanged:Boolean;*/
		private var _subTickUnit:TimeUnit;
		private var _subTickUnitChanged:Boolean;
		private var _subTickSteps:Number = 1;
		private var _subTickStepsChanged:Boolean;
		private var _tickItemFactory:IFactory;
		private var _timeController:TimeController;
		private var _tickUnit:TimeUnit;
		private var _tickUnitChanged:Boolean;
		private var _tickSteps:Number = 1;
		private var _tickStepsChanged:Boolean;
		private var _measuringTickItem:TimeScaleTickItem;
		private var _measuringLabelRenderer:IFlexDisplayObject;
		private var _measuringTickSkin:IFlexDisplayObject;
		
		public function TimeScaleRow()
		{
			this._unusedTickItemPool = new Vector.<TimeScaleTickItem>();
			this._tickItems = new Vector.<TimeScaleTickItem>();
			this._subTickItems = new Vector.<TimeScaleTickItem>();
			this._cellItems = new Vector.<TimeScaleCellItem>();
			this._tickTimes = new Vector.<Number>();
			this._subTickTimes = new Vector.<Number>();
//			this._timeFormatter = new CLDRDateFormatter();
			super();
//			this._timeFormatter.formatString = this._formatString;
//			this._timeFormatter.startOfYear = this.startOfYear;
			
			this._cellLayer = new RendererLayer(this, "cells", this);
			this._cellLayer.rendererFactory = null;
			this._cellLayer.addFirst = true;
			
			this._subTickLayer = new RendererLayer(this, "subticks", this);
			this._subTickLayer.rendererFactory = new ClassFactory(TimeScaleSubTickSkin);
			this._subTickLayer.addAfter = "cells";
			
			this._tickLayer = new RendererLayer(this, "ticks", this);
			this._tickLayer.rendererFactory = new ClassFactory(TimeScaleTickSkin);
			this._tickLayer.addAfter = "subticks";
			
			this._labelLayer = new RendererLayer(this, "labels", this);
			this._labelLayer.rendererFactory = this.labelRenderer;
			this._labelLayer.addAfter = "ticks";
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
			var styleDeclaration:CSSStyleDeclaration = CSSUtil.createSelector("TimeScaleRow", "mokylin.gantt", styleManager);
			styleDeclaration.defaultFactory = function ():void
			{
				this.labelBottom = 0;
				this.labelPosition = DEFAULT_LABEL_POSITION;
				this.labelStyleName = "timelineFont";
				this.labelTop = 0;
				this.paddingBottom = DEFAULT_PADDING_BOTTOM;
				this.paddingTop = DEFAULT_PADDING_TOP;
				this.rollOverAlpha = 1;
				this.subTickAlpha = 1;
				this.subTickBottom = 0;
				this.subTickColor = 0xC9C9C9;
				this.subTickSkin = TimeScaleSubTickSkin;
				this.subTickThickness = 1;
				this.subTickTop = 10;
				this.tickAlpha = 1;
				this.tickBottom = 0;
				this.tickColor = 0xC9C9C9;
				this.tickSkin = TimeScaleTickSkin;
				this.tickThickness = 1;
				this.tickTop = 0;
			}
		}
		
		[Bindable("autoConfigureChanged")]
		[Inspectable(category="General", defaultValue="true")]
		public function get autoConfigure():Boolean
		{
			return this._autoConfigure;
		}
		
		public function set autoConfigure(value:Boolean):void
		{
			if (value == this._autoConfigure)
			{
				return;
			}
			this._autoConfigure = value;
			if (this.timeScale)
			{
				this.timeScale.invalidateRowConfigurationPolicy();
			}
			dispatchEvent(new FlexEvent("autoConfigureChanged"));
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
			if (value == this._timeComputer)
			{
				return;
			}
			if (!value)
			{
				value = new TimeComputer();
			}
			if (this._timeComputer != null)
			{
				this._timeComputer.removeEventListener(Event.CHANGE, this.calendarChangeHandler);
			}
			this._timeComputer = value;
			if (this._timeComputer != null)
			{
				this._timeComputer.addEventListener(Event.CHANGE, this.calendarChangeHandler, false, 0, true);
			}
			this._timeComputerChanged = true;
			invalidateProperties();
		}
		
		[Bindable("cellRendererChanged")]
		[Inspectable(category="General")]
		public function get cellRenderer():IFactory
		{
			return this._cellRenderer;
		}
		
		public function set cellRenderer(value:IFactory):void
		{
			if (this._cellRenderer == value)
			{
				return;
			}
			this._cellRenderer = value;
			this._cellRendererChanged = true;
			invalidateProperties();
			dispatchEvent(new FlexEvent("cellRendererChanged"));
		}
		
		[Bindable("formatStringChanged")]
		[Inspectable(category="General", defaultValue="dd")]
		public function get formatString():String
		{
			return this._formatString;
		}
		
		public function set formatString(value:String):void
		{
			if (this._formatString == value)
			{
				return;
			}
			this._formatString = value;
			this._formatStringChanged = true;
			invalidateProperties();
			dispatchEvent(new FlexEvent("formatStringChanged"));
		}
		
		[Bindable("labelFunctionChanged")]
		[Inspectable(category="General")]
		public function get labelFunction():Function
		{
			return this._labelFunction;
		}
		
		public function set labelFunction(value:Function):void
		{
			if (this._labelFunction == value)
			{
				return;
			}
			this._labelFunction = value;
			this._labelFunctionChanged = true;
			invalidateProperties();
			dispatchEvent(new FlexEvent("labelFunctionChanged"));
		}
		
		[Bindable("labelRendererChanged")]
		[Inspectable(category="General")]
		public function get labelRenderer():IFactory
		{
			if (!this._labelRenderer)
			{
				this._labelRenderer = new TimeScaleLabelFactory(this);
			}
			return this._labelRenderer;
		}
		
		public function set labelRenderer(value:IFactory):void
		{
			if (this._labelRenderer == value)
			{
				return;
			}
			this._labelRenderer = value;
			this._labelRendererChanged = true;
			invalidateProperties();
			dispatchEvent(new FlexEvent("labelRendererChanged"));
		}
		
		public function createDefaultLabel():Object
		{
			var label:IUITextField = IUITextField(createInFontContext(UITextField));
			label.ignorePadding = false;
			label.mouseWheelEnabled = false;
			label.mouseEnabled = false;
			label.includeInLayout = false;
			return label;
		}
		
		[Bindable("labelRendererFieldChanged")]
		[Inspectable(category="General", defaultValue="text")]
		public function get labelRendererField():String
		{
			return this._labelRendererField;
		}
		
		public function set labelRendererField(value:String):void
		{
			if (this._labelRendererField == value)
			{
				return;
			}
			this._labelRendererField = value;
			this._labelRendererFieldChanged = true;
			invalidateProperties();
			dispatchEvent(new FlexEvent("labelRendererFieldChanged"));
		}
		
		[Bindable("showCellsChanged")]
		[Inspectable(category="General", defaultValue="false")]
		public function get showCells():Boolean
		{
			return this._showCells;
		}
		
		public function set showCells(value:Boolean):void
		{
			if (this._showCells == value)
			{
				return;
			}
			this._showCells = value;
			invalidateDisplayList();
			dispatchEvent(new FlexEvent("showCellsChanged"));
		}
		
		[Bindable("showLabelsChanged")]
		[Inspectable(category="General", defaultValue="true")]
		public function get showLabels():Boolean
		{
			return this._showLabels;
		}
		
		public function set showLabels(value:Boolean):void
		{
			if (this._showLabels == value)
			{
				return;
			}
			this._showLabels = value;
			this._showLabelsChanged = true;
			invalidateProperties();
			dispatchEvent(new FlexEvent("showLabelsChanged"));
		}
		
		[Bindable("showSubTicksChanged")]
		[Inspectable(category="General", defaultValue="false")]
		public function get showSubTicks():Boolean
		{
			return this._showSubTicks;
		}
		
		public function set showSubTicks(value:Boolean):void
		{
			if (this._showSubTicks == value)
			{
				return;
			}
			this._showSubTicks = value;
			this._showSubTicksChanged = true;
			invalidateProperties();
			dispatchEvent(new FlexEvent("showSubTicksChanged"));
		}
		
		[Bindable("showTicksChanged")]
		[Inspectable(category="General", defaultValue="true")]
		public function get showTicks():Boolean
		{
			return this._showTicks;
		}
		
		public function set showTicks(value:Boolean):void
		{
			if (this._showTicks == value)
			{
				return;
			}
			this._showTicks = value;
			this._showTicksChanged = true;
			invalidateProperties();
			dispatchEvent(new FlexEvent("showTicksChanged"));
		}
		
		/*[Bindable("startOfYearChanged")]
		[Inspectable(category="General", defaultValue="null")]
		public function get startOfYear():Number
		{
			return this._startOfYear;
		}
		
		public function set startOfYear(value:Number):void
		{
			this._startOfYear = value;
			this._startOfYearChanged = true;
			invalidateProperties();
			dispatchEvent(new FlexEvent("startOfYearChanged"));
		}*/
		
		[Bindable(event="propertyChange")]
		[Inspectable(category="General")]
		public function get subTickUnit():TimeUnit
		{
			return this._subTickUnit;
		}
		public function set subTickUnit(value:TimeUnit):void
		{
			var oldValue:Object = this.subTickUnit;
			if (oldValue !== value)
			{
				this._subTickUnitChanged = true;
				this._subTickUnit = value;
				invalidateProperties();
//				dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "subTickUnit", oldValue, value));
				if (this.hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
				{
					this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "subTickUnit", oldValue, value));
				}
			}
		}
		
		[Bindable(event="propertyChange")]
		[Inspectable(category="General", defaultValue="1")]
		public function get subTickSteps():Number
		{
			return this._subTickSteps;
		}
		public function set subTickSteps(value:Number):void
		{
			if (value < 1)
			{
				value = 1;
			}
			else
			{
				value = Math.ceil(value);
			}
			var oldValue:Object = this.subTickSteps;
			if (oldValue !== value)
			{
				this._subTickStepsChanged = true;
				this._subTickSteps = value;
				invalidateProperties();
//				dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "subTickSteps", oldValue, value));
				if (this.hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
				{
					this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "subTickSteps", oldValue, value));
				}
			}
		}
		
		private function get tickItemFactory():IFactory
		{
			if (!this._tickItemFactory)
			{
				this._tickItemFactory = new ClassFactory(TimeScaleTickItem);
			}
			return this._tickItemFactory;
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
			invalidateDisplayList();
		}
		
		public function get timeScale():TimeScale
		{
			return owner as TimeScale;
		}
		
		[Bindable(event="propertyChange")]
		[Inspectable(category="General")]
		public function get tickUnit():TimeUnit
		{
			return this._tickUnit;
		}
		public function set tickUnit(value:TimeUnit):void
		{
			var oldValue:Object = this.tickUnit;
			if (oldValue !== value)
			{
				this._tickUnitChanged = true;
				this._tickUnit = value;
				invalidateProperties();
//				this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "tickUnit", oldValue, value));
				if (this.hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
				{
					this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "tickUnit", oldValue, value));
				}
			}
		}
		
		[Bindable(event="propertyChange")]
		[Inspectable(category="General", defaultValue="1")]
		public function get tickSteps():Number
		{
			return this._tickSteps;
		}
		
		public function set tickSteps(value:Number):void
		{
			if (value < 1)
			{
				value = 1;
			}
			else
			{
				value = Math.ceil(value);
			}
			var oldValue:Object = this.tickSteps;
			if (oldValue !== value)
			{
				this._tickStepsChanged = true;
				this._tickSteps = value;
				invalidateProperties();
//				dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "tickSteps", oldValue, value));
				if (this.hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
				{
					this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "tickSteps", oldValue, value));
				}
			}
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
			var ticksUpdateNeeded:Boolean;
			var subTicksUpdateNeeded:Boolean;
			var labelsUpdateNeeded:Boolean;
			var subTickSkinClass:Class;
			var tickSkinClass:Class;
			super.commitProperties();
			if (this._timeComputerChanged)
			{
				this._timeComputerChanged = false;
				ticksUpdateNeeded = true;
				subTicksUpdateNeeded = true;
				labelsUpdateNeeded = true;
//				this._timeFormatter.timeComputer = this.timeComputer;
				invalidateDisplayList();
			}
			if (this._cellRendererChanged)
			{
				this._cellRendererChanged = false;
				this._cellLayer.rendererFactory = this.cellRenderer;
				invalidateDisplayList();
			}
			if (this._subTickSkinChanged)
			{
				this._subTickSkinChanged = false;
				subTickSkinClass = getStyle("subTickSkin");
				if (subTickSkinClass == null)
				{
					subTickSkinClass = TimeScaleSubTickSkin;
				}
				this._subTickLayer.rendererFactory = new ClassFactory(subTickSkinClass);
				invalidateDisplayList();
			}
			if (this._tickSkinChanged)
			{
				this._tickSkinChanged = false;
				tickSkinClass = getStyle("tickSkin");
				if (tickSkinClass == null)
				{
					tickSkinClass = TimeScaleTickSkin;
				}
				this._tickLayer.rendererFactory = new ClassFactory(tickSkinClass);
				invalidateDisplayList();
				this._rowConfigurationPolicyCriteriaChanged = true;
			}
			if (this._labelRendererChanged)
			{
				this._labelRendererChanged = false;
				this._labelLayer.rendererFactory = this.labelRenderer;
				invalidateDisplayList();
				this._rowConfigurationPolicyCriteriaChanged = true;
			}
			if (this._labelRendererFieldChanged)
			{
				this._labelRendererFieldChanged = false;
				this._labelLayer.clear();
				invalidateDisplayList();
				this._rowConfigurationPolicyCriteriaChanged = true;
			}
			if (this._subTickUnitChanged || this._subTickStepsChanged)
			{
				this._subTickUnitChanged = false;
				this._subTickStepsChanged = false;
				subTicksUpdateNeeded = true;
			}
			if (this._tickUnitChanged || this._tickStepsChanged)
			{
				this._tickUnitChanged = false;
				this._tickStepsChanged = false;
				ticksUpdateNeeded = true;
			}
			if (this._formatStringChanged)
			{
				this._formatStringChanged = false;
				labelsUpdateNeeded = true;
			}
			
			/*if (this._startOfYearChanged)
			{
				this._startOfYearChanged = false;
				labelsUpdateNeeded = true;
			}*/
			if (this._labelFunctionChanged)
			{
				this._labelFunctionChanged = false;
				labelsUpdateNeeded = true;
			}
			if (this._visibleTimeRangeChanged)
			{
				_visibleTimeRangeChanged = false;
				ticksUpdateNeeded = true;
				subTicksUpdateNeeded = true;
			}
			if (this._showSubTicksChanged)
			{
				this._showSubTicksChanged = false;
				subTicksUpdateNeeded = true;
			}
			if (this._showTicksChanged)
			{
				this._showTicksChanged = false;
				ticksUpdateNeeded = true;
			}
			if (this._showLabelsChanged)
			{
				this._showLabelsChanged = false;
				ticksUpdateNeeded = true;
				labelsUpdateNeeded = true;
			}
			if (ticksUpdateNeeded && this.timeController && this.timeController.configured)
			{
				ticksUpdateNeeded = false;
				labelsUpdateNeeded = true;
				if ((this._showTicks || this._showLabels) && this._tickUnit != null && !isNaN(this._tickSteps))
				{
					this._tickTimes = this.getTickTimes(this._tickUnit, this._tickSteps);
				}
				else
				{
					this._tickTimes = new Vector.<Number>();
				}
			}
			if (labelsUpdateNeeded)
			{
				labelsUpdateNeeded = false;
				this.recycleTickItems(this._tickItems);
				this._tickItems = this.createTickItemsForTicks(this._tickTimes);
				this._cellItems = this.createCellItems(this._tickTimes);
				invalidateDisplayList();
			}
			if (subTicksUpdateNeeded && this.timeController && this.timeController.configured)
			{
				subTicksUpdateNeeded = false;
				if (this._showSubTicks && this._subTickUnit != null && !isNaN(this._subTickSteps))
				{
					this._subTickTimes = this.getTickTimes(this._subTickUnit, this._subTickSteps);
				}
				else
				{
					this._subTickTimes = new Vector.<Number>();
				}
				this.recycleTickItems(this._subTickItems);
				this._subTickItems = this.createTickItemsForSubTicks(this._subTickTimes);
				invalidateDisplayList();
			}
			if (this._rowConfigurationPolicyCriteriaChanged && this.timeScale != null)
			{
				this._rowConfigurationPolicyCriteriaChanged = false;
				this.timeScale.invalidateRowConfigurationPolicyCriteria();
			}
		}
		
		override protected function measure():void
		{
			super.measure();
			var measuredLabelHeight:Number = this.getMeasuredLabelHeight(_stringForHeight);
			var height:Number = this._paddingTop + this._paddingBottom + measuredLabelHeight + getStyle("labelTop") + getStyle("labelBottom");
			measuredHeight = height;
			measuredMinHeight = height;
			measuredMinWidth = 0;
		}
		
		override protected function createChildren():void
		{
			var g:Graphics;
			super.createChildren();
			if (!this._maskShape)
			{
				this._maskShape = new FlexShape();
				this._maskShape.name = "mask";
				this._maskShape.visible = false;
				g = this._maskShape.graphics;
				g.beginFill(0xFFFFFF);
				g.drawRect(0, 0, 10, 10);
				g.endFill();
				addChild(this._maskShape);
				mask = this._maskShape;
			}
			this._cellLayer.createRendererContainer();
			this._subTickLayer.createRendererContainer();
			this._tickLayer.createRendererContainer();
			this._labelLayer.createRendererContainer();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			graphics.clear();
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			graphics.endFill();
			if (this._maskShape)
			{
				this._maskShape.x = 0;
				this._maskShape.y = 0;
				this._maskShape.width = unscaledWidth;
				this._maskShape.height = unscaledHeight;
			}
			if (!this._timeController || !this._timeController.configured)
			{
				return;
			}
			var cellsVisible:Boolean = this._showCells && this._cellLayer.rendererFactory != null;
			if (this._cellLayer.rendererContainer != null)
			{
				this._cellLayer.rendererContainer.setActualSize(unscaledWidth, unscaledHeight);
				this._cellLayer.rendererContainer.visible = cellsVisible;
			}
			if (cellsVisible)
			{
				this.drawCells(this._cellItems);
			}
			var subTicksVisible:Boolean = this._showSubTicks && this._subTickLayer.rendererFactory != null;
			if (this._subTickLayer.rendererContainer != null)
			{
				this._subTickLayer.rendererContainer.setActualSize(unscaledWidth, unscaledHeight);
				this._subTickLayer.rendererContainer.visible = subTicksVisible;
			}
			if (subTicksVisible)
			{
				this.drawSubTicks(this._subTickItems);
			}
			var ticksVisible:Boolean = this._showTicks && this._tickLayer.rendererFactory != null;
			if (this._tickLayer.rendererContainer != null)
			{
				this._tickLayer.rendererContainer.setActualSize(unscaledWidth, unscaledHeight);
				this._tickLayer.rendererContainer.visible = ticksVisible;
			}
			if (ticksVisible)
			{
				this.drawTicks(this._tickItems);
			}
			var labelsVisible:Boolean = this._showLabels && this._labelLayer.rendererFactory != null;
			if (this._labelLayer.rendererContainer != null)
			{
				this._labelLayer.rendererContainer.setActualSize(unscaledWidth, unscaledHeight);
				this._labelLayer.rendererContainer.visible = labelsVisible;
			}
			if (labelsVisible)
			{
				this.drawLabels(this._tickItems);
			}
		}
		
		private function getTickTimes(unit:TimeUnit, steps:Number):Vector.<Number>
		{
			var value:Number;
			var times:Vector.<Number> = new Vector.<Number>();
			var iterator:TimeIterator = this.createTimeIterator(this.timeComputer, this.timeController.startTime, this.timeController.endTime, unit, steps);
			while (iterator.hasNext())
			{
				value = iterator.next() as Number;
				times.push(value);
			}
			return times;
		}
		
		private function createTimeIterator(timeComputer:TimeComputer, start:Number, end:Number, unit:TimeUnit, steps:Number):TimeIterator
		{
			var sampler:TimeSampler;
			sampler = new TimeSampler(timeComputer, start, end, unit, steps);
			sampler.extendRange = true;
			return sampler.createIterator();
		}
		
		private function valueToLabel(value:Number, unit:TimeUnit, steps:Number):String
		{
			if (this._labelFunction != null)
			{
				return this._labelFunction(value, unit, steps);
			}
			
			var units:String = "s";
			var label:String = value/1000 + units;
			return label;
		}
		
		private function drawCells(items:Vector.<TimeScaleCellItem>):void
		{
			var item:TimeScaleCellItem;
			var skin:IFlexDisplayObject;
			var startX:Number;
			var endX:Number;
			var x:Number;
			var y:Number;
			var width:Number;
			var height:Number;
			this._cellLayer.recycleAllRenderers();
			for each (item in items)
			{
				skin = this._cellLayer.createRenderer(item);
				startX = this.timeController.getCoordinate(item.start);
				endX = this.timeController.getCoordinate(item.end);
				x = startX;
				y = 0;
				width = endX - startX + 1;
				height = unscaledHeight;
				skin.move(x, y);
				skin.setActualSize(width, height);
				this.invalidateDisplayObjectDisplayList(skin);
			}
		}
		
		private function drawSubTicks(items:Vector.<TimeScaleTickItem>):void
		{
			var item:TimeScaleTickItem;
			var skin:IFlexDisplayObject;
			var measuredSkinWidth:Number;
			var x:Number;
			var y:Number;
			var height:Number;
			var width:Number;
			this._subTickLayer.recycleAllRenderers();
			var contentY:Number = this._paddingTop;
			var contentHeight:Number = unscaledHeight - this._paddingTop - this._paddingBottom;
			var subtickTop:Number = getStyle("subTickTop");
			var subtickBottom:Number = getStyle("subTickBottom");
			for each (item in items)
			{
				skin = this._subTickLayer.createRenderer(item);
				measuredSkinWidth = skin.measuredWidth;
				x = this.timeController.getCoordinate(item.value) - (measuredSkinWidth - 1) / 2;
				y = contentY + subtickTop;
				height = contentHeight - subtickTop - subtickBottom;
				width = measuredSkinWidth;
				skin.move(x, y);
				skin.setActualSize(width, height);
				this.invalidateDisplayObjectDisplayList(skin);
			}
		}
		
		private function drawTicks(items:Vector.<TimeScaleTickItem>):void
		{
			var item:TimeScaleTickItem;
			var skin:IFlexDisplayObject;
			var measuredSkinWidth:Number;
			var x:Number;
			var y:Number;
			var height:Number;
			var width:Number;
			this._tickLayer.recycleAllRenderers();
			var contentY:Number = this._paddingTop;
			var contentHeight:Number = unscaledHeight - this._paddingTop - this._paddingBottom;
			var tickTop:Number = getStyle("tickTop");
			var tickBottom:Number = getStyle("tickBottom");
			for each (item in items)
			{
				skin = this._tickLayer.createRenderer(item);
				measuredSkinWidth = skin.measuredWidth;
				x = this.timeController.getCoordinate(item.value) - (measuredSkinWidth - 1) / 2;
				y = contentY + tickTop;
				height = contentHeight - tickTop - tickBottom;
				width = measuredSkinWidth;
				skin.move(x, y);
				skin.setActualSize(width, height);
				item.elixir_internal::labelOffset = (width / 2) + 1;
				this.invalidateDisplayObjectDisplayList(skin);
			}
		}
		
		private function drawLabels(tickItems:Vector.<TimeScaleTickItem>):void
		{
			this._labelLayer.recycleAllRenderers();
			var labelStyleName:String = getStyle("labelStyleName");
			var contentY:Number = this._paddingTop;
			var contentHeight:Number = (unscaledHeight - this._paddingTop) - this._paddingBottom;
			this.drawLabelsWithStandardAlignement(tickItems, labelStyleName, contentY, contentHeight);
		}
		
		private function drawLabelsWithStandardAlignement(tickItems:Vector.<TimeScaleTickItem>, labelStyleName:String, contentY:Number, contentHeight:Number):void
		{
			var tickItem:TimeScaleTickItem;
			var nextTickItem:TimeScaleTickItem;
			var tickX:Number;
			var nextTickX:Number;
			var cellWidth:Number;
			var renderer:IFlexDisplayObject;
			var measuredRendererHeight:Number;
			var measuredRendererWidth:Number;
			var labelOffset:Number;
			var x:Number;
			var y:Number;
			var height:Number;
			var width:Number;
			var labelTop:Number = getStyle("labelTop");
			var labelBottom:Number = getStyle("labelBottom");
			var verticalAlign:String = getStyle("verticalAlign");
			if (verticalAlign == VerticalAlign.JUSTIFY)
			{
				verticalAlign = VerticalAlign.MIDDLE;
			}
			var tickCount:uint = tickItems.length;
			var i:uint;
			while (i < (tickCount - 1))
			{
				tickItem = tickItems[i];
				nextTickItem = tickItems[(i + 1)];
				tickX = this.timeController.getCoordinate(tickItem.value);
				nextTickX = this.timeController.getCoordinate(nextTickItem.value);
				cellWidth = (nextTickX - tickX);
				renderer = this.createLabelRenderer(tickItem, labelStyleName);
				if ((renderer is IInvalidating))
				{
					IInvalidating(renderer).validateNow();
				}
				measuredRendererHeight = renderer.measuredHeight;
				measuredRendererWidth = renderer.measuredWidth;
				labelOffset = tickItem.elixir_internal::labelOffset;
				if (isNaN(labelOffset))
				{
					labelOffset = 0;
				}
				height = contentHeight - labelTop - labelBottom;
				width = measuredRendererWidth;
				if (this._labelPosition == TimeScaleLabelPosition.AFTER_TICK)
				{
					if (cellWidth >= (measuredRendererWidth + labelOffset))
					{
						x = tickX + labelOffset;
						if (x < 0 && nextTickX > 0)
						{
							if (nextTickX - measuredRendererWidth - labelOffset > 0)
							{
								x = labelOffset;
							}
							else
							{
								x = nextTickX - measuredRendererWidth - labelOffset;
							}
						}
					}
					else
					{
						x = tickX + labelOffset;
						width = Math.max(0, cellWidth - labelOffset);
					}
				}
				else if (this._labelPosition == TimeScaleLabelPosition.CENTERED_IN_CELL)
				{
					x = tickX + (cellWidth - measuredRendererWidth) / 2;
					width = Math.min(cellWidth, measuredRendererWidth);
				}
				else if (this._labelPosition == TimeScaleLabelPosition.CENTERED_ON_TICK)
				{
					x = tickX - measuredRendererWidth / 2;
					width = Math.min(cellWidth, measuredRendererWidth);
				}
				if (verticalAlign == VerticalAlign.BOTTOM)
				{
					y = contentY + labelTop + height - measuredRendererHeight;
				}
				else if (verticalAlign == VerticalAlign.TOP)
				{
					y = contentY + labelTop;
				}
				else if (verticalAlign == VerticalAlign.MIDDLE)
				{
					y = contentY + labelTop + (height - measuredRendererHeight) / 2;
				}
				renderer.move(x, y);
				renderer.setActualSize(width, height);
				this.invalidateDisplayObjectDisplayList(renderer);
				i++;
			}
		}
		
		private function createLabelRenderer(item:TimeScaleTickItem, styleName:String):IFlexDisplayObject
		{
			var renderer:IFlexDisplayObject = this._labelLayer.createRenderer(item);
			if (renderer is ISimpleStyleClient)
			{
				ISimpleStyleClient(renderer).styleName = styleName;
			}
			if (Object(renderer).hasOwnProperty(this._labelRendererField))
			{
				renderer[this._labelRendererField] = item.label;
			}
			else
			{
				if (renderer is IUITextField)
				{
					IUITextField(renderer).text = item.label;
				}
			}
			return renderer;
		}
		
		override public function styleChanged(styleProp:String):void
		{
			var allStyles:Boolean = styleProp == null || styleProp == "styleName";
			super.styleChanged(styleProp);
			if (allStyles || styleProp == "labelPosition")
			{
				if (styleManager.isValidStyleValue("labelPosition"))
				{
					this._labelPosition = getStyle("labelPosition");
				}
				else
				{
					this._labelPosition = DEFAULT_LABEL_POSITION;
				}
				invalidateDisplayList();
			}
			if (allStyles || styleProp == "paddingTop")
			{
				if (styleManager.isValidStyleValue("paddingTop"))
				{
					this._paddingTop = getStyle("paddingTop");
				}
				else
				{
					this._paddingTop = DEFAULT_PADDING_TOP;
				}
				invalidateSize();
				invalidateDisplayList();
			}
			if (allStyles || styleProp == "paddingBottom")
			{
				if (styleManager.isValidStyleValue("paddingBottom"))
				{
					this._paddingBottom = getStyle("paddingBottom");
				}
				else
				{
					this._paddingBottom = DEFAULT_PADDING_BOTTOM;
				}
				invalidateSize();
				invalidateDisplayList();
			}
			if (allStyles || styleProp == "subTickSkin")
			{
				this._subTickSkinChanged = true;
				invalidateProperties();
			}
			if (allStyles || styleProp == "tickSkin")
			{
				this._tickSkinChanged = true;
				invalidateProperties();
			}
			if (allStyles || styleProp == "labelStyleName")
			{
				if (this.timeScale)
				{
					this.timeScale.invalidateRowConfigurationPolicyCriteria();
				}
				invalidateSize();
				invalidateDisplayList();
			}
		}
		
		private function visibleTimeRangeChangeHandler(event:GanttSheetEvent):void
		{
			this._visibleTimeRangeChanged = true;
			invalidateProperties();
		}
		
		private function calendarChangeHandler(event:Event):void
		{
			this._timeComputerChanged = true;
			invalidateProperties();
		}
		
		private function createTickItemsForSubTicks(times:Vector.<Number>):Vector.<TimeScaleTickItem>
		{
			var item:TimeScaleTickItem;
			var items:Vector.<TimeScaleTickItem> = this.createTickItems(times);
			for each (item in items)
			{
				item.isSubTick = true;
			}
			return items;
		}
		
		private function createTickItemsForTicks(times:Vector.<Number>):Vector.<TimeScaleTickItem>
		{
			var item:TimeScaleTickItem;
			var items:Vector.<TimeScaleTickItem> = this.createTickItems(times);
			for each (item in items)
			{
				item.label = this.valueToLabel(item.value, this.tickUnit, this.tickSteps);
			}
			return items;
		}
		
		private function createTickItems(times:Vector.<Number>):Vector.<TimeScaleTickItem>
		{
			var time:Number;
			var item:TimeScaleTickItem;
			var items:Vector.<TimeScaleTickItem> = new Vector.<TimeScaleTickItem>();
			for each (time in times)
			{
				item = this.createTickItem();
				item.value = time;
				items.push(item);
			}
			return items;
		}
		
		private function createTickItem():TimeScaleTickItem
		{
			var item:TimeScaleTickItem;
			if (this._unusedTickItemPool.length > 0)
			{
				item = this._unusedTickItemPool.pop();
				item.isSubTick = false;
				item.label = null;
				item.value = 0;
			}
			else
			{
				item = this.tickItemFactory.newInstance();
			}
			return item;
		}
		
		private function recycleTickItem(item:TimeScaleTickItem):void
		{
			this._unusedTickItemPool.push(item);
		}
		
		private function recycleTickItems(items:Vector.<TimeScaleTickItem>):void
		{
			this._unusedTickItemPool = this._unusedTickItemPool.concat(items);
		}
		
		private function createCellItems(times:Vector.<Number>):Vector.<TimeScaleCellItem>
		{
			var item:TimeScaleCellItem;
			var items:Vector.<TimeScaleCellItem> = new Vector.<TimeScaleCellItem>();
			var cellCount:int = (times.length - 1);
			var i:int;
			while (i < cellCount)
			{
				item = new TimeScaleCellItem();
				item.start = times[i];
				item.end = times[(i + 1)];
				items.push(item);
				i++;
			}
			return items;
		}
		
		private function getMeasuringTickItem():TimeScaleTickItem
		{
			if (!this._measuringTickItem)
			{
				this._measuringTickItem = new TimeScaleTickItem();
				this._measuringTickItem.value = 0;
			}
			return this._measuringTickItem;
		}
		
		private function getMeasuringLabelRenderer(item:TimeScaleTickItem):IFlexDisplayObject
		{
			var labelStyleName:String;
			if (!this._measuringLabelRenderer)
			{
				labelStyleName = getStyle("labelStyleName");
				this._measuringLabelRenderer = this.createLabelRenderer(item, labelStyleName);
				if (this._measuringLabelRenderer)
				{
					this._measuringLabelRenderer.visible = false;
				}
			}
			return this._measuringLabelRenderer;
		}
		
		private function recycleMeasuringLabelRenderer():void
		{
			if (!this._measuringLabelRenderer)
			{
				return;
			}
			this._labelLayer.recycleRenderer(this._measuringLabelRenderer);
			this._measuringLabelRenderer = null;
		}
		
		private function getMeasuringTickSkin(item:TimeScaleTickItem):IFlexDisplayObject
		{
			if (!this._measuringTickSkin)
			{
				this._measuringTickSkin = this._tickLayer.createRenderer(item);
				this._measuringTickSkin.visible = false;
			}
			return this._measuringTickSkin;
		}
		
		private function recycleMeasuringTickSkin():void
		{
			if (!this._measuringTickSkin)
			{
				return;
			}
			this._tickLayer.recycleRenderer(this._measuringTickSkin);
			this._measuringTickSkin = null;
		}
		
		public function getMeasuredTickSkinWidth():Number
		{
			var width:Number;
			var tickItem:TimeScaleTickItem = this.getMeasuringTickItem();
			var skin:IFlexDisplayObject = this.getMeasuringTickSkin(tickItem);
			if (skin)
			{
				this.validateDisplayObjectNow(skin);
				width = skin.measuredWidth;
				this.recycleMeasuringTickSkin();
				return width;
			}
			return NaN;
		}
		
		public function getMeasuredLabelWidth(text:String):Number
		{
			var width:Number;
			var measuringItem:TimeScaleTickItem = this.getMeasuringTickItem();
			measuringItem.label = text;
			var renderer:IFlexDisplayObject = this.getMeasuringLabelRenderer(measuringItem);
			if (renderer)
			{
				this.validateDisplayObjectNow(renderer);
				width = renderer.measuredWidth;
				this.recycleMeasuringLabelRenderer();
				return width;
			}
			return NaN;
		}
		
		private function getMeasuredLabelHeight(text:String):Number
		{
			var height:Number;
			var measuringItem:TimeScaleTickItem = this.getMeasuringTickItem();
			measuringItem.label = text;
			var renderer:IFlexDisplayObject = this.getMeasuringLabelRenderer(measuringItem);
			if (renderer)
			{
				this.validateDisplayObjectNow(renderer);
				height = renderer.measuredHeight;
				this.recycleMeasuringLabelRenderer();
				return height;
			}
			return NaN;
		}
		
		public function getMeasuredLabelWidthForDate(value:Number, unit:TimeUnit, steps:Number):Number
		{
			var width:Number;
			var measuringItem:TimeScaleTickItem = this.getMeasuringTickItem();
			measuringItem.value = value;
			measuringItem.label = this.valueToLabel(value, unit, steps);
			var renderer:IFlexDisplayObject = this.getMeasuringLabelRenderer(measuringItem);
			if (renderer)
			{
				if (renderer is IInvalidating)
				{
					IInvalidating(renderer).invalidateSize();
				}
				if (renderer is ILayoutManagerClient)
				{
					LayoutManager.getInstance().validateClient(ILayoutManagerClient(renderer), true);
				}
				width = renderer.measuredWidth;
				this.recycleMeasuringLabelRenderer();
				return width;
			}
			return NaN;
		}
		
		private function invalidateDisplayObjectDisplayList(value:Object):void
		{
			if (value is IInvalidating)
			{
				IInvalidating(value).invalidateDisplayList();
			}
			else if (value is IProgrammaticSkin)
			{
				IProgrammaticSkin(value).validateDisplayList();
			}
		}
		
		private function validateDisplayObjectNow(value:Object):void
		{
			if (value is IInvalidating)
			{
				IInvalidating(value).validateNow();
			}
			else if (value is IProgrammaticSkin)
			{
				IProgrammaticSkin(value).validateNow();
			}
		}
		/**
		 * 根据当前行的位置，得到一个日期范围
		 * @param p
		 * @return 
		 * 
		 */
		public function getCellRangeAt(p:Point):Vector.<Number>
		{
			if (this._tickUnit == null || isNaN(this._tickSteps))
			{
				return null;
			}
			var start:Number = this.timeComputer.floor(this.timeController.getTime(p.x), this._tickUnit, this._tickSteps);
			var end:Number = this.timeComputer.addUnits(start, this._tickUnit, this._tickSteps);
			end = this.timeComputer.floor(end, this._tickUnit, this._tickSteps);
			var range:Vector.<Number> = new Vector.<Number>(2, true);
			range[0] = start;
			range[1] = end;
			return range;
		}
	}
}
