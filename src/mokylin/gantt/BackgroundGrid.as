package mokylin.gantt
{
    import mx.core.IFactory;
    import __AS3__.vec.Vector;
    import mx.graphics.IFill;
    import mx.graphics.IStroke;
    import mokylin.utils.DataUtil;
    import mx.graphics.SolidColor;
    import mx.graphics.Stroke;
    import flash.geom.Rectangle;
    import flash.display.DisplayObject;
    import flash.display.Graphics;

    public class BackgroundGrid extends GanttSheetGridBase 
    {

        private var _rendererContainer:GanttSheetGridRendererContainer;
        private var _showBackground:Boolean = true;
        private var _showBackgroundChanged:Boolean;
        private var _backgroundSkin:IFactory;
        private var _backgroundSkinChanged:Boolean;
        private var _alternatingItemColors:Vector.<IFill>;
        private var _alternatingItemColorsChanged:Boolean;
        private var _backgroundField:String;
        private var _backgroundFieldChanged:Boolean;
        private var _backgroundFunction:Function;
        private var _backgroundFunctionChanged:Boolean;
        private var _showHorizontalGridLines:Boolean;
        private var _showHorizontalGridLinesChanged:Boolean;
        private var _horizontalGridLines:IStroke;
        private var _horizontalGridLinesChanged:Boolean;

        public function BackgroundGrid()
        {
            drawPerRow = true;
        }

        public function get showBackground():Boolean
        {
            return this._showBackground;
        }

        public function set showBackground(value:Boolean):void
        {
            if (this._showBackground != value)
            {
                this._showBackgroundChanged = true;
                this._showBackground = value;
                invalidateProperties();
            }
        }

        public function get backgroundSkin():IFactory
        {
            return this._backgroundSkin;
        }

        public function set backgroundSkin(value:IFactory):void
        {
            if (this._backgroundSkin == value)
            {
                return;
            }
            this._backgroundSkin = value;
            this._backgroundSkinChanged = true;
            invalidateProperties();
        }

        public function get alternatingItemColors():Vector.<IFill>
        {
            return this._alternatingItemColors != null ? this._alternatingItemColors.slice() : null;
        }

        public function set alternatingItemColors(value:Vector.<IFill>):void
        {
            this._alternatingItemColors = value != null ? value.slice() : null;
            this._alternatingItemColorsChanged = true;
            invalidateProperties();
        }

        public function get backgroundField():String
        {
            return this._backgroundField;
        }

        public function set backgroundField(value:String):void
        {
            if (this._backgroundField == value)
            {
                return;
            }
            this._backgroundField = value;
            this._backgroundFieldChanged = true;
            invalidateProperties();
        }

        public function get backgroundFunction():Function
        {
            return this._backgroundFunction;
        }

        public function set backgroundFunction(value:Function):void
        {
            if (this._backgroundFunction == value)
            {
                return;
            }
            this._backgroundFunction = value;
            this._backgroundFunctionChanged = true;
            invalidateProperties();
        }

        public function get showHorizontalGridLines():Boolean
        {
            return this._showHorizontalGridLines;
        }

        public function set showHorizontalGridLines(value:Boolean):void
        {
            if (this._showHorizontalGridLines != value)
            {
                this._showHorizontalGridLinesChanged = true;
                this._showHorizontalGridLines = value;
                invalidateProperties();
            }
        }

        public function get horizontalGridLines():IStroke
        {
            return this._horizontalGridLines;
        }

        public function set horizontalGridLines(value:IStroke):void
        {
            if (this._horizontalGridLines != value)
            {
                this._horizontalGridLinesChanged = true;
                this._horizontalGridLines = value;
                invalidateProperties();
            }
        }

        override public function clone():GanttSheetGridBase
        {
            var grid:BackgroundGrid = new BackgroundGrid();
            grid.drawPerRow = drawPerRow;
            grid.drawToBottom = drawToBottom;
            if (this.alternatingItemColors != null)
            {
                grid.alternatingItemColors = this.alternatingItemColors.slice();
            }
            grid.backgroundField = this.backgroundField;
            grid.backgroundFunction = this.backgroundFunction;
            grid.showHorizontalGridLines = this.showHorizontalGridLines;
            grid.backgroundSkin = this.backgroundSkin;
            return grid;
        }

        override protected function commitProperties():void
        {
            super.commitProperties();
            if (this._showHorizontalGridLinesChanged)
            {
                this._showHorizontalGridLinesChanged = false;
                invalidateDisplayList();
            }
            if (this._backgroundFieldChanged || this._backgroundFunctionChanged || this._alternatingItemColorsChanged)
            {
                this._backgroundFieldChanged = this._backgroundFunctionChanged = this._alternatingItemColorsChanged = false;
                invalidateDisplayList();
            }
            if (this._backgroundSkinChanged)
            {
                this._backgroundSkinChanged = false;
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

        protected function getFill(rowIndex:int, data:Object):IFill
        {
            var styledColors:Array;
            if (this.backgroundFunction != null || this.backgroundField != null && data != null)
            {
                return DataUtil.getFieldValue(data, this.backgroundField, null, this.backgroundFunction) as IFill;
            }
            if (this._alternatingItemColors != null && this._alternatingItemColors.length != 0)
            {
                return rowIndex!=-1 ? this._alternatingItemColors[(rowIndex % this._alternatingItemColors.length)] : this._alternatingItemColors[0];
            }
            styledColors = getStyle("alternatingItemColors");
            if (styledColors != null && styledColors.length != 0)
            {
                return new SolidColor(rowIndex!=-1 ? styledColors[(rowIndex % styledColors.length)] : styledColors[0]);
            }
            return null;
        }

        protected function getStroke(rowIndex:int, data:Object):IStroke
        {
            var lineColor:uint;
            if (this._horizontalGridLines == null)
            {
                lineColor = getStyle("horizontalGridLineColor");
                return new Stroke(lineColor);
            }
            return this._horizontalGridLines;
        }

        override protected function updateGridDisplayList(r:Rectangle, rowIndex:int, data:Object):void
        {
            this.drawBackground(r, rowIndex, data);
        }

        private function updateRenderer(r:Rectangle, data:Object):DisplayObject
        {
            if (this._rendererContainer == null)
            {
                this._rendererContainer = new GanttSheetGridRendererContainer();
                this._rendererContainer.itemSkin = this.backgroundSkin;
                addChild(this._rendererContainer);
            }
            var renderer:DisplayObject = this._rendererContainer.useRenderer(data);
            renderer.x = r.x;
            renderer.y = r.y;
            renderer.height = r.height;
            renderer.width = r.width;
            return renderer;
        }

        protected function drawBackground(r:Rectangle, rowIndex:int, data:Object):void
        {
            var g:Graphics;
            var fill:IFill;
            var stroke:IStroke;
            if (this._backgroundSkin != null)
            {
                this.updateRenderer(r, data);
            }
            else
            {
                g = graphics;
                fill = this._showBackground ? this.getFill(rowIndex, data) : null;
                if (fill != null)
                {
                    if (fill != null)
                    {
                        fill.begin(g, r, null);
                    }
                    g.drawRect(r.x, r.y, r.width, r.height);
                    if (fill != null)
                    {
                        fill.end(g);
                    }
                }
                stroke = this._showHorizontalGridLines ? this.getStroke(rowIndex, data) : null;
                if (stroke != null)
                {
                    stroke.apply(g, r, null);
                    g.moveTo(r.x, r.bottom);
                    g.lineTo(r.right, r.bottom);
                }
            }
        }

        override protected function timeControllerChanged():void
        {
        }
    }
}
