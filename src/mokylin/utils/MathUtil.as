package mokylin.utils
{
    [ExcludeClass]
    public class MathUtil 
    {

        private static const PI2:Number = (2 * Math.PI);//6.28318530717959


        public static function mod2PI(angle:Number):Number
        {
            if (angle >= PI2)
            {
                do 
                {
                    angle = (angle - PI2);
                } while (angle >= PI2);
            }
            else
            {
                while (angle < 0)
                {
                    angle = (angle + PI2);
                }
            }
            return angle;
        }

        public static function mod360(angle:Number):Number
        {
            if (angle >= 360)
            {
                do 
                {
                    angle = (angle - 360);
                } while (angle >= 360);
            }
            else
            {
                while (angle < 0)
                {
                    angle = (angle + 360);
                }
            }
            return angle;
        }

        public static function truncate(value:Number, precision:int=6):Number
        {
            var mult:Number = Math.pow(10, precision);
            return Math.floor(value * mult) / mult;
        }

        public static function sign(value:Number):int
        {
            if (value < 0)
            {
                return -1;
            }
            if (value > 0)
            {
                return 1;
            }
            return 0;
        }

        public static function toRadians(deg:Number):Number
        {
            return (deg * Math.PI) / 180;
        }

        public static function toDegrees(rad:Number):Number
        {
            return (rad * 180) / Math.PI;
        }

        public static function clamp(v:Number, min:Number, max:Number):Number
        {
            if (v > max)
            {
                return max;
            }
            if (v < min)
            {
                return min;
            }
            return v;
        }

        public static function pointAngleDeg(x1:Number, y1:Number, x2:Number, y2:Number):Number
        {
            var deg:Number;
            if (x1 == x2)
            {
                return y1<y2 ? 270 : 90;
            }
            if (y1 == y2)
            {
                return x1<x2 ? 0 : 180;
            }
            deg = MathUtil.toDegrees(Math.atan2((y1 - y2), (x2 - x1)));
            if (deg < 0)
            {
                deg = deg + 360;
            }
            return deg;
        }
    }
}