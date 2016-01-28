package mokylin.gantt
{
    import mx.core.UIComponent;
    import mx.core.IFactory;
    import flash.display.DisplayObject;
    import mx.core.FlexShape;
    import mx.core.IDataRenderer;

    [ExcludeClass]
    public class GanttSheetGridRendererContainer extends UIComponent 
    {

        private var _rendererIndex:int;
        public var itemSkin:IFactory;

        public function GanttSheetGridRendererContainer()
        {
            mouseEnabled = false;
        }

		public function startRendering():void
        {
            this._rendererIndex = 0;
        }

		public function stopRendering():void
        {
            while (numChildren > this._rendererIndex)
            {
                removeChildAt(this._rendererIndex);
            }
        }

        private function createRenderer():DisplayObject
        {
            return this.itemSkin != null ? this.itemSkin.newInstance() as DisplayObject : new FlexShape();
        }

		public function useRenderer(data:Object):DisplayObject
        {
            var renderer:DisplayObject;
            if (this._rendererIndex >= numChildren)
            {
                renderer = this.createRenderer();
                addChild(renderer);
            }
            else
            {
                renderer = getChildAt(this._rendererIndex);
            }
            if (renderer is IDataRenderer)
            {
                IDataRenderer(renderer).data = data;
            }
            this._rendererIndex++;
            return renderer;
        }
    }
}
