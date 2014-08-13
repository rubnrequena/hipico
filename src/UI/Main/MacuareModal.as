package UI.Main
{
	import UI.shared.ModalSkin;
	
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.controls.Alert;
	import mx.events.FlexEvent;
	
	public class MacuareModal extends ModalSkin
	{
		private var mac:MacuareView;
		public function MacuareModal(closeEvent:Function)
		{
			super(width, height);
			
			mac = new MacuareView;
			mac.addEventListener(FlexEvent.CREATION_COMPLETE,onComplete,false,0,true);
			view.addElement(mac);
			
			addCloseEvent(closeEvent);
		}
		
		protected function onComplete(event:FlexEvent):void {
			mac.removeEventListener(FlexEvent.CREATION_COMPLETE,onComplete);
			mac.btnAtras.addEventListener(MouseEvent.CLICK,atrasClick);
			mac.btnAtras.setStyle("chromeColor",CANCEL_COLOR_BUTTON);
			
			mac.menu.addEventListener(MouseEvent.CLICK,menuClick);
		}
		
		protected function menuClick(event:MouseEvent):void {
			if (event.target.name!="nuevo") {
				closeModal(Alert.YES,event.target.name);
			} else {
				mac.currentState = "agregar";
			}
		}
		
		protected function atrasClick(event:MouseEvent):void {
			closeModal(Alert.NO);
		}
		
		override protected function keyUpHandler(event:KeyboardEvent):void {
			if (event.keyCode==Keyboard.ESCAPE) closeModal(Alert.NO);
		}
		
	}
}