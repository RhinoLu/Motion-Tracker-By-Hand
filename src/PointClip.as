package
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class PointClip extends Sprite
	{
		public function PointClip(parent:DisplayObjectContainer, xpos:Number = 0, ypos:Number = 0)
		{
			x = xpos;
			y = ypos;
			parent.addChild(this);
			stage ? init() : addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			
			drawCross();
			
			addEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}
		
		private function onRemove(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}
		
		private function drawCross():void
		{
			var g:Graphics = graphics;
			
			g.beginFill(0xFFFF00, 0.5);
			g.drawCircle(0, 0, 5);
			g.endFill();
			
			g.lineStyle(1, 0xFF0000, 1);
			g.moveTo(-5, 0);
			g.lineTo(5, 0);
			g.moveTo(0, -5);
			g.lineTo(0, 5);
		}
		
		private function onDown(e:MouseEvent):void
		{
			startDrag();
			stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
			dispatchEvent(new Event("ON_DOWN", true));
		}
		
		private function onUp(e:MouseEvent):void
		{
			stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			dispatchEvent(new Event("ON_UP", true));
		}
	}
}

