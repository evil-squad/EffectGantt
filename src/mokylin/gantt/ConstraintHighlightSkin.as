package mokylin.gantt
{
    import mx.skins.ProgrammaticSkin;
    import flash.display.LineScaleMode;
    import flash.display.CapsStyle;
    import flash.display.JointStyle;
    import flash.geom.Rectangle;
    import mokylin.utils.GraphicsUtil;

    public class ConstraintHighlightSkin extends ProgrammaticSkin 
    {
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            graphics.clear();
            var borderThickness:Number = getStyle("constraintHighlightThickness");
            if (borderThickness <= 0 || unscaledWidth <= 2 || unscaledHeight <= 2)
            {
                return;
            }
            var borderColor:uint = getStyle("constraintHighlightColor");
            graphics.lineStyle(borderThickness, borderColor, 1, true, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.MITER);
            var leftPadding:Number = getStyle("constraintHighlightLeftPadding");
            var rightPadding:Number = getStyle("constraintHighlightRightPadding");
            var topPadding:Number = getStyle("constraintHighlightTopPadding");
            var bottomPadding:Number = getStyle("constraintHighlightBottomPadding");
            var rect:Rectangle = new Rectangle(leftPadding, topPadding, Math.max(0, unscaledWidth - leftPadding - rightPadding), Math.max(0, unscaledHeight - topPadding - bottomPadding));
            GraphicsUtil.drawHorizontalDottedLine(graphics, rect.x, rect.right, rect.y, borderThickness);
            GraphicsUtil.drawHorizontalDottedLine(graphics, rect.x, rect.right, rect.bottom, borderThickness);
            GraphicsUtil.drawVerticalDottedLine(graphics, rect.right, rect.y, rect.bottom, borderThickness);
            GraphicsUtil.drawVerticalDottedLine(graphics, rect.x, rect.y, rect.bottom, borderThickness);
        }
    }
}