package mokylin.gantt
{
    import mx.skins.ProgrammaticSkin;
    import flash.geom.Rectangle;
    import flash.geom.Point;
    import mx.graphics.IStroke;
    import flash.display.Graphics;
    import flash.display.LineScaleMode;
    import flash.display.CapsStyle;
    import flash.display.JointStyle;

    public class ConstraintSkin extends ProgrammaticSkin 
    {

        private static const handleBorderColor:uint = 0x111111;
        private static const handleFillColorEditable:uint = 0xFFFFFF;
        private static const handleFillColorNotEditable:uint = 0x111111;
        private static const handleCircleSize:Number = 6;
        private static const handleSquareSide:Number = 4;


        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            var path:Array;
            var arrowDirection:String;
            var clipRectangle:Rectangle;
            var renderer:ConstraintItemRenderer;
            var info:ConstraintInfo;
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            var selectionMinThickness:Number = 3;
            if (parent is ConstraintItemRenderer)
            {
                renderer = ConstraintItemRenderer(parent);
                clipRectangle = renderer.clipRectangle;
                info = renderer.info;
                if (!info)
                {
                    return;
                }
                path = info.path;
                arrowDirection = info.arrowDirection;
                selectionMinThickness = renderer.constraintItem.ganttSheet.linkSelectionMinThickness;
            }
            if (!path || path.length == 0)
            {
                return;
            }
            var position:Point = Point(path[(path.length - 1)]);
            var linkStroke:IStroke = getStyle("linkStroke");
            var linkColor:uint = getStyle("linkColor");
            var linkAlpha:Number = getStyle("linkAlpha");
            var linkThickness:Number = getStyle("linkThickness");
            var arrowAlpha:Number = getStyle("arrowAlpha");
            var arrowColor:uint = getStyle("arrowColor");
            var arrowStroke:IStroke = getStyle("arrowStroke");
            var arrowBorderThickness:Number = getStyle("arrowBorderThickness");
            var arrowSize:Number = getStyle("arrowSize");
            var weigth:Number = linkStroke ? linkStroke.weight : linkThickness;
            var g:Graphics = graphics;
            g.clear();
            switch (name)
            {
                case "selectedSkin":
                case "selectedOverSkin":
                    if (weigth < selectionMinThickness)
                    {
                        this.drawLink(g, clipRectangle, path, selectionMinThickness, 0, 0, null);
                    }
                    this.drawLink(g, clipRectangle, path, linkThickness, linkColor, linkAlpha, linkStroke);
                    this.drawArrow(g, clipRectangle, position.x, position.y, arrowDirection, arrowBorderThickness, arrowColor, arrowAlpha, arrowStroke, arrowSize);
                    this.drawEndHandles(g, clipRectangle, path, handleBorderColor, handleFillColorEditable, getStyle("handleShape"));
                    break;
                case "skin":
                case "overSkin":
                    if (weigth < selectionMinThickness)
                    {
                        this.drawLink(g, clipRectangle, path, selectionMinThickness, 0, 0, null);
                    }
                    this.drawLink(g, clipRectangle, path, linkThickness, linkColor, linkAlpha, linkStroke);
                    this.drawArrow(g, clipRectangle, position.x, position.y, arrowDirection, arrowBorderThickness, arrowColor, arrowAlpha, arrowStroke, arrowSize);
                    break;
            }
        }

        private function drawLink(g:Graphics, clip:Rectangle, path:Array, thickness:Number, color:uint, alpha:Number, stroke:IStroke):void
        {
            var p:Point;
            if (stroke)
            {
                stroke.apply(g, null, null);
            }
            else
            {
                g.lineStyle(thickness, color, alpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);
            }
            var first:Boolean = true;
            for each (p in path)
            {
                if (first)
                {
                    g.moveTo(this.clipX(p.x, clip), this.clipY(p.y, clip));
                    first = false;
                }
                else
                {
                    g.lineTo(this.clipX(p.x, clip), this.clipY(p.y, clip));
                }
            }
        }

        private function drawArrow(g:Graphics, clip:Rectangle, x:Number, y:Number, direction:String, thickness:Number, color:uint, alpha:Number, stroke:IStroke, arrowSize:Number):void
        {
            if (!clip || !clip.contains(x, y))
            {
                return;
            }
            var halfArrowSize:Number = Math.floor((arrowSize / 2));
            if (stroke)
            {
                stroke.apply(g, null, null);
            }
            else
            {
                g.lineStyle(thickness, color, alpha, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.MITER);
            }
            g.moveTo(x, y);
            g.beginFill(color, alpha);
            switch (direction)
            {
                case "left":
                    g.lineTo((x + arrowSize), (y + halfArrowSize));
                    g.lineTo((x + arrowSize), (y - halfArrowSize));
                    g.lineTo(x, y);
                    break;
                case "right":
                    g.lineTo((x - arrowSize), (y + halfArrowSize));
                    g.lineTo((x - arrowSize), (y - halfArrowSize));
                    g.lineTo(x, y);
                    break;
                case "bottom":
                    g.lineTo((x + halfArrowSize), (y - arrowSize));
                    g.lineTo((x - halfArrowSize), (y - arrowSize));
                    g.lineTo(x, y);
                    break;
            }
            g.endFill();
        }

        private function drawEndHandles(g:Graphics, clip:Rectangle, path:Array, borderColor:uint, fillColor:uint, shape:String):void
        {
            this.drawHandle(g, clip, Point(path[0]), borderColor, fillColor, shape);
            this.drawHandle(g, clip, Point(path[(path.length - 1)]), borderColor, fillColor, shape);
        }

        private function drawHandle(g:Graphics, clip:Rectangle, p:Point, borderColor:uint, fillColor:uint, shape:String):void
        {
            var _local7:Number;
            if (!p)
            {
                return;
            }
            if (clip && !clip.containsPoint(p))
            {
                return;
            }
            switch (shape)
            {
                case "circle":
                    g.lineStyle(1, borderColor, 1, true);
                    g.beginFill(fillColor, 1);
                    g.drawEllipse((p.x - ((handleCircleSize - 1) / 2)), (p.y - ((handleCircleSize - 1) / 2)), handleCircleSize, handleCircleSize);
                    g.endFill();
                    break;
                case "square":
                    _local7 = (handleSquareSide / 2);
                    g.moveTo((p.x - _local7), (p.y - _local7));
                    g.lineStyle(1, borderColor, 1, true);
                    g.beginFill(fillColor, 1);
                    g.lineTo((p.x + _local7), (p.y - _local7));
                    g.lineTo((p.x + _local7), (p.y + _local7));
                    g.lineTo((p.x - _local7), (p.y + _local7));
                    g.lineTo((p.x - _local7), (p.y - _local7));
                    g.endFill();
                    break;
            }
        }

        private function clipX(value:Number, clip:Rectangle):Number
        {
            if (!clip)
            {
                return value;
            }
            if (value < clip.x)
            {
                return clip.x;
            }
            if (value > (clip.x + clip.width))
            {
                return clip.x + clip.width;
            }
            return value;
        }

        private function clipY(value:Number, clip:Rectangle):Number
        {
            if (!clip)
            {
                return value;
            }
            if (value < clip.y)
            {
                return clip.y;
            }
            if (value > (clip.y + clip.height))
            {
                return clip.y + clip.height;
            }
            return value;
        }
    }
}
