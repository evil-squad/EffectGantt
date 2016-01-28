package mokylin.utils
{
    [ExcludeClass]
    public class ColorUtil 
    {
        public static function getHSBColor(hue:Number, saturation:Number, brightness:Number):uint
        {
            var h:Number;
            var f:Number;
            var p:Number;
            var q:Number;
            var t:Number;
            var r:uint;
            var g:uint;
            var b:uint;
            if (saturation == 0)
            {
                b = uint(brightness * 0xFF + 0.5);
                g = b;
                r = g;
            }
            else
            {
                h = (hue - Math.floor(hue)) * 6;
                f = h - Math.floor(h);
                p = brightness * (1 - saturation);
                q = brightness * (1 - saturation * f);
                t = brightness * (1 - saturation * (1 - f));
                switch (uint(h))
                {
                    case 0:
                        r = uint(brightness * 0xFF + 0.5);
                        g = uint(t * 0xFF + 0.5);
                        b = uint(p * 0xFF + 0.5);
                        break;
                    case 1:
                        r = uint(q * 0xFF + 0.5);
                        g = uint(brightness * 0xFF + 0.5);
                        b = uint(p * 0xFF + 0.5);
                        break;
                    case 2:
                        r = uint(p * 0xFF + 0.5);
                        g = uint(brightness * 0xFF + 0.5);
                        b = uint(t * 0xFF + 0.5);
                        break;
                    case 3:
                        r = uint(p * 0xFF + 0.5);
                        g = uint(q * 0xFF + 0.5);
                        b = uint(brightness * 0xFF + 0.5);
                        break;
                    case 4:
                        r = uint(t * 0xFF + 0.5);
                        g = uint(p * 0xFF + 0.5);
                        b = uint(brightness * 0xFF + 0.5);
                        break;
                    case 5:
                        r = uint(brightness * 0xFF + 0.5);
                        g = uint(p * 0xFF + 0.5);
                        b = uint(q * 0xFF + 0.5);
                        break;
                }
            }
            return r << 16 | (g << 8) | b;
        }

        public static function uintToRGB(color:uint):Object
        {
            return ({
                "r":((color & 0xFF0000) >> 16),
                "g":((color & 0xFF00) >> 8),
                "b":(color & 0xFF)
            });
        }

        public static function RGBToUint(color:Object):uint
        {
            return color.r << 16 | (color.g << 8) | color.b;
        }

        public static function addAlpha(color:uint, alpha:Number):uint
        {
            color = color | (((alpha * 0xFF) & 0xFF) << 24);
            return color;
        }
    }
}
