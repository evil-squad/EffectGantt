package mokylin.utils
{
    [ExcludeClass]
    public interface IIterator 
    {
        function hasNext():Boolean;
        function next():Object;
    }
}
