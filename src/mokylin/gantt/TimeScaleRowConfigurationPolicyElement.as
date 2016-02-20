package mokylin.gantt
{
    import __AS3__.vec.Vector;
    import __AS3__.vec.*;

    [ExcludeClass]
    public class TimeScaleRowConfigurationPolicyElement 
    {
		/**
		 * criteria - 标准; 条件; 准则; 
		 * 时间与像素的对应关系，比如1秒钟对应100像素
		 */
        public var criteria:Number;
        public var settings:Vector.<TimeScaleRowSetting>;

        public function TimeScaleRowConfigurationPolicyElement()
        {
            this.settings = new Vector.<TimeScaleRowSetting>();
            super();
        }

        public static function compareSizeRequirement(e1:TimeScaleRowConfigurationPolicyElement, e2:TimeScaleRowConfigurationPolicyElement):int
        {
            var setting1:TimeScaleRowSetting;
            var setting2:TimeScaleRowSetting;
            var size1:Number;
            var size2:Number;
            var settings1:Vector.<TimeScaleRowSetting> = e1.settings;
            var settings2:Vector.<TimeScaleRowSetting> = e2.settings;
            var count:uint = settings1.length;
            var i:uint;
            while (i < count)
            {
                setting1 = settings1[count - 1 - i];
                setting2 = settings2[count - 1 - i];
                size1 = (setting1.milliseconds * e1.criteria);
                size2 = (setting2.milliseconds * e2.criteria);
                if (size1 < size2)
                {
                    return -1;
                }
                if (size2 < size1)
                {
                    return 1;
                }
                i++;
            }
            return 0;
        }
    }
}
