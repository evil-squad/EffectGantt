package mokylin.gantt
{
    import __AS3__.vec.Vector;
    import mokylin.utils.TimeUnit;
    import mx.resources.IResourceManager;
    import __AS3__.vec.*;

    [ExcludeClass]
    public class TimeScaleConfigurationPolicyForOneRow extends TimeScaleRowConfigurationPolicy 
    {

        private static var _defaultPropertyValues:Object;
        private static var _configurationSettings:Array;

        public function TimeScaleConfigurationPolicyForOneRow()
        {
            automaticSubTicks = false;
        }

        private static function get defaultPropertyValues():Object
        {
            if (_defaultPropertyValues == null)
            {
                _defaultPropertyValues = createDefaultPropertyValues();
            };
            return (_defaultPropertyValues);
        }

        private static function createDefaultPropertyValues():Object
        {
            var values:Object = {};
            values["date.upto.millisecond.format.1"] = "MMMM dd yyyy, h:mm:ss.bbb a";
            values["date.upto.millisecond.format.2"] = "MMM dd yyyy, h:mm:ss.bbb a";
            values["date.upto.millisecond.format.3"] = "MMM dd ''yy, h:mm:ss.bbb a";
            values["date.upto.millisecond.format.4"] = "MMM dd ''yy, h:mm:ss.S a";
            values["date.upto.second.format.1"] = "MMMM dd yyyy, h:mm:ss a";
            values["date.upto.second.format.2"] = "MMM dd 'yy, h:mm:ss a";
            values["date.upto.minute.format.1"] = "MMMM dd yyyy, h:mm a";
            values["date.upto.minute.format.2"] = "MMM dd 'yy, h:mm a";
            values["date.upto.hour.format.1"] = "EEEE MMMM dd yyyy, h a";
            values["date.upto.hour.format.2"] = "EEE MMM dd 'yy, h a";
            values["date.upto.hour.format.3"] = "MMM dd ''yy, h a";
            values["date.upto.day.format.1"] = "EEEE MMMM dd, yyyy";
            values["date.upto.day.format.2"] = "EEEE MMM dd, yyyy";
            values["date.upto.day.format.3"] = "EEE MMM dd, yy";
            values["date.upto.day.format.4"] = "MMM dd, yy";
            values["date.upto.month.format.1"] = "MMMM yyyy";
            values["date.upto.month.format.2"] = "MMM yyyy";
            values["date.upto.month.format.3"] = "MMM ''yy";
            values["date.upto.quarter.format.1"] = "QQQ, yyyy";
            values["date.upto.halfyear.format.1"] = "RRR, yyyy";
            values["millisecond.format.1"] = "b";
            values["second.format.1"] = "ss";
            values["minute.format.1"] = "mm";
            values["hour.format.1"] = "h a";
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
            return (values);
        }

        private static function get configurationSettings():Array
        {
            if (_configurationSettings == null)
            {
                _configurationSettings = createConfigurationSettings();
            };
            return (_configurationSettings);
        }

        private static function createConfigurationSettings():Array
        {
            var entry:Vector.<TimeScaleRowSetting>;
            var settings:Array = [];
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MILLISECOND, 200, "date.upto.millisecond.format.1", TimeUnit.MILLISECOND, 50);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MILLISECOND, 200, "date.upto.millisecond.format.2", TimeUnit.MILLISECOND, 50);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MILLISECOND, 200, "date.upto.millisecond.format.3", TimeUnit.MILLISECOND, 50);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MILLISECOND, 250, "date.upto.millisecond.format.1", TimeUnit.MILLISECOND, 50);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MILLISECOND, 250, "date.upto.millisecond.format.2", TimeUnit.MILLISECOND, 50);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MILLISECOND, 250, "date.upto.millisecond.format.3", TimeUnit.MILLISECOND, 50);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MILLISECOND, 500, "date.upto.millisecond.format.1", TimeUnit.MILLISECOND, 100);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MILLISECOND, 500, "date.upto.millisecond.format.2", TimeUnit.MILLISECOND, 100);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MILLISECOND, 500, "date.upto.millisecond.format.3", TimeUnit.MILLISECOND, 100);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MILLISECOND, 500, "date.upto.millisecond.format.4", TimeUnit.MILLISECOND, 100);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.SECOND, 1, "date.upto.second.format.1", TimeUnit.MILLISECOND, 200);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.SECOND, 1, "date.upto.second.format.2", TimeUnit.MILLISECOND, 200);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.SECOND, 2, "date.upto.second.format.1", TimeUnit.SECOND, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.SECOND, 2, "date.upto.second.format.2", TimeUnit.SECOND, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.SECOND, 5, "date.upto.second.format.1", TimeUnit.SECOND, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.SECOND, 5, "date.upto.second.format.2", TimeUnit.SECOND, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.SECOND, 10, "date.upto.second.format.1", TimeUnit.SECOND, 2);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.SECOND, 10, "date.upto.second.format.2", TimeUnit.SECOND, 2);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.SECOND, 15, "date.upto.second.format.1", TimeUnit.SECOND, 5);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.SECOND, 15, "date.upto.second.format.2", TimeUnit.SECOND, 5);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.SECOND, 30, "date.upto.second.format.1", TimeUnit.SECOND, 5);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.SECOND, 30, "date.upto.second.format.2", TimeUnit.SECOND, 5);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MINUTE, 1, "date.upto.minute.format.1", TimeUnit.SECOND, 10);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MINUTE, 1, "date.upto.minute.format.2", TimeUnit.SECOND, 10);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MINUTE, 2, "date.upto.minute.format.1", TimeUnit.MINUTE, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MINUTE, 2, "date.upto.minute.format.2", TimeUnit.MINUTE, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MINUTE, 5, "date.upto.minute.format.1", TimeUnit.MINUTE, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MINUTE, 5, "date.upto.minute.format.2", TimeUnit.MINUTE, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MINUTE, 10, "date.upto.minute.format.1", TimeUnit.MINUTE, 2);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MINUTE, 10, "date.upto.minute.format.2", TimeUnit.MINUTE, 2);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MINUTE, 15, "date.upto.minute.format.1", TimeUnit.MINUTE, 5);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MINUTE, 15, "date.upto.minute.format.2", TimeUnit.MINUTE, 5);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MINUTE, 30, "date.upto.minute.format.1", TimeUnit.MINUTE, 5);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MINUTE, 30, "date.upto.minute.format.2", TimeUnit.MINUTE, 5);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.HOUR, 1, "date.upto.hour.format.1", TimeUnit.MINUTE, 15);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.HOUR, 1, "date.upto.hour.format.2", TimeUnit.MINUTE, 15);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.HOUR, 1, "date.upto.hour.format.3", TimeUnit.MINUTE, 15);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.HOUR, 2, "date.upto.hour.format.2", TimeUnit.HOUR, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.HOUR, 2, "date.upto.hour.format.3", TimeUnit.HOUR, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.HOUR_CALENDAR, 4, "date.upto.hour.format.2", TimeUnit.HOUR, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.HOUR_CALENDAR, 4, "date.upto.hour.format.3", TimeUnit.HOUR, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.HOUR_CALENDAR, 6, "date.upto.hour.format.2", TimeUnit.HOUR, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.HOUR_CALENDAR, 6, "date.upto.hour.format.3", TimeUnit.HOUR, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.HOUR_CALENDAR, 12, "date.upto.hour.format.2", TimeUnit.HOUR_CALENDAR, 4);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.HOUR_CALENDAR, 12, "date.upto.hour.format.3", TimeUnit.HOUR_CALENDAR, 4);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.DAY, 1, "date.upto.day.format.1", TimeUnit.HOUR_CALENDAR, 4);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.DAY, 1, "date.upto.day.format.2", TimeUnit.HOUR_CALENDAR, 4);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.DAY, 1, "date.upto.day.format.3", TimeUnit.HOUR_CALENDAR, 4);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.DAY, 1, "date.upto.day.format.4", TimeUnit.HOUR_CALENDAR, 4);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.DAY, 2, "date.upto.day.format.4", TimeUnit.DAY, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.DAY, 4, "date.upto.day.format.4", TimeUnit.DAY, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.WEEK, 1, "date.upto.day.format.4", TimeUnit.DAY, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MONTH, 1, "date.upto.month.format.1", TimeUnit.WEEK, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MONTH, 1, "date.upto.month.format.2", TimeUnit.WEEK, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.MONTH, 1, "date.upto.month.format.3", TimeUnit.WEEK, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.QUARTER, 1, "date.upto.quarter.format.1", TimeUnit.MONTH, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.HALFYEAR, 1, "date.upto.halfyear.format.1", TimeUnit.QUARTER, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.YEAR, 1, "year.format.1", TimeUnit.QUARTER, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.YEAR, 5, "year.format.1", TimeUnit.YEAR, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.DECADE, 1, "year.format.1", TimeUnit.YEAR, 2);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.DECADE, 5, "year.format.1", TimeUnit.DECADE, 1);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.DECADE, 10, "year.format.1", TimeUnit.DECADE, 2);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.DECADE, 50, "year.format.1", TimeUnit.DECADE, 10);
            settings.push(entry);
            entry = new Vector.<TimeScaleRowSetting>(1, true);
            entry[0] = new TimeScaleRowSetting(TimeUnit.DECADE, 100, "year.format.1", TimeUnit.DECADE, 20);
            settings.push(entry);
            return (settings);
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
            };
            return (elements);
        }

        override protected function validateResources():void
        {
            var element:TimeScaleRowConfigurationPolicyElement;
            var setting:TimeScaleRowSetting;
            if (!(_invalidResources))
            {
                return;
            };
            _invalidResources = false;
            for each (element in rawElements)
            {
                for each (setting in element.settings)
                {
                    setting.formatString = this.getPropertyValue(resourceManager, setting.resourceName);
                };
            };
        }

        private function getPropertyValue(resourceManager:IResourceManager, propertyName:String):String
        {
            var propertyValue:String = resourceManager.getString("mokylingantt", propertyName);
            if (!(propertyValue))
            {
                propertyValue = defaultPropertyValues[propertyName];
            };
            return (propertyValue);
        }


    }
}
