package mokylin.gantt
{
    import mokylin.core.elixir_internal;

    use namespace elixir_internal;

    public class TimeScaleTickItem 
    {
        public var value:Date;
        public var isSubTick:Boolean;
        public var label:String;
        elixir_internal var labelOffset:Number = NaN;
    }
}
