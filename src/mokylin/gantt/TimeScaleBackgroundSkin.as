package mokylin.gantt
{
    import mx.skins.ProgrammaticSkin;
    import flash.display.Graphics;
    import flash.geom.Matrix;
    import flash.display.GradientType;

    public class TimeScaleBackgroundSkin extends ProgrammaticSkin 
    {
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            var g:Graphics = graphics;
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            g.clear();
            var colors:Array = getStyle("backgroundColors");
            styleManager.getColorNames(colors);
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(unscaledWidth, unscaledHeight + 1, Math.PI / 2, 0, 0);
            colors = [colors[0], colors[0], colors[1]];
            var ratios:Array = [0, 60, 0xFF];
            var alphas:Array = [1, 1, 1];
            g.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
            g.lineStyle(0, 0, 0);
            g.moveTo(0, 0);
            g.lineTo(unscaledWidth, 0);
            g.lineTo(unscaledWidth, unscaledHeight - 0.5);
            g.lineStyle(0, getStyle("borderColor"), 100);
            g.lineTo(0, unscaledHeight - 0.5);
            g.lineStyle(0, 0, 0);
            g.endFill();
        }
    }
}
