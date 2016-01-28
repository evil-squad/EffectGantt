package mokylin.utils
{
    import mx.styles.CSSStyleDeclaration;
    import mx.styles.StyleManager;
    import mx.styles.IStyleManager2;
    import mx.graphics.IFill;
    import mx.graphics.SolidColor;

    [ExcludeClass]
    public class CSSUtil 
    {

        public static const DEFAULT_COLORS:Array = [14976769, 10861646, 1807833, 13290142, 6722480, 15752743, 8835556, 15006112, 16766226, 0x75B000, 418480, 15591622, 0xCC3300, 13754343, 5428426, 12968029, 15188340, 16775063, 12973711, 12448230, 10393725, 15440013, 9554405, 9690186, 0xFFB900, 10402765, 0x9797, 897730];


        public static function createSelector(selectorName:String, packageName:String=null, styleManager:IStyleManager2=null):CSSStyleDeclaration
        {
            var selector:CSSStyleDeclaration;
            if (packageName != null)
            {
                selectorName = packageName + "." + selectorName;
            }
            if (styleManager == null)
            {
                selector = StyleManager.getStyleManager(null).getStyleDeclaration(selectorName);
                if (selector == null)
                {
                    selector = new CSSStyleDeclaration();
                    StyleManager.getStyleManager(null).setStyleDeclaration(selectorName, selector, false);
                }
            }
            else
            {
                selector = styleManager.getStyleDeclaration(selectorName);
                if (selector == null)
                {
                    selector = new CSSStyleDeclaration();
                    styleManager.setStyleDeclaration(selectorName, selector, false);
                }
            }
            return selector;
        }

        public static function fillFromStyle(v:Object):IFill
        {
            if (v is IFill)
            {
                return IFill(v);
            }
            if (v != null)
            {
                return IFill(new SolidColor(uint(v)));
            }
            return null;
        }
    }
}