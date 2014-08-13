package UI.Main
{
	import UI.shared.ModalSkin;
	
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.events.CloseEvent;
	
	public class CargarCarrerasModal extends ModalSkin
	{
		private var carreras:Carreras;
		public function CargarCarrerasModal(width:int=0, height:int=0)
		{
			super(width, height);
			
			carreras = new Carreras;
			view.addElement(carreras);
			carreras.addEventListener(CloseEvent.CLOSE,onClose);
		}
		
		protected function onClose(event:CloseEvent):void {
			closeModal();
		}
		
		override protected function keyUpHandler(event:KeyboardEvent):void
		{
			if (event.keyCode==Keyboard.ESCAPE) {
				closeModal();
			}
		}
		
		
	}
}