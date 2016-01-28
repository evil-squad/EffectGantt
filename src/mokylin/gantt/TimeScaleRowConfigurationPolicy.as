package mokylin.gantt
{
    import mx.resources.IResourceManager;
    import __AS3__.vec.Vector;
    import mokylin.utils.TimeUnit;
    import __AS3__.vec.*;

    [ExcludeClass]
    public class TimeScaleRowConfigurationPolicy 
    {

        private var _resourceManager:IResourceManager;
        private var _rows:Vector.<TimeScaleRow>;
        private var _timeController:TimeController;
        protected var _automaticSubTicks:Boolean;
        protected var _elements:Vector.<TimeScaleRowConfigurationPolicyElement>;
        protected var _rawElements:Vector.<TimeScaleRowConfigurationPolicyElement>;
        private var _validationDates:Vector.<Date>;
        protected var _invalidResources:Boolean = true;
        protected var _invalidCriteria:Boolean = true;

        public function TimeScaleRowConfigurationPolicy()
        {
            this._rows = new Vector.<TimeScaleRow>();
            super();
        }

        public function get resourceManager():IResourceManager
        {
            return this._resourceManager;
        }

        public function set resourceManager(value:IResourceManager):void
        {
            if (this._resourceManager == value)
            {
                return;
            }
            this._resourceManager = value;
            this.invalidateResources();
        }

        public function get rows():Vector.<TimeScaleRow>
        {
            return this._rows;
        }

        public function set rows(value:Vector.<TimeScaleRow>):void
        {
            if (value == null)
            {
                value = new Vector.<TimeScaleRow>();
            }
            if (this.rowsEquals(this._rows, value))
            {
                return;
            }
            this._rows = value;
            this.invalidateCriteria();
        }

        private function rowsEquals(r1:Vector.<TimeScaleRow>, r2:Vector.<TimeScaleRow>):Boolean
        {
            if (r1 == r2)
            {
                return true;
            }
            if (r1 == null || r2 == null)
            {
                return false;
            }
            if (r1.length != r2.length)
            {
                return false;
            }
            var i:uint;
            while (i < r1.length)
            {
                if (r1[i] != r2[i])
                {
                    return false;
                }
                i++;
            }
            return true;
        }

        public function get timeController():TimeController
        {
            return this._timeController;
        }

        public function set timeController(value:TimeController):void
        {
            if (value == this._timeController)
            {
                return;
            }
            this._timeController = value;
            this.invalidateCriteria();
        }

        protected function get automaticSubTicks():Boolean
        {
            return this._automaticSubTicks;
        }

        protected function set automaticSubTicks(value:Boolean):void
        {
            this._automaticSubTicks = value;
        }

        protected function get elements():Vector.<TimeScaleRowConfigurationPolicyElement>
        {
            return this._elements;
        }

        protected function get rawElements():Vector.<TimeScaleRowConfigurationPolicyElement>
        {
            if (this._rawElements == null)
            {
                this._rawElements = this.createRawElements();
                this.invalidateResources();
                this.invalidateCriteria();
            }
            return this._rawElements;
        }

        protected function createRawElements():Vector.<TimeScaleRowConfigurationPolicyElement>
        {
            return new Vector.<TimeScaleRowConfigurationPolicyElement>();
        }

        protected function get validationDates():Vector.<Date>
        {
            if (this._validationDates == null)
            {
                this._validationDates = this.createValidationDates();
            }
            return this._validationDates;
        }

        protected function createValidationDates():Vector.<Date>
        {
            var day:int;
            var d:Date;
            var dates:Vector.<Date> = new Vector.<Date>();
            var month:int = 9;
            while (month < 12)
            {
                day = 0;
                while (day < 7)
                {
                    d = new Date(2003, month, (28 - day), 23, 59, 59, 999);
                    dates.push(d);
                    day++;
                }
                month++;
            }
            return dates;
        }

        public function computeRowSettings(zoomFactor:Number):Vector.<TimeScaleRowSetting>
        {
            var fitElement:TimeScaleRowConfigurationPolicyElement;
            var element:TimeScaleRowConfigurationPolicyElement;
            this.validateResources();
            this.validateCriteria();
            for each (element in this.elements)
            {
                if (element.criteria >= zoomFactor)
                {
                    fitElement = element;
                    break;
                }
            }
            if (fitElement == null && this.rawElements.length > 0)
            {
                fitElement = this.rawElements[(this.rawElements.length - 1)];
            }
            if (fitElement != null)
            {
                return fitElement.settings;
            }
            return TimeScaleRowSetting.EMPTY_VECTOR;
        }

        public function invalidateResources():void
        {
            this._invalidResources = true;
            this._invalidCriteria = true;
            this._validationDates = null;
        }

        public function invalidateCriteria():void
        {
            this._invalidCriteria = true;
        }

        protected function validateResources():void
        {
        }

        protected function validateCriteria():void
        {
            if (!this._invalidCriteria)
            {
                return;
            }
            this._invalidCriteria = false;
            this.updateRawElementsCriteria();
            this.updateElements();
            if (this.automaticSubTicks)
            {
                this.updateSubTicksSettings();
            }
        }

        protected function updateRawElementsCriteria():void
        {
            var element:TimeScaleRowConfigurationPolicyElement;
            for each (element in this.rawElements)
            {
                element.criteria = this.computeCriteriaForElement(element);
            }
        }

        protected function updateElements():void
        {
            var lastCriteria:Number;
            var element:TimeScaleRowConfigurationPolicyElement;
            var criteria:Number;
            this._elements = new Vector.<TimeScaleRowConfigurationPolicyElement>();
            var sortedElements:Vector.<TimeScaleRowConfigurationPolicyElement> = this._rawElements.sort(this.compareElements);
            for each (element in sortedElements)
            {
                criteria = element.criteria;
                if (isNaN(lastCriteria) || criteria > lastCriteria)
                {
                    lastCriteria = criteria;
                    this._elements.push(element);
                }
            }
        }

        protected function updateSubTicksSettings():void
        {
            var element:TimeScaleRowConfigurationPolicyElement;
            var lastElement:TimeScaleRowConfigurationPolicyElement;
            for each (element in this.elements)
            {
                this.updateSubTicksSettingsForElement(element, lastElement);
                lastElement = element;
            }
        }

        protected function updateSubTicksSettingsForElement(element:TimeScaleRowConfigurationPolicyElement, nextElement:TimeScaleRowConfigurationPolicyElement):void
        {
            var subunit:TimeUnit;
            var substeps:Number;
            var nextSettingForLastRow:TimeScaleRowSetting;
            this.clearSubTickSettingsForElement(element);
            var settings:Vector.<TimeScaleRowSetting> = element.settings;
            if (settings == null || settings.length == 0)
            {
                return;
            }
            var settingForLastRow:TimeScaleRowSetting = settings[(settings.length - 1)];
            var nextSettings:Vector.<TimeScaleRowSetting> = nextElement!=null ? nextElement.settings : null;
            var unit:TimeUnit = settingForLastRow.unit;
            var steps:Number = settingForLastRow.steps;
            if (nextSettings != null && nextSettings.length > 0)
            {
                nextSettingForLastRow = nextSettings[(nextSettings.length - 1)];
                if (nextSettingForLastRow.unit == unit && nextSettingForLastRow.steps == steps)
                {
                    subunit = nextSettingForLastRow.subunit;
                    substeps = nextSettingForLastRow.substeps;
                }
                else
                {
                    subunit = nextSettingForLastRow.unit;
                    substeps = nextSettingForLastRow.steps;
                }
            }
            else
            {
                subunit = settingForLastRow.unit;
                substeps = settingForLastRow.steps;
            }
            settingForLastRow.subunit = subunit;
            settingForLastRow.substeps = substeps;
        }

        private function clearSubTickSettingsForElement(element:TimeScaleRowConfigurationPolicyElement):void
        {
            var setting:TimeScaleRowSetting;
            for each (setting in element.settings)
            {
                setting.substeps = NaN;
                setting.subunit = null;
            }
        }

        protected function computeCriteriaForElement(element:TimeScaleRowConfigurationPolicyElement):Number
        {
            var minMillisecondsPerPixel:Number;
            var row:TimeScaleRow;
            var setting:TimeScaleRowSetting;
            var width:Number;
            var milliseconds:Number;
            var millisecondsPerPixel:Number;
            var rows:Vector.<TimeScaleRow> = this.rows;
            var dates:Vector.<Date> = this.validationDates;
            var i:uint;
            while (i < rows.length)
            {
                row = rows[i];
                setting = this.rowIndexToSetting(i, element.settings);
                width = this.measureLabelRequirement(setting, row, dates) + this.measureTickRequirement(row);
                milliseconds = this.getProjectedTime(setting);
                millisecondsPerPixel = milliseconds / width;
                if (i == 0 || millisecondsPerPixel < minMillisecondsPerPixel)
                {
                    minMillisecondsPerPixel = millisecondsPerPixel;
                }
                i++;
            }
            return minMillisecondsPerPixel;
        }

        protected function getProjectedTime(setting:TimeScaleRowSetting):Number
        {
            return this.timeController.getProjectedTimeForUnit(setting.unit, setting.steps);
        }

        protected function rowIndexToSetting(index:uint, settings:Vector.<TimeScaleRowSetting>):TimeScaleRowSetting
        {
            if (index >= settings.length)
            {
                index = settings.length - 1;
            }
            return settings[index];
        }

        protected function measureLabelRequirement(setting:TimeScaleRowSetting, row:TimeScaleRow, dates:Vector.<Date>):Number
        {
            var d:Date;
            var width:Number;
            var minWidth:Number = 0;
            var first:Boolean = true;
            for each (d in dates)
            {
                width = row.getMeasuredLabelWidthForDate(d, setting.formatString, setting.unit, setting.steps);
                if (first)
                {
                    first = false;
                    minWidth = width;
                }
                else
                {
                    if (width > minWidth)
                    {
                        minWidth = width;
                    }
                }
            }
            return minWidth;
        }

        protected function measureTickRequirement(row:TimeScaleRow):Number
        {
            return row.getMeasuredTickSkinWidth() + 2;
        }

        protected function compareElements(e1:TimeScaleRowConfigurationPolicyElement, e2:TimeScaleRowConfigurationPolicyElement):int
        {
            var settings1:Vector.<TimeScaleRowSetting> = e1.settings;
            var settings2:Vector.<TimeScaleRowSetting> = e2.settings;
            var setting1:TimeScaleRowSetting = settings1[(settings1.length - 1)];
            var setting2:TimeScaleRowSetting = settings2[(settings2.length - 1)];
            var testMilliseconds:int = TimeScaleRowSetting.compareMilliseconds(setting1, setting2);
            if (testMilliseconds != 0)
            {
                return testMilliseconds;
            }
            return TimeScaleRowConfigurationPolicyElement.compareSizeRequirement(e1, e2);
        }
    }
}