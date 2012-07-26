package  
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.data.DataLoaderVars;
	import com.greensock.loading.data.LoaderMaxVars;
	import com.greensock.loading.data.SWFLoaderVars;
	import com.greensock.loading.DataLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.SWFLoader;
	import com.ycccc.Skew;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class Test extends Sprite 
	{
		private var loaderMax:LoaderMax; // ------------- 載入 XML
		private var loaderSWF:SWFLoader; // ------------- 載入影片
		private var movie:MovieClip; // ----------------- 影片
		private var skewVector:Vector.<Skew>; // -------- skew vector
		private var positionVector:Vector.<Object>; // -- 對位資料 vector
		private var skew_container:Sprite; // ----------- skew 容器
		
		public function Test() 
		{
			stage?init():addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			positionVector = new Vector.<Object>;
			loadXML();
			skew_container = new Sprite();
			addChild(skew_container);
		}
		
		// 載入對位資料 XML
		private function loadXML():void 
		{
			loaderMax = new LoaderMax(new LoaderMaxVars().maxConnections(1).onChildComplete(onChildXMLComplete).onComplete(onLoadXMLComplete).vars);
			for (var i:int = 0; i < 2; i++) 
			{
				loaderMax.append(new DataLoader("xml/" + i + ".xml", new DataLoaderVars().name("x" + i).noCache(true).vars));
			}
			loaderMax.load();
		}
		
		private function onChildXMLComplete(e:LoaderEvent):void 
		{
			var loader:DataLoader = e.target as DataLoader;
			//trace(loader.name);
			var xml:XML = XML(loader.content);
			//trace(xml);
			var obj:Object = { };
			obj.num = int(xml.num);
			obj.start = int(xml.start);
			obj.end = int(xml.end);
			obj.f = [];
			for (var i:int = 0; i < xml.f.length(); i++) 
			{
				var arr:Array = String(xml.f[i]).split(",");
				obj.f[i] = [];
				obj.f[i][0] = new Point(int(arr[0]), int(arr[1]));
				obj.f[i][1] = new Point(int(arr[2]), int(arr[3]));
				obj.f[i][2] = new Point(int(arr[4]), int(arr[5]));
				obj.f[i][3] = new Point(int(arr[6]), int(arr[7]));
				//trace(obj.f[i]);
			}
			positionVector[loader.name.split("x")[1]] = obj;
			//t.obj(obj);
		}
		
		private function onLoadXMLComplete(e:LoaderEvent):void 
		{
			loadMovie();
		}
		
		// 載入對位影片
		private function loadMovie():void
		{
			loaderSWF = new SWFLoader("final.swf", new SWFLoaderVars().onComplete(onLoadMovieComplete).vars);
			loaderSWF.load();
		}
		
		private function onLoadMovieComplete(e:LoaderEvent):void 
		{
			var _class:Class = loaderSWF.getClass("MovieMC") as Class;
			movie = new _class();
			//movie.stop();
			addChild(movie);
			movie.addEventListener(Event.ENTER_FRAME, parsePosition);
			
			bitmapDataToVector();
		}
		
		// 將圖片餵給 skew
		private function bitmapDataToVector():void
		{
			// 每個 skew 要有自己的 container
			for (var i:int = 0; i < positionVector.length; i++) 
			{
				var sp:Sprite = new Sprite();
				skew_container.addChild(sp);
			}
			skewVector = new Vector.<Skew>;
			skewVector[0] = new Skew(skew_container.getChildAt(0) as Sprite, new PIC1(), 1, 1);
			skewVector[1] = new Skew(skew_container.getChildAt(1) as Sprite, new PIC2(), 1, 1);
		}
		
		// 每 frame 解析
		private function parsePosition(e:Event):void 
		{
			var cf:uint = movie.currentFrame;
			//trace(cf);
			
			for (var i:int = 0; i < positionVector.length; i++) 
			{
				var skew:Skew = skewVector[i];
				var obj:Object = positionVector[i];
				if (cf - 1 >= obj.start && cf - 1 <= obj.end) {
					var posArray:Array = obj.f[(cf - 1) - obj.start];
					skew.setTransform(posArray[0], posArray[1], posArray[2], posArray[3]);
				}else {
					skew.sp.graphics.clear();
				}
			}
			
			if (cf == movie.totalFrames) {
				//movie.stop();
				//movie.removeEventListener(Event.ENTER_FRAME, parsePosition);
			}
		}
		
	}
}