package mokylin.gantt
{
    import mx.core.UIComponent;
    import mx.core.IDataRenderer;
    import mx.core.IFlexDisplayObject;
    import mx.core.IFlexModuleFactory;
    import mx.styles.CSSStyleDeclaration;
    import mokylin.utils.CSSUtil;
    import flash.geom.Rectangle;
    import mx.events.FlexEvent;
    import mx.styles.ISimpleStyleClient;
    import flash.display.DisplayObject;
    import mx.core.IInvalidating;
    import mx.core.IProgrammaticSkin;

    [Event(name="dataChange", type="mx.events.FlexEvent")]
    [Style(name="arrowSize", type="int", format="Number", inherit="no")]
    [Style(name="arrowAlpha", type="Number", inherit="no")]
    [Style(name="arrowColor", type="uint", format="Color", inherit="no")]
    [Style(name="arrowStroke", type="mx.graphics.IStroke", inherit="no")]
    [Style(name="arrowBorderThickness", type="Number", format="Length", inherit="no")]
    [Style(name="handleShape", type="String", enumeration="circle,square", inherit="no")]
    [Style(name="linkAlpha", type="Number", inherit="no")]
    [Style(name="linkColor", type="uint", format="Color", inherit="no")]
    [Style(name="linkStroke", type="mx.graphics.IStroke", inherit="no")]
    [Style(name="linkThickness", type="Number", format="Length", inherit="no")]
    [Style(name="skin", type="Class", inherit="no")]
    public class ConstraintItemRenderer extends UIComponent implements IDataRenderer 
    {

        protected var _skin:IFlexDisplayObject;
        private var _styleInitialized:Boolean = false;
        private var _data:Object;

        public function ConstraintItemRenderer()
        {
            this.mouseChildren = false;
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
            var styleDeclaration:CSSStyleDeclaration = CSSUtil.createSelector("ConstraintItemRenderer", "mokylin.gantt", styleManager);
            styleDeclaration.defaultFactory = function ():void
            {
                this.arrowSize = 5;
                this.arrowAlpha = 1;
                this.arrowColor = 0xFF0000;
                this.arrowBorderThickness = 1;
                this.linkAlpha = 1;
                this.linkColor = 0xFF;
                this.linkThickness = 1;
                this.handleShape = "circle";
                this.skin = ConstraintSkin;
            }
        }

        public function get constraintItem():ConstraintItem
        {
            return this._data as ConstraintItem;
        }

        public function get clipRectangle():Rectangle
        {
            if (!this.constraintItem)
            {
                return null;
            }
            return this.constraintItem.ganttSheet.constraintClipRectangle;
        }

        public function get info():ConstraintInfo
        {
            if (!this.constraintItem)
            {
                return null;
            }
            return this.constraintItem.ganttSheet.getConstraintInfo(this.constraintItem);
        }

        [Bindable("dataChange")]
        public function get data():Object
        {
            return this._data;
        }

        public function set data(value:Object):void
        {
            this._data = value;
            invalidateDisplayList();
            if (hasEventListener(FlexEvent.DATA_CHANGE))
            {
                dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
            }
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            if (!this.constraintItem)
            {
                return;
            }
            var owner:GanttSheet = this.constraintItem.ganttSheet;
            if (owner == null)
            {
                return;
            }
            var selected:Boolean = owner.isItemSelected(this.constraintItem.data);
            var highlighted:Boolean = owner.isItemHighlighted(this.constraintItem.data);
            this.updateSkin(selected, highlighted);
        }

        protected function updateSkin(selected:Boolean, highlighted:Boolean):void
        {
            var skinClass:Class;
            if (!this._skin)
            {
                skinClass = Class(getStyle("skin"));
                if (skinClass)
                {
                    this._skin = IFlexDisplayObject(new (skinClass)());
                    this._skin.name = "skin";
                    if (this._skin is ISimpleStyleClient)
                    {
                        ISimpleStyleClient(this._skin).styleName = this;
                    }
                    addChild(DisplayObject(this._skin));
                }
            }
            if (this._skin)
            {
                this._skin.name = this.getSkinName(selected, highlighted);
                if (this._skin is IInvalidating)
                {
                    IInvalidating(this._skin).invalidateDisplayList();
                }
                else if (this._skin is IProgrammaticSkin)
				{
                    IProgrammaticSkin(this._skin).validateDisplayList();
                }
            }
        }

        protected function getSkinName(selected:Boolean, highlighted:Boolean):String
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

        override public function styleChanged(styleProp:String):void
        {
            super.styleChanged(styleProp);
            if (!styleProp || styleProp == "styleName" || styleProp == "skin")
            {
                if (this._skin)
                {
                    removeChild(DisplayObject(this._skin));
                    this._skin = null;
                }
            }
        }
    }
}
