package Ventanas.Reporte
{
	import spark.components.Label;
	
	public class negativeRedColorLabel extends Label
	{
		private var val:Number;
		public function negativeRedColorLabel()
		{
			super();
		}
		
		override public function set text(value:String):void {
			super.text = value;
			val = Number(value.split(",").join(""));
			if (val) {
				if (val>0) {
					setStyle("color",0x000000);
				} else {
					setStyle("color",0xFF0000);
				}
			}
		}
	}
}