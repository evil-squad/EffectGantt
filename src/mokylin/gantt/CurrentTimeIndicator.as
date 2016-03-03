package mokylin.gantt
{
    import flash.events.TimerEvent;
    import flash.geom.Rectangle;
    import flash.utils.Timer;
    
    import mx.graphics.SolidColorStroke;
    
    import mokylin.utils.TimeUnit;

    public class CurrentTimeIndicator extends TimeGridBase 
    {

        private var _updateTimer:Timer;
        private var _updateTime:TimeUnit;
        private var _updateTimeChanged:Boolean = true;

        public function CurrentTimeIndicator()
        {
            this._updateTime = TimeUnit.MINUTE;
            super();
            stroke = new SolidColorStroke(0xFF, 0.5);
        }

        public function get updateTime():TimeUnit
        {
            return this._updateTime;
        }

        public function set updateTime(value:TimeUnit):void
        {
            if (this._updateTime == value)
            {
                return;
            }
            this._updateTime = value;
            this._updateTimeChanged = true;
            invalidateProperties();
        }

        override public function clone():GanttSheetGridBase
        {
            var grid:CurrentTimeIndicator;
            grid = new CurrentTimeIndicator();
            grid.drawPerRow = drawPerRow;
            grid.drawToBottom = drawToBottom;
            grid.stroke = stroke;
            grid.dashStyle = dashStyle;
            grid.timeElementSkin = timeElementSkin;
            grid.updateTime = this.updateTime;
            return grid;
        }

        override protected function commitProperties():void
        {
            var currentTime:Number;
            var floor:Number;
            super.commitProperties();
            if (this._updateTimeChanged)
            {
                this._updateTimeChanged = false;
                if (this._updateTime != null && this._updateTime.milliseconds > 0)
                {
                    if (this._updateTimer == null)
                    {
                        this._updateTimer = new Timer(0);
                        this._updateTimer.addEventListener(TimerEvent.TIMER, this.updateTimeGrid);
                    }
                    currentTime = 0;
                    floor = timeComputer.floor(currentTime, this._updateTime, 1);
                    this._updateTimer.delay = this._updateTime.milliseconds - currentTime - floor;
                    if (!this._updateTimer.running)
                    {
                        this._updateTimer.start();
                    }
                    invalidateDisplayList();
                }
                else
                {
                    if (this._updateTimer != null)
                    {
                        this._updateTimer.stop();
                    }
                    this._updateTimer = null;
                }
            }
        }

        private function updateTimeGrid(event:TimerEvent):void
        {
            if (this._updateTimer != null)
            {
                this._updateTimer.delay = this._updateTime.milliseconds;
            }
            invalidateDisplayList();
        }

        override protected function updateGridDisplayList(r:Rectangle, rowIndex:int, data:Object):void
        {
            if (this._updateTime == null)
            {
                return;
            }
            if (!timeController.configured)
            {
                return;
            }
            var size:Number = getRendererWidth();
            var startTime:Number = timeController.getTime(-size);
            var endTime:Number = timeController.getTime(timeController.width + size);
            var currentTime:Number = timeComputer.floor(0, this.updateTime, 1);
            if (currentTime >= startTime && currentTime <= endTime)
            {
                drawLine(r, timeController.getCoordinate(currentTime), data);
            }
        }
    }
}