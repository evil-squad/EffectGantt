package mokylin.gantt
{
    import flash.events.Event;

    public class PrintResourceChart extends ResourceChart 
    {
        private var _pageCount:Number = 0;
        private var _maxPages:Number = 20;
        private var _currentColumn:Number = 0;
        private var _currentRow:Number = 0;
        private var _dataGridVisible:Boolean = true;

        public function get maxPages():Number
        {
            return this._maxPages;
        }

        public function set maxPages(value:Number):void
        {
            this._maxPages = value;
            this._pageCount = 0;
        }

        private function get printGanttSheet():PrintGanttSheet
        {
            return PrintGanttSheet(ganttSheet);
        }

        private function get printDataGrid():PrintGanttDataGrid
        {
            return PrintGanttDataGrid(dataGrid);
        }

        public function get validNextPage():Boolean
        {
            return this.printGanttSheet.validNextPage || this.printDataGrid.validNextPage;
        }

        [Bindable("currentColumnChanged")]
        public function get currentColumn():Number
        {
            return this._currentColumn;
        }

        [Bindable("currentRowChanged")]
        public function get currentRow():Number
        {
            return this._currentRow;
        }

        public function get dataGridVisible():Boolean
        {
            return this._dataGridVisible;
        }

        public function set dataGridVisible(value:Boolean):void
        {
            this._dataGridVisible = value;
            dataGrid.includeInLayout = (dataGrid.visible = value);
        }

        public function get isLastRow():Boolean
        {
            return !this.printDataGrid.validNextPage;
        }

        public function get isLastColumn():Boolean
        {
            return !this.printGanttSheet.validNextPage;
        }

        public function initializeFrom(value:ResourceChart):void
        {
            taskDataProvider = value.taskDataProvider;
            taskStartTimeField = value.taskStartTimeField;
            taskEndTimeField = value.taskEndTimeField;
            taskStartTimeFunction = value.taskStartTimeFunction;
            taskEndTimeFunction = value.taskEndTimeFunction;
            taskIsMilestoneField = value.taskIsMilestoneField;
            taskIsMilestoneFunction = value.taskIsMilestoneFunction;
            taskLabelField = value.taskLabelField;
            taskLabelFunction = value.taskLabelFunction;
            taskResourceIdField = value.taskResourceIdField;
            taskResourceIdFunction = value.taskResourceIdFunction;
            resourceDataProvider = value.resourceDataProvider;
            resourceIdField = value.resourceIdField;
            resourceIdFunction = value.resourceIdFunction;
            if (this.printDataGrid != null)
            {
                this.printDataGrid.initializeFrom(value.dataGrid);
            }
            if (this.printGanttSheet != null)
            {
                this.printGanttSheet.initializeFrom(value.ganttSheet);
            }
            invalidateProperties();
            invalidateSize();
            invalidateDisplayList();
        }

        override protected function createChildren():void
        {
            if (_dataGrid == null)
            {
                _dataGrid = new PrintGanttDataGrid();
                integrateDataGrid();
            }
            if (_ganttSheet == null)
            {
                _ganttSheet = new PrintGanttSheet();
                integrateGanttSheet();
            }
            super.createChildren();
        }

        public function nextPage():void
        {
            if (this.printGanttSheet.validNextPage)
            {
                this.printGanttSheet.nextPage();
                this._currentColumn++;
                dispatchEvent(new Event("currentColumnChanged"));
                this._pageCount++;
            }
            else if (this.printDataGrid.validNextPage)
			{
				this.printGanttSheet.carriageReturn();
				this.printDataGrid.nextPage();
				this._currentColumn = 0;
				dispatchEvent(new Event("currentColumnChanged"));
				this._currentRow++;
				dispatchEvent(new Event("currentRowChanged"));
				this._pageCount++;
			}
        }
    }
}
