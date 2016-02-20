package mokylin.utils
{
    import mx.resources.ResourceManager;
	/**
	 * 时间刻度的枚举 
	 * @author NEIL
	 * 
	 */
    [ExcludeClass]
    public class TimeIterator implements IIterator 
    {

        private var _sampler:TimeSampler;
        private var _next:Date;
        private var _endReached:Boolean;

        public function TimeIterator(sampler:TimeSampler)
        {
            this._sampler = sampler;
            this._endReached = false;
            this.goFirst();
        }

        public function hasNext():Boolean
        {
            return !this._endReached;
        }

        public function next():Object
        {
            var value:Date = this._next;
            if (this._endReached)
            {
                throw new Error(ResourceUtil.getError(ResourceUtil.ELIXIR_UTILITIES, 5, ResourceManager.getInstance(), "mokylinutils", "read.past.end"));
            }
            this.goNext();
            return value;
        }

        final private function goFirst():void
        {
            this._next = this._sampler.getFirstTime();
            this.checkEndReached();
        }

        final private function goNext():void
        {
            this._next = this._sampler.getNextTime(this._next);
            this.checkEndReached();
        }

        final private function checkEndReached():void
        {
            if (this._next > this._sampler.end)
            {
                this._endReached = true;
            }
        }
    }
}
