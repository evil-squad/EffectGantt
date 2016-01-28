package mokylin.gantt.supportClasses
{
    import mx.core.IChildList;
    import mx.core.IFactory;
    import flash.display.DisplayObject;
    import mx.core.IFlexDisplayObject;

    [ExcludeClass]
    public class RendererPool extends InstancePool 
    {
        protected var _container:IChildList;

        public function RendererPool(factory:IFactory, container:IChildList)
        {
            super(factory);
            this._container = container;
        }

        override protected function instanceCreated(value:Object):void
        {
            this._container.addChild(DisplayObject(value));
        }

        override protected function instanceReused(value:Object):void
        {
            IFlexDisplayObject(value).visible = true;
        }

        override protected function instanceRecycled(value:Object):void
        {
            IFlexDisplayObject(value).visible = false;
        }

        override protected function instanceRemoved(value:Object):void
        {
            this._container.removeChild(DisplayObject(value));
        }
    }
}
