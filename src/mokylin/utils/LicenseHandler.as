package mokylin.utils
{
    import flash.display.DisplayObjectContainer;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.filters.GlowFilter;
    import flash.geom.Point;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    import flash.system.Security;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    
    import mx.core.Container;
    import mx.core.FlexGlobals;
    import mx.core.UIComponent;
    import mx.resources.ResourceManager;

    [ExcludeClass]
    [ResourceBundle("mokylinsparkutilities")]
    public class LicenseHandler 
    {
        private static const wmarkAfter:Number = 0;
        private static const dBuild:Number = 1391114221786;
        private static const wText:String = "enterprise Version";
        private static const MENU_CAPTION:String = ResourceManager.getInstance().getString("mokylinsparkutilities", "about.elixirenterprise");
        private static const MENU_URL:String = ResourceManager.getInstance().getString("mokylinsparkutilities", "about.elixirenterprise.url");
        private static const DAY:Number = 86400000;
        private static const TRIAL_PERIOD_DAYS:Number = (92 * DAY);//7948800000

        private var _p:DisplayObjectContainer;
        private var _textField:TextField;
        private var _foreground:Sprite;
        private var _time:Number;
        private var _darkBackground:Boolean = false;

        public function LicenseHandler(p:DisplayObjectContainer, darkBackground:Boolean, time:Number)
        {
            this._p = p;
            this._time = time;
            this._darkBackground = darkBackground;
            this._p.addEventListener(Event.ENTER_FRAME, this.enterFrameHandler);
        }

        public static function displayWatermark(where:DisplayObjectContainer, darkBackground:Boolean=false):void
        {
            new LicenseHandler(where, darkBackground, new Date().getTime());
        }

        public static function addElixirEnterpriseToMenu():void
        {
            addToMenu(MENU_CAPTION, MENU_URL);
        }

        private static function addToMenu(menuText:String, url:String):void
        {
            var item:ContextMenuItem;
            if (Security.sandboxType == Security.LOCAL_WITH_FILE)
            {
                return;
            }
            var existingMenu:* = FlexGlobals.topLevelApplication.contextMenu;
            if (existingMenu == null)
            {
                return;
            }
            if (!(existingMenu is ContextMenu))
            {
                return;
            }
            var menu:ContextMenu = existingMenu as ContextMenu;
            if (menu.customItems == null)
            {
                return;
            }
            for each (item in menu.customItems)
            {
                if (item.caption == menuText)
                {
                    return;
                }
            }
            item = new ContextMenuItem(menuText, true);
            item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function (event:ContextMenuEvent):void
            {
                navigateToURL(new URLRequest(url));
            });
            menu.customItems.push(item);
        }


        protected function checkVisible(p:DisplayObjectContainer):Boolean
        {
            return true;
        }

        private function enterFrameHandler(event:Event):void
        {
            var g:Graphics;
            var holder:UIComponent;
            var tf:TextFormat;
            var text:String;
            var a:Array;
            var component:UIComponent;
            if (this._textField != null && !this.checkVisible(this._p))
            {
                this._textField.visible = false;
                return;
            }
            var ul:Point = new Point();
            var lr:Point = new Point(this._p.width, this._p.height);
            ul = this._p.localToGlobal(ul);
            lr = this._p.localToGlobal(lr);
            var dx:Number = Math.abs((lr.x - ul.x));
            var dy:Number = Math.abs((lr.y - ul.y));
            if (this._time > (dBuild + TRIAL_PERIOD_DAYS))
            {
                if (!this._foreground)
                {
                    this._foreground = new Sprite();
                    this._foreground.mouseEnabled = false;
                }
                if (!this._foreground.parent)
                {
                    if (this._p is Container)
                    {
                        holder = new UIComponent();
                        this._p.addChild(holder);
                        holder.addChild(this._foreground);
                    }
                    else
                    {
                        this._p.addChild(this._foreground);
                    }
                }
                this._foreground.width = this._p.width;
                this._foreground.height = this._p.height;
                g = this._foreground.graphics;
                g.clear();
                g.beginFill(0x111111, 0/*(this._time - dBuild - TRIAL_PERIOD_DAYS) / 1 * DAY*/);
                g.drawRect(0, 0, this._p.width, this._p.height);
                g.endFill();
            }
            if ((dx < 20 && dy < 20) || !this._p.visible)
            {
                if (this._textField != null)
                {
                    this._textField.visible = false;
                }
                return;
            }
            if (!this._textField)
            {
                this._textField = new TextField();
                this._textField.selectable = false;
                this._textField.autoSize = TextFieldAutoSize.CENTER;
                this._textField.textColor = 0xFFFFFF;
                this._textField.backgroundColor = 0;
                tf = new TextFormat();
                tf.font = "Verdana";
                tf.size = 32;
                tf.bold = true;
                this._textField.defaultTextFormat = tf;
                text = wText;
                if (text == null || text.length < 1)
                {
                    text = "IBM ILOG Elixir Trial";
                }
                if (this._time < (dBuild + TRIAL_PERIOD_DAYS))
                {
                    text = text + " " + Math.round((dBuild + TRIAL_PERIOD_DAYS - this._time) / DAY) + " Days Left";
                }
                else
                {
                    text = text + " Ended";
                }
                this._textField.text = text;
                this._textField.alpha = 0.35;
                this._textField.mouseEnabled = false;
                a = [];
                a.push(new GlowFilter(this._darkBackground ? 0xFFFFFF : 0, 1, 6, 6, 2, 1, false, true));
                this._textField.filters = a;
                this._textField.x = Math.round((-10 * Math.random()));
                this._textField.y = Math.round((-40 * Math.random()));
            }
            if (!this._textField.parent)
            {
                if (this._p is Container)
                {
                    component = new UIComponent();
                    this._p.addChild(component);
                    component.addChild(this._textField);
                }
                else
                {
                    this._p.addChild(this._textField);
                }
            }
            if (!this._textField.visible)
            {
                this._textField.visible = true;
            }
            this._textField.x = this._p.width / 2 - this._textField.width / 2;
            this._textField.y = this._p.height / 2 - this._textField.height / 2;
        }
    }
}
