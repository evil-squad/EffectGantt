package mokylin.gantt
{
    import mx.core.IFactory;
    import mx.graphics.IStroke;
    import mx.graphics.SolidColorStroke;
    import flash.display.DisplayObject;
    import flash.geom.Rectangle;
    import mx.core.FlexShape;
    import flash.display.CapsStyle;
    import flash.display.Graphics;
    import mokylin.utils.GraphicsUtil;
    import flash.display.Shape;

    public class TimeGridBase extends GanttSheetGridBase 
    {

        private var _rendererContainer:GanttSheetGridRendererContainer;
        private var _dashStyle:Boolean;
        private var _dashStyleChanged:Boolean;
        private var _timeElementSkin:IFactory;
        private var _timeElementSkinChanged:Boolean;
        private var _stroke:IStroke;
        private var _strokeChanged:Boolean;

        public function TimeGridBase()
        {
            this._stroke = new SolidColorStroke(0xff0000);
            super();
        }

        public function get dashStyle():Boolean
        {
            return this._dashStyle;
        }

        public function set dashStyle(value:Boolean):void
        {
            if (this._dashStyle == value)
            {
                return;
            }
            this._dashStyle = value;
            this._dashStyleChanged = true;
            invalidateProperties();
        }

        public function get timeElementSkin():IFactory
        {
            return this._timeElementSkin;
        }

        public function set timeElementSkin(value:IFactory):void
        {
            if (this._timeElementSkin == value)
            {
                return;
            }
            this._timeElementSkin = value;
            this._timeElementSkinChanged = true;
            invalidateProperties();
        }

        public function get stroke():IStroke
        {
            return this._stroke;
        }

        public function set stroke(value:IStroke):void
        {
            if (this._stroke != value)
            {
                this._strokeChanged = true;
                this._stroke = value;
                invalidateProperties();
            }
        }

        override protected function commitProperties():void
        {
            super.commitProperties();
            if (this._dashStyleChanged)
            {
                this._dashStyleChanged = false;
                this.invalidateRendererContainer();
                invalidateDisplayList();
            }
            if (this._strokeChanged)
            {
                this._strokeChanged = false;
                invalidateDisplayList();
            }
            if (this._timeElementSkinChanged)
            {
                this._timeElementSkinChanged = false;
                this.invalidateRendererContainer();
                invalidateDisplayList();
            }
        }

        private function invalidateRendererContainer():void
        {
            if (this._rendererContainer != null)
            {
                removeChild(this._rendererContainer);
                this._rendererContainer = null;
            }
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            if (this._rendererContainer != null)
            {
                this._rendererContainer.startRendering();
            }
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            if (this._rendererContainer != null)
            {
                this._rendererContainer.stopRendering();
            }
        }

		public function getRendererWidth():Number
        {
            var d:DisplayObject;
            var r:Rectangle;
            if (this._timeElementSkin != null)
            {
                if (this._rendererContainer != null && this._rendererContainer.numChildren != 0)
                {
                    d = this._rendererContainer.getChildAt(0);
                    if (d != null)
                    {
                        r = d.getBounds(this._rendererContainer);
                        if (r != null && r.width != 0)
                        {
                            return r.width;
                        }
                    }
                }
                return 100;
            }
            if (this._stroke != null)
            {
                return this._stroke.weight;
            }
            return 1;
        }

        private function updateRenderer(r:Rectangle, x:Number, data:Object):DisplayObject
        {
            if (this._rendererContainer == null)
            {
                this._rendererContainer = new GanttSheetGridRendererContainer();
                this._rendererContainer.itemSkin = this.timeElementSkin;
                addChild(this._rendererContainer);
            }
            var renderer:DisplayObject = this._rendererContainer.useRenderer(data);
            if (this._timeElementSkin == null && Math.floor(renderer.height) != Math.floor(r.height))
            {
                this.updateDashedLine((renderer as FlexShape), r);
            }
            renderer.height = r.height;
            renderer.x = x;
            renderer.y = r.y;
            return renderer;
        }

        protected function drawLine(r:Rectangle, x:Number, data:Object):void
        {
            if (this._timeElementSkin != null || (this._dashStyle && this._stroke != null))
            {
                this.updateRenderer(r, x, data);
            }
            else
            {
                if (this._stroke != null)
                {
                    this._stroke.apply(graphics, r, null);
                    graphics.moveTo(x, r.y);
                    graphics.lineTo(x, r.bottom);
                }
            }
        }

        private function updateDashedLine(line:Shape, r:Rectangle):void
        {
            if (this._stroke == null)
            {
                return;
            }
            if (this._stroke is SolidColorStroke && SolidColorStroke(this._stroke).caps != CapsStyle.NONE)
            {
                SolidColorStroke(this._stroke).caps = CapsStyle.NONE;
            }
            var g:Graphics = line.graphics;
            g.clear();
            this._stroke.apply(g, r, null);
            GraphicsUtil.drawVerticalDottedLine(g, 0, 0, r.height, Math.max(1, this._stroke.weight));
        }
    }
}
