package mokylin.gantt
{
    import mx.skins.ProgrammaticSkin;
    import flash.display.Graphics;
    import flash.display.LineScaleMode;
    import flash.display.CapsStyle;

    public class TimeScaleTickSkin extends ProgrammaticSkin 
    {

        public static const DEFAULT_THICKNESS:Number = 1;

        private var _measuredWidth:Number;

        public function TimeScaleTickSkin()
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
            var thickness:Number = getStyle("tickThickness");
            var alpha:Number = getStyle("tickAlpha");
            var color:uint = getStyle("tickColor");
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
            var allStyles:Boolean = (styleProp == null);
            if (allStyles || styleProp == "tickThickness")
            {
                if (styleManager.isValidStyleValue("tickThickness"))
                {
                    this._measuredWidth = getStyle("tickThickness");
                }
                else
                {
                    this._measuredWidth = DEFAULT_THICKNESS;
                }
            }
        }
    }
}
