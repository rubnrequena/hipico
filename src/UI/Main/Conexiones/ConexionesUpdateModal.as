package UI.Main.Conexiones
{
	import UI.shared.ModalSkin;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.TextInput;
	
	public class ConexionesUpdateModal extends ModalSkin
	{

		private var h:HGroup;

		private var btnCerrar:Button;

		private var btnConfirmar:Button;
		public function ConexionesUpdateModal(width:int=0, height:int=0)
		{
			super(width, height);
			
			h = new HGroup;
			view.addElement(h);
			
			var txt:TextInput;
			txt = new TextInput;
			txt.width = 40;
			txt.maxChars = 2;
			h.addElement(txt);
			
			txt = new TextInput;
			txt.width = 40;
			txt.maxChars = 2;
			h.addElement(txt);
			
			txt = new TextInput;
			txt.width = 50;
			txt.maxChars = 3;
			h.addElement(txt);
			
			
			btnConfirmar = new Button();
			btnConfirmar.label = 'Confirmar';
			view.addElement(btnConfirmar);
			
			btnCerrar = new Button();
			btnCerrar.label = '';
			view.addElement(btnCerrar);
			
			addEventListener(Event.ADDED_TO_STAGE,onAdded,false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE,onRemoved,false,0,true);
		}
		
		protected function onRemoved(event:Event):void {
			btnConfirmar.addEventListener(MouseEvent.CLICK,confirmarClick);
		}
		
		protected function confirmarClick(event:MouseEvent):void {
			
		}
		
		protected function onAdded(event:Event):void {
			
		}
	}
}