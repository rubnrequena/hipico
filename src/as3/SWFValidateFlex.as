package as3
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.Panel;
	import spark.components.SkinnableContainer;
	import spark.components.TextInput;
	import spark.layouts.VerticalLayout;

	public class SWFValidateFlex extends SWFValidate
	{

		private var b:Button;

		private var t:TextInput;

		private var panel:Panel;
		private var _lbl:Label;
		public function SWFValidateFlex() {
			super();
			addEventListener("licenciaInvalida",insertarLicencia);
			addEventListener("licenciaInsertada",licenciaCreada);
			addEventListener("licenciaExpirada",licenciaExpiro);
			addEventListener("licenciaUpdate",updateLicencia);
			
			var rect:SkinnableContainer = new SkinnableContainer;
			rect.styleName = "cont-licencia";
			rect.width = 350;
			rect.height = 30;
			rect.bottom = 0;
			rect.horizontalCenter = 0;
			
			_lbl = new Label;
			_lbl.styleName = "label-licencia";
			_lbl.horizontalCenter = _lbl.verticalCenter = 0;
			rect.addElement(_lbl);
			
			FlexGlobals.topLevelApplication.addElement(rect);
		}
		
		protected function updateLicencia(event:Event):void {
			var d:Date = timeAvailableDate;
			var dias:int = Math.floor(timeAvailable/86400000);
			_lbl.text = "Tiempo Restante: "+dias+" dias, "+[d.hours,d.minutes].join(":");
		}
		
		protected function licenciaExpiro(event:Event):void {
			GUIKey("Licencia Expiró");
		}
		
		protected function licenciaCreada(event:Event):void {
			validate();
		}
		
		protected function insertarLicencia(event:Event):void {
			GUIKey();
		}
		
		public function GUIKey (titulo:String="Licencia"):void {
			panel = new Panel;
			panel.width = 200;
			panel.height = 100;
			panel.layout = new VerticalLayout;
			panel.title = titulo;
						
			t = new TextInput;
			t.height = 30;
			t.percentWidth = 100;
			t.styleName = "input-licencia";
			panel.addElement(t);
			
			b = new Button;
			b.styleName = "btn-licencia";
			b.label = "Confirmar";
			b.height = 30;
			b.percentWidth = 100;
			b.addEventListener(MouseEvent.CLICK,onClick);
			panel.addElement(b);
			
			PopUpManager.addPopUp(panel,FlexGlobals.topLevelApplication as DisplayObject,true);
			PopUpManager.centerPopUp(panel);
		}
		
		protected function onClick(event:MouseEvent):void {
			b.removeEventListener(MouseEvent.CLICK,onClick);
			PopUpManager.removePopUp(panel);
			create(t.text);
			panel=null;
		}
	}
}