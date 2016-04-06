package mokylin.gantt
{
    import mx.core.UIComponent;
    import mx.core.IDataRenderer;
    import mx.controls.listClasses.IListItemRenderer;
    import mx.core.IUITextField;
    import mx.core.IFlexDisplayObject;
    import flash.geom.Rectangle;
    import mx.core.IFlexModuleFactory;
    import mx.styles.CSSStyleDeclaration;
    import mokylin.utils.CSSUtil;
    import mx.events.FlexEvent;
    import mx.core.UITextField;
    import flash.display.DisplayObject;
    import mx.core.UITextFormat;
    import flash.text.TextLineMetrics;
    import mx.styles.ISimpleStyleClient;
    import mx.core.IInvalidating;
    import mx.core.IProgrammaticSkin;
    import mx.styles.StyleManager;

    [Event(name="dataChange", type="mx.events.FlexEvent")]
    [Style(name="backgroundColor", type="uint", format="Color", inherit="no")]
    [Style(name="barBottomMargin", type="Number", format="Percent", inherit="no")]
    [Style(name="barSkin", type="Class", inherit="no")]
    [Style(name="barTopMargin", type="Number", format="Percent", inherit="no")]
    [Style(name="borderColor", type="uint", format="Color", inherit="no")]
    [Style(name="borderRollOverColor", type="uint", format="Color", inherit="no")]
    [Style(name="borderSelectedColor", type="uint", format="Color", inherit="no")]
    [Style(name="borderSelectedRollOverColor", type="uint", format="Color", inherit="no")]
    [Style(name="borderThickness", type="Number", format="Length", inherit="no")]
    [Style(name="constraintHighlightSkin", type="Class", inherit="no")]
    [Style(name="constraintHighlightColor", type="uint", format="Color", inherit="no")]
    [Style(name="constraintHighlightThickness", type="Number", format="Length", inherit="no")]
    [Style(name="constraintHighlightLeftPadding", type="Number", format="Length", inherit="no")]
    [Style(name="constraintHighlightRightPadding", type="Number", format="Length", inherit="no")]
    [Style(name="constraintHighlightTopPadding", type="Number", format="Length", inherit="no")]
    [Style(name="constraintHighlightBottomPadding", type="Number", format="Length", inherit="no")]
    [Style(name="endSymbolBorderColor", type="uint", format="Color", inherit="yes")]
    [Style(name="endSymbolBorderThickness", type="Number", format="Length", inherit="yes")]
    [Style(name="endSymbolColor", type="uint", format="Color", inherit="yes")]
    [Style(name="endSymbolShape", type="String", inherit="yes", enumeration="none,upPentagon,downPentagon,diamond,upTriangle,downTriangle,upArrow,downArrow")]
    [Style(name="endSymbolSkin", type="Class", inherit="no")]
    [Style(name="horizontalGap", type="Number", format="Length", inherit="no")]
    [Style(name="rollOverColor", type="uint", format="Color", inherit="yes")]
    [Style(name="selectedColor", type="uint", format="Color", inherit="yes")]
    [Style(name="selectedRollOverColor", type="uint", format="Color", inherit="yes")]
    [Style(name="startSymbolBorderColor", type="uint", format="Color", inherit="yes")]
    [Style(name="startSymbolBorderThickness", type="Number", format="Length", inherit="yes")]
    [Style(name="startSymbolColor", type="uint", format="Color", inherit="yes")]
    [Style(name="startSymbolShape", type="String", inherit="yes", enumeration="none,upPentagon,downPentagon,diamond,upTriangle,downTriangle,upArrow,downArrow")]
    [Style(name="startSymbolSkin", type="Class", inherit="no")]
    [Style(name="textPosition", type="String", inherit="yes", enumeration="left,right,inside")]
    [Style(name="textRollOverColor", type="uint", format="Color", inherit="yes")]
    [Style(name="textSelectedColor", type="uint", format="Color", inherit="yes")]
    [Style(name="textSelectedRollOverColor", type="uint", format="Color", inherit="yes")]
    [Style(name="textStyleName", type="String", inherit="no")]
    [Style(name="useTruncate", type="Boolean", inherit="yes")]
    public class TaskItemRenderer extends UIComponent implements IDataRenderer, IListItemRenderer, IConstraintConnectionBounds 
    {
		/**
		 * 当字符超过显示区域时，会用这个字符替代 
		 */
        protected static const TRUNCATION_ELLIPSIS:String = "…";

        protected var _label:IUITextField;
        protected var _useTruncate:Boolean;
        private var _oldUnscaledWidth:Number;
        private var _oldUnscaledHeight:Number;
		
        protected var _barSkin:IFlexDisplayObject;
        protected var _constraintHighlightSkin:IFlexDisplayObject;
        protected var _startSkin:IFlexDisplayObject;
        protected var _endSkin:IFlexDisplayObject;
		
        protected var _childAdded:Boolean;
        protected var _labelChanged:Boolean;
        private var _previousLabelColor:uint = 0xFFFFFFFF;
        private var _styleInitialized:Boolean = false;
        private var _data:Object;
        private var _dataChanged:Boolean;
        protected var _connectionBounds:Rectangle;
        protected var _invalidConnectionBounds:Boolean = true;


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
            var styleDeclaration:CSSStyleDeclaration = CSSUtil.createSelector("TaskItemRenderer", "mokylin.gantt", styleManager);
            styleDeclaration.defaultFactory = function ():void
            {
                this.backgroundColor = 0XFF0000;
                this.barBottomMargin = 0;
                this.barSkin = TaskBarSkin;
                this.barTopMargin = 0;
                this.borderColor = 0xACA899;
                this.borderRollOverColor = 0xACA899;
                this.borderSelectedColor = 0xACA899;
                this.borderSelectedRollOverColor = 0xACA899;
                this.borderThickness = 1;
                this.constraintHighlightSkin = ConstraintHighlightSkin;
                this.constraintHighlightColor = 0;
                this.constraintHighlightLeftPadding = 2;
                this.constraintHighlightRightPadding = 2;
                this.constraintHighlightTopPadding = 2;
                this.constraintHighlightBottomPadding = 2;
                this.constraintHighlightThickness = 2;
				
                this.endSymbolBorderColor = 0xACA899;
                this.endSymbolBorderThickness = 1;
                this.endSymbolColor = 0XFFDB97;
                this.endSymbolShape = "none";
                this.endSymbolSkin = TaskSymbolSkin;
				
                this.horizontalGap = 15;
				
                this.startSymbolBorderColor = 0xACA899;
                this.startSymbolBorderThickness = 1;
                this.startSymbolColor = 0XFFDB97;
                this.startSymbolShape = "none";
                this.startSymbolSkin = TaskSymbolSkin;
				
                this.textPosition = "right";
                this.textRollOverColor = 0xFF0000;
                this.textSelectedColor = 0xFF0000;
                this.textSelectedRollOverColor = 0xFF0000;
                this.textStyleName = null;
                this.useTruncate = false;
                this.selectedColor = this.selectionColor;
                this.selectedRollOverColor = this.selectionColor;
            }
            var defaultLeafDeclaration:CSSStyleDeclaration = CSSUtil.createSelector(".leafTask", null, styleManager);
            defaultLeafDeclaration.defaultFactory = function ():void
            {
                this.backgroundColor = 0X7F7FFF;
                this.barBottomMargin = 0;
                this.barSkin = TaskBarSkin;
                this.barTopMargin = 0;
                this.borderColor = 0xFF;
                this.borderRollOverColor = 0xFF;
                this.borderSelectedColor = 0xFF;
                this.borderSelectedRollOverColor = 0xFF;
                this.borderThickness = 1;
                this.endSymbolBorderColor = 0xFF;
                this.endSymbolBorderThickness = 1;
                this.endSymbolColor = 0xFF;
                this.endSymbolShape = "none";
                this.endSymbolSkin = TaskSymbolSkin;
                this.horizontalGap = 15;
                this.startSymbolBorderColor = 0xFF;
                this.startSymbolBorderThickness = 1;
                this.startSymbolColor = 0xFF;
                this.startSymbolShape = "none";
                this.startSymbolSkin = TaskSymbolSkin;
                this.textPosition = "right";
            }
            var defaultMilestone:CSSStyleDeclaration = CSSUtil.createSelector(".milestoneTask", null, styleManager);
            defaultMilestone.defaultFactory = function ():void
            {
                this.backgroundColor = 0;
                this.barBottomMargin = 1;
                this.barTopMargin = 1;
                this.borderColor = 0;
                this.borderRollOverColor = 0;
                this.borderSelectedColor = 0;
                this.borderSelectedRollOverColor = 0xff0000;
                this.constraintHighlightLeftPadding = 0;
                this.constraintHighlightRightPadding = 0;
                this.constraintHighlightTopPadding = 0;
                this.constraintHighlightBottomPadding = 0;
                this.endSymbolShape = "none";
                this.startSymbolBorderColor = 0;
                this.startSymbolColor = 0;
                this.startSymbolShape = "diamond";
                this.textPosition = "right";
            }
            var defaultSummary:CSSStyleDeclaration = CSSUtil.createSelector(".summaryTask", null, styleManager);
            defaultSummary.defaultFactory = function ():void
            {
                this.backgroundColor = 0;
                this.barBottomMargin = 0.5;
                this.barTopMargin = 0;
                this.borderColor = 0;
                this.borderRollOverColor = 0;
                this.borderSelectedColor = 0;
                this.borderSelectedRollOverColor = 0;
                this.constraintHighlightLeftPadding = 0;
                this.constraintHighlightRightPadding = 0;
                this.constraintHighlightTopPadding = 0;
                this.constraintHighlightBottomPadding = 0;
                this.endSymbolBorderColor = 0;
                this.endSymbolColor = 0;
                this.endSymbolShape = "downArrow";
                this.startSymbolBorderColor = 0;
                this.startSymbolColor = 0;
                this.startSymbolShape = "downArrow";
                this.textPosition = "right";
            }
            var defaultText:CSSStyleDeclaration = CSSUtil.createSelector(".defaultText", null, styleManager);
            defaultText.defaultFactory = function ():void
            {
                this.fontSize = 10;
                this.fontWeight = "normal";
                this.textAlign = "right";
            }
        }

        [Bindable("dataChange")]
        public function get data():Object
        {
            return this._data;
        }

        public function set data(value:Object):void
        {
            this._dataChanged = true;
            this._data = value;
            invalidateProperties();
            if (hasEventListener(FlexEvent.DATA_CHANGE))
            {
                dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
            }
        }

        protected function get taskItem():TaskItem
        {
            return this._data as TaskItem;
        }
		/**
		 * 创建一个label 
		 * 
		 */
        override protected function createChildren():void
        {
            var style:Object;
            super.createChildren();
            if (!this._label)
            {
                this._label = createInFontContext(UITextField) as IUITextField;
                style = getStyle("textStyleName");
                this._label.styleName = style ? style : this;
                this._label.ignorePadding = false;
                this._label.includeInLayout = false;
                addChild(DisplayObject(this._label));
                this._childAdded = true;
            }
        }

        override protected function commitProperties():void
        {
            var newText:String;
            super.commitProperties();
            if (this._dataChanged)
            {
                this._dataChanged = false;
                if (this._barSkin is IDataRenderer)
                {
                    IDataRenderer(this._barSkin).data = this.data;
                }
                if (this._label)
                {
                    newText = this.taskItem ? this.taskItem.label : "";
                    this._labelChanged = newText != this._label.text;
                    this._label.text = newText;
                    invalidateDisplayList();
                }
            }
        }
		/**
		 * 设置该组件的默认大小------[计量] 测量值；测定值
		 * 
		 */
        override protected function measure():void
        {
            var format:UITextFormat;
            var lineMetrics:TextLineMetrics;
            var labelHeight:Number;
            var textPosition:String;
            if (this._label != null)
            {
                format = this._label.getUITextFormat();
                lineMetrics = format.measureText(this._label.text);
                labelHeight = lineMetrics.height;
                textPosition = getStyle("textPosition");
                if (textPosition == "inside")
                {
                    measuredMinHeight = labelHeight + (2 * getStyle("borderThickness"));
                    measuredMinHeight = measuredMinHeight + 1;
                }
                else
                {
                    measuredMinHeight = labelHeight;
                }
                measuredHeight = labelHeight + 4;
            }
            else
            {
                measuredMinHeight = 1;
                measuredHeight = 1;
            }
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            if (!this.taskItem)
            {
                return;
            }
            var owner:GanttSheet = this.taskItem.ganttSheet;
            if (owner == null)
            {
                return;
            }
            var sizeChanged:Boolean = unscaledWidth != this._oldUnscaledWidth || unscaledHeight != this._oldUnscaledHeight;
            this._oldUnscaledWidth = unscaledWidth;
            this._oldUnscaledHeight = unscaledHeight;
            this.invalidateConnectionBounds();
            var selected:Boolean = owner.isItemSelected(this.taskItem.data);
            var highlighted:Boolean = owner.isItemHighlighted(this.taskItem.data);
            this.updateBar(unscaledWidth, unscaledHeight, sizeChanged, selected, highlighted);
            this.updateStart(unscaledWidth, unscaledHeight, sizeChanged, selected, highlighted);
            this.updateEnd(unscaledWidth, unscaledHeight, sizeChanged, selected, highlighted);
            this.updateLabel(unscaledWidth, unscaledHeight, sizeChanged, selected, highlighted);
            var constraintHighlight:Boolean = owner.isItemConstraintTarget(this.taskItem.data) || owner.isItemConstraintSource(this.taskItem.data);
            if (constraintHighlight)
            {
                validateNow();
                this.updateConstraintHighlight(this.getRendererBounds());
            }
            else
            {
                this.updateConstraintHighlight(null);
            }
            if (this._childAdded)
            {
                this._childAdded = false;
                if (this._constraintHighlightSkin)
                {
                    setChildIndex(DisplayObject(this._constraintHighlightSkin), 0);
                }
                if (this._label)
                {
                    setChildIndex(DisplayObject(this._label), 0);
                }
                if (this._endSkin)
                {
                    setChildIndex(DisplayObject(this._endSkin), 0);
                }
                if (this._startSkin)
                {
                    setChildIndex(DisplayObject(this._startSkin), 0);
                }
                if (this._barSkin)
                {
                    setChildIndex(DisplayObject(this._barSkin), 0);
                }
            }
        }

        private function getRendererBounds():Rectangle
        {
            var startRect:Rectangle;
            var endRect:Rectangle;
            var rect:Rectangle;
            if (this._barSkin != null)
            {
                rect = this._barSkin.getBounds(this);
            }
            if (this._startSkin != null)
            {
                startRect = this._startSkin.getBounds(this);
                if (rect == null)
                {
                    rect = startRect;
                }
                else
                {
                    rect = rect.union(startRect);
                }
            }
            if (this._endSkin != null)
            {
                endRect = this._endSkin.getBounds(this);
                if (rect == null)
                {
                    rect = endRect;
                }
                else
                {
                    rect = rect.union(endRect);
                }
            }
            return rect;
        }

        protected function updateConstraintHighlight(rect:Rectangle):void
        {
            var skinClass:Class;
            var skinNeeded:Boolean = rect != null && rect.height > 5;
            if (!this._constraintHighlightSkin && skinNeeded)
            {
                skinClass = Class(getStyle("constraintHighlightSkin"));
                if (skinClass)
                {
                    this._constraintHighlightSkin = IFlexDisplayObject(new skinClass());
                    if (this._constraintHighlightSkin is ISimpleStyleClient)
                    {
                        ISimpleStyleClient(this._constraintHighlightSkin).styleName = this;
                    }
                    addChild(DisplayObject(this._constraintHighlightSkin));
                    this._childAdded = true;
                }
            }
            else
            {
                if (this._constraintHighlightSkin && !skinNeeded)
                {
                    removeChild(DisplayObject(this._constraintHighlightSkin));
                    this._constraintHighlightSkin = null;
                }
            }
            if (this._constraintHighlightSkin)
            {
                this._constraintHighlightSkin.move(rect.x, rect.y);
                this._constraintHighlightSkin.setActualSize(rect.width, rect.height);
                if (this._constraintHighlightSkin is IInvalidating)
                {
                    IInvalidating(this._constraintHighlightSkin).invalidateDisplayList();
                }
                else
                {
                    if (this._constraintHighlightSkin is IProgrammaticSkin)
                    {
                        IProgrammaticSkin(this._constraintHighlightSkin).validateDisplayList();
                    }
                }
                if (this._constraintHighlightSkin is IDataRenderer)
                {
                    IDataRenderer(this._constraintHighlightSkin).data = this.data;
                }
            }
        }

        protected function updateLabel(unscaledWidth:Number, unscaledHeight:Number, sizeChanged:Boolean, selected:Boolean, highlighted:Boolean):void
        {
            var labelX:Number;
            var labelY:Number;
            var labelWidth:Number;
            var labelHeight:Number;
            var labelColor:uint;
            var borderThickness:Number;
            var format:UITextFormat;
            var lineMetrics:TextLineMetrics;
            var horizontalGap:Number;
            var b:Rectangle;
            if (this._label == null)
            {
                return;
            }
            var textPosition:String = getStyle("textPosition");
            if (textPosition == "inside")
            {
                borderThickness = getStyle("borderThickness");
                labelX = borderThickness;
                labelY = borderThickness;
                labelWidth = (unscaledWidth - (2 * borderThickness));
                labelHeight = (unscaledHeight - (2 * borderThickness));
                if (labelWidth > 0 && labelHeight > 0)
                {
                    this._label.move(labelX, labelY);
                    this._label.setActualSize(labelWidth, labelHeight);
                    this._label.visible = true;
                }
                else
                {
                    this._label.visible = false;
                }
                if (sizeChanged && this._useTruncate)
                {
                    this._label.text = this.taskItem ? this.taskItem.label : "";
                    this._labelChanged = true;
                }
                if (this._useTruncate && this._labelChanged)
                {
                    this._labelChanged = false;
                    this._label.truncateToFit(TRUNCATION_ELLIPSIS);
                }
            }
            else
            {
                format = this._label.getUITextFormat();
                lineMetrics = format.measureText(this._label.text);
                horizontalGap = getStyle("horizontalGap");
                labelWidth = lineMetrics.width + 5;
                labelHeight = lineMetrics.height + 4;
                b = this.connectionBounds;
                labelX = textPosition == "right" ? (b.x - x) + b.width + horizontalGap : (b.x - x) - labelWidth - horizontalGap;
                labelY = (unscaledHeight - labelHeight) / 2;
                this._label.move(labelX, labelY);
                this._label.setActualSize(labelWidth, labelHeight);
                this._label.visible = true;
            }
            if (selected && highlighted)
            {
                labelColor = getStyle("textSelectedRollOverColor");
            }
            else if (selected)
			{
				labelColor = getStyle("textSelectedColor");
			}
			else if (highlighted)
			{
				labelColor = getStyle("textRollOverColor");
			}
			else
			{
				labelColor = StyleManager.NOT_A_COLOR;
			}
            if (this._previousLabelColor != labelColor)
            {
                this._label.setColor(labelColor);
            }
            this._previousLabelColor = labelColor;
        }

        protected function updateBar(unscaledWidth:Number, unscaledHeight:Number, sizeChanged:Boolean, selected:Boolean, highlighted:Boolean):void
        {
            var skinClass:Class;
            var topMargin:Number = getStyle("barTopMargin");
            var bottomMargin:Number = getStyle("barBottomMargin");
            var skinY:Number = (unscaledHeight * topMargin);
            var skinHeight:Number = (unscaledHeight * ((1 - bottomMargin) - topMargin));
            var skinNeeded:Boolean = (skinHeight > 0);
            if (skinNeeded && skinHeight < 1)
            {
                skinHeight = 1;
            }
            if (!this._barSkin && skinNeeded)
            {
                skinClass = Class(getStyle("barSkin"));
                if (skinClass)
                {
                    this._barSkin = IFlexDisplayObject(new skinClass());
                    if (this._barSkin is ISimpleStyleClient)
                    {
                        ISimpleStyleClient(this._barSkin).styleName = this;
                    }
                    addChild(DisplayObject(this._barSkin));
                    this._childAdded = true;
                }
            }
            else
            {
                if (this._barSkin && !skinNeeded)
                {
                    removeChild(DisplayObject(this._barSkin));
                    this._barSkin = null;
                }
            }
            if (this._barSkin)
            {
                this._barSkin.name = this.getBarSkinName(selected, highlighted);
                this._barSkin.move(0, skinY);
                this._barSkin.setActualSize(unscaledWidth, skinHeight);
                if (this._barSkin is IDataRenderer)
                {
                    IDataRenderer(this._barSkin).data = this.data;
                }
                if (this._barSkin is IInvalidating)
                {
                    IInvalidating(this._barSkin).invalidateDisplayList();
                }
                else
                {
                    if (this._barSkin is IProgrammaticSkin)
                    {
                        IProgrammaticSkin(this._barSkin).validateDisplayList();
                    }
                }
            }
        }

        protected function updateStart(unscaledWidth:Number, unscaledHeight:Number, sizeChanged:Boolean, selected:Boolean, highlighted:Boolean):void
        {
            var skinClass:Class;
            var skinWidth:Number;
            var skinHeight:Number;
            var symbolShape:String = getStyle("startSymbolShape");
            var skinNeeded:Boolean = symbolShape && symbolShape.length != 0 && symbolShape != "none";
            if (!this._startSkin && skinNeeded)
            {
                skinClass = Class(getStyle("startSymbolSkin"));
                if (skinClass)
                {
                    this._startSkin = IFlexDisplayObject(new skinClass());
                    if (this._startSkin is ISimpleStyleClient)
                    {
                        ISimpleStyleClient(this._startSkin).styleName = this;
                    }
                    addChild(DisplayObject(this._startSkin));
                    this._childAdded = true;
                }
            }
            else
            {
                if (this._startSkin && !skinNeeded)
                {
                    removeChild(DisplayObject(this._startSkin));
                    this._startSkin = null;
                }
            }
            if (this._startSkin)
            {
                this._startSkin.name = this.getStartSkinName(selected, highlighted);
                skinWidth = unscaledHeight;
                skinHeight = unscaledHeight;
                this._startSkin.move((-skinWidth / 2), 0);
                this._startSkin.setActualSize(skinWidth, skinHeight);
                if (this._startSkin is IDataRenderer)
                {
                    IDataRenderer(this._startSkin).data = this.data;
                }
                if (this._startSkin is IInvalidating)
                {
                    IInvalidating(this._startSkin).invalidateDisplayList();
                }
                else
                {
                    if (this._startSkin is IProgrammaticSkin)
                    {
                        IProgrammaticSkin(this._startSkin).validateDisplayList();
                    }
                }
            }
        }

        protected function updateEnd(unscaledWidth:Number, unscaledHeight:Number, sizeChanged:Boolean, selected:Boolean, highlighted:Boolean):void
        {
            var skinClass:Class;
            var skinWidth:Number;
            var skinHeight:Number;
            var symbolShape:String = getStyle("endSymbolShape");
            var skinNeeded:Boolean = symbolShape && symbolShape.length != 0 && symbolShape != "none";
            if (!this._endSkin && skinNeeded)
            {
                skinClass = Class(getStyle("endSymbolSkin"));
                if (skinClass)
                {
                    this._endSkin = IFlexDisplayObject(new skinClass());
                    if (this._endSkin is ISimpleStyleClient)
                    {
                        ISimpleStyleClient(this._endSkin).styleName = this;
                    }
                    addChild(DisplayObject(this._endSkin));
                    this._childAdded = true;
                }
            }
            else
            {
                if (this._endSkin && !skinNeeded)
                {
                    removeChild(DisplayObject(this._endSkin));
                    this._endSkin = null;
                }
            }
            if (this._endSkin)
            {
                this._endSkin.name = this.getEndSkinName(selected, highlighted);
                skinWidth = unscaledHeight;
                skinHeight = unscaledHeight;
                this._endSkin.move(unscaledWidth - (skinWidth / 2), 0);
                this._endSkin.setActualSize(skinWidth, skinHeight);
                if (this._endSkin is IDataRenderer)
                {
                    IDataRenderer(this._endSkin).data = this.data;
                }
                if (this._endSkin is IInvalidating)
                {
                    IInvalidating(this._endSkin).invalidateDisplayList();
                }
                else
                {
                    if (this._endSkin is IProgrammaticSkin)
                    {
                        IProgrammaticSkin(this._endSkin).validateDisplayList();
                    }
                }
            }
        }

        protected function getBarSkinName(selected:Boolean, highlighted:Boolean):String
        {
            if (selected && highlighted)
            {
                return "selectedOverSkin";
            }
            if (selected)
            {
                return "selectedSkin";
            }
            if (highlighted)
            {
                return "overSkin";
            }
            return "skin";
        }

        protected function getStartSkinName(selected:Boolean, highlighted:Boolean):String
        {
            if (selected && highlighted)
            {
                return "startSelectedOverSkin";
            }
            if (selected)
            {
                return "startSelectedSkin";
            }
            if (highlighted)
            {
                return "startOverSkin";
            }
            return "startSkin";
        }

        protected function getEndSkinName(selected:Boolean, highlighted:Boolean):String
        {
            if (selected && highlighted)
            {
                return "endSelectedOverSkin";
            }
            if (selected)
            {
                return "endSelectedSkin";
            }
            if (highlighted)
            {
                return "endOverSkin";
            }
            return "endSkin";
        }

        override public function styleChanged(styleProp:String):void
        {
            super.styleChanged(styleProp);
            if (!styleProp || styleProp == "useTruncate")
            {
                this._useTruncate = (getStyle("useTruncate") as Boolean);
            }
            if (!styleProp || styleProp == "styleName" || styleProp == "textStyleName")
            {
                if (this._label)
                {
                    this._label.styleName = getStyle("textStyleName");
                }
            }
            if (!styleProp || styleProp == "styleName" || styleProp == "startSymbolSkin")
            {
                if (this._startSkin)
                {
                    removeChild(DisplayObject(this._startSkin));
                    this._startSkin = null;
                }
            }
            if (!styleProp || styleProp == "styleName" || styleProp == "endSymbolSkin")
            {
                if (this._endSkin)
                {
                    removeChild(DisplayObject(this._endSkin));
                    this._endSkin = null;
                }
            }
            if (!styleProp || styleProp == "styleName" || styleProp == "barSkin")
            {
                if (this._barSkin)
                {
                    removeChild(DisplayObject(this._barSkin));
                    this._barSkin = null;
                }
            }
        }

        protected function invalidateConnectionBounds():void
        {
            this._invalidConnectionBounds = true;
        }

        public function get connectionBounds():Rectangle
        {
            if (this._invalidConnectionBounds)
            {
                this._invalidConnectionBounds = false;
                this.measureConnectionBounds();
            }
            return this._connectionBounds;
        }

        public function measureConnectionBounds():void
        {
            var x0:Number = 0;
            var x1:Number = 0;
            var y0:Number = 0;
            var y1:Number = 0;
            var topMargin:Number = getStyle("barTopMargin");
            var bottomMargin:Number = getStyle("barBottomMargin");
            var skinY:Number = (unscaledHeight * topMargin);
            var skinHeight:Number = unscaledHeight * (1 - bottomMargin - topMargin);
            var skinNeeded:Boolean = skinHeight > 0;
            if (skinNeeded)
            {
                x0 = 0;
                x1 = unscaledWidth;
                y0 = skinY;
                y1 = skinHeight;
            }
            var symbolShape:String = getStyle("startSymbolShape");
            skinNeeded = symbolShape && symbolShape.length != 0 && symbolShape != "none";
            var symbolSize:Number = unscaledHeight;
            if (skinNeeded)
            {
                x0 = Math.min(x0, (-symbolSize / 2));
                x1 = Math.max(x1, (symbolSize / 2));
                y0 = Math.min(y0, 0);
                y1 = Math.max(y1, unscaledHeight);
            }
            symbolShape = getStyle("endSymbolShape");
            skinNeeded = symbolShape && symbolShape.length != 0 && symbolShape != "none";
            if (skinNeeded)
            {
                x0 = Math.min(x0, (unscaledWidth - (symbolSize / 2)));
                x1 = Math.max(x1, (unscaledWidth + (symbolSize / 2)));
                y0 = Math.min(y0, 0);
                y1 = Math.max(y1, unscaledHeight);
            }
            if (!this._connectionBounds)
            {
                this._connectionBounds = new Rectangle();
            }
            this._connectionBounds.x = this.x + x0;
            this._connectionBounds.y = this.y + y0;
            this._connectionBounds.width = x1 - x0 + 1;
            this._connectionBounds.height = y1 - y0;
        }
    }
}
