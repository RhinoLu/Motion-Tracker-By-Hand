package com.ycccc{
	
	//import flash.display.MovieClip;
	import flash.display.Sprite;
    import flash.display.BitmapData;
    import flash.geom.Point;
    import flash.geom.Matrix;
	import flash.geom.*

	public class Skew extends Sprite {
		
	//切割成多个三角形
		//private var _orderA:Array = [];
		private var _sp:Sprite;
		private var _w:Number;
		private var _h:Number;
		private var _sMat:Matrix;
		private var _tMat:Matrix;
		private var _xMin:Number;
		private var _xMax:Number;
		private var _yMin:Number;
		private var _yMax:Number;
		private var _hP:Number;
		private var _vP:Number;
		private var _hsLen:Number;
		private var _vsLen:Number;
		//private var _dotList:Vector.<Point>;
		private var _dotList:Array;
		private var _pieceList:Array;
		private var _imageBitmap:BitmapData;
		/* Constructor
	     *
	     * @param mc Sprite :   圖片容器
	     * @param imageLink String : linkage name
	     * @param vP Number : 横向切割刀数
	     * @param hP Number : 綜向切割刀数
	     */
		//可改成Sprite
		public function Skew(sp:Sprite, imageBitmapData:BitmapData, vP:Number, hP:Number) {
			_sp = sp;
			_imageBitmap = imageBitmapData
			_vP = vP > 20 || vP <0 ? 2 : vP;
			_hP = hP > 20 || hP <0 ? 2 : hP;
			//_vP = vP;
			//_hP = hP;
			_w = _imageBitmap.width;
			_h = _imageBitmap.height;
			init();
		}
	    private function init():void {
		    _dotList = [];
		    _pieceList = [];
		    var ix:Number;
		    var iy:Number;
		    var w2:Number = _w/2;
		    var h2:Number = _h/2;
		    _xMin = _yMin=0;
		    _xMax = _w;
		    _yMax = _h;
		    _hsLen = _w / (_hP + 1);
		    //纵向每块的高
		    _vsLen = _h / (_vP + 1);
		    //横向每块的宽（根据精度来分割三角形）
		    var x:Number, y:Number;
		    for (ix = 0; ix < _vP + 2; ix++) {
			    //分割的顶点集合
			    for (iy = 0; iy < _hP + 2; iy++) {
				    x = ix * _hsLen;
				    y = iy * _vsLen;
				    
				    _dotList.push( { p:new Point(x, y), sp:new Point(x, y) } );
			    }
		    }
		    for (ix = 0; ix < _vP + 1; ix++) {
			    //分割成的三角形的顶点集合
			    for (iy = 0; iy < _hP + 1; iy++) {
					//trace('ix : ' + ix, 'iy : ' + iy);
				    _pieceList.push([_dotList[iy + ix * (_hP + 2)],
									 _dotList[iy + ix * (_hP + 2) + 1], 
									 _dotList[iy + (ix + 1) * (_hP + 2)]
									 ]);
									 
				    _pieceList.push([_dotList[iy + (ix + 1) * (_hP + 2) + 1],
									 _dotList[iy + (ix + 1) * (_hP + 2)],
									 _dotList[iy + ix * (_hP + 2) + 1]
									]);
			    }
		    }
		    render();
			//渲染
	    }
		
	    /* setTransform
	     *
	     * @param x0,y0 矩形左上控制点
	     * @param x1,y1 矩形右上控制点
	     * @param x2,y2 矩形右下控制点
	     * @param x3,y4 矩形左下控制点
	     *
	     */
	    public function setTransform(point0:Point, point1:Point, point2:Point, point3:Point):void {
		    var w:Number = _w;
		    var h:Number = _h;
		    var dx30:Number = point3.x - point0.x;
		    var dy30:Number = point3.y - point0.y;
		    var dx21:Number = point2.x - point1.x;
		    var dy21:Number = point2.y - point1.y;
		    var l:Number = _dotList.length;
		    while (--l>-1) {
			    //var point:Object = _dotList[l];
			    var p:Point = _dotList[l].p;
			    var sp:Point = _dotList[l].sp;
				
			    var gx:Number = (p.x - _xMin) / w;
			    var gy:Number = (p.y - _yMin) / h;
			    var bx:Number = point0.x + gy * (dx30);
			    var by:Number = point0.y + gy * (dy30);
			    sp.x = bx + gx * ((point1.x + gy * (dx21)) - bx);
			    sp.y = by + gx * ((point1.y + gy * (dy21)) - by);
				
		    }
		    render();
	    }
		
	    private function render():void {
			//trace("render")
		    //var t:Number;
			var p0:Object;
		    var p1:Object;
		    var p2:Object;
		    var c:Sprite = _sp;
		    var a:Array;
		    c.graphics.clear();
		    _sMat = new Matrix();
		    _tMat = new Matrix();
		    var l:Number = _pieceList.length;
		    while (--l>-1) {
			    a = _pieceList[l];
			    p0 = a[0];
			    p1 = a[1];
			    p2 = a[2];
			    var x0:Number = p0.sp.x;
			    var y0:Number = p0.sp.y;
			    var x1:Number = p1.sp.x;
			    var y1:Number = p1.sp.y;
			    var x2:Number = p2.sp.x;
			    var y2:Number = p2.sp.y;
				//----------------------------
			    var u0:Number = p0.p.x;
			    var v0:Number = p0.p.y;
			    var u1:Number = p1.p.x;
			    var v1:Number = p1.p.y;
			    var u2:Number = p2.p.x;
			    var v2:Number = p2.p.y;
			    _tMat.tx = u0;
			    _tMat.ty = v0;
			    _tMat.a = (u1 - u0) / _w;
			    _tMat.b = (v1 - v0) / _w;
			    _tMat.c = (u2 - u0) / _h;
			    _tMat.d = (v2 - v0) / _h;
			    _sMat.a = (x1 - x0) / _w;
			    _sMat.b = (y1 - y0) / _w;
			    _sMat.c = (x2 - x0) / _h;
			    _sMat.d = (y2 - y0) / _h;
				
			    _sMat.tx = x0;
			    _sMat.ty = y0;
			    _tMat.invert();
			    _tMat.concat(_sMat);
				//beginBitmapFill(bitmap:BitmapData, matrix:Matrix = null, repeat:Boolean = true, smooth:Boolean = false):void 
			    c.graphics.beginBitmapFill(_imageBitmap, _tMat, false, true);
			    c.graphics.moveTo(x0, y0);
			    c.graphics.lineTo(x1, y1);
			    c.graphics.lineTo(x2, y2);
			    c.graphics.endFill();
		    }
		}
		public function get sp():Sprite { return _sp; }
		public function set sp(value:Sprite):void {	_sp = value; }
		
		public function get imageBitmap():BitmapData 
		{
			return _imageBitmap;
		}
		
		public function set imageBitmap(value:BitmapData):void 
		{
			_imageBitmap = value;
		}
		
		
		
		
		
	}
}