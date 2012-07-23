package  
{
	import com.bit101.components.UISlider;
	import flash.display.DisplayObjectContainer;
	
	public class MyHUISlider extends UISlider 
	{
		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this HUISlider.
		 * @param x The x position to place this component.
		 * @param y The y position to place this component.
		 * @param label The string to use as the label for this component.
		 * @param defaultHandler The event handling function to handle the default event for this component.
		 */
		public function MyHUISlider(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, label:String = "", defaultHandler:Function = null)
		{
			_sliderClass = MyHSlider;
			super(parent, xpos, ypos, label, defaultHandler);
		}
		
		/**
		 * Initializes the component.
		 */
		override protected function init():void
		{
			super.init();
			setSize(200, 18);
		}
		
		/**
		 * Centers the label when label text is changed.
		 */
		override protected function positionLabel():void
		{
			_valueLabel.x = _slider.x + _slider.width + 5;
		}
		
		
		
		
		///////////////////////////////////
		// public methods
		///////////////////////////////////
		
		/**
		 * Draws the visual ui of this component.
		 */
		override public function draw():void
		{
			super.draw();
			_slider.x = _label.width + 5;
			_slider.y = height / 2 - _slider.height / 2;
			_slider.width = width - _label.width - 50 - 10;
			
			_valueLabel.x = _slider.x + _slider.width + 5;
		}
		
		///////////////////////////////////
		// event handlers
		///////////////////////////////////
		
		///////////////////////////////////
		// getter/setters
		///////////////////////////////////
		
	}
}