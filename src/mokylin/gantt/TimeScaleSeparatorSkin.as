package mokylin.gantt
{
    import mx.skins.ProgrammaticSkin;
    import flash.display.Graphics;
    import flash.display.LineScaleMode;
    import flash.display.CapsStyle;

    public class TimeScaleSeparatorSkin extends ProgrammaticSkin 
    {

        public static const DEFAULT_THICKNESS:Number = 1;

        private var _measuredHeight:Number;

        public function TimeScaleSeparatorSkin()
        {
            this._measuredHeight = DEFAULT_THICKNESS;
        }

        override public function get measuredHeight():Number
        {
            return this._measuredHeight;
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            var g:Graphics = graphics;
            g.clear();
            var separatorThickness:Number = getStyle("separatorThickness");
            var separatorAlpha:Number = getStyle("separatorAlpha");
            var separatorColor:uint = getStyle("separatorColor");
            if (separatorThickness < DEFAULT_THICKNESS)
            {
                return;
            }
            var y:Number = (separatorThickness - DEFAULT_THICKNESS) / 2;
            g.lineStyle(separatorThickness, separatorColor, separatorAlpha, true, LineScaleMode.NORMAL, CapsStyle.ROUND);
            g.moveTo(0, y);
            g.lineTo(unscaledWidth, y);
        }

        override public function styleChanged(styleProp:String):void
        {
            super.styleChanged(styleProp);
            var allStyles:Boolean = (styleProp == null);
            if (allStyles || styleProp == "separatorThickness")
            {
                if (styleManager.isValidStyleValue("separatorThickness"))
                {
                    this._measuredHeight = getStyle("separatorThickness");
                }
                else
                {
                    this._measuredHeight = DEFAULT_THICKNESS;
                }
            }
        }
    }
}
