package mokylin.gantt
{
    import flash.geom.Rectangle;

    public interface IConstraintConnectionBounds 
    {
        function measureConnectionBounds():void;
        function get connectionBounds():Rectangle;
    }
}
