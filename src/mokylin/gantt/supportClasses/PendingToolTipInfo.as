package mokylin.gantt.supportClasses
{
    import flash.utils.Timer;
    import flash.display.DisplayObject;

    [ExcludeClass]
    public class PendingToolTipInfo 
    {

        public var timer:Timer;
        public var renderer:DisplayObject;
        public var text:String;

        public function PendingToolTipInfo(timer:Timer, renderer:DisplayObject, text:String)
        {
            this.timer = timer;
            this.renderer = renderer;
            this.text = text;
        }

    }
}
