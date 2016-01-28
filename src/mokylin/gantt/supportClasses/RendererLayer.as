package mokylin.gantt.supportClasses
{
    import flash.display.DisplayObjectContainer;
    import mx.core.IFactory;
    import mx.core.UIComponent;
    import flash.display.DisplayObject;
    import mx.core.IFlexDisplayObject;
    import mx.styles.ISimpleStyleClient;
    import mx.core.IProgrammaticSkin;
    import mx.core.IDataRenderer;

    [ExcludeClass]
    public class RendererLayer 
    {

        protected var _parent:DisplayObjectContainer;
        protected var _containerName:String;
        protected var _rendererStyleName:Object;
        protected var _rendererFactory:IFactory;
        protected var _dataToStyleNameFunction:Function;
        protected var _rendererContainer:UIComponent;
        protected var _unusedRendererPool:RendererPool;
        protected var _renderers:Array;
        protected var _uidToRenderer:Object;
        public var addBefore:String;
        public var addAfter:String;
        public var addFirst:Boolean;
        public var addLast:Boolean = true;

        public function RendererLayer(parent:DisplayObjectContainer, containerName:String, rendererStyleName:Object)
        {
            this._renderers = [];
            this._uidToRenderer = {};
            super();
            this._parent = parent;
            this._containerName = containerName;
            this._rendererStyleName = rendererStyleName;
        }

        public function get rendererFactory():IFactory
        {
            return this._rendererFactory;
        }

        public function set rendererFactory(value:IFactory):void
        {
            this._rendererFactory = value;
            this.clear();
        }

        public function set dataToStyleNameFunction(value:Function):void
        {
            this._dataToStyleNameFunction = value;
        }

        public function get renderers():Array
        {
            return this._renderers;
        }

        public function get rendererContainer():UIComponent
        {
            return this._rendererContainer;
        }

        public function createRendererContainer():void
        {
            if (this._rendererContainer)
            {
                return;
            }
            this._rendererContainer = new UIComponent();
            this._rendererContainer.name = this._containerName;
            this._rendererContainer.mouseEnabled = false;
            this._rendererContainer.includeInLayout = false;
            this.addRendererContainerToParent();
            this.createRendererPool();
        }

        private function removeRendererContainer():void
        {
            if (!this._rendererContainer)
            {
                return;
            }
            this._parent.removeChild(this._rendererContainer);
            this._rendererContainer = null;
            this._unusedRendererPool = null;
        }

        private function addRendererContainerToParent():void
        {
            var index:int;
            var other:DisplayObject;
            if (this.addBefore)
            {
                other = this._parent.getChildByName(this.addBefore);
                index = other ? this._parent.getChildIndex(other) : this._parent.numChildren;
            }
            else if (this.addAfter)
			{
				other = this._parent.getChildByName(this.addAfter);
				index = other ? (this._parent.getChildIndex(other) + 1) : this._parent.numChildren;
			}
            else if (this.addFirst)
			{
				index = 0;
			} 
            else if (this.addLast)
			{
				index = this._parent.numChildren;
			}
            else
            {
                index = this._parent.numChildren;
            }
            this._parent.addChildAt(this._rendererContainer, index);
        }

        public function createRenderer(data:Object=null, uid:String=null):IFlexDisplayObject
        {
            var styleName:Object;
            if (!this._unusedRendererPool)
            {
                return null;
            }
            var renderer:IFlexDisplayObject = IFlexDisplayObject(this._unusedRendererPool.getInstance());
            if (this._dataToStyleNameFunction != null && data)
            {
                styleName = this._dataToStyleNameFunction(data);
            }
            else
            {
                if (this._rendererStyleName)
                {
                    styleName = this._rendererStyleName;
                }
            }
            if (renderer is ISimpleStyleClient && styleName)
            {
                ISimpleStyleClient(renderer).styleName = styleName;
                if (renderer is IProgrammaticSkin)
                {
                    ISimpleStyleClient(renderer).styleChanged(null);
                }
            }
            if (renderer is IDataRenderer)
            {
                IDataRenderer(renderer).data = data;
            }
            this._renderers.push(renderer);
            if (uid)
            {
                this._uidToRenderer[uid] = renderer;
            }
            return renderer;
        }

        public function recycleRenderer(renderer:IFlexDisplayObject, uid:String=null):void
        {
            var index:int = this._renderers.indexOf(renderer);
            if (index >= 0)
            {
                this._renderers.splice(index, 1);
            }
            if (this._unusedRendererPool)
            {
                this._unusedRendererPool.recycle(renderer);
            }
            if (uid)
            {
                delete this._uidToRenderer[uid];
            }
        }

        public function recycleAllRenderers():void
        {
            if (this._unusedRendererPool)
            {
                this._unusedRendererPool.recycleAll(this._renderers);
            }
            this._renderers = [];
            this._uidToRenderer = {};
        }

        public function uidToRenderer(uid:String):IFlexDisplayObject
        {
            if (uid)
            {
                return this._uidToRenderer[uid];
            }
            return null;
        }

        public function clear():void
        {
            this._renderers = [];
            this._uidToRenderer = [];
            if (this._rendererContainer)
            {
                this.removeRendererContainer();
                this.createRendererContainer();
            }
        }

        private function createRendererPool():void
        {
            if (this._rendererContainer && this._rendererFactory)
            {
                this._unusedRendererPool = new RendererPool(this._rendererFactory, this._rendererContainer);
            }
            else
            {
                this._unusedRendererPool = null;
            }
        }
    }
}