package mokylin.gantt
{
    import __AS3__.vec.Vector;
    
    import mokylin.utils.TimeUnit;

    [ExcludeClass]
    public class TimeScaleConfigurationPolicyForTwoRows extends TimeScaleRowConfigurationPolicy 
    {

        private static var _defaultPropertyValues:Object;
        private static var _configurationSettings:Array;

        public function TimeScaleConfigurationPolicyForTwoRows()
        {
            automaticSubTicks = true;
        }

        private static function get configurationSettings():Array
        {
            if (_configurationSettings == null)
            {
                _configurationSettings = createConfigurationSettings();
            }
            return _configurationSettings;
        }

        private static function createConfigurationSettings():Array
        {
            var entry:Vector.<TimeScaleRowSetting>;
            var settings:Array = [];
			
			/*entry = new Vector.<TimeScaleRowSetting>(2, true);
			entry[0] = new TimeScaleRowSetting(TimeUnit.MILLISECOND, 5);
			entry[1] = new TimeScaleRowSetting(TimeUnit.MILLISECOND, 1);
			settings.push(entry);*/
			
			entry = new Vector.<TimeScaleRowSetting>(2, true);
			entry[0] = new TimeScaleRowSetting(TimeUnit.MILLISECOND, 100);
			entry[1] = new TimeScaleRowSetting(TimeUnit.MILLISECOND, 10);
			settings.push(entry);
            
            entry = new Vector.<TimeScaleRowSetting>(2, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MILLISECOND, 500);
            entry[1] = new TimeScaleRowSetting(TimeUnit.MILLISECOND, 50);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(2, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.SECOND, 1);
            entry[1] = new TimeScaleRowSetting(TimeUnit.MILLISECOND, 100);
            settings.push(entry);
            
            entry = new Vector.<TimeScaleRowSetting>(2, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.SECOND, 5);
            entry[1] = new TimeScaleRowSetting(TimeUnit.MILLISECOND, 500);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(2, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.SECOND, 5);
            entry[1] = new TimeScaleRowSetting(TimeUnit.SECOND, 1);
            settings.push(entry);
            /*entry = new Vector.<TimeScaleRowSetting>(2, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.SECOND, 10);
            entry[1] = new TimeScaleRowSetting(TimeUnit.SECOND, 5);
            settings.push(entry);*/
            entry = new Vector.<TimeScaleRowSetting>(2, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.SECOND, 10);
            entry[1] = new TimeScaleRowSetting(TimeUnit.SECOND, 1);
			settings.push(entry);
			
			entry = new Vector.<TimeScaleRowSetting>(2, true);
			entry[0] = new TimeScaleRowSetting(TimeUnit.SECOND, 15);
			entry[1] = new TimeScaleRowSetting(TimeUnit.SECOND, 3);
            settings.push(entry);
      
            return settings;
        }

        override protected function createRawElements():Vector.<TimeScaleRowConfigurationPolicyElement>
        {
            var entry:Vector.<TimeScaleRowSetting>;
            var element:TimeScaleRowConfigurationPolicyElement;
            var elements:Vector.<TimeScaleRowConfigurationPolicyElement> = new Vector.<TimeScaleRowConfigurationPolicyElement>();
            var settings:Array = configurationSettings;
            for each (entry in settings)
            {
                element = new TimeScaleRowConfigurationPolicyElement();
                element.settings = TimeScaleRowSetting.cloneVector(entry);
                elements.push(element);
            }
            return elements;
        }
    }
}
