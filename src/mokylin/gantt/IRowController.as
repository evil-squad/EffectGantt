package mokylin.gantt
{
    [ExcludeClass]
    public interface IRowController 
    {
        function calculateGanttSheetRowHeight(_arg1:Object):Number;
        function getRowPosition(_arg1:Object):Number;
        function getRowHeight(_arg1:Object):Number;
        function getVisibleItems():Array;
        function getItemAt(_arg1:Number):Object;
        function getItemIndex(_arg1:Object):int;
        function getItemCount():uint;
        function isItemVisible(_arg1:Object):Boolean;
        function invalidateItemsSize():void;
        function scroll(_arg1:Number, _arg2:String):Number;
		/**
		 * 一个标志，指示各行是否可以采用不同的高度。TileList 和 HorizontalList 将忽略此属性。如果设置为 true，则各行可以具有不同的高度值。 
		 * @return 
		 * 
		 */		
        function get variableRowHeight():Boolean;
        function validateHeaderSize():void;
    }
}
