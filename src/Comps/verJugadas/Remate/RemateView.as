package Comps.verJugadas.Remate
{
	import events.Evento;
	
	import libVOs.infoCarrera;
	
	import mx.events.FlexEvent;
	
	import spark.components.Window;
	
	public class RemateView extends Window
	{
		public var carrera:infoCarrera;
		private var r:Remate;
		public function RemateView() {
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE,onComplete);
			width=900;
			height=500;
			showStatusBar=false;
		}
		
		protected function onComplete(event:FlexEvent):void
		{
			r = new Remate;
			r.carrera = carrera;
			r.addEventListener("titleChange",titleChange,false,0,true);
			addElement(r);
		}
		
		protected function titleChange(event:Evento):void {
			title = event.data;
		}
	}
}