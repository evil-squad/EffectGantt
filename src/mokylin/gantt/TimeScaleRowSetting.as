package mokylin.gantt
{
    import __AS3__.vec.Vector;
    import mokylin.utils.TimeUnit;
    import __AS3__.vec.*;

    [ExcludeClass]
    public class TimeScaleRowSetting 
    {
        public static const EMPTY_VECTOR:Vector.<TimeScaleRowSetting> = new Vector.<TimeScaleRowSetting>(0, true);

        public var unit:TimeUnit;
        public var steps:Number = 1;
        public var subunit:TimeUnit;
        public var substeps:Number;
        public var resourceName:String;
        public var formatString:String;

        public function TimeScaleRowSetting(unit:TimeUnit=null, steps:Number=1, resourceName:String=null, subunit:TimeUnit=null, substeps:Number=NaN)
        {
            this.unit = unit;
            this.steps = steps;
            this.resourceName = resourceName;
            this.subunit = subunit;
            this.substeps = substeps;
        }

        public static function cloneVector(value:Vector.<TimeScaleRowSetting>):Vector.<TimeScaleRowSetting>
        {
            var clone:Vector.<TimeScaleRowSetting> = new Vector.<TimeScaleRowSetting>(value.length, value.fixed);
            var i:int;
            while (i < value.length)
            {
                clone[i] = TimeScaleRowSetting(value[i].clone());
                i++;
            }
            return clone;
        }

        public static function compareMilliseconds(s1:TimeScaleRowSetting, s2:TimeScaleRowSetting):int
        {
            var milliseconds1:Number = s1.milliseconds;
            var milliseconds2:Number = s2.milliseconds;
            if (milliseconds1 < milliseconds2)
            {
                return -1;
            }
            if (milliseconds1 > milliseconds2)
            {
                return 1;
            }
            return 0;
        }


        public function get milliseconds():Number
        {
            if (this.unit == null || isNaN(this.steps))
            {
                return NaN;
            }
            return this.unit.milliseconds * this.steps;
        }

        public function clone():Object
        {
            var clone:TimeScaleRowSetting = new TimeScaleRowSetting(this.unit, this.steps, this.resourceName, this.subunit, this.substeps);
            clone.formatString = this.formatString;
            return clone;
        }
    }
}
