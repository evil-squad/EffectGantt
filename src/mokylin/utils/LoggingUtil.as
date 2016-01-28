package mokylin.utils
{
    import flash.utils.getQualifiedClassName;
    import mx.logging.Log;
    import mx.logging.ILogger;
    import mx.resources.IResourceManager;
    import mx.logging.LogEventLevel;

    [ExcludeClass]
    public class LoggingUtil 
    {
        private static function getLogger(clazz:Class):ILogger
        {
            var qname:String = getQualifiedClassName(clazz);
            qname = qname.replace("::", ".");
            return Log.getLogger(qname);
        }

        public static function info(clazz:Class, resourceManager:IResourceManager, bundleName:String, resourceName:String, parameters:Array=null, locale:String=null):void
        {
            if (Log.isInfo())
            {
                getLogger(clazz).info(resourceManager.getString(bundleName, resourceName, parameters, locale));
            }
        }

        public static function warn(clazz:Class, resourceManager:IResourceManager, bundleName:String, resourceName:String, parameters:Array=null, locale:String=null):void
        {
            if (Log.isWarn())
            {
                getLogger(clazz).warn(resourceManager.getString(bundleName, resourceName, parameters, locale));
            }
        }

        public static function error(clazz:Class, resourceManager:IResourceManager, bundleName:String, resourceName:String, parameters:Array=null, locale:String=null):void
        {
            if (Log.isError())
            {
                getLogger(clazz).error(resourceManager.getString(bundleName, resourceName, parameters, locale));
            }
        }

        public static function debug(clazz:Class, resourceManager:IResourceManager, bundleName:String, resourceName:String, parameters:Array=null, locale:String=null):void
        {
            if (Log.isDebug())
            {
                getLogger(clazz).debug(resourceManager.getString(bundleName, resourceName, parameters, locale));
            }
        }

        public static function fatal(clazz:Class, resourceManager:IResourceManager, bundleName:String, resourceName:String, parameters:Array=null, locale:String=null):void
        {
            if (Log.isFatal())
            {
                getLogger(clazz).fatal(resourceManager.getString(bundleName, resourceName, parameters, locale));
            }
        }

        public static function logCategory(category:String, level:int, message:String, parameters:Array=null):void
        {
            if (isLoggable(level))
            {
                Log.getLogger(category).log(level, message, parameters);
            }
        }

        public static function log(clazz:Class, level:int, message:String):void
        {
            if (isLoggable(level))
            {
                getLogger(clazz).log(level, message);
            }
        }

        private static function isLoggable(level:int):Boolean
        {
            switch (level)
            {
                case LogEventLevel.ALL:
                    return true;
                case LogEventLevel.DEBUG:
                    return Log.isDebug();
                case LogEventLevel.FATAL:
                    return Log.isFatal();
                case LogEventLevel.ERROR:
                    return Log.isError();
                case LogEventLevel.WARN:
                    return Log.isWarn();
                case LogEventLevel.INFO:
                    return Log.isInfo();
            }
            return false;
        }
    }
}
