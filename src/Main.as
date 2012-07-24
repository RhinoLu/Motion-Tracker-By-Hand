package 
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.HUISlider;
	import com.bit101.components.InputText;
	import com.bit101.components.PushButton;
	import com.bit101.components.RadioButton;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.data.SWFLoaderVars;
	import com.greensock.loading.SWFLoader;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	// TODO 複製前一 frame position
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
		
		private var finalRadio:RadioButton; // -------- 挖洞影片
		private var colorRadio:RadioButton; // -------- 有色版影片
		
		private var playButton:PushButton; // --------- 播放/停止
		private var prevButton:PushButton; // --------- 上一格
		private var nextButton:PushButton; // --------- 下一格
		private var jumpButton:PushButton; // --------- 跳至某 frame
		private var frameText:InputText; // ----------- 目標 frame
		
		private var frameSlider:MyHUISlider; // ------- 目前 frmae
		
		private var movie_container:Sprite; // -------- 影片容器
		private var movie:MovieClip; // --------------- 影片
		
		private var p4:Point4;
		private var point4_container:Sprite; // ------- 四點對位容器
		
		private var position_vector:Vector.<Object>;
		
		private var focusClip:PointClip;
		
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
			
			exportButton = new PushButton(this, 10, 10, "Export", onExportClick);
			exportButton.enabled = false;
			importButton = new PushButton(this, 10, 35, "Import", onImportClick);
			//importButton.enabled = false;
			
			numberText = new InputText(this , 200, 10, "Number");
			numberText.restrict = "0-9";
			startText = new InputText(this , 200, 30, "Start at");
			startText.restrict = "0-9";
			endText = new InputText(this , 200, 50, "End at");
			endText.restrict = "0-9";
			addButton = new PushButton(this, 200, 70, "Add" , onAddClick);
			
			finalRadio = new RadioButton(this, 400, 10, "final",  true, onRadioClick);
			colorRadio = new RadioButton(this, 400, 25, "color", false, onRadioClick);
			
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
			
			clipXText = new InputText(this , 565, 10);
			clipXText.restrict = "0-9 . \\-";
			clipXText.enabled = false;
			clipYText = new InputText(this , 565, 30);
			clipYText.restrict = "0-9 . \\-";
			clipYText.enabled = false;
			updateButton = new PushButton(this, 565, 50, "Update", onUpdateClick);
			updateButton.enabled = false;
			
			movie_container = new Sprite();
			movie_container.x = 0;
			movie_container.y = 100;
			addChild(movie_container);
			
			var swfLoader:SWFLoader = new SWFLoader("movie.swf", new SWFLoaderVars().container(movie_container).onComplete(onSWFLoadComplete).vars);
			swfLoader.load();
			
			point4_container = new Sprite();
			point4_container.x = movie_container.x;
			point4_container.y = movie_container.y;
			addChild(point4_container);
		}
		
		private function initPositionVector():void 
		{
			position_vector = new Vector.<Object>;
			for (var i:int = 0; i < movie.totalFrames; i++) 
			{
				position_vector[i] = null;
			}
		}
		
		private function checkFrame():void
		{
			//trace("checkFrame : " + movie.currentFrame);
			if (!position_vector || !p4) return;
			if (position_vector[movie.currentFrame-1]) {
				p4.result = position_vector[movie.currentFrame-1];
				p4.visible = true;
			}else {
				p4.visible = false;
			}
		}
		
		private function onFrameSliderDrag(e:Event):void 
		{
			movie.stop();
			movie.removeEventListener(Event.ENTER_FRAME, onMovieFrame);
		}
		
		private function onFrameSliderDrop(e:Event):void 
		{
			movie.gotoAndStop(Math.round(frameSlider.value));
		}
		
		private function onFrameSliderChange(e:Event):void 
		{
			movie.gotoAndStop(Math.round(frameSlider.value));
			checkFrame();
		}
		
		private function onSWFLoadComplete(e:LoaderEvent):void 
		{
			var swfLoader:SWFLoader = e.target as SWFLoader;
			var _class:Class = swfLoader.getClass("MovieMC") as Class;
			movie = new _class();
			movie.stop();
			movie_container.addChild(movie);
			frameSlider.maximum = movie.totalFrames
			initPositionVector();
		}
		
		private function onMovieFrame(e:Event):void 
		{
			frameSlider.value = movie.currentFrame;
			checkFrame();
			/*trace("onMovieFrame : " + movie.currentFrame);
			if (movie.currentFrame == movie.totalFrames) {
				movie.removeEventListener(Event.ENTER_FRAME, onMovieFrame);
				movie.stop();
				playButton.label = "Play";
				playButton.selected = false;
			}*/
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
        }
		
		private function onAddClick(e:MouseEvent ):void 
		{
			var num:uint   = int(numberText.text);
			var start:uint = int(startText.text);
			var end:uint   = int(endText.text);
			if (end > movie.totalFrames - 1) {
				end = movie.totalFrames - 1;
				endText.text = String(end);
			}
			numberText.text = String(num);
			startText.text  = String(start);
			endText.text    = String(end);
			//trace(num, start, end);
			addPoint4(num, start, end, false);
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
					
					movie.addFrameScript(start, function():void {
						movie.addFrameScript(movie.currentFrame-1, null);
						checkFrame();
					} );
					movie.gotoAndStop(start + 1);
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
				position_vector[movie.currentFrame-1] = p4.result;
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
				}
			}else {
				focusClip = null;
				clipXText.enabled = clipYText.enabled = updateButton.enabled = false;
				clipXText.text = "";
				clipYText.text = "";
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
				position_vector[movie.currentFrame-1] = p4.result;
			}
		}
		
		private function onRadioClick(e:MouseEvent ):void 
		{
			
			var radio:RadioButton = e.target as RadioButton;
			trace(radio);
			
		}
		
		private function onShowClick(e:MouseEvent ):void 
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
			if (movie.isPlaying) {
				playButton.label = "Play";
				movie.stop();
				movie.removeEventListener(Event.ENTER_FRAME, onMovieFrame);
			}else {
				playButton.label = "Stop";
				//if (movie.currentFrame == movie.totalFrames) {
					//movie.gotoAndPlay(2); // 因為第 1 格有下 stop();
				//}else {
					movie.play();
				//}
				movie.addEventListener(Event.ENTER_FRAME, onMovieFrame);
			}
		}
		
		private function onPrevClick(e:MouseEvent ):void 
		{
			movie.stop();
			movie.addFrameScript(movie.currentFrame-2, function():void {
				movie.addFrameScript(movie.currentFrame-1, null);
				//trace("prev complete");
				checkFrame();
			} );
			movie.prevFrame();
			
			frameSlider.value = movie.currentFrame;
			playButton.label = "Play";
			playButton.selected = false;
		}
		
		private function onNextClick(e:MouseEvent ):void 
		{
			movie.stop();
			movie.addFrameScript(movie.currentFrame, function():void {
				movie.addFrameScript(movie.currentFrame-1, null);
				//trace("next complete");
				checkFrame();
			} );
			movie.nextFrame();
			
			frameSlider.value = movie.currentFrame;
			playButton.label = "Play";
			playButton.selected = false;
		}
		
		private function onJumpClick(e:MouseEvent ):void 
		{
			var toFrame:uint = int(frameText.text);
			movie.stop();
			movie.addFrameScript(toFrame-1, function():void {
				movie.addFrameScript(movie.currentFrame-1, null);
				//trace("jump complete");
				checkFrame();
			} );
			movie.gotoAndStop(toFrame);
			frameSlider.value = movie.currentFrame;
			playButton.label = "Play";
			playButton.selected = false;
		}
	}
}