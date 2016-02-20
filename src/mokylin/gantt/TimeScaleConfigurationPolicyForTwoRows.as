﻿package mokylin.gantt
{
    import __AS3__.vec.Vector;
    import mokylin.utils.TimeUnit;
    import mx.resources.IResourceManager;
    import __AS3__.vec.*;

    [ExcludeClass]
    public class TimeScaleConfigurationPolicyForTwoRows extends TimeScaleRowConfigurationPolicy 
    {

        private static var _defaultPropertyValues:Object;
        private static var _configurationSettings:Array;

        public function TimeScaleConfigurationPolicyForTwoRows()
        {
            automaticSubTicks = true;
        }

        private static function get defaultPropertyValues():Object
        {
            if (_defaultPropertyValues == null)
            {
                _defaultPropertyValues = createDefaultPropertyValues();
            }
            return _defaultPropertyValues;
        }

        private static function createDefaultPropertyValues():Object
        {
            var values:Object = {};
            values["date.upto.second.format.1"] = "MMMM dd yyyy, h:mm:ss a";
            values["date.upto.second.format.2"] = "MMM dd 'YY, h:mm:ss a";
            values["date.upto.minute.format.1"] = "MMMM dd yyyy, h:mm a";
            values["date.upto.minute.format.2"] = "MMM dd 'yy, h:mm a";
            values["date.upto.hour.format.1"] = "EEEE MMMM dd yyyy, h a";
            values["date.upto.hour.format.2"] = "EEE MMM dd 'yy h a";
            values["date.upto.day.format.1"] = "EEEE MMMM dd, yyyy";
            values["date.upto.day.format.2"] = "EEEE MMM dd, yyyy";
            values["date.upto.day.format.3"] = "EEE MMM dd, yy";
            values["date.upto.day.format.4"] = "MMM dd, yy";
            values["date.upto.month.format.1"] = "MMMM yyyy";
            values["date.upto.quarter.format.1"] = "QQQ, yyyy";
            values["date.upto.halfyear.format.1"] = "RRR, yyyy";
            values["millisecond.format.1"] = "b";
            values["second.format.1"] = "ss";
            values["minute.format.1"] = "mm";
            values["hour.format.1"] = "h";//"h a";
            values["halfday.format.1"] = "U";
            values["day.format.1"] = "EEE dd";
            values["day.format.2"] = "dd";
            values["week.format.1"] = "'W'w";
            values["month.format.1"] = "MMMM";
            values["month.format.2"] = "MMM";
            values["month.format.3"] = "MM";
            values["quarter.format.1"] = "QQQ";
            values["halfyear.format.1"] = "RRR";
            values["year.format.1"] = "yyyy";
            values["year.format.2"] = "yy";
            return values;
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
            entry = new Vector.<TimeScaleRowSetting>(2, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.SECOND, 1, "second.format.1");
            entry[1] = new TimeScaleRowSetting(TimeUnit.MILLISECOND, 5, "millisecond.format.1");
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(2, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.SECOND, 1, "second.format.1");
            entry[1] = new TimeScaleRowSetting(TimeUnit.MILLISECOND, 10, "millisecond.format.1");
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(2, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.SECOND, 1, "second.format.1");
            entry[1] = new TimeScaleRowSetting(TimeUnit.MILLISECOND, 50, "millisecond.format.1");
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(2, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.SECOND, 1, "second.format.1");
            entry[1] = new TimeScaleRowSetting(TimeUnit.MILLISECOND, 100, "millisecond.format.1");
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(2, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.SECOND, 1, "second.format.1");
            entry[1] = new TimeScaleRowSetting(TimeUnit.MILLISECOND, 500, "millisecond.format.1");
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(2, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MINUTE, 1, "minute.format.1");
            entry[1] = new TimeScaleRowSetting(TimeUnit.SECOND, 1, "second.format.1");
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(2, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MINUTE, 1, "minute.format.1");
            entry[1] = new TimeScaleRowSetting(TimeUnit.SECOND, 5, "second.format.1");
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(2, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MINUTE, 1, "minute.format.1");
            entry[1] = new TimeScaleRowSetting(TimeUnit.SECOND, 15, "second.format.1");
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(2, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.HOUR, 1, "hour.format.1");
            entry[1] = new TimeScaleRowSetting(TimeUnit.MINUTE, 1, "minute.format.1");
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(2, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.HOUR, 1, "hour.format.1");
            entry[1] = new TimeScaleRowSetting(TimeUnit.MINUTE, 5, "minute.format.1");
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(2, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.HOUR, 1, "hour.format.1");
            entry[1] = new TimeScaleRowSetting(TimeUnit.MINUTE, 15, "minute.format.1");
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

		/**
		 *  
		 * 
		 */		
        override protected function validateResources():void
        {
            var element:TimeScaleRowConfigurationPolicyElement;
            var setting:TimeScaleRowSetting;
            if (!_invalidResources)
            {
                return;
            }
            _invalidResources = false;
            for each (element in rawElements)
            {
                for each (setting in element.settings)
                {
                    setting.formatString = this.getPropertyValue(resourceManager, setting.resourceName);
                }
            }
        }
		/**
		 * 从.properties文件读取对应propertyName的 value值
		 * .properties文件是键值对的数据，key为propertyName，value为值
		 * @param resourceManager
		 * @param propertyName
		 * @return 
		 * 
		 */
        private function getPropertyValue(resourceManager:IResourceManager, propertyName:String):String
        {
            var propertyValue:String = resourceManager.getString("mokylingantt", propertyName);
            if (!propertyValue)
            {
                propertyValue = defaultPropertyValues[propertyName];
            }
            return propertyValue;
        }
    }
}
