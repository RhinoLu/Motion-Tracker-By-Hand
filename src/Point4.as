package  
{
	import com.ycccc.Skew;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import org.osflash.signals.Signal;
	
	public class Point4 extends Sprite 
	{
		public static const POSITION_UPDATE:String = "position update";
		public static const FOCUS_UPDATE:String = "focus update";
		
		private var p0:PointClip; // --- 左上
		private var p1:PointClip; // --- 右上
		private var p2:PointClip; // --- 右下
		private var p3:PointClip; // --- 左下
		private var shapeSprite:Sprite; // --- shape 容器
		private var _text:TextField; 
		private var _bitmapData:BitmapData;
		private var _skew:Skew;
		
		private var _signal:Signal = new Signal();
		
		private var _movieWidth:Number;
		private var _movieHeight:Number;
		
		public function Point4(id:uint, movieWidth:Number = 960, movieHeight:Number = 420) 
		{
			_movieWidth = movieWidth;
			_movieHeight = movieHeight;
			
			var format:TextFormat = new TextFormat();
            format.font = "Verdana";
            format.color = 0xFF0000;
            format.size = 200;
			
			_text = new TextField();
			_text.autoSize = TextFieldAutoSize.LEFT;
			_text.defaultTextFormat = format;
			_text.text = String(id);
			//addChild(_text);
			
			stage?init():addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			
			var halfWidth:Number = _movieWidth * 0.5;
			var halfHeight:Number = _movieHeight * 0.5;
			
			p0 = new PointClip(this, halfWidth - 100, halfHeight - 100);
			p1 = new PointClip(this, halfWidth + 100, halfHeight - 100);
			p2 = new PointClip(this, halfWidth + 100, halfHeight + 100);
			p3 = new PointClip(this, halfWidth - 100, halfHeight + 100);
			
			shapeSprite = new Sprite();
			shapeSprite.alpha = 0.5;
			addChildAt(shapeSprite, 0);
			
			_bitmapData = new BitmapData(_text.textWidth, _text.textHeight, false, 0x00FF00);
			_bitmapData.draw(_text, null, null, null, null, true);
			
			_text = null;
			
			_skew = new Skew(shapeSprite, _bitmapData, 1, 1);
			
			drawRect();
			
			addEventListener("ON_DOWN", onPointDown);
			addEventListener("ON_UP"  , onPointUp);
		}
		
		private function onRemove(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			_bitmapData.dispose();
			stopDrag();
			removeEventListener("ON_DOWN", onPointDown);
			removeEventListener("ON_UP"  , onPointUp);
		}
		
		private function onPointDown(e:Event):void 
		{
			addEventListener(Event.ENTER_FRAME, drawRect);
		}
		
		private function onPointUp(e:Event):void 
		{
			drawRect();
			removeEventListener(Event.ENTER_FRAME, drawRect);
			_signal.dispatch(Point4.POSITION_UPDATE);
		}
		
		private function drawRect(e:Event = null):void
		{
			_skew.setTransform(new Point(p0.x, p0.y), new Point(p1.x, p1.y), new Point(p2.x, p2.y), new Point(p3.x, p3.y));
		}
		
		public function get result():Object 
		{
			//trace("get");
			// TODO : Global convert
			var value:Object = { };
			value.pts = [];
			value.pts[0] = new Point(p0.x, p0.y);
			value.pts[1] = new Point(p1.x, p1.y);
			value.pts[2] = new Point(p2.x, p2.y);
			value.pts[3] = new Point(p3.x, p3.y);
			//trace(value[0], value[1], value[2], value[3]);
			return value;
		}
		
		public function set result(value:Object):void 
		{
			//trace("set");
			p0.x = value.pts[0].x;
			p0.y = value.pts[0].y;
			p1.x = value.pts[1].x;
			p1.y = value.pts[1].y;
			p2.x = value.pts[2].x;
			p2.y = value.pts[2].y;
			p3.x = value.pts[3].x;
			p3.y = value.pts[3].y;
			drawRect();
		}
		
		public function get signal():Signal 
		{
			return _signal;
		}
		
		public function update():void
		{
			drawRect();
		}
	}
}