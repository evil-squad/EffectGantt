package mokylin.gantt
{
    import mx.skins.ProgrammaticSkin;
    import flash.display.LineScaleMode;
    import flash.display.CapsStyle;
    import flash.display.JointStyle;

    public class TaskBarSkin extends ProgrammaticSkin 
    {
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            var color:uint;
            var borderColor:uint;
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            graphics.clear();
            var borderThickness:Number = getStyle("borderThickness");
            switch (name)
            {
                case "selectedSkin":
                    borderColor = getStyle("borderSelectedColor");
                    color = getStyle("selectedColor");
                    break;
                case "overSkin":
                    borderColor = getStyle("borderRollOverColor");
                    color = getStyle("rollOverColor");
                    break;
                case "selectedOverSkin":
                    borderColor = getStyle("borderSelectedRollOverColor");
                    color = getStyle("selectedRollOverColor");
                    break;
                case "skin":
                    borderColor = getStyle("borderColor");
                    color = getStyle("backgroundColor");
                    break;
            }
            if (borderThickness > 0)
            {
                graphics.lineStyle(borderThickness, borderColor, 1, true, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.MITER);
            }
            graphics.beginFill(color);
            graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
            graphics.endFill();
        }
    }
}
