package mokylin.utils
{
    import mx.binding.utils.BindingUtils;

    [ExcludeClass]
    public class DataUtil 
    {
        public static function getFieldValue(data:Object, field:Object, defaultValue:Object=null, fieldFunction:Function=null):Object
        {
            var r:Object;
            if (fieldFunction != null)
            {
                return fieldFunction(data);
            }
            if (data is XML)
            {
                r = data[field];
                if (r is XMLList)
                {
                    r = r.toString();
                    if (r.length == 0)
                    {
                        r = defaultValue;
                    }
                }
            }
            else
            {
                if (data.hasOwnProperty(field))
                {
                    r = data[field];
                }
                else
                {
                    r = defaultValue;
                }
            }
            return r;
        }

        public static function wrapProperty(obj1:Object, prop1:String, obj2:Object, prop2:String=null):void
        {
            if (prop2 == null)
            {
                prop2 = prop1;
            }
            if (obj1[prop1] != null)
            {
                obj2[prop2] = obj1[prop1];
            }
            BindingUtils.bindProperty(obj1, prop1, obj2, prop2);
            BindingUtils.bindProperty(obj2, prop2, obj1, prop1);
        }
    }
}
