package mokylin.gantt.supportClasses
{
    import mx.resources.ResourceManager;
    import mx.resources.IResourceManager;
    import mokylin.utils.LoggingUtil;
    import mx.logging.LogEventLevel;

    [ExcludeClass]
    [ResourceBundle("mokylingantt")]
    public final class MessageUtil 
    {
        public static function getMessage(bundleName:String, resourceName:String, parameters:Array=null, resourceManager:IResourceManager=null):String
        {
            if (resourceManager == null)
            {
                resourceManager = ResourceManager.getInstance();
            }
            var msg:String = resourceManager.getString(bundleName, resourceName, parameters);
            var messageWithID:String = resourceManager.getString("mokylingantt", "logged.message.format", [getMessageUniqueID(resourceName), msg]);
            return messageWithID;
        }

        public static function log(clazz:Class, level:int, bundleName:String, resourceName:String, parameters:Array=null, resourceManager:IResourceManager=null):String
        {
            var msg:String = getMessage(bundleName, resourceName, parameters, resourceManager);
            LoggingUtil.log(clazz, level, msg);
            return msg;
        }

        public static function wrongArgument(clazz:Class, method:String, argument:String, resourceManager:IResourceManager=null):Error
        {
            var msg:String = log(clazz, LogEventLevel.ERROR, GanttProperties.ELIXIR_GANTT_BUNDLE, GanttProperties.INVALID_ARGUMENT_MESSAGE, [method, argument], resourceManager);
            return new ArgumentError(msg);
        }

        private static function getMessageUniqueID(resourceName:String):String
        {
            var index:int = resourceName.lastIndexOf(".");
            return index != -1 ? resourceName.substr(index + 1) : "";
        }
    }
}
