package 
{
	import com.bit101.components.InputText;
	import com.bit101.components.PushButton;
	import com.bit101.components.RadioButton;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.ui.Keyboard;
	import net.hires.debug.Stats;
	
	/**
	 * 每次處理一個編號
	 */
	public class Main extends Sprite 
	{
		private var exportButton:PushButton; // ------- 輸出場景中所有的 XML
		private var importButton:PushButton; // ------- 匯入某編號的 XML (複數檔案？)
		private var numberText:InputText; // ---------- 編號
		private var startText:InputText; // ----------- 起始 frame
		private var endText:InputText; // ------------- 結束 frame
		private var addButton:PushButton; // ---------- 加入四點對位
		private var showButton:PushButton; // --------- 顯示或隱藏四點對位
		private var musicButton:PushButton; // -------- 音樂開關
		
		private var clipXText:InputText; // ----------- clip x value
		private var clipYText:InputText; // ----------- clip y value
		private var updateButton:PushButton; // ------- 更新座標
		
		private var loadMovieButton:PushButton; // ---- 載入挖洞影片
		private var loadMovieColorButton:PushButton; // 載入色版影片
		private var finalRadio:RadioButton; // -------- 挖洞影片
		private var colorRadio:RadioButton; // -------- 有色版影片
		
		private var duplicatePrevButton:PushButton; //  複製上一格座標
		private var duplicateNextButton:PushButton; //  複製下一格座標
		
		private var playButton:PushButton; // --------- 播放/停止
		private var prevButton:PushButton; // --------- 上一格
		private var nextButton:PushButton; // --------- 下一格
		private var jumpButton:PushButton; // --------- 跳至某 frame
		private var frameText:InputText; // ----------- 目標 frame
		
		private var fileMovie:FileReference = new FileReference(); // 提出來避免被GC
		private var movieType:String; // -------------- 欲載入影片類型
		private var currentMovie:MovieClip; // -------- 當前目標影片
		private var totalFrames:uint; // -------------- 影片總 frame 數
		
		private var frameSlider:MyHUISlider; // ------- 目前 frmaeUI
		
		private var movie_container:Sprite; // -------- 挖洞影片容器
		private var movie:MovieClip; // --------------- 挖洞影片
		private var movie_color_container:Sprite; // -- 色版影片容器
		private var movieColor:MovieClip; // ---------- 色版影片
		
		private var p4:Point4; // --------------------- 四點對位工具
		private var point4_container:Sprite; // ------- 四點對位容器
		
		private var position_vector:Vector.<Object>; // 座標 vector
		
		private var focusClip:PointClip; // ----------- 目前選取 PointClip
		
		public function Main():void 
		{
			stage?init():addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.stageFocusRect = false; // 防止按 tab 出現黃框
			
			exportButton = new PushButton(this, 80, 10, "Export XML", onExportClick);
			exportButton.enabled = false;
			importButton = new PushButton(this, 80, 35, "Import XML", onImportClick);
			//importButton.enabled = false;
			
			loadMovieButton      = new PushButton(this, 200, 10, "Load Final", onLoadFinalMovie);
			loadMovieColorButton = new PushButton(this, 200, 35, "Load Color", onLoadColorMovie);
			finalRadio = new RadioButton(this, 310, 10, "final",  true, onRadioClick);
			finalRadio.enabled = false;
			colorRadio = new RadioButton(this, 310, 25, "color", false, onRadioClick);
			colorRadio.enabled = false;
			
			numberText = new InputText(this , 400, 10, "Number");
			numberText.restrict = "0-9";
			startText = new InputText(this , 400, 30, "Start at");
			startText.restrict = "0-9";
			endText = new InputText(this , 400, 50, "End at");
			endText.restrict = "0-9";
			addButton = new PushButton(this, 400, 70, "Add" , onAddClick);
			addButton.enabled = false;
			
			clipXText = new InputText(this , 565, 10);
			clipXText.restrict = "0-9 . \\-";
			clipXText.enabled = false;
			clipYText = new InputText(this , 565, 30);
			clipYText.restrict = "0-9 . \\-";
			clipYText.enabled = false;
			updateButton = new PushButton(this, 565, 50, "Update", onUpdateClick);
			updateButton.enabled = false;
			
			duplicatePrevButton = new PushButton(this, 700, 10, "Copy Prev Frame", onDuplicatePrevClick);
			duplicatePrevButton.enabled = false;
			duplicateNextButton = new PushButton(this, 700, 35, "Copy Next Frame", onDuplicateNextClick);
			duplicateNextButton.enabled = false;
			
			musicButton  = new PushButton(this, 860, 10, "Music ON", onMusicClick);
			musicButton.toggle = true;
			musicButton.selected = true;
			showButton   = new PushButton(this, 860, 35, "Show Point4", onShowClick);
			showButton.toggle = true;
			showButton.selected = true;
			
			playButton = new PushButton(this,  10, 700, "Play", onPlayClick);
			playButton.toggle = true;
			prevButton = new PushButton(this, 160, 700, "< Prev", onPrevClick);
			nextButton = new PushButton(this, 265, 700, "Next >", onNextClick);
			jumpButton = new PushButton(this, 415, 700, "Jump", onJumpClick);
			frameText  = new InputText(this , 520, 700);
			frameText.restrict = "0-9";
			
			frameSlider = new MyHUISlider(this, 10, 750, "frame", onFrameSliderChange);
			frameSlider.minimum = 1;
			frameSlider.maximum = 1500;
			frameSlider.labelPrecision = 0;
			frameSlider.width = 990;
			frameSlider.addEventListener("ON_DRAG", onFrameSliderDrag);
			frameSlider.addEventListener("ON_DROP", onFrameSliderDrop);
			
			movie_container = new Sprite();
			movie_container.x = 0;
			movie_container.y = 100;
			addChild(movie_container);
			
			movie_color_container = new Sprite();
			movie_color_container.x = 0;
			movie_color_container.y = 100;
			addChild(movie_color_container);
			movie_color_container.visible = false;
			
			point4_container = new Sprite();
			point4_container.x = movie_container.x;
			point4_container.y = movie_container.y;
			addChild(point4_container);
			
			addChild(new Stats());
		}
		
		private function onLoadFinalMovie(e:MouseEvent):void
		{
			movieType = "final";
			loadMovie();
		}
		
		private function onLoadColorMovie(e:MouseEvent):void
		{
			movieType = "color";
			loadMovie();
		}
		
		private function loadMovie():void
		{
			fileMovie.addEventListener(Event.SELECT, onMovieSelect);
			fileMovie.addEventListener(Event.COMPLETE, onMovieComplete);
            fileMovie.browse([new FileFilter("SWF", "*.swf")]);
		}
		
		private function onMovieSelect(e:Event):void
		{
            //trace("onMovieSelect: name=" + fileMovie.name);
			fileMovie.load();
        }
		
		private function onMovieComplete(e:Event):void
		{
            //trace("onMovieComplete: " + e.target);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadMovieComplete);
			var lc:LoaderContext = new LoaderContext(false, new ApplicationDomain(ApplicationDomain.currentDomain), null);
			lc.allowCodeImport = true;
			loader.loadBytes(fileMovie.data, lc);
        }
		
		private function onLoadMovieComplete(e:Event):void 
		{
			//trace("onLoadMovieComplete");
			var info:LoaderInfo = e.target as LoaderInfo;
			if (info.applicationDomain.hasDefinition("MovieMC")) {
				var _class:Class = info.applicationDomain.getDefinition("MovieMC") as Class;
				if (movieType == "final") {
					movie = new _class();
					movie.stop();
					movie_container.addChild(movie);
					totalFrames = frameSlider.maximum = movie.totalFrames;
					loadMovieButton.enabled = false;
					movie_container.visible = true;
					movie_color_container.visible = false;
					finalRadio.selected = true;
					currentMovie = movie;
					finalRadio.selected = finalRadio.enabled = true;
				}else if (movieType == "color") {
					movieColor = new _class();
					movieColor.stop();
					movie_color_container.addChild(movieColor);
					totalFrames = frameSlider.maximum = movieColor.totalFrames;
					loadMovieColorButton.enabled = false;
					movie_container.visible = false;
					movie_color_container.visible = true;
					colorRadio.selected = true;
					currentMovie = movieColor;
					colorRadio.selected = colorRadio.enabled = true;
				}
				if (!position_vector) {
					initPositionVector();
					addButton.enabled = true;
				}
			}else {
				// error
			}
		}
		
		private function initPositionVector():void 
		{
			position_vector = new Vector.<Object>;
			for (var i:int = 0; i < totalFrames; i++) 
			{
				position_vector[i] = null;
			}
		}
		
		private function checkFrame():void
		{
			//trace("checkFrame : " + currentMovie.currentFrame);
			if (!position_vector || !p4) return;
			if (position_vector[currentMovie.currentFrame-1]) {
				p4.result = position_vector[currentMovie.currentFrame-1];
				p4.visible = true;
			}else {
				p4.visible = false;
			}
		}
		
		private function onFrameSliderDrag(e:Event):void 
		{
			currentMovie.stop();
			currentMovie.removeEventListener(Event.ENTER_FRAME, onMovieFrame);
		}
		
		private function onFrameSliderDrop(e:Event):void 
		{
			currentMovie.gotoAndStop(Math.round(frameSlider.value));
		}
		
		private function onFrameSliderChange(e:Event):void 
		{
			currentMovie.gotoAndStop(Math.round(frameSlider.value));
			checkFrame();
		}
		
		private function onMovieFrame(e:Event):void 
		{
			if (movie_container.visible) {
				currentMovie = movie;
			}else {
				currentMovie = movieColor;
			}
			
			frameSlider.value = currentMovie.currentFrame;
			checkFrame();
		}
		
		private function onExportClick(e:MouseEvent ):void 
		{
			var num:uint = int(numberText.text);
			var start:uint = int(startText.text);
			var end:uint   = int(endText.text);
			
			var xml:XML = 
				<data>
					<num>{num}</num>
					<start>{start}</start>
					<end>{end}</end>
				</data>
			
			for (var i:int = start; i < end + 1; i++) 
			{
				var pts:Array = position_vector[i].pts;
				var str:String = pts[0].x + "," + pts[0].y + "," + pts[1].x + "," + pts[1].y + "," + pts[2].x + "," + pts[2].y + "," + pts[3].x + "," + pts[3].y;
				xml.appendChild(<f>{str}</f>);
			}
			
			var file:FileReference = new FileReference();
			file.save(xml, numberText.text + ".xml");
		}
		
		private var fileImport:FileReference = new FileReference();
		private function onImportClick(e:MouseEvent ):void 
		{
            fileImport.addEventListener(Event.SELECT, onImportSelect);
			fileImport.addEventListener(Event.COMPLETE, onImportComplete);
			//fileImport.addEventListener(ProgressEvent.PROGRESS, onImportProgress);
            fileImport.browse([new FileFilter("XML", "*.xml")]);
		}
		
		private function onImportSelect(e:Event):void
		{
            //trace("onImportSelect: name=" + fileImport.name);
			fileImport.load();
        }
		/*
		private function onImportProgress(e:ProgressEvent):void
		{
            trace("onImportProgress: name=" + fileImport.name + " bytesLoaded=" + e.bytesLoaded + " bytesTotal=" + e.bytesTotal);
        }*/
		
		private function onImportComplete(e:Event):void
		{
            //trace("onImportComplete: " + e.target.data);
			var xml:XML = XML(e.target.data);
			//trace(xml);
			numberText.text = String(xml.num);
			startText.text = String(xml.start);
			endText.text = String(xml.end);
			var num:uint = int(xml.num);
			var start:uint = int(xml.start);
			var end:uint   = int(xml.end);
			for (var i:int = 0; i < end - start + 1; i++) 
			{
				var array:Array = String(xml.f[i]).split(",");
				//trace(array);
				var value:Object = { };
				value.pts = [];
				value.pts[0] = new Point(array[0], array[1]);
				value.pts[1] = new Point(array[2], array[3]);
				value.pts[2] = new Point(array[4], array[5]);
				value.pts[3] = new Point(array[6], array[7]);
				//trace(i + start);
				position_vector[i + start] = value;
			}
			addPoint4(num, start, end, true);
			//t.obj(position_vector[0]);
			duplicatePrevButton.enabled = true;
			duplicateNextButton.enabled = true;
        }
		
		private function onAddClick(e:MouseEvent ):void 
		{
			var num:uint   = int(numberText.text);
			var start:uint = int(startText.text);
			var end:uint   = int(endText.text);
			if (end > currentMovie.totalFrames - 1) {
				end = currentMovie.totalFrames - 1;
				endText.text = String(end);
			}
			numberText.text = String(num);
			startText.text  = String(start);
			endText.text    = String(end);
			//trace(num, start, end);
			addPoint4(num, start, end, false);
			
			importButton.enabled = false;
			addButton.enabled = false;
			duplicatePrevButton.enabled = true;
			duplicateNextButton.enabled = true;
		}
		
		private function addPoint4(num:uint, start:uint, end:uint, isImport:Boolean):void
		{
			if (num > -1 && start > -1 && end > -1) {
				if (start <= end) {
					numberText.enabled = startText.enabled = endText.enabled = addButton.enabled = false;
					
					p4 = new Point4(num);
					p4.signal.add(onP4Call);
					point4_container.addChild(p4);
					
					if (!isImport) {
						for (var i:int = start; i < end + 1; i++) 
						{
							position_vector[i] = p4.result;
						}
					}
					
					currentMovie.addFrameScript(start, function():void {
						currentMovie.addFrameScript(currentMovie.currentFrame-1, null);
						checkFrame();
					} );
					currentMovie.gotoAndStop(start + 1);
					frameSlider.value = start + 1;
					
					stage.addEventListener(MouseEvent.CLICK, onStageClick);
					exportButton.enabled = true;
				}else {
					// error
				}
			}else {
				// error
			}
		}
		
		private function onP4Call(type:String, obj:*= null):void 
		{
			if (type == Point4.POSITION_UPDATE) {
				position_vector[currentMovie.currentFrame-1] = p4.result;
			}
		}
		
		private function onStageClick(e:MouseEvent):void
		{
			//trace("onStageClick : " + e.target);
			var p:PointClip = e.target as PointClip;
			//if(new Rectangle(_list.x, _list.y, _list.width, _list.height).contains(event.stageX, event.stageY)) return;
			if (e.target == clipXText || clipXText.contains(e.target as DisplayObject) || e.target == clipYText || clipYText.contains(e.target as DisplayObject) || e.target == updateButton || p) {
				if (p) {
					focusClip = p;
					clipXText.enabled = clipYText.enabled = updateButton.enabled = true;
					clipXText.text = String(focusClip.x);
					clipYText.text = String(focusClip.y);
					
					// 偵聽鍵盤上下左右
					stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				}
			}else {
				focusClip = null;
				clipXText.enabled = clipYText.enabled = updateButton.enabled = false;
				clipXText.text = "";
				clipYText.text = "";
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			}
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			//trace("Key Pressed: " + String.fromCharCode(e.charCode) +" (character code: " + e.charCode + ")");
			if (focusClip) {
				if (e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN || e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.RIGHT) {
					if (e.keyCode == Keyboard.UP)
					{
						//trace("上");
						focusClip.y--;
						clipYText.text = String(focusClip.y);
					}else
					if (e.keyCode == Keyboard.DOWN)
					{ 
						//trace("下");
						focusClip.y++;
						clipYText.text = String(focusClip.y);
					}else
					if (e.keyCode == Keyboard.LEFT)
					{ 
						//trace("左");
						focusClip.x--;
						clipXText.text = String(focusClip.x);
					}else
					if (e.keyCode == Keyboard.RIGHT)
					{ 
						//trace("右");
						focusClip.x++;
						clipXText.text = String(focusClip.x);
					}
					p4.update();
					position_vector[currentMovie.currentFrame - 1] = p4.result;
				}
			}
		}
		
		private function onUpdateClick(e:MouseEvent):void
		{
			//trace("onUpdateClick");
			// 此動作先於 onStageClick
			if (focusClip) {
				focusClip.x = Number(clipXText.text);
				focusClip.y = Number(clipYText.text);
				p4.update();
				position_vector[currentMovie.currentFrame - 1] = p4.result;
			}
		}
		
		private function onRadioClick(e:MouseEvent ):void 
		{
			var radio:RadioButton = e.target as RadioButton;
			if (radio == finalRadio) {
				movie_container.visible = true;
				movie_color_container.visible = false;
				if (movie && movieColor) {
					movieColor.stop();
					movie.gotoAndStop(movieColor.currentFrame);
				}
				currentMovie = movie;
			}else if (radio == colorRadio) {
				movie_container.visible = false;
				movie_color_container.visible = true;
				if (movie && movieColor) {
					movie.stop();
					movieColor.gotoAndStop(movie.currentFrame);
				}
				currentMovie = movieColor;
			}
		}
		
		// 複製上一格資料
		private function onDuplicatePrevClick(e:MouseEvent):void 
		{
			var cf:uint = currentMovie.currentFrame;
			if (cf - 1 > int(startText.text) && cf - 1 <= int(endText.text)) {
				var prev:Array = position_vector[cf - 2].pts;
				position_vector[cf - 1].pts = prev.concat();
				p4.result = position_vector[cf - 1];
			}else {
				// error
				trace("error");
			}
		}
		
		// 複製下一格資料
		private function onDuplicateNextClick(e:MouseEvent):void 
		{
			var cf:uint = currentMovie.currentFrame;
			if (cf - 1 >= int(startText.text) && cf - 1 < int(endText.text)) {
				var next:Array = position_vector[cf].pts;
				position_vector[cf - 1].pts = next.concat();
				p4.result = position_vector[cf - 1];
			}else {
				// error
				trace("error");
			}
		}
		
		private function onShowClick(e:MouseEvent):void 
		{
			if (showButton.selected) {
				showButton.label = "Show Point4";
				point4_container.visible = true;
			}else {
				showButton.label = "Hide Point4";
				point4_container.visible = false;
			}
		}
		
		private function onMusicClick(e:MouseEvent ):void 
		{
			var st:SoundTransform = SoundMixer.soundTransform;
			if (st.volume > 0) {
				musicButton.label = "Music OFF";
			}else {
				musicButton.label = "Music ON";
			}
			SoundMixer.soundTransform = new SoundTransform(1 - st.volume);
		}
		
		private function onPlayClick(e:MouseEvent ):void 
		{
			// isPlaying - player 11
			if (currentMovie.isPlaying) {
				playButton.label = "Play";
				currentMovie.stop();
				currentMovie.removeEventListener(Event.ENTER_FRAME, onMovieFrame);
			}else {
				playButton.label = "Stop";
				currentMovie.play();
				currentMovie.addEventListener(Event.ENTER_FRAME, onMovieFrame);
			}
		}
		
		private function onPrevClick(e:MouseEvent ):void 
		{
			jumpToFrame("prev");
		}
		
		private function onNextClick(e:MouseEvent ):void 
		{
			jumpToFrame("next");
		}
		
		private function onJumpClick(e:MouseEvent ):void 
		{
			var toFrame:uint = int(frameText.text);
			jumpToFrame("jump", toFrame);
		}
		
		private function jumpToFrame(action:String, frame:uint = 0):void
		{
			if (action == "prev") {
				frame = currentMovie.currentFrame - 1;
			}else if (action == "next") {
				frame = currentMovie.currentFrame + 1;
			}
			
			currentMovie.stop();
			currentMovie.addFrameScript(frame - 1, function():void {
				currentMovie.addFrameScript(currentMovie.currentFrame - 1, null);
				checkFrame();
			} );
			currentMovie.gotoAndStop(frame);
			
			frameSlider.value = currentMovie.currentFrame;
			playButton.label = "Play";
			playButton.selected = false;
		}
	}
}