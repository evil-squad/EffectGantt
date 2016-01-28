package mokylin.utils
{
    import mx.resources.IResourceManager;
    import mx.logging.LogEventLevel;

    [ExcludeClass]
    public final class ResourceUtil 
    {
        private static const ELIXIR_PREFIX:String = "CWZEF";
        public static const ELIXIR_RADAR:String = 		ELIXIR_PREFIX + "1";
        public static const ELIXIR_PIVOT:String = 		ELIXIR_PREFIX + "1";
        public static const ELIXIR_CHARTS3D:String = 	ELIXIR_PREFIX + "1";
        public static const ELIXIR_GAUGES:String = 		ELIXIR_PREFIX + "2";
        public static const ELIXIR_INDICATORS:String = 	ELIXIR_PREFIX + "2";
        public static const ELIXIR_HEATMAP:String = 	ELIXIR_PREFIX + "3";
        public static const ELIXIR_MAPS:String = 		ELIXIR_PREFIX + "3";
        public static const ELIXIR_CALENDAR:String = 	ELIXIR_PREFIX + "4";
        public static const ELIXIR_TIMELINE:String = 	ELIXIR_PREFIX + "4";
        public static const ELIXIR_ORGCHART:String = 	ELIXIR_PREFIX + "5";
        public static const ELIXIR_TREEMAP:String = 	ELIXIR_PREFIX + "5";
        public static const ELIXIR_UTILITIES:String = 	ELIXIR_PREFIX + "6";


        public static function getInfo(module:String, messageNumber:uint, resourceManager:IResourceManager, 
									   bundleName:String, resourceName:String, parameters:Array=null):String
        {
            var msgId:String = getMessageUniqueID(module, messageNumber, "I");
            return msgId + ": " + getMessage(resourceManager, bundleName, resourceName + "." + msgId, parameters);
        }

        public static function getWarning(module:String, messageNumber:uint, resourceManager:IResourceManager, 
										  bundleName:String, resourceName:String, parameters:Array=null):String
        {
            var msgId:String = getMessageUniqueID(module, messageNumber, "W");
            return msgId + ": " + getMessage(resourceManager, bundleName, resourceName + "." + msgId, parameters);
        }

        public static function getError(module:String, messageNumber:uint, resourceManager:IResourceManager, 
										bundleName:String, resourceName:String, parameters:Array=null):String
        {
            var msgId:String = getMessageUniqueID(module, messageNumber, "E");
            return msgId + ": " + getMessage(resourceManager, bundleName, resourceName + "." + msgId, parameters);
        }

        public static function logInfo(clazz:Class, module:String, messageNumber:uint, resourceManager:IResourceManager, 
									   bundleName:String, resourceName:String, parameters:Array=null):void
        {
            LoggingUtil.log(clazz, LogEventLevel.INFO, getInfo(module, messageNumber, resourceManager, bundleName, resourceName, parameters));
        }

        public static function logWarning(clazz:Class, module:String, messageNumber:uint, resourceManager:IResourceManager, 
										  bundleName:String, resourceName:String, parameters:Array=null):void
        {
            LoggingUtil.log(clazz, LogEventLevel.WARN, getWarning(module, messageNumber, resourceManager, bundleName, resourceName, parameters));
        }

        public static function logAndThrowError(clazz:Class, module:String, messageNumber:uint, resourceManager:IResourceManager, 
												bundleName:String, resourceName:String, parameters:Array=null):void
        {
            var msg:String = getError(module, messageNumber, resourceManager, bundleName, resourceName, parameters);
            LoggingUtil.log(clazz, LogEventLevel.ERROR, msg);
            throw new Error(msg);
        }

        private static function getMessage(resourceManager:IResourceManager, bundleName:String, resourceName:String, parameters:Array=null):String
        {
            return resourceManager.getString(bundleName, resourceName, parameters);
        }

        private static function getMessageUniqueID(module:String, messageNumber:uint, type:String):String
        {
            return module + formatNumber(messageNumber, 9 - module.length) + type;
        }

        private static function formatNumber(messageNumber:uint, length:uint):String
        {
            var str:String = "0000" + messageNumber.toString();
            return str.substr(str.length - length, length);
        }
    }
}
