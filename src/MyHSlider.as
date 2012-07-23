package  
{
	import com.bit101.components.Slider;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.osflash.signals.Signal;
	
	public class MyHSlider extends Slider 
	{
		//private var _signal:Signal;
		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this HSlider.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 * @param defaultHandler The event handling function to handle the default event for this component.
		 */
		public function MyHSlider(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, defaultHandler:Function = null)
		{
			super(Slider.HORIZONTAL, parent, xpos, ypos, defaultHandler);
			//_signal = new Signal();
		}
		
		override protected function onDrag(event:MouseEvent):void 
		{
			super.onDrag(event);
			//trace("onDrag!");
			//_signal.dispatch("ON_DRAG");
			dispatchEvent(new Event("ON_DRAG", true));
		}
		
		override protected function onDrop(event:MouseEvent):void 
		{
			super.onDrop(event);
			//trace("onDrop!");
			//_signal.dispatch("ON_DROP");
			dispatchEvent(new Event("ON_DROP", true));
		}
	}

}