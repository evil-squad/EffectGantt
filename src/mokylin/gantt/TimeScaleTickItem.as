package mokylin.gantt
{
    import mokylin.core.elixir_internal;

    use namespace elixir_internal;
	/**
	 * tick的数据载体 
	 * @author NEIL
	 * 
	 */
    public class TimeScaleTickItem 
    {
        public var value:Number;
        public var isSubTick:Boolean;
        public var label:String;
        elixir_internal var labelOffset:Number = NaN;
    }
}
