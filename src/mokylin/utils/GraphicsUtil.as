package mokylin.utils
{
    import flash.display.Graphics;
    import mx.graphics.IStroke;
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.geom.Rectangle;

    [ExcludeClass]
    public class GraphicsUtil 
    {
        private static const DOTTED_LINE_BITMAP_LENGTH:Number = 16;

        public static function drawDashedLine(target:Graphics, stroke:IStroke, x0:Number, y0:Number, x1:Number, y1:Number, pattern:Array):void
        {
            target.moveTo(x0, y0);
            var context:Object = {
                "drawing":true,
                "index":0,
                "offset":0,
                "styleInited":false
            };
            drawDashedLineImpl(target, stroke, x0, y0, x1, y1, pattern, context);
        }

        private static function drawDashedLineImpl(target:Graphics, stroke:IStroke, x0:Number, y0:Number, x1:Number, y1:Number, pattern:Array, context:Object=null):void
        {
            var x:int;
            var dX:Number = x1 - x0;
            var dY:Number = y1 - y0;
            var len:Number = Math.sqrt(dX * dX + dY * dY);
            dX = dX / len;
            dY = dY / len;
            var tMax:Number = len;
            var t:Number = -context.offset;
            var bDrawing:Boolean = context.drawing;
            var patternIndex:int = context.index;
            var styleInited:Boolean = context.styleInited;
            while (t < tMax)
            {
                t = (t + pattern[patternIndex]);
                if (t < 0)
                {
                    x = 5;
                }
                if (t >= tMax)
                {
                    context.offset = (pattern[patternIndex] - (t - tMax));
                    context.patternIndex = patternIndex;
                    context.drawing = bDrawing;
                    context.styleInited = true;
                    t = tMax;
                }
                if (styleInited == false)
                {
                    if (bDrawing)
                    {
                        stroke.apply(target, null, null);
                    }
                    else
                    {
                        target.lineStyle(0, 0, 0);
                    }
                }
                else
                {
                    styleInited = false;
                }
                target.lineTo((x0 + (t * dX)), (y0 + (t * dY)));
                bDrawing = !(bDrawing);
                patternIndex = ((patternIndex + 1) % pattern.length);
            }
        }

        public static function drawVerticalDottedLine(g:Graphics, x:Number, y0:Number, y1:Number, width:Number=1):void
        {
            var patternBitmap:BitmapData;
            if ((y1 - y0) > DOTTED_LINE_BITMAP_LENGTH)
            {
                patternBitmap = createVerticalDottedLinePatternBitmap(g, width);
                if (width < 2)
                {
                    width = 2;
                }
                g.lineStyle(width);
                g.lineBitmapStyle(patternBitmap);
                g.moveTo(x, y0);
                g.lineTo(x, y1);
            }
            else
            {
                drawVerticalDottedLineImpl(g, x, y0, y1, width);
            }
        }

        private static function createVerticalDottedLinePatternBitmap(g:Graphics, width:Number):BitmapData
        {
            var s:Shape = new Shape();
            var g2:Graphics = s.graphics;
            g2.copyFrom(g);
            var l:Number = Math.max((width * 2), DOTTED_LINE_BITMAP_LENGTH);
            drawVerticalDottedLineImpl(g2, 0, 0, l, width);
            var bitmapData:BitmapData = new BitmapData(width, l);
            bitmapData.draw(s, null, null, null, new Rectangle(0, 0, width, l), false);
            return bitmapData;
        }

        private static function drawVerticalDottedLineImpl(g:Graphics, x:Number, y0:Number, y1:Number, width:Number=1):void
        {
            var y:Number = y0;
            while (y < y1)
            {
                g.moveTo(x, y);
                g.lineTo(x, Math.min(y + width, y1));
                y = y + (2 * width);
            }
        }

        public static function drawHorizontalDottedLine(g:Graphics, x0:Number, x1:Number, y:Number, width:Number=1):void
        {
            var patternBitmap:BitmapData;
            if ((x1 - x0) > DOTTED_LINE_BITMAP_LENGTH)
            {
                patternBitmap = createHorizontalDottedLinePatternBitmap(g, width);
                if (width < 2)
                {
                    width = 2;
                }
                g.lineStyle(width);
                g.lineBitmapStyle(patternBitmap);
                g.moveTo(x0, y);
                g.lineTo(x1, y);
            }
            else
            {
                drawHorizontalDottedLineImpl(g, x0, x1, y, width);
            }
        }

        private static function createHorizontalDottedLinePatternBitmap(g:Graphics, width:Number):BitmapData
        {
            var s:Shape = new Shape();
            var g2:Graphics = s.graphics;
            g2.copyFrom(g);
            var l:Number = Math.max(width * 2, DOTTED_LINE_BITMAP_LENGTH);
            drawHorizontalDottedLineImpl(g2, 0, l, 0, width);
            var bitmapData:BitmapData = new BitmapData(width, l);
            bitmapData.draw(s, null, null, null, new Rectangle(0, 0, l, width), false);
            return bitmapData;
        }

        private static function drawHorizontalDottedLineImpl(g:Graphics, x0:Number, x1:Number, y:Number, width:Number=1):void
        {
            var x:Number = x0;
            while (x < x1)
            {
                g.moveTo(x, y);
                g.lineTo(Math.min(x + width, x1), y);
                x = x + (2 * width);
            }
        }
    }
}