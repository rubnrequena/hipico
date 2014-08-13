package UI.shared
{
	import appkit.responders.NResponder;
	
	import core.Vista;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	
	import spark.components.Button;
	import spark.components.Label;
	
	import vistas.Modal;
	import vistas.ModalSkin;

	public class ModalYesNo extends ModalSkin
	{		
		public function ModalYesNo(text:String,closeEvent:Function)
		{
			super();
			view.width = 300;
			view.height = 80;
			
			var lbl:Label = new Label;
			lbl.text = text;
			lbl.width = 300;
			lbl.height = 50;
			lbl.setStyle("paddingTop",5);
			lbl.setStyle("paddingLeft",5);
			lbl.setStyle("paddingRight",5);
			lbl.setStyle("paddingBottom",5);
			lbl.maxDisplayedLines = 3;
			view.addElement(lbl);
			btn.visible=false;
			var btns:Button;
			btns = new Button;
			btns.label = "Si";
			btns.width = (view.width * 0.6) - 6;
			btns.height = 27;
			btns.x = 3;
			btns.y = 50;
			view.addElement(btns);
			
			btns = new Button;
			btns.label = "No";
			btns.width = (view.width * 0.4) - 3;
			btns.height = 27;
			btns.x = (view.width * 0.6);
			btns.y = 50;
			btns.setStyle("chromeColor",CANCEL_COLOR_BUTTON);
			view.addElement(btns);
			
			addCloseEvent(closeEvent,1);
			addEventListener(MouseEvent.CLICK,onClick);
		}
		
		private function onClick(e:MouseEvent):void {
			if (e.target is Button) {
				if (e.target.label=="Si") {
					closeModal(Alert.YES);
				} else {
					closeModal(Alert.NO);	
				}
				removeEventListener(MouseEvent.CLICK,onClick);
			}
		}
		
		static public function show(text:String,view:Vista,closeEvent:Function):void {
			var m:ModalYesNo = new ModalYesNo(text,closeEvent);
			view.modalPopUp(m);
		}
	}
}