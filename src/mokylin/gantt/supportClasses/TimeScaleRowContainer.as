package mokylin.gantt.supportClasses
{
    import mx.core.UIComponent;
    import mx.core.IUIComponent;

    [ExcludeClass]
    public class TimeScaleRowContainer extends UIComponent 
    {
        private var _verticalGap:Number = 1;

        public function get verticalGap():Number
        {
            return this._verticalGap;
        }

        public function set verticalGap(value:Number):void
        {
            this._verticalGap = value;
            invalidateSize();
            invalidateDisplayList();
        }

        override protected function measure():void
        {
            var child:IUIComponent;
            var preferredChildHeight:Number;
            var minHeight:Number = 0;
            var preferredHeight:Number = 0;
            var count:int = numChildren;
            var i:int;
            while (i < count)
            {
                child = (getChildAt(i) as IUIComponent);
                if (child == null)
                {
                }
                else
                {
                    preferredChildHeight = child.getExplicitOrMeasuredHeight();
                    preferredHeight = preferredHeight + preferredChildHeight;
                    minHeight = minHeight + (isNaN(child.percentHeight) ? preferredChildHeight : child.minHeight);
                }
                i++;
            }
            var gaps:Number = (this.verticalGap * count);
            preferredHeight = preferredHeight + gaps;
            minHeight = (minHeight + gaps);
            this.measuredMinHeight = minHeight;
            this.measuredHeight = preferredHeight;
            this.measuredMinWidth = 0;
            this.measuredWidth = 0;
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            this.layoutChildren(unscaledWidth, unscaledHeight);
        }

        private function layoutChildren(unscaledWidth:Number, unscaledHeight:Number):void
        {
            var child:IUIComponent;
            var preferredHeight:Number;
            var w:Number = unscaledWidth;
            var h:Number = unscaledHeight;
            var count:int = numChildren;
            var preferredTotal:Number = this.getChildrenTotalPreferred();
            var explicitTotal:Number = this.getChildrenTotalExplicit();
            var measuredTotal:Number = (preferredTotal - explicitTotal);
            var nonExplicitHeight:Number = ((unscaledHeight - explicitTotal) - ((count - 1) * this.verticalGap));
            var currentY:Number = 0;
            var i:int;
            while (i < count)
            {
                child = (getChildAt(i) as IUIComponent);
                if (child == null)
                {
                }
                else
                {
                    if (!(isNaN(child.explicitHeight)))
                    {
                        preferredHeight = child.explicitHeight;
                    }
                    else
                    {
                        preferredHeight = Math.round(((nonExplicitHeight * child.measuredHeight) / measuredTotal));
                        if (preferredHeight < child.minHeight)
                        {
                            preferredHeight = child.minHeight;
                        }
                    }
                    child.move(0, currentY);
                    child.setActualSize(w, preferredHeight);
                    currentY = (currentY + (preferredHeight + this.verticalGap));
                }
                i++;
            }
        }

        private function getChildrenTotalExplicit():Number
        {
            var child:IUIComponent;
            var count:int = numChildren;
            var total:Number = 0;
            var i:int;
            while (i < count)
            {
                child = (getChildAt(i) as IUIComponent);
                if (child == null)
                {
                }
                else
                {
                    if (!isNaN(child.explicitHeight))
                    {
                        total = total + child.explicitHeight;
                    }
                }
                i++;
            }
            return total;
        }

        private function getChildrenTotalPreferred():Number
        {
            var child:IUIComponent;
            var count:int = numChildren;
            var total:Number = 0;
            var i:int;
            while (i < count)
            {
                child = (getChildAt(i) as IUIComponent);
                if (child == null)
                {
                }
                else
                {
                    total = total + child.getExplicitOrMeasuredHeight();
                }
                i++;
            }
            return total;
        }
    }
}
