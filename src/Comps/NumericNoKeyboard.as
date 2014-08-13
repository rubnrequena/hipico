package Comps
{
	import flash.events.KeyboardEvent;
	
	import spark.components.NumericStepper;
	
	public class NumericNoKeyboard extends NumericStepper
	{
		public function NumericNoKeyboard()
		{
			super();
		}
		override protected function keyDownHandler(event:KeyboardEvent):void {
			
		}
	}
}