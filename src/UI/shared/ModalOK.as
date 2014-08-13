package UI.shared
{
	import appkit.responders.NResponder;
	
	import core.Vista;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import spark.components.Button;
	import spark.components.Label;
	
	import vistas.Modal;

	public class ModalOK extends ModalSkin
	{
		public function ModalOK(text:String,closeEvent:Function)
		{
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
			
			var btn:Button;
			btn = new Button;
			btn.label = "Confirmar";
			btn.width = view.width - 6;
			btn.height = 27;
			btn.x = 3;
			btn.y = 50;
			view.addElement(btn);
			
			if (closeEvent!=null) NResponder.add(Modal.onModalClose,closeEvent,1,0,0,this);
			NResponder.addNative(this,Event.ADDED_TO_STAGE,onAdded,1);
		}
		
		private function onAdded(e:Event):void {
			NResponder.addNative(this,MouseEvent.CLICK,onClick);
			NResponder.addNative(this,Event.REMOVED_FROM_STAGE,onRemoved,1);
		}
		
		private function onRemoved(e:Event):void {
			NResponder.remove(MouseEvent.CLICK,onClick,this);
			NResponder.addNative(this,Event.ADDED_TO_STAGE,onAdded,1);
		}
		
		protected function onClick(e:MouseEvent):void {
			closeModal();
		}
		
		static public function show(text:String,view:Vista,closeEvent:Function=null):void {
			var m:ModalOK = new ModalOK(text,closeEvent);
			view.modalPopUp(m);
		}
	}
}