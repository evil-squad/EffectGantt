package mokylin.utils
{
    import mx.core.UIComponent;
    import mx.core.IFlexDisplayObject;
    import mx.styles.IStyleClient;
	/**
	 * 鼠标指针样式 
	 * @author neil
	 * 
	 */
    [ExcludeClass]
    public class Cursor 
    {
        private var _target:UIComponent;
        private var _styleProperty:String;
        private var _offsetStyleProperty:String;
        private var _class:Class;
        private var _xOffset:Number;
        private var _yOffset:Number;
        private var _isValid:Boolean;
        private var _id:int = -1;

        public function Cursor(target:UIComponent, styleProperty:String, offsetStyleProperty:String=null)
        {
            this._target = target;
            this._styleProperty = styleProperty;
            this._offsetStyleProperty = offsetStyleProperty;
            this._isValid = false;
        }

        public function get isInstalled():Boolean
        {
            return this._id != -1;
        }

        public function setCursor(priority:int=2):void
        {
            if (this.isInstalled)
            {
                return;
            }
            this.validate();
            if (this._class)
            {
                this._id = this._target.cursorManager.setCursor(this._class, priority, this._xOffset, this._yOffset);
            }
        }

        public function removeCursor():void
        {
            if (!this.isInstalled)
            {
                return;
            }
            this._target.cursorManager.removeCursor(this._id);
            this._id = -1;
        }

        public function styleChanged(styleProp:String, allStyles:Boolean=false):void
        {
            if (!styleProp || allStyles || styleProp == this._styleProperty || styleProp == this._offsetStyleProperty)
            {
                this._isValid = false;
            }
        }

        private function validate():void
        {
            var c:*;
            var d:IFlexDisplayObject;
            if (this._isValid)
            {
                return;
            }
            this._isValid = true;
            var styleClient:IStyleClient = IStyleClient(this._target);
            this._class = styleClient.getStyle(this._styleProperty);
            this._xOffset = 0;
            this._yOffset = 0;
            if (!this._class)
            {
                return;
            }
            var offset:Array = this._offsetStyleProperty ? styleClient.getStyle(this._offsetStyleProperty) : null;
            if (offset)
            {
                this._xOffset = offset[0];
                this._yOffset = offset[1];
            }
            else
            {
                c = new this._class();
                if (c is IFlexDisplayObject)
                {
                    d = IFlexDisplayObject(c);
                    this._xOffset = -d.width / 2;
                    this._yOffset = -d.height / 2;
                }
            }
        }
    }
}
