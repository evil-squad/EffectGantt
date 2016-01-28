package mokylin.gantt
{
    import mx.skins.ProgrammaticSkin;
    import flash.geom.Point;
    import flash.display.LineScaleMode;
    import flash.display.CapsStyle;
    import flash.display.JointStyle;
    import flash.display.Graphics;

    public class TaskSymbolSkin extends ProgrammaticSkin 
    {

		/**
		 * 
		 * 
		 * 
		 * @   @
		 * @   @
		 * **@***********************
		 *  
		 * @param a 假如a为y轴1个星，x轴2个星
		 * @return 
		 * 
		 */
        private static function GetUpPentagonPath(a:Number):Array
        {
            return [new Point(a + a, a + a), new Point(0, a + a), new Point(0, a), new Point(a, 0), new Point((a + a), a)];
        }
		/**
		 * 
		 * 
		 * 
		 *   @
		 *@     @
		 *@ ****@*********************
		 *  
		 * @param a假如a为y轴1个星，x轴2个星
		 * @return 
		 * 
		 */
        private static function GetDownPentagonPath(a:Number):Array
        {
            return [new Point(0, 0), new Point((a + a), 0), new Point((a + a), a), new Point(a, (a + a)), new Point(0, a)];
        }

		/**
		 *        @
		 * 
		 * 
		 * 
		 *@               @
		 *@   @       @   @
		 *            
		 *    @       @
		 * *************************
		 *  
		 * @param a 假如a为y轴4个星，x轴8个星
		 * @return 
		 * 
		 */		
        private static function GetDownArrowPath(a:Number):Array
        {
            return [new Point(a, (a + a)), 
				new Point((a + a), a), 
				new Point((a + a), (a - (a / 4))), 
				new Point((a + (a / 2)), (a - (a / 4))), 
				new Point((a + (a / 2)), 0), 
				new Point((a - (a / 2)), 0), 
				new Point((a - (a / 2)), (a - (a / 4))), 
				new Point(0, (a - (a / 4))), 
				new Point(0, a)];
        }

		/**
		 *9 
		 *8      @           @
		 *7         
		 *6 
		 *5@     @           @     @
		 *4@                       @
		 *3               
		 *2             
		 *1           
		 *0            @
		 * 0**1**2**3**4**5**6**7**8**9**10**11***
		 *  
		 * @param a 假如a为 4
		 * @return 
		 * 
		 */
        private static function GetUpArrowPath(a:Number):Array
        {
            return ([new Point(a, 0), 
				new Point((a + a), a), 
				new Point((a + a), (a + (a / 4))), 
				new Point((a + (a / 2)), (a + (a / 4))), 
				new Point((a + (a / 2)), (a + a)), 
				new Point((a - (a / 2)), (a + a)), 
				new Point((a - (a / 2)), (a + (a / 4))), 
				new Point(0, (a + (a / 4))), 
				new Point(0, a)]);
        }

		/**
		 *9 
		 *8@                       @               
		 *7         
		 *6 
		 *5                    
		 *4                       
		 *3               
		 *2             
		 *1           
		 *0            @
		 * 0**1**2**3**4**5**6**7**8**9**10**11***
		 *  
		 * @param a 假如a为 4
		 * @return 
		 * 
		 */
        private static function GetUpTrianglePath(a:Number):Array
        {
            return [new Point(a, 0), new Point((a + a), (a + a)), new Point(0, (a + a))];
        }
		/**
		 *9 
		 *8            @                           
		 *7         
		 *6 
		 *5                    
		 *4                       
		 *3               
		 *2             
		 *1           
		 *0@                       @           
		 * 0**1**2**3**4**5**6**7**8**9**10**11***
		 *  
		 * @param a 假如a为 4
		 * @return 
		 * 
		 */
        private static function GetDownTrianglePath(a:Number):Array
        {
            return [new Point((a + a), 0), new Point(a, (a + a)), new Point(0, 0)];
        }
		/**
		 *9 
		 *8            @                            
		 *7         
		 *6 
		 *5                    
		 *4@                       
		 *3               
		 *2             
		 *1           
		 *0            @                      
		 * 0**1**2**3**4**5**6**7**8**9**10**11***
		 *  
		 * @param a 假如a为 4
		 * @return 
		 * 
		 */
        private static function GetLeftTrianglePath(a:Number):Array
        {
            return [new Point(0, a), new Point(a, 0), new Point(a, (a + a))];
        }
		/**
		 *9 
		 *8            @                           
		 *7         
		 *6 
		 *5                    
		 *4                        @
		 *3               
		 *2             
		 *1           
		 *0            @                      
		 * 0**1**2**3**4**5**6**7**8**9**10**11***
		 *  
		 * @param a 假如a为 4
		 * @return 
		 * 
		 */
        private static function GetRightTrianglePath(a:Number):Array
        {
            return [new Point((a + a), a), new Point(a, 0), new Point(a, (a + a))];
        }
		/**
		 *9 
		 *8            @                            
		 *7         
		 *6 
		 *5                    
		 *4@                       @
		 *3               
		 *2             
		 *1           
		 *0            @                      
		 * 0**1**2**3**4**5**6**7**8**9**10**11***
		 *  
		 * @param a 假如a为 4
		 * @return 
		 * 
		 */
        private static function GetDiamondPath(a:Number):Array
        {
            return [new Point(a, 0), new Point((a + a), a), new Point(a, (a + a)), new Point(0, a)];
        }


        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            var path:Array;
            var borderColor:uint;
            var color:uint;
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            graphics.clear();
            var isStart:Boolean = name.charAt(0) == "s";
            var shape:String = getStyle(isStart ? "startSymbolShape" : "endSymbolShape");
            path = this.getSymbolPath(shape, unscaledWidth, unscaledHeight);
            if (!path)
            {
                return;
            }
            var borderThickness:Number = getStyle(isStart ? "startSymbolBorderThickness" : "endSymbolBorderThickness");
            switch (name)
            {
                case "startSelectedSkin":
                case "endSelectedSkin":
                    borderColor = getStyle("borderSelectedColor");
                    color = getStyle("selectedColor");
                    break;
                case "startSelectedOverSkin":
                case "endSelectedOverSkin":
                    borderColor = getStyle("borderSelectedRollOverColor");
                    color = getStyle("selectedRollOverColor");
                    break;
                case "startOverSkin":
                case "endOverSkin":
                    borderColor = getStyle("borderRollOverColor");
                    color = getStyle("rollOverColor");
                    break;
                case "startSkin":
                    borderColor = getStyle("startSymbolBorderColor");
                    color = getStyle("startSymbolColor");
                    break;
                case "endSkin":
                    borderColor = getStyle("endSymbolBorderColor");
                    color = getStyle("endSymbolColor");
                    break;
            }
            this.drawSymbol(path, graphics, borderThickness, borderColor, color);
        }

        protected function drawSymbol(path:Array, g:Graphics, borderThickness:Number, borderColor:uint, fillColor:uint):void
        {
            var p:Point;
            if (borderThickness > 0)
            {
                g.lineStyle(borderThickness, borderColor, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.MITER);
            }
            var first:Boolean = true;
            for each (p in path)
            {
                if (first)
                {
                    g.moveTo(p.x, p.y);
                    g.beginFill(fillColor);
                    first = false;
                }
                else
                {
                    g.lineTo(p.x, p.y);
                }
            }
            g.endFill();
        }

        protected function getSymbolPath(shape:String, symbolWidth:Number, symbolHeight:Number):Array
        {
            var size:Number = Math.min(symbolWidth, symbolHeight);
            var path:Array;
            switch (shape)
            {
                case "upPentagon":
                case "up-pentagon":
                    return GetUpPentagonPath(size / 2);
                case "downPentagon":
                case "down-pentagon":
                    return GetDownPentagonPath(size / 2);
                case "diamond":
                    return GetDiamondPath(size / 2);
                case "upTriangle":
                case "up-triangle":
                    return GetUpTrianglePath(size / 2);
                case "downTriangle":
                case "down-triangle":
                    return GetDownTrianglePath(size / 2);
                case "upArrow":
                case "up-arrow":
                    return GetUpArrowPath(size / 2);
                case "downArrow":
                case "down-arrow":
                    return GetDownArrowPath(size / 2);
                case "none":
            }
            return path;
        }
    }
}
