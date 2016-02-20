package mokylin.gantt
{
    import mx.core.UIComponent;
    import mokylin.utils.GregorianCalendar;
    import flash.geom.Rectangle;
    import mx.core.IDataRenderer;

    public class GanttSheetGridBase extends UIComponent 
    {
        private var _drawPerRow:Boolean;
        private var _drawPerRowChanged:Boolean;
        private var _drawToBottom:Boolean = true;
        private var _drawToBottomChanged:Boolean;
        protected var _ganttSheet:GanttSheet;

        public function get drawPerRow():Boolean
        {
            return this._drawPerRow;
        }

        public function set drawPerRow(value:Boolean):void
        {
            if (this._drawPerRow != value)
            {
                this._drawPerRowChanged = true;
                this._drawPerRow = value;
                invalidateProperties();
            }
        }

        public function get drawToBottom():Boolean
        {
            return this._drawToBottom;
        }

        public function set drawToBottom(value:Boolean):void
        {
            if (this._drawToBottom != value)
            {
                this._drawToBottomChanged = true;
                this._drawToBottom = value;
                invalidateProperties();
            }
        }

        public function get ganttSheet():GanttSheet
        {
            return this._ganttSheet;
        }

        public function setGanttSheet(value:GanttSheet):void
        {
            this._ganttSheet = value;
            styleName = value;
            if (value != null)
            {
                invalidateDisplayList();
            }
        }

		public function get ganttChart():GanttChartBase
        {
            return this._ganttSheet != null ? this._ganttSheet.ganttChart : null;
        }

		public function get timeController():TimeController
        {
            return this._ganttSheet != null ? this._ganttSheet.timeController : null;
        }

		public function get calendar():GregorianCalendar
        {
            return this._ganttSheet != null ? this._ganttSheet.calendar : null;
        }

        public function clone():GanttSheetGridBase
        {
            return null;
        }

        override protected function commitProperties():void
        {
            super.commitProperties();
            if (this._drawPerRowChanged)
            {
                this._drawPerRowChanged = false;
                invalidateDisplayList();
            }
            if (this._drawToBottomChanged)
            {
                this._drawToBottomChanged = false;
                invalidateDisplayList();
            }
        }

        override public function set visible(value:Boolean):void
        {
            if (value != visible && value)
            {
                invalidateDisplayList();
            }
            super.visible = value;
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            var firstRow:int;
            var lastRow:int;
            var currentRow:int;
            var renderers:Array;
            var data:Object;
            var r:Rectangle;
            var h:Number;
            var i:uint;
            var renderers2:Array;
            var data2:Object;
            if (!visible)
            {
                return;
            }
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            graphics.clear();
            if (this.ganttChart == null || this.ganttChart.dataGrid == null)
            {
                return;
            }
            var rowInfo:Array = this.ganttChart.dataGrid.getRowInfo();
            var items:Array = this.ganttChart.dataGrid.getListItems();
            if (this.drawPerRow)
            {
                firstRow = this.ganttChart.dataGrid.verticalScrollPosition;
                lastRow = items.length;
                currentRow = 0;
                while (currentRow < lastRow)
                {
                    renderers = (items[currentRow] as Array);
                    data = (renderers != null && renderers.length != 0 && renderers[0] is IDataRenderer) ? IDataRenderer(renderers[0]).data : null;
                    if (data == null && !this.drawToBottom)
                    {
                        break;
                    }
                    r = new Rectangle(0, (rowInfo[currentRow].y - rowInfo[0].y), unscaledWidth, rowInfo[currentRow].height);
                    this.updateGridDisplayList(r, firstRow + currentRow, data);
                    currentRow++;
                }
            }
            else
            {
                h = unscaledHeight;
                if (!this.drawToBottom)
                {
                    i = (items.length - 1);
                    while (i >= 0)
                    {
                        renderers2 = (items[i] as Array);
                        data2 = renderers2 != null && renderers2.length != 0 && renderers2[0] is IDataRenderer ? IDataRenderer(renderers2[0]).data : null;
                        if (data2 != null)
                        {
                            h = rowInfo[i].y + rowInfo[i].height - rowInfo[0].y;
                            break;
                        }
                        i--;
                    }
                }
                this.updateGridDisplayList(new Rectangle(0, 0, unscaledWidth, h), -1, null);
            }
        }

        protected function updateGridDisplayList(r:Rectangle, rowIndex:int, data:Object):void
        {
        }

		public function rowControllerChangedInternal():void
        {
            this.rowControllerChanged();
        }

        protected function rowControllerChanged():void
        {
            if (this.drawPerRow || !this.drawToBottom)
            {
                invalidateDisplayList();
            }
        }

		public function timeControllerChangedInternal():void
        {
            this.timeControllerChanged();
        }

        protected function timeControllerChanged():void
        {
            invalidateDisplayList();
        }
    }
}
