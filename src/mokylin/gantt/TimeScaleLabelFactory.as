package mokylin.gantt
{
    import mx.core.IFactory;

    [ExcludeClass]
    public class TimeScaleLabelFactory implements IFactory 
    {

        private var _context:TimeScaleRow;

        public function TimeScaleLabelFactory(context:TimeScaleRow)
        {
            this._context = context;
        }

        public function newInstance():*
        {
            return this._context.createDefaultLabel();
        }
    }
}
