package mokylin.utils
{
    import __AS3__.vec.Vector;

    [ExcludeClass]
    public class VectorUtil 
    {
        public static function sort(a:Vector.<Object>, compareFunction:Function):void
        {
            var aux:Object;
            var aux2:Object;
            var lo:int;
            var hi:int;
            var aux1:Object;
            var first:Boolean;
            var second:Boolean;
            var n:int = a.length;
            if (n == 1)
            {
                return;
            }
            if (n == 2)
            {
                if (compareFunction(a[0], a[1]) > 0)
                {
                    aux1 = a[0];
                    a[0] = a[1];
                    a[1] = aux1;
                }
                return;
            }
            var b:Vector.<Object> = new Vector.<Object>(n);
            var runs:Vector.<int> = new Vector.<int>((n + 2));
            var i:int;
            var j:int;
            var s:int;
            while (i < n)
            {
                do 
                {
                    aux = a[i++];
                } while (i < n && compareFunction(aux, a[i]) <= 0);
                var _local17:int = j++;
                runs[_local17] = i;
                s = i;
                while (i < n && compareFunction(a[i], aux) <= 0)
                {
                    if (compareFunction(aux, a[i]) > 0)
                    {
                        if (s < (i - 1))
                        {
                            lo = s;
                            hi = (i - 1);
                            while (lo < hi)
                            {
                                aux2 = a[lo];
                                a[lo] = a[hi];
                                a[hi] = aux2;
                                lo++;
                                hi--;
                            }
                        }
                        s = i;
                    }
                    aux = a[i++];
                }
                if (s < (i - 1))
                {
                    lo = s;
                    hi = (i - 1);
                    while (lo < hi)
                    {
                        aux2 = a[lo];
                        a[lo] = a[hi];
                        a[hi] = aux2;
                        lo++;
                        hi--;
                    }
                }
                var _local18:int = j++;
                runs[_local18] = i;
            }
            runs[j] = n;
            var done:Boolean;
            while (!done)
            {
                first = mergeruns(a, b, runs, n, compareFunction);
                second = mergeruns(b, a, runs, n, compareFunction);
                done = first || second;
            }
        }

        private static function mergeruns(src:Vector.<Object>, dst:Vector.<Object>, runs:Vector.<int>, n:int, compareFunction:Function):Boolean
        {
            var m:int;
            var i:int;
            var j:int;
            var k:int;
            var r:int;
            var ascending:Boolean = true;
            while (i < n)
            {
                k = i;
                m = runs[j++];
                i = runs[j++];
                merge(src, dst, k, (i - 1), m, ascending, compareFunction);
                ascending = !ascending;
                var _local12:int = r++;
                runs[_local12] = i;
            }
            runs[r] = n;
            return k == 0;
        }

        private static function merge(src:Vector.<Object>, dst:Vector.<Object>, lo:int, hi:int, mid:int, asc:Boolean, compareFunction:Function):void
        {
            var k:int = asc ? lo : hi;
            var c:int = asc ? 1 : -1;
            var i:int = lo;
            var j:int = hi;
            while (i < mid && j >= mid)
            {
                if (compareFunction(src[i], src[j]) <= 0)
                {
                    dst[k] = src[i++];
                }
                else
                {
                    dst[k] = src[j--];
                };
                k = k + c;
            }
            while (i < mid)
            {
                dst[k] = src[i++];
                k = k + c;
            }
            while (j >= mid)
            {
                dst[k] = src[j--];
                k = k + c;
            }
        }
    }
}
