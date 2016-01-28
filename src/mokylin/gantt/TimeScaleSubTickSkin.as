package mokylin.gantt
{
    import mx.skins.ProgrammaticSkin;
    import flash.display.Graphics;
    import flash.display.LineScaleMode;
    import flash.display.CapsStyle;

    public class TimeScaleSubTickSkin extends ProgrammaticSkin 
    {

        public static const DEFAULT_THICKNESS:Number = 1;

        private var _measuredWidth:Number;

        public function TimeScaleSubTickSkin()
        {
            this._measuredWidth = DEFAULT_THICKNESS;
        }

        override public function get measuredWidth():Number
        {
            return this._measuredWidth;
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            var g:Graphics = graphics;
            g.clear();
            var thickness:Number = getStyle("subTickThickness");
            var alpha:Number = getStyle("subTickAlpha");
            var color:uint = getStyle("subTickColor");
            if (thickness < 0)
            {
                return;
            }
            var x:Number = (thickness - 1) / 2;
            g.lineStyle(thickness, color, alpha, true, LineScaleMode.NORMAL, CapsStyle.NONE);
            g.moveTo(x, 0);
            g.lineTo(x, unscaledHeight);
        }

        override public function styleChanged(styleProp:String):void
        {
            super.styleChanged(styleProp);
            var allStyles:Boolean = styleProp == null;
            if (allStyles || styleProp == "subTickThickness")
            {
                if (styleManager.isValidStyleValue("subTickThickness"))
                {
                    this._measuredWidth = getStyle("subTickThickness");
                }
                else
                {
                    this._measuredWidth = DEFAULT_THICKNESS;
                }
            }
        }
    }
}
