package mokylin.utils
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import __AS3__.vec.Vector;

    [ExcludeClass]
    public class ClippingUtil 
    {
        public static function bestClipPointOnRay(startPoint:Point, controlPoint:Point, intersectionPoints:Vector.<Point>, numIntersections:uint):Point
        {
            var dx:Number;
            var dy:Number;
            var distSquare:Number;
            switch (numIntersections)
            {
                case 0:
                    return new Point(startPoint.x, startPoint.y);
                case 1:
                    return intersectionPoints[0];
            }
            var anyOnRay:Boolean;
            var closestPoint:Point;
            var farthestPoint:Point;
            var closestDistSquare:Number = Number.MAX_VALUE;
            var farthestDistSquare:Number = -1;
            var i:uint;
            while (i < numIntersections)
            {
                if (intersectionPoints[i] != null)
                {
                    dx = (intersectionPoints[i].x - startPoint.x);
                    dy = (intersectionPoints[i].y - startPoint.y);
                    distSquare = (dx * dx) + (dy * dy);
                    if (pointOnRay(startPoint, controlPoint, intersectionPoints[i]))
                    {
                        anyOnRay = true;
                        if (distSquare > farthestDistSquare)
                        {
                            farthestDistSquare = distSquare;
                            farthestPoint = intersectionPoints[i];
                        }
                    }
                    else if (!anyOnRay && distSquare <= closestDistSquare)
					{
						closestDistSquare = distSquare;
						closestPoint = intersectionPoints[i];
					}
                }
                i++;
            }
            return anyOnRay ? farthestPoint : closestPoint;
        }

        private static function pointOnRay(p1:Point, p2:Point, testPoint:Point):Boolean
        {
            var dx:Number = p2.x > p1.x ? (p2.x - p1.x) : (p1.x - p2.x);
            var dy:Number = p2.y > p1.y ? (p2.y - p1.y) : (p1.y - p2.y);
            if (dx > dy)
            {
                if (p1.x < p2.x && p1.x <= testPoint.x)
                {
                    return true;
                }
                if (p1.x > p2.x && p1.x >= testPoint.x)
                {
                    return true;
                }
            }
            else
            {
                if (p1.y < p2.y && p1.y <= testPoint.y)
                {
                    return (true);
                }
                if (p1.y > p2.y && p1.y >= testPoint.y)
                {
                    return true;
                }
            }
            return false;
        }

        public static function lineIntersectsSegment(p1:Point, p2:Point, p3:Point, p4:Point, res:Point):Boolean
        {
            var dx:Number;
            var dy:Number;
            if (p3.equals(p4))
            {
                if ((p3.x - p1.x) * (p2.y - p1.y) == (p2.x - p1.x) * (p3.y - p1.y))
                {
                    res.x = p3.x;
                    res.y = p3.y;
                    return true;
                }
            }
            else
            {
                if (GetLineIntersection(p1, p2, p3, p4, res) != null)
                {
                    dx = p4.x > p3.x ? (p4.x - p3.x) : (p3.x - p4.x);
                    dy = p4.y > p3.y ? (p4.y - p3.y) : (p3.y - p4.y);
                    if (dx > dy)
                    {
                        if ((p3.x <= res.x && res.x <= p4.x) || (p4.x <= res.x && res.x <= p3.x))
                        {
                            return true;
                        }
                    }
                    else
                    {
                        if ((p3.y <= res.y && res.y <= p4.y) || (p4.y <= res.y && res.y <= p3.y))
                        {
                            return true;
                        }
                    }
                }
            }
            return false;
        }

        public static function lineIntersectsPolyPoints(p1:Point, p2:Point, points:Vector.<Point>, closed:Boolean, res:Vector.<Point>):int
        {
            var numIntersections:int;
            var pa:Point;
            var pb:Point;
            var pc:Point;
            var intersectsFirstSegment:Boolean;
            var intersectsAB:Boolean;
            var intersectsBC:Boolean;
            var prevCrossPoint:Point;
            var crossPoint:Point = new Point();
            var pab:Point = new Point();
            var pbc:Point = new Point();
            var i:int;
            while (i < points.length)
            {
                pc = points[i];
                if (pb != null)
                {
                    if (lineIntersectsSegment(p1, p2, pb, pc, crossPoint))
                    {
                        if (prevCrossPoint == null || !prevCrossPoint.equals(crossPoint))
                        {
                            var _local19:int = numIntersections++;
                            prevCrossPoint = crossPoint;
                            res[_local19] = prevCrossPoint;
                            crossPoint = new Point();
                            intersectsBC = true;
                            if (i == 1)
                            {
                                intersectsFirstSegment = true;
                            }
                        }
                    }
                }
                if (pa != null && !intersectsAB && !intersectsBC)
                {
                    pab.x = (0.5 * (pa.x + pb.x));
                    pab.y = (0.5 * (pa.y + pb.y));
                    pbc.x = (0.5 * (pb.x + pc.x));
                    pbc.y = (0.5 * (pb.y + pc.y));
                    if (lineIntersectsSegment(p1, p2, pab, pbc, crossPoint))
                    {
                        if (prevCrossPoint == null || !prevCrossPoint.equals(pb))
                        {
                            _local19 = numIntersections++;
                            prevCrossPoint = pb;
                            res[_local19] = prevCrossPoint;
                        }
                    }
                }
                pa = pb;
                pb = pc;
                intersectsAB = intersectsBC;
                i++;
            }
            var firstCrossPoint:Point = numIntersections > 0 ? res[0] : null;
            if (points.length > 2 && closed)
            {
                pc = points[0];
                if (lineIntersectsSegment(p1, p2, pb, pc, crossPoint))
                {
                    if ((prevCrossPoint == null || !prevCrossPoint.equals(crossPoint)) && (firstCrossPoint == null || !firstCrossPoint.equals(crossPoint)))
                    {
                        _local19 = numIntersections++;
                        res[_local19] = crossPoint;
                        crossPoint = new Point();
                        intersectsBC = true;
                    }
                }
                if (!intersectsAB && !intersectsBC)
                {
                    pab.x = 0.5 * (pa.x + pb.x);
                    pab.y = 0.5 * (pa.y + pb.y);
                    pbc.x = 0.5 * (pb.x + pc.x);
                    pbc.y = 0.5 * (pb.y + pc.y);
                    if (lineIntersectsSegment(p1, p2, pab, pbc, crossPoint))
                    {
                        if ((prevCrossPoint == null || !prevCrossPoint.equals(pb)) && (firstCrossPoint == null || !firstCrossPoint.equals(pb)))
                        {
                            _local19 = numIntersections++;
                            prevCrossPoint = pb;
                            res[_local19] = prevCrossPoint;
                        }
                    }
                }
                pa = points[0];
                if (!intersectsFirstSegment && !intersectsBC)
                {
                    pab.x = 0.5 * (pa.x + pc.x);
                    pab.y = 0.5 * (pa.y + pc.y);
                    pbc.x = 0.5 * (pb.x + pc.x);
                    pbc.y = 0.5 * (pb.y + pc.y);
                    if (lineIntersectsSegment(p1, p2, pab, pbc, crossPoint))
                    {
                        if ((prevCrossPoint == null || !prevCrossPoint.equals(pc)) && (firstCrossPoint == null || !firstCrossPoint.equals(pc)))
                        {
                            _local19 = numIntersections++;
                            res[_local19] = pc;
                        }
                    }
                }
            }
            return numIntersections;
        }

        public static function lineIntersectsEllipse(p1:Point, p2:Point, rect:Rectangle, res:Vector.<Point>):int
        {
            var x:Number;
            var y:Number;
            var f:Number;
            var g:Number;
            var z:Number;
            var sqrtz:Number;
            var dx:Number = (p2.x - p1.x);
            var dy:Number = (p2.y - p1.y);
            var a:Number = (0.5 * rect.width);
            var b:Number = (0.5 * rect.height);
            var cx:Number = (rect.x + a);
            var cy:Number = (rect.y + b);
            if (dx == 0 && dy == 0)
            {
                return 0;
            }
            if ((dx > 0 ? dx : -dx) > (dy > 0 ? dy : -dy))
            {
                f = (dy / dx);
                g = ((p1.y - cy) - (f * (p1.x - cx)));
                z = (((b * b) + (((a * a) * f) * f)) - (g * g));
                if (z < 0)
                {
                    return 0;
                }
                if (z == 0)
                {
                    x = ((((-(f) * g) * a) * a) / ((b * b) + (((a * a) * f) * f)));
                    y = ((f * x) + g);
                    res[0] = new Point((x + cx), (y + cy));
                    return 1;
                }
                sqrtz = Math.sqrt(z);
                x = ((((a * b) * sqrtz) - (((f * g) * a) * a)) / ((b * b) + (((a * a) * f) * f)));
                y = ((f * x) + g);
                res[0] = new Point((x + cx), (y + cy));
                x = ((((-(a) * b) * sqrtz) - (((f * g) * a) * a)) / ((b * b) + (((a * a) * f) * f)));
                y = ((f * x) + g);
                res[1] = new Point((x + cx), (y + cy));
                return 2;
            }
            f = (dx / dy);
            g = ((p1.x - cx) - (f * (p1.y - cy)));
            z = (((a * a) + (((b * b) * f) * f)) - (g * g));
            if (z < 0)
            {
                return 0;
            }
            if (z == 0)
            {
                y = ((((-(f) * g) * b) * b) / ((a * a) + (((b * b) * f) * f)));
                x = ((f * y) + g);
                res[0] = new Point((x + cx), (y + cy));
                return 1;
            }
            sqrtz = Math.sqrt(z);
            y = ((((a * b) * sqrtz) - (((f * g) * b) * b)) / ((a * a) + (((b * b) * f) * f)));
            x = ((f * y) + g);
            res[0] = new Point((x + cx), (y + cy));
            y = ((((-(a) * b) * sqrtz) - (((f * g) * b) * b)) / ((a * a) + (((b * b) * f) * f)));
            x = ((f * y) + g);
            res[1] = new Point((x + cx), (y + cy));
            return 2;
        }

        public static function lineIntersectsArc(p1:Point, p2:Point, rect:Rectangle, startAngle:Number, deltaAngle:Number, res:Vector.<Point>):int
        {
            var i:int;
            var numPoints:int = lineIntersectsEllipse(p1, p2, rect, res);
            var j:int;
            i = 0;
            while (i < numPoints)
            {
                if (ellipticAngle(rect, res[i], startAngle) <= deltaAngle)
                {
                    var _local10:int = j++;
                    res[_local10] = res[i];
                }
                i++;
            }
            i = j;
            while (i < numPoints)
            {
                res[i] = null;
                i++;
            }
            return j;
        }

        public static function lineIntersectsQuadSpline(p1:Point, p2:Point, c:Vector.<Point>, startIndex:int, res:Vector.<Point>):int
        {
            var numSolutions:int;
            var f:Number;
            var g:Number;
            var cx:Number = c[startIndex].x;
            var bx:Number = 2 * (c[(startIndex + 1)].x - cx);
            var ax:Number = c[(startIndex + 2)].x - bx - cx;
            var cy:Number = c[startIndex].y;
            var by:Number = 2 * (c[(startIndex + 1)].y - cy);
            var ay:Number = c[(startIndex + 2)].y - by - cy;
            var DistX:Number = p2.x - p1.x;
            var DistY:Number = p2.y - p1.y;
            if (DistX == 0 && DistY == 0)
            {
                return 0;
            }
            var t:Vector.<Number> = new Vector.<Number>(2);
            if ((DistX > 0 ? DistX : -DistX) > (DistY > 0 ? DistY : -DistY))
            {
                f = DistY / DistX;
                g = p1.y - (f * p1.x);
                numSolutions = calcQuadSolution((f * ax - ay), (f * bx - by), (f * cx - cy + g), t);
            }
            else
            {
                f = (DistX / DistY);
                g = (p1.x - (f * p1.y));
                numSolutions = calcQuadSolution((f * ay - ax), (f * by - bx), (f * cy - cx + g), t);
            }
            var numPoints:int;
            var i:int;
            while (i < numSolutions)
            {
                if (0 <= t[i] && t[i] <= 1)
                {
                    var _local20:int = numPoints++;
                    res[_local20] = new Point(ax * t[i] * t[i] + bx * t[i] + cx, ay * t[i] * t[i] + by * t[i] + cy);
                }
                i++;
            }
            return numPoints;
        }

        public static function lineIntersectsCubicSpline(p1:Point, p2:Point, c:Vector.<Point>, startIndex:int, res:Vector.<Point>):int
        {
            var numSolutions:int;
            var f:Number;
            var g:Number;
            var dx:Number = c[startIndex].x;
            var cx:Number = (3 * (c[(startIndex + 1)].x - dx));
            var bx:Number = ((3 * (c[(startIndex + 2)].x - c[(startIndex + 1)].x)) - cx);
            var ax:Number = (((c[(startIndex + 3)].x - bx) - cx) - dx);
            var dy:Number = c[startIndex].y;
            var cy:Number = (3 * (c[(startIndex + 1)].y - dy));
            var by:Number = ((3 * (c[(startIndex + 2)].y - c[(startIndex + 1)].y)) - cy);
            var ay:Number = (((c[(startIndex + 3)].y - by) - cy) - dy);
            var DistX:Number = (p2.x - p1.x);
            var DistY:Number = (p2.y - p1.y);
            if (DistX == 0 && DistY == 0)
            {
                return (0);
            }
            var t:Vector.<Number> = new Vector.<Number>(3);
            if ((DistX > 0 ? DistX : -DistX) > (DistY > 0 ? DistY : -DistY))
            {
                f = (DistY / DistX);
                g = (p1.y - (f * p1.x));
                numSolutions = calcCubicSolution(((f * ax) - ay), ((f * bx) - by), ((f * cx) - cy), (((f * dx) - dy) + g), t);
            }
            else
            {
                f = (DistX / DistY);
                g = (p1.x - (f * p1.y));
                numSolutions = calcCubicSolution(((f * ay) - ax), ((f * by) - bx), ((f * cy) - cx), (((f * dy) - dx) + g), t);
            }
            var numPoints:int;
            var i:int;
            while (i < numSolutions)
            {
                if (0 <= t[i] && t[i] <= 1)
                {
                    var _local22:int = numPoints++;
                    res[_local22] = new Point(((((((ax * t[i]) * t[i]) * t[i]) + ((bx * t[i]) * t[i])) + (cx * t[i])) + dx), ((((((ay * t[i]) * t[i]) * t[i]) + ((by * t[i]) * t[i])) + (cy * t[i])) + dy));
                }
                i++;
            }
            return numPoints;
        }

        private static function ellipticAngle(rect:Rectangle, p:Point, startAngle:Number):Number
        {
            var dx:Number = (p.x - rect.x) - (rect.width / 2);
            var dy:Number = rect.y + rect.height / 2 - p.y;
            var x:Number = dx / rect.width;
            var y:Number = dy / rect.height;
            var a:Number = (180 / Math.PI) * Math.atan2(y, x);
            a = a - startAngle;
            while (a < 0)
            {
                a = a + 360;
            }
            while (a > 360)
            {
                a = a - 360;
            }
            return a;
        }

        private static function retrieveArcPointFromAngle(rect:Rectangle, angle:Number, p:Point):void
        {
            angle = (angle * Math.PI) / 180;
            p.x = rect.x + (0.5 * rect.width) * (1 + Math.cos(angle));
            p.y = rect.y + (0.5 * rect.height) * (1 - Math.sin(angle));
        }

        public static function arcStartPoint(rect:Rectangle, startAngle:Number):Point
        {
            var delta:Number;
            var bestDelta:Number;
            var angle:Number = startAngle;
            var p:Point = new Point();
            retrieveArcPointFromAngle(rect, angle, p);
            var testAngle:Number = ellipticAngle(rect, p, startAngle);
            if (testAngle > 180)
            {
                delta = 0;
                while (testAngle > 180)
                {
                    delta = (delta + 0.004);
                    angle = (startAngle + delta);
                    retrieveArcPointFromAngle(rect, angle, p);
                    testAngle = ellipticAngle(rect, p, startAngle);
                }
                bestDelta = delta;
                while (testAngle < 180)
                {
                    bestDelta = delta;
                    delta = (delta / 8);
                    angle = (startAngle + delta);
                    retrieveArcPointFromAngle(rect, angle, p);
                    testAngle = ellipticAngle(rect, p, startAngle);
                }
                angle = (startAngle + bestDelta);
                retrieveArcPointFromAngle(rect, angle, p);
            }
            return p;
        }

        public static function arcEndPoint(rect:Rectangle, startAngle:Number, deltaAngle:Number):Point
        {
            var delta:Number;
            var bestDelta:Number;
            if (deltaAngle == 0)
            {
                return arcStartPoint(rect, startAngle);
            }
            var angle:Number = (startAngle + deltaAngle);
            var p:Point = new Point();
            retrieveArcPointFromAngle(rect, angle, p);
            var testAngle:Number = ellipticAngle(rect, p, startAngle);
            if (testAngle > deltaAngle)
            {
                delta = 0;
                while (testAngle > deltaAngle)
                {
                    delta = (delta + 0.004);
                    angle = ((startAngle + deltaAngle) - delta);
                    retrieveArcPointFromAngle(rect, angle, p);
                    testAngle = ellipticAngle(rect, p, startAngle);
                }
                bestDelta = delta;
                while (testAngle < deltaAngle)
                {
                    bestDelta = delta;
                    delta = (delta / 8);
                    angle = ((startAngle + deltaAngle) - delta);
                    retrieveArcPointFromAngle(rect, angle, p);
                    testAngle = ellipticAngle(rect, p, startAngle);
                }
                angle = ((startAngle + deltaAngle) - bestDelta);
                retrieveArcPointFromAngle(rect, angle, p);
            }
            return p;
        }

        public static function getClippedPoint(bbox:Rectangle, p1:Point, p2:Point):Point
        {
            var intersectionPoints:Vector.<Point> = new Vector.<Point>();
            var numIntersections:int = ClippingUtil.lineIntersectsRect(p1, p2, bbox, intersectionPoints);
            return ClippingUtil.bestClipPointOnRay(p1, p2, intersectionPoints, numIntersections);
        }

        public static function lineIntersectsRect(p1:Point, p2:Point, bbox:Rectangle, res:Vector.<Point>):int
        {
            var pts:Vector.<Point> = new Vector.<Point>(4);
            pts[0] = new Point(bbox.x, bbox.y);
            pts[1] = new Point((bbox.x + bbox.width), pts[0].y);
            pts[2] = new Point(pts[1].x, (bbox.y + bbox.height));
            pts[3] = new Point(bbox.x, pts[2].y);
            return ClippingUtil.lineIntersectsPolyPoints(p1, p2, pts, true, res);
        }

        public static function correctPoint(point:Point, otherPoint:Point):void
        {
            var separator:Number;
            var i:int;
            var ox:Number = point.x;
            var oy:Number = point.y;
            var dx:Number = (otherPoint.x - ox);
            var dy:Number = (otherPoint.y - oy);
            var dist:Number = Math.sqrt(dx * dx + dy * dy);
            if (dist > 1E-11)
            {
                separator = 1E-5;
                i = 0;
                while (i < 6)
                {
                    point.x = point.x - (dx / dist) * separator;
                    point.y = point.y - (dy / dist) * separator;
                    if (point.x != ox || point.y != oy)
                    {
                        return;
                    }
                    separator = separator * 10;
                    i++;
                }
            }
        }

        public static function calcLinearSolution(a:Number, b:Number, result:Vector.<Number>):int
        {
            if (a == 0)
            {
                if (b == 0)
                {
                    return -1;
                }
                return 0;
            }
            result[0] = -b / a;
            return 1;
        }

        public static function calcQuadSolution(a:Number, b:Number, c:Number, result:Vector.<Number>):int
        {
            if (a == 0)
            {
                return calcLinearSolution(b, c, result);
            }
            var D:Number = b * b - 4 * a * c;
            if (D < 0)
            {
                return 0;
            }
            if (D == 0)
            {
                result[0] = -b / (2 * a);
                return 1;
            }
            var sqrtD:Number = Math.sqrt(D);
            result[0] = (sqrtD - b) / (2 * a);
            result[1] = (-sqrtD - b) / (2 * a);
            return 2;
        }

        public static function calcCubicSolution(a:Number, b:Number, c:Number, d:Number, result:Vector.<Number>):int
        {
            var sgn:Number;
            var rho:Number;
            var phi:Number;
            var f:Number;
            var u1:Number;
            var u:Number;
            var v:Number;
            if (a == 0)
            {
                return calcQuadSolution(b, c, d, result);
            }
            var oneThird:Number = 1 / 3;
            var z:Number = b / (3 * a);
            var r:Number = (3 * a) * a;
            var p:Number = (3 * a * c - b * b) / r;
            var q:Number = (2 * b * b * b - 9 * a * b * c + 9 * r * d) / (9 * r * a);
            if (p == 0)
            {
                sgn = q >= 0 ? 1 : -1;
                result[0] = -sgn * Math.pow(sgn * q, oneThird) - z;
                return 1;
            }
            var cubicPThird:Number = (p * p * p) / 27;
            var squareQHalf:Number = (q * q) / 4;
            var D:Number = cubicPThird + squareQHalf;
            if (D < 0)
            {
                rho = Math.sqrt(-cubicPThird);
                phi = Math.acos(-q / 2 * rho);
                sgn = rho >= 0 ? 1 : -1;
                f = (2 * sgn) * Math.pow(sgn * rho, oneThird);
                result[0] = f * Math.cos(phi / 3) - z;
                result[1] = f * Math.cos((phi + 2 * Math.PI) / 3) - z;
                result[2] = f * Math.cos((phi + 4 * Math.PI) / 3) - z;
                return 3;
            }
            u1 = q > 0 ? cubicPThird / (Math.sqrt(D) + q / 2) : Math.sqrt(D) - q / 2;
            sgn = u1 >= 0 ? 1 : -1;
            u = sgn * Math.pow(sgn * u1, oneThird);
            if (u == 0)
            {
                sgn = q >= 0 ? 1 : -1;
                result[0] = -sgn * Math.pow(sgn * q, oneThird) - z;
                return 1;
            }
            v = -p / (3 * u);
            if (u == v)
            {
                result[0] = u + v - z;
                result[1] = -0.5 * (u + v) - z;
                return 2;
            }
            result[0] = u + v - z;
            return 1;
        }

        public static function GetLineIntersection(p1LA:Point, p2LA:Point, p1LB:Point, p2LB:Point, result:Point):Point
        {
            return GetLineIntersection1(p1LA.x, p1LA.y, p2LA.x, p2LA.y, p1LB.x, p1LB.y, p2LB.x, p2LB.y, result);
        }

        public static function GetLineIntersection1(ax1:Number, ay1:Number, ax2:Number, ay2:Number, bx1:Number, by1:Number, bx2:Number, by2:Number, result:Point):Point
        {
            var dx1:Number = ax2 - ax1;
            var dy1:Number = ay2 - ay1;
            var dx2:Number = bx2 - bx1;
            var dy2:Number = by2 - by1;
            var dx1y2:Number = dx1 * dy2;
            var dx2y1:Number = dx2 * dy1;
            if (dx1y2 == dx2y1)
            {
                return null;
            }
            if (result == null)
            {
                result = new Point();
            }
            if (ax1 == ax2)
            {
                result.x = ax1;
            }
            else if (bx1 == bx2)
			{
				result.x = bx1;
			}
			else
			{
				result.x = (ax1 * dx2y1 - bx1 * dx1y2 + (by1 - ay1) * dx1 * dx2) / (dx2y1 - dx1y2);
			}
            if (ay1 == ay2)
            {
                result.y = ay1;
            }
            else if (by1 == by2)
			{
				result.y = by1;
			}
			else
			{
				result.y = ((((ay1 * dx1y2) - (by1 * dx2y1)) + (((bx1 - ax1) * dy1) * dy2)) / (dx1y2 - dx2y1));
			}
            return result;
        }
    }
}
