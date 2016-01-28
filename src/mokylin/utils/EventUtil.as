package mokylin.utils
{
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    
    import mokylin.ModifierKey;

    [ExcludeClass]
    public class EventUtil 
    {
        public static function isMatching(event:Object, modifier:String):Boolean
        {
            if (event is MouseEvent || event is KeyboardEvent)
            {
                if (event.ctrlKey && modifier == ModifierKey.CTRL && !event.altKey && !event.shiftKey)
                {
                    return true;
                }
                if (event.altKey && modifier == ModifierKey.ALT && !event.ctrlKey && !event.shiftKey)
                {
                    return true;
                }
                if (event.shiftKey && modifier == ModifierKey.SHIFT && !event.ctrlKey && !event.altKey)
                {
                    return true;
                }
                if (!event.ctrlKey && !event.altKey && !event.shiftKey && modifier == ModifierKey.NONE)
                {
                    return true;
                }
            }
            return false;
        }

        public static function hasModifier(event:Object, modifier:String):Boolean
        {
            if (event is MouseEvent || event is KeyboardEvent)
            {
                if (event.ctrlKey && modifier == ModifierKey.CTRL)
                {
                    return true;
                }
                if (event.altKey && modifier == ModifierKey.ALT)
                {
                    return true;
                }
                if (event.shiftKey && modifier == ModifierKey.SHIFT)
                {
                    return true;
                }
                if (modifier == ModifierKey.NONE)
                {
                    return true;
                }
            }
            return false;
        }
    }
}
