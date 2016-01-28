package mokylin.gantt
{
    import mx.core.ScrollPolicy;
    import mx.controls.AdvancedDataGrid;
    import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
    import mx.controls.listClasses.ListRowInfo;

    [Exclude(name="allowDragSelection", kind="property")]
    [Exclude(name="allowMultipleSelection", kind="property")]
    [Exclude(name="dataTipField", kind="property")]
    [Exclude(name="dataTipFunction", kind="property")]
    [Exclude(name="doubleClickEnabled", kind="property")]
    [Exclude(name="dragEnabled", kind="property")]
    [Exclude(name="draggableColumns", kind="property")]
    [Exclude(name="dragMoveEnabled", kind="property")]
    [Exclude(name="dropEnabled", kind="property")]
    [Exclude(name="dropTarget", kind="property")]
    [Exclude(name="editable", kind="property")]
    [Exclude(name="editedItemPosition", kind="property")]
    [Exclude(name="editedItemRenderer", kind="property")]
    [Exclude(name="horizontalScrollBar", kind="property")]
    [Exclude(name="horizontalScrollPolicy", kind="property")]
    [Exclude(name="maxHorizontalScrollPosition", kind="property")]
    [Exclude(name="maxVerticalScrollPosition", kind="property")]
    [Exclude(name="scrollTipFunction", kind="property")]
    [Exclude(name="selectable", kind="property")]
    [Exclude(name="selectedIndex", kind="property")]
    [Exclude(name="selectedIndices", kind="property")]
    [Exclude(name="selectedItem", kind="property")]
    [Exclude(name="selectedItems", kind="property")]
    [Exclude(name="showScrollTips", kind="property")]
    [Exclude(name="toolTip", kind="property")]
    [Exclude(name="useHandCursor", kind="property")]
    [Exclude(name="verticalScrollBar", kind="property")]
    [Exclude(name="verticalScrollPolicy", kind="property")]
    [Exclude(name="lockedRowCount", kind="property")]
    [Exclude(name="anchorBookmark", kind="property")]
    [Exclude(name="anchorIndex", kind="property")]
    [Exclude(name="caretBookmark", kind="property")]
    [Exclude(name="caretIndex", kind="property")]
    [Exclude(name="caretIndicator", kind="property")]
    [Exclude(name="caretItemRenderer", kind="property")]
    [Exclude(name="caretUID", kind="property")]
    [Exclude(name="dragImage", kind="property")]
    [Exclude(name="dragImageOffsets", kind="property")]
    [Exclude(name="highlightIndicator", kind="property")]
    [Exclude(name="highlightUID", kind="property")]
    [Exclude(name="keySelectionPending", kind="property")]
    [Exclude(name="lastDropIndex", kind="property")]
    [Exclude(name="selectionLayer", kind="property")]
    [Exclude(name="selectionTweens", kind="property")]
    [Exclude(name="showCaret", kind="property")]
    [Exclude(name="calculateDropIndex", kind="method")]
    [Exclude(name="createItemEditor", kind="method")]
    [Exclude(name="destroyItemEditor", kind="method")]
    [Exclude(name="effectFinished", kind="method")]
    [Exclude(name="effectStarted", kind="method")]
    [Exclude(name="endEffectStarted", kind="method")]
    [Exclude(name="hideDropFeedback", kind="method")]
    [Exclude(name="isItemHighlighted", kind="method")]
    [Exclude(name="isItemSelected", kind="method")]
    [Exclude(name="showDropFeedback", kind="method")]
    [Exclude(name="startDrag", kind="method")]
    [Exclude(name="dragCompleteHandler", kind="method")]
    [Exclude(name="dragDropHandler", kind="method")]
    [Exclude(name="dragEnterHandler", kind="method")]
    [Exclude(name="dragExitHandler", kind="method")]
    [Exclude(name="dragOverHandler", kind="method")]
    [Exclude(name="dragScroll", kind="method")]
    [Exclude(name="drawCaretIndicator", kind="method")]
    [Exclude(name="drawHighlightIndicator", kind="method")]
    [Exclude(name="drawSelectionIndicator", kind="method")]
    [Exclude(name="mouseClickHandler", kind="method")]
    [Exclude(name="mouseDoubleClickHandler", kind="method")]
    [Exclude(name="mouseDownHandler", kind="method")]
    [Exclude(name="mouseEventToItemRenderer", kind="method")]
    [Exclude(name="mouseMoveHandler", kind="method")]
    [Exclude(name="mouseOutHandler", kind="method")]
    [Exclude(name="mouseOverHandler", kind="method")]
    [Exclude(name="mouseUpHandler", kind="method")]
    [Exclude(name="mouseWheelHandler", kind="method")]
    [Exclude(name="moveSelectionHorizontally", kind="method")]
    [Exclude(name="moveSelectionVertically", kind="method")]
    [Exclude(name="placeSortArrow", kind="method")]
    [Exclude(name="removeIndicators", kind="method")]
    [Exclude(name="selectItem", kind="method")]
    [Exclude(name="setScrollBarProperties", kind="method")]
    [Exclude(name="expandItemHandler", kind="method")]
    [Exclude(name="click", kind="event")]
    [Exclude(name="doubleClick", kind="event")]
    [Exclude(name="dragComplete", kind="event")]
    [Exclude(name="dragDrop", kind="event")]
    [Exclude(name="dragEnter", kind="event")]
    [Exclude(name="dragExit", kind="event")]
    [Exclude(name="dragOver", kind="event")]
    [Exclude(name="effectEnd", kind="event")]
    [Exclude(name="effectStart", kind="event")]
    [Exclude(name="headerRelease", kind="event")]
    [Exclude(name="itemClick", kind="event")]
    [Exclude(name="itemDoubleClick", kind="event")]
    [Exclude(name="itemEditBegin", kind="event")]
    [Exclude(name="itemEditBeginning", kind="event")]
    [Exclude(name="itemEditEnd", kind="event")]
    [Exclude(name="itemFocusIn", kind="event")]
    [Exclude(name="itemFocusOut", kind="event")]
    [Exclude(name="itemRollOut", kind="event")]
    [Exclude(name="itemRollOver", kind="event")]
    [Exclude(name="keyDown", kind="event")]
    [Exclude(name="keyUp", kind="event")]
    [Exclude(name="mouseDown", kind="event")]
    [Exclude(name="mouseDownOutside", kind="event")]
    [Exclude(name="mouseFocusChange", kind="event")]
    [Exclude(name="mouseMove", kind="event")]
    [Exclude(name="mouseOut", kind="event")]
    [Exclude(name="mouseOver", kind="event")]
    [Exclude(name="mouseUp", kind="event")]
    [Exclude(name="mouseWheel", kind="event")]
    [Exclude(name="mouseWheelOutside", kind="event")]
    [Exclude(name="rollOut", kind="event")]
    [Exclude(name="rollOver", kind="event")]
    [Exclude(name="toolTipCreate", kind="event")]
    [Exclude(name="toolTipEnd", kind="event")]
    [Exclude(name="toolTipHide", kind="event")]
    [Exclude(name="toolTipShow", kind="event")]
    [Exclude(name="toolTipShown", kind="event")]
    [Exclude(name="toolTipStart", kind="event")]
    [Exclude(name="columnDropIndicatorSkin", kind="style")]
    [Exclude(name="columnResizeSkin", kind="style")]
    [Exclude(name="dropIndicatorSkin", kind="style")]
    [Exclude(name="headerDragProxyStyleName", kind="style")]
    [Exclude(name="horizontalScrollBarStyleName", kind="style")]
    [Exclude(name="rollOverColor", kind="style")]
    [Exclude(name="selectionColor", kind="style")]
    [Exclude(name="selectionDisabledColor", kind="style")]
    [Exclude(name="selectionDuration", kind="style")]
    [Exclude(name="selectionEasingFunction", kind="style")]
    [Exclude(name="strechCursor", kind="style")]
    [Exclude(name="textRollOverColor", kind="style")]
    [Exclude(name="textSelectedColor", kind="style")]
    [Exclude(name="useRollOver", kind="style")]
    [Exclude(name="verticalScrollBarStyleName", kind="style")]
    [Exclude(name="addedEffect", kind="effect")]
    [Exclude(name="creationCompleteEffect", kind="effect")]
    [Exclude(name="focusInEffect", kind="effect")]
    [Exclude(name="focusOutEffect", kind="effect")]
    [Exclude(name="hideEffect", kind="effect")]
    [Exclude(name="mouseDownEffect", kind="effect")]
    [Exclude(name="mouseUpEffect", kind="effect")]
    [Exclude(name="moveEffect", kind="effect")]
    [Exclude(name="removedEffect", kind="effect")]
    [Exclude(name="resizeEffect", kind="effect")]
    [Exclude(name="rollOutEffect", kind="effect")]
    [Exclude(name="rollOverEffect", kind="effect")]
    [Exclude(name="showEffect", kind="effect")]
    public class PrintGanttDataGrid extends GanttDataGrid 
    {

        private var repeatRow:Boolean;

        public function PrintGanttDataGrid()
        {
            verticalScrollPolicy = ScrollPolicy.OFF;
            horizontalScrollPolicy = ScrollPolicy.OFF;
        }

		public function initializeFrom(value:AdvancedDataGrid):void
        {
            this.cloneColumns(value);
            dataProvider = value.dataProvider;
            itemRenderer = value.itemRenderer;
            headerRenderer = value.headerRenderer;
            groupItemRenderer = value.groupItemRenderer;
            rendererProviders = value.rendererProviders;
            labelField = value.labelField;
            labelFunction = value.labelFunction;
            groupIconFunction = value.groupIconFunction;
            groupLabelFunction = value.groupLabelFunction;
            displayDisclosureIcon = value.displayDisclosureIcon;
            displayItemsExpanded = value.displayItemsExpanded;
            itemIcons = value.itemIcons;
            lockedColumnCount = value.lockedColumnCount;
            lockedRowCount = value.lockedRowCount;
            wordWrap = value.wordWrap;
            variableRowHeight = value.variableRowHeight;
            if (!explicitRowHeight)
            {
                rowHeight = value.rowHeight;
            }
            setStyle("alternatingItemColors", value.getStyle("alternatingItemColors"));
            itemsSizeChanged = true;
            invalidateProperties();
            invalidateSize();
            invalidateDisplayList();
        }

		public function get validNextPage():Boolean
        {
            var vPos:int = (verticalScrollPosition + rowCount) - (this.repeatRow ? 1 : 0);
            return dataProvider && vPos < dataProvider.length ? true : false;
        }

		public function nextPage():void
        {
            if (verticalScrollPosition < dataProvider.length)
            {
                verticalScrollPosition = (verticalScrollPosition + (rowCount - ((this.repeatRow) ? 1 : 0)));
                itemsSizeChanged = true;
                invalidateSize();
                invalidateDisplayList();
            }
        }

        private function cloneColumns(adg:AdvancedDataGrid):void
        {
            var grouped:Boolean;
            var sourceColumns:Array;
            var newColumn:AdvancedDataGridColumn;
            var newTreeColumn:AdvancedDataGridColumn;
            var c:AdvancedDataGridColumn;
            if (adg.groupedColumns != null)
            {
                sourceColumns = adg.groupedColumns;
                grouped = true;
            }
            else
            {
                sourceColumns = adg.columns;
                grouped = false;
            }
            var newColumns:Array = [];
            for each (c in sourceColumns)
            {
                newColumn = c.clone();
                newColumns.push(newColumn);
                if (c == adg.treeColumn)
                {
                    newTreeColumn = newColumn;
                }
            }
            if (grouped)
            {
                groupedColumns = newColumns;
            }
            else
            {
                columns = newColumns;
            }
            treeColumn = newTreeColumn;
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            if (!listItems || listItems.length == 0)
            {
                return;
            }
            var info:ListRowInfo = rowInfo[(rowCount - 1)];
            var ir:Object = listItems[(rowCount - 1)][0];
            this.repeatRow = ((rowInfo[(rowCount - 1)].y + rowInfo[(rowCount - 1)].height) > listContent.height);
            if (ir && this.repeatRow)
            {
                for each (ir in listItems[(rowCount - 1)])
                {
                    ir.visible = false;
                }
            }
        }

        override protected function configureScrollBars():void
        {
        }
    }
}
