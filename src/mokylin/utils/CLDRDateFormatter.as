package mokylin.utils
{
    import mx.formatters.Formatter;
    import mx.formatters.DateFormatter;
    import mx.utils.StringUtil;
    import mx.formatters.DateBase;

    [ResourceBundle("mokylinsparkutilities")]
    [ResourceBundle("controls")]
    public class CLDRDateFormatter extends Formatter 
    {

        private const VALID_PATTERN_LETTERS:String = "yRQMwdDEeaUhHKkmsSbZ";
        private const VALID_ELAPSED_PATTERN_LETTERS:String = "yRQMwdDEehHKkmsb";
        private const VALID_ALTERNATE_START_OF_YEAR_PATTERN_LETTERS:String = "yRQMwdDaUhHKkmsSbZ";

        private var _calendar:GregorianCalendar;
        private var _explicitDayNamesNarrow:Array;
        private var _defaultDayNamesNarrow:Array;
        private var _explicitMonthNamesNarrow:Array;
        private var _defaultMonthNamesNarrow:Array;
        private var _explicitFormatString:String;
        private var _defaultFormatString:String;
        private var _referenceDate:Date;
        private var _startOfYear:Date;
        private var _halfyearAbbreviatedFormat:String;
        private var _quarterAbbreviatedFormat:String;
        private var _periodAMStandaloneText:String;
        private var _periodPMStandaloneText:String;
        private var _gmtFormat:String;
        private var _positiveSign:String;
        private var _negativeSign:String;


        public function get calendar():GregorianCalendar
        {
            if (!this._calendar)
            {
                this._calendar = new GregorianCalendar();
            }
            return this._calendar;
        }

        public function set calendar(value:GregorianCalendar):void
        {
            this._calendar = value;
        }

        [ArrayElementType("String")]
        [Inspectable(category="General", defaultValue="null")]
        public function get dayNamesNarrow():Array
        {
            if (this._explicitDayNamesNarrow)
            {
                return this._explicitDayNamesNarrow;
            }
            return this._defaultDayNamesNarrow;
        }

        public function set dayNamesNarrow(value:Array):void
        {
            this._explicitDayNamesNarrow = value;
        }

        [ArrayElementType("String")]
        [Inspectable(category="General", defaultValue="null")]
        public function get monthNamesNarrow():Array
        {
            if (this._explicitMonthNamesNarrow)
            {
                return (this._explicitMonthNamesNarrow);
            }
            return this._defaultMonthNamesNarrow;
        }

        public function set monthNamesNarrow(value:Array):void
        {
            this._explicitMonthNamesNarrow = value;
        }

        [Inspectable(category="General", defaultValue="null")]
        public function get formatString():String
        {
            if (this._explicitFormatString != null)
            {
                return this._explicitFormatString;
            }
            return this._defaultFormatString;
        }

        public function set formatString(value:String):void
        {
            this._explicitFormatString = value;
        }

        [Inspectable(category="General")]
        public function get referenceDate():Date
        {
            if (this._referenceDate == null)
            {
                this._referenceDate = new Date(2000, 0, 1, 0, 0, 0, 0);
            }
            return this._referenceDate;
        }

        public function set referenceDate(value:Date):void
        {
            this._referenceDate = value;
        }

        [Inspectable(category="General", defaultValue="null")]
        public function get startOfYear():Date
        {
            return this._startOfYear;
        }

        public function set startOfYear(value:Date):void
        {
            this._startOfYear = value;
        }

        override public function format(value:Object):String
        {
            var letter:String;
            var endQuoteIndex:int;
            error = null;
            if (value == null || value == "")
            {
                return (this.formatWithInvalidValue());
            }
            if (value is String)
            {
                value = DateFormatter.parseDateString(String(value));
                if (value == null)
                {
                    return this.formatWithInvalidValue();
                }
            }
            else
            {
                if (!(value is Date))
                {
                    return this.formatWithInvalidValue();
                }
                if (value is Date && isNaN((value as Date).time))
                {
                    return this.formatWithInvalidValue();
                }
            }
            var patternCount:int;
            var usedPatternLetters:String = "";
            var prefix:String;
            var n:int = this.formatString.length;
            var i:int;
            while (i < n)
            {
                letter = this.formatString.charAt(i);
                if (letter == "'")
                {
                    if (prefix != null)
                    {
                        return this.formatWithInvalidFormat();
                    }
                    endQuoteIndex = this.formatString.indexOf("'", (i + 1));
                    if (endQuoteIndex == -1)
                    {
                        return this.formatWithInvalidFormat();
                    }
                    i = endQuoteIndex;
                }
                else if (letter == "%" || letter == "#")
				{
					prefix = letter;
				}
				else if (letter == "+")
				{
					if (prefix != "#")
					{
						return this.formatWithInvalidFormat();
					}
				}
				else if (this.VALID_PATTERN_LETTERS.indexOf(letter) != -1)
				{
					if (usedPatternLetters.indexOf(letter) != -1)
					{
						if (this.formatString.charAt(i - 1) != letter)
						{
							return this.formatWithInvalidFormat();
						}
					}
					else
					{
						if (prefix == "#" && this.VALID_ELAPSED_PATTERN_LETTERS.indexOf(letter) == -1)
						{
							return this.formatWithInvalidFormat();
						}
						if (prefix == "%" && this.VALID_ALTERNATE_START_OF_YEAR_PATTERN_LETTERS.indexOf(letter) == -1)
						{
							return this.formatWithInvalidFormat();
						}
						usedPatternLetters = (usedPatternLetters + letter);
						patternCount = (patternCount + 1);
					}
					prefix = null;
				}
				else
				{
					if (prefix != null)
					{
						return this.formatWithInvalidFormat();
					}
				}
                i++;
            }
            if (prefix != null)
            {
                return this.formatWithInvalidFormat();
            }
            if (patternCount == 0)
            {
                return this.formatWithInvalidFormat();
            }
            return this.formatImpl(value as Date);
        }

        protected function formatImpl(value:Date):String
        {
            var letter:String;
            var count:int;
            var text:String;
            var number:Number;
            var usePositiveSign:Boolean;
            var _local11:Boolean;
            var _local12:Number;
            var _local13:Number;
            var _local14:String;
            var _local15:String;
            var next:int;
            var count2:int;
            var j:int;
            var output:String = "";
            var prefix:String;
            var n:int = this.formatString.length;
            var i:int;
            while (i < n)
            {
                letter = this.formatString.charAt(i);
                count = 1;
                while ((i + count) < n && this.formatString.charAt(i + count) == letter)
                {
                    count++;
                }
                i = i + count - 1;
                switch (letter)
                {
                    case "'":
                        while (count > 1)
                        {
                            output = output + "'";
                            count = count - 2;
                        }
                        while (count > 0)
                        {
                            next = this.formatString.indexOf("'", (i + 1));
                            output = (output + this.formatString.substring((i + 1), next));
                            i = next;
                            count2 = 1;
                            while ((i + count2) < n && this.formatString.charAt(i + count2) == "'")
                            {
                                count2++;
                            }
                            i = i + count2 - 1;
                            while (count2 > 1)
                            {
                                output = output + "'";
                                count2 = count2 - 2;
                            }
                            count = count - count2;
                        }
                        break;
                    case "#":
                        prefix = letter;
                        break;
                    case "%":
                        prefix = letter;
                        usePositiveSign = false;
                        break;
                    case "+":
                        usePositiveSign = true;
                        break;
                    case "y":
                        if (prefix == "#")
                        {
                            number = this.calendar.getElapsedYears(this.referenceDate, value);
                            output = output + this.padNumberWithLeadingZeros(number, count, usePositiveSign);
                        }
                        else if (prefix == "%")
						{
							number = this.calendar.getUnitValue(value, TimeUnit.YEAR, this.startOfYear);
						}
						else
						{
							number = value.fullYear;
						}
						if (count == 1)
						{
							output = output + String(number);
						}
						else if (count == 2)
						{
							output = output + this.padStringWithLeadingZeros(String(number).substr(-2, 2), 2);
						}
						else
						{
							output = output + this.padNumberWithLeadingZeros(number, count);
						}
                        prefix = null;
                        break;
                    case "R":
                        if (prefix == "#")
                        {
                            number = this.calendar.getElapsedHalfYears(this.referenceDate, value);
                            output = (output + this.padNumberWithLeadingZeros(number, count, usePositiveSign));
                        }
                        else if (prefix == "%")
						{
							number = this.calendar.getUnitValue(value, TimeUnit.HALFYEAR, this.startOfYear);
						}
						else
						{
							number = this.calendar.getHalfYear(value);
						}
						if (count == 1)
						{
							output = output + String(number);
						}
						else if (count == 2)
						{
							output = output + this.padNumberWithLeadingZeros(number, count);
						}
						else
						{
							output = output + StringUtil.substitute(this._halfyearAbbreviatedFormat, number);
						}
                        prefix = null;
                        break;
                    case "Q":
                        if (prefix == "#")
                        {
                            number = this.calendar.getElapsedQuarters(this.referenceDate, value);
                            output = (output + this.padNumberWithLeadingZeros(number, count, usePositiveSign));
                        }
                        else if (prefix == "%")
						{
							number = this.calendar.getUnitValue(value, TimeUnit.QUARTER, this.startOfYear);
						}
						else
						{
							number = this.calendar.getQuarter(value);
						}
						if (count == 1)
						{
							output = output + String(number);
						}
						else if (count == 2)
						{
							output = output + this.padNumberWithLeadingZeros(number, count);
						}
						else if (count == 3)
						{
							output = output + StringUtil.substitute(this._quarterAbbreviatedFormat, number);
						}
                        prefix = null;
                        break;
                    case "M":
                        if (prefix == "#")
                        {
                            number = this.calendar.getElapsedMonths(this.referenceDate, value);
                            output = (output + this.padNumberWithLeadingZeros(number, count, usePositiveSign));
                        }
                        else if (prefix == "%")
						{
							number = this.calendar.getUnitValue(value, TimeUnit.MONTH, this.startOfYear);
						}
						else
						{
							number = value.month;
						}
						if (count == 1)
						{
							output = output + String(number + 1);
						}
						else if (count == 2)
						{
							output = output + this.padNumberWithLeadingZeros((number + 1), count);
						}
						else if (count == 3)
						{
							output = output + DateBase.monthNamesShort[number];
						}
						else if (count == 4)
						{
							output = output + DateBase.monthNamesLong[number];
						}
						else if (count == 5)
						{
							output = output + this.monthNamesNarrow[number];
						}
                        prefix = null;
                        break;
                    case "w":
                        if (prefix == "#")
                        {
                            number = this.calendar.getElapsedWeeks(this.referenceDate, value);
                            output = output + this.padNumberWithLeadingZeros(number, count, usePositiveSign);
                        }
                        else if (prefix == "%")
						{
							number = this.calendar.getUnitValue(value, TimeUnit.WEEK, this.startOfYear);
						}
						else
						{
							number = this.calendar.getWeek(value);
						}
						if (count == 1)
						{
							output = output + String(number);
						}
						else
						{
							output = output + this.padNumberWithLeadingZeros(number, count > 2 ? 2 : count);
						}
                        prefix = null;
                        break;
                    case "d":
                        if (prefix == "#")
                        {
                            number = this.calendar.getElapsedDays(this.referenceDate, value);
                            output = output + this.padNumberWithLeadingZeros(number, count, usePositiveSign);
                        }
                        else if (prefix == "%")
						{
							number = this.calendar.getUnitValue(value, TimeUnit.DAY, this.startOfYear);
						}
						else
						{
							number = value.date;
						}
						if (count == 1)
						{
							output = output + String(number);
						}
						else
						{
							output = output + this.padNumberWithLeadingZeros(number, count > 2 ? 2 : count);
						}
                        prefix = null;
                        break;
                    case "D":
                        if (prefix == "#")
                        {
                            number = this.calendar.getElapsedDays(this.referenceDate, value);
                            output = output + this.padNumberWithLeadingZeros(number, count, usePositiveSign);
                        }
                        else if (prefix == "%")
						{
							number = this.calendar.getDayOfYear(value);
						}
						else
						{
							number = this.calendar.getDayOfYear(value);
						}
						if (count == 1)
						{
							output = output + String(number);
						}
						else
						{
							output = output + this.padNumberWithLeadingZeros(number, count > 3 ? 3 : count);
						}
                        prefix = null;
                        break;
                    case "E":
                        if (prefix == "#")
                        {
                            number = this.calendar.getElapsedDays(this.referenceDate, value);
                            output = output + this.padNumberWithLeadingZeros(number, count, usePositiveSign);
                        }
                        else
                        {
                            number = value.day;
                            if (count < 4)
                            {
                                output = output + DateBase.dayNamesShort[number];
                            }
                            else if (count == 4)
							{
								output = output + DateBase.dayNamesLong[number];
							}
							else if (count == 5)
							{
								output = output + this.dayNamesNarrow[number];
							}
                        }
                        prefix = null;
                        break;
                    case "e":
                        if (prefix == "#")
                        {
                            number = this.calendar.getElapsedDays(this.referenceDate, value);
                            output = output + this.padNumberWithLeadingZeros(number, count, usePositiveSign);
                        }
                        else
                        {
                            number = value.day;
                            if (count == 1)
                            {
                                output = output + String(number + this.calendar.firstDayOfWeek + 1);
                            }
                            else if (count == 2)
							{
								output = output + this.padNumberWithLeadingZeros(number + this.calendar.firstDayOfWeek + 1, 2);
							}
							else if (count == 3)
							{
								output = output + DateBase.dayNamesShort[number];
							}
							else if (count == 4)
							{
								output = output + DateBase.dayNamesLong[number];
							}
							else if (count == 5)
							{
								output = output + this.dayNamesNarrow[number];
							}
                        }
                        prefix = null;
                        break;
                    case "a":
                        if (prefix == "%")
                        {
                            number = this.calendar.getUnitValue(value, TimeUnit.HOUR_CALENDAR, this.startOfYear);
                        }
                        else
                        {
                            number = value.hours;
                        }
                        number = number < 12 ? 0 : 1;
                        output = output + DateBase.timeOfDay[number];
                        prefix = null;
                        break;
                    case "U":
                        if (prefix == "%")
                        {
                            number = this.calendar.getUnitValue(value, TimeUnit.HOUR_CALENDAR, this.startOfYear);
                        }
                        else
                        {
                            number = value.hours;
                        }
                        output = output + (number < 12 ? this._periodAMStandaloneText : this._periodPMStandaloneText);
                        prefix = null;
                        break;
                    case "h":
                        if (prefix == "#")
                        {
                            number = this.calendar.getElapsedHours(this.referenceDate, value);
                            output = (output + this.padNumberWithLeadingZeros(number, count, usePositiveSign));
                        }
                        else if (prefix == "%")
						{
							number = this.calendar.getUnitValue(value, TimeUnit.HOUR, this.startOfYear);
						}
						else
						{
							number = value.hours;
						}
						number = (number % 12);
						if (number == 0)
						{
							number = 12;
						}
						if (count == 1)
						{
							output = output + String(number);
						}
						else
						{
							output = output + this.padNumberWithLeadingZeros(number, count > 2 ? 2 : count);
						}
                        prefix = null;
                        break;
                    case "H":
                        if (prefix == "#")
                        {
                            number = this.calendar.getElapsedHours(this.referenceDate, value);
                            output = (output + this.padNumberWithLeadingZeros(number, count, usePositiveSign));
                        }
                        else if (prefix == "%")
						{
							number = this.calendar.getUnitValue(value, TimeUnit.HOUR, this.startOfYear);
						}
						else
						{
							number = value.hours;
						}
						if (count == 1)
						{
							output = output + String(number);
						}
						else
						{
							output = output + this.padNumberWithLeadingZeros(number, count > 2 ? 2 : count);
						}
                        prefix = null;
                        break;
                    case "K":
                        if (prefix == "#")
                        {
                            number = this.calendar.getElapsedHours(this.referenceDate, value);
                            output = (output + this.padNumberWithLeadingZeros(number, count, usePositiveSign));
                        }
                        else if (prefix == "%")
						{
							number = this.calendar.getUnitValue(value, TimeUnit.HOUR, this.startOfYear);
						}
						else
						{
							number = value.hours;
						}
						number = (number % 12);
						if (count == 1)
						{
							output = output + String(number);
						}
						else
						{
							output = output + this.padNumberWithLeadingZeros(number, count > 2 ? 2 : count);
						}
                        prefix = null;
                        break;
                    case "k":
                        if (prefix == "#")
                        {
                            number = this.calendar.getElapsedHours(this.referenceDate, value);
                            output = (output + this.padNumberWithLeadingZeros(number, count, usePositiveSign));
                        }
                        else if (prefix == "%")
						{
							number = this.calendar.getUnitValue(value, TimeUnit.HOUR, this.startOfYear);
						}
						else
						{
							number = value.hours;
						}
						if (number == 0)
						{
							number = 24;
						}
						if (count == 1)
						{
							output = output + String(number);
						}
						else
						{
							output = output + this.padNumberWithLeadingZeros(number, count > 2 ? 2 : count);
						}
                        prefix = null;
                        break;
                    case "m":
                        if (prefix == "#")
                        {
                            number = this.calendar.getElapsedMinutes(this.referenceDate, value);
                            output = (output + this.padNumberWithLeadingZeros(number, count, usePositiveSign));
                        }
                        else if (prefix == "%")
						{
							number = this.calendar.getUnitValue(value, TimeUnit.MINUTE, this.startOfYear);
						}
						else
						{
							number = value.minutes;
						}
						if (count == 1)
						{
							output = output + String(number);
						}
						else
						{
							output = output + this.padNumberWithLeadingZeros(number, count > 2 ? 2 : count);
						}
                        prefix = null;
                        break;
                    case "s":
                        if (prefix == "#")
                        {
                            number = this.calendar.getElapsedSeconds(this.referenceDate, value);
                            output = (output + this.padNumberWithLeadingZeros(number, count, usePositiveSign));
                        }
                        else if (prefix == "%")
						{
							number = this.calendar.getUnitValue(value, TimeUnit.SECOND, this.startOfYear);
						}
						else
						{
							number = value.seconds;
						}
						if (count == 1)
						{
							output = output + String(number);
						}
						else
						{
							output = output + this.padNumberWithLeadingZeros(number, count > 2 ? 2 : count);
						}
                        prefix = null;
                        break;
                    case "S":
                        if (prefix == "%")
                        {
                            number = this.calendar.getUnitValue(value, TimeUnit.MILLISECOND, this.startOfYear);
                        }
                        else
                        {
                            number = value.milliseconds;
                        }
                        if (count == 1)
                        {
                            number = Math.floor(number / 100);
                        }
                        else if (count == 2)
						{
							number = Math.floor(number / 10);
						}
                        if (count == 1)
                        {
                            output = output + String(number);
                        }
                        else
                        {
                            output = output + this.padNumberWithLeadingZeros(number, count > 3 ? 3 : count);
                        }
                        prefix = null;
                        break;
                    case "b":
                        if (prefix == "#")
                        {
                            number = this.calendar.getElapsedMilliseconds(this.referenceDate, value);
                            output = (output + this.padNumberWithLeadingZeros(number, count, usePositiveSign));
                        }
                        else if (prefix == "%")
						{
							number = this.calendar.getUnitValue(value, TimeUnit.MILLISECOND, this.startOfYear);
						}
						else
						{
							number = value.milliseconds;
						}
						if (count == 1)
						{
							output = output + String(number);
						}
						else
						{
							output = output + this.padNumberWithLeadingZeros(number, count > 3 ? 3 : count);
						}
                        prefix = null;
                        break;
                    case "Z":
                        number = -(value.timezoneOffset);
                        _local11 = (number < 0);
                        if (_local11)
                        {
                            number = -(number);
                        }
                        _local12 = Math.floor((number / 60));
                        _local13 = (number - (_local12 * 60));
                        _local14 = this.padNumberWithLeadingZeros(((_local11) ? -(_local12) : _local12), 2, true);
                        _local15 = this.padNumberWithLeadingZeros(_local13, 2);
                        if (count <= 3)
                        {
                            output = (output + (_local14 + _local15));
                        }
                        else if (count == 4)
						{
							output = (output + StringUtil.substitute(this._gmtFormat, _local14, _local15));
						}
                        prefix = null;
                        break;
                    default:
                        j = 0;
                        while (j < count)
                        {
                            output = (output + letter);
                            j++;
                        }
                }
                i++;
            }
            return output;
        }

		public function padNumberWithLeadingZeros(value:Number, paddedLength:Number, usePositiveSign:Boolean=false):String
        {
            var isNegative:Boolean = (value < 0);
            if (isNegative)
            {
                value = -value;
            }
            var paddedString:String = this.padStringWithLeadingZeros(String(value), paddedLength);
            if (isNegative)
            {
                return this._negativeSign + paddedString;
            }
            if (usePositiveSign && value != 0)
            {
                return this._positiveSign + paddedString;
            }
            return paddedString;
        }

		public function padStringWithLeadingZeros(value:String, paddedLength:Number):String
        {
            if (value.length >= paddedLength)
            {
                return value;
            }
            return this.createZerosPadding(paddedLength - value.length) + value;
        }

        private function createZerosPadding(count:int):String
        {
            var pad:String = "";
            var i:int;
            while (i < count)
            {
                pad = pad + "0";
                i++;
            }
            return pad;
        }

        private function formatWithInvalidFormat():String
        {
            error = defaultInvalidFormatError;
            return "";
        }

        private function formatWithInvalidValue():String
        {
            error = defaultInvalidValueError;
            return "";
        }

        override protected function resourcesChanged():void
        {
            super.resourcesChanged();
            this._halfyearAbbreviatedFormat = this.getPropertyValue("mokylinsparkutilities", "halfyear.abbreviated.format", "H{0}");
            this._quarterAbbreviatedFormat = this.getPropertyValue("mokylinsparkutilities", "quarter.abbreviated.format", "Q{0}");
            this._periodAMStandaloneText = this.getPropertyValue("mokylinsparkutilities", "period.am.standalone.text", "AM");
            this._periodPMStandaloneText = this.getPropertyValue("mokylinsparkutilities", "period.pm.standalone.text", "PM");
            this._gmtFormat = this.getPropertyValue("mokylinsparkutilities", "gmt.format", "GMT{0}{1}");
            this._positiveSign = this.getPropertyValue("mokylinsparkutilities", "positive.sign.text", "+");
            this._negativeSign = this.getPropertyValue("mokylinsparkutilities", "negative.sign.text", "−");
            this._defaultFormatString = this.getPropertyValue("mokylinsparkutilities", "default.date.format", "MM/dd/yyyy");
            this._defaultDayNamesNarrow = this.getStringArrayPropertyValue("controls", "dayNamesShortest", ["S", "M", "T", "W", "T", "F", "S"]);
            this._defaultMonthNamesNarrow = this.getStringArrayPropertyValue("mokylinsparkutilities", "month.names.narrow", ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"]);
        }

        private function getPropertyValue(bundleName:String, propertyName:String, defaultValue:String):String
        {
            var propertyValue:String = resourceManager.getString(bundleName, propertyName);
            if (propertyValue != null)
            {
                return propertyValue;
            }
            return defaultValue;
        }

        private function getStringArrayPropertyValue(bundleName:String, propertyName:String, defaultValue:Array):Array
        {
            var propertyValue:Array = resourceManager.getStringArray(bundleName, propertyName);
            if (propertyValue != null)
            {
                return propertyValue;
            }
            return defaultValue;
        }
    }
}
