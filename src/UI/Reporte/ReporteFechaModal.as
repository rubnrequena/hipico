package UI.Reporte
{
	import UI.myDate;
	import UI.shared.ModalSkin;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.core.IVisualElement;
	
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.DropDownList;
	import spark.components.Form;
	import spark.components.FormItem;
	import spark.components.HGroup;
	import spark.layouts.VerticalLayout;
	
	public class ReporteFechaModal extends ModalSkin
	{
		public var desde:myDate;
		public var hasta:myDate;
		public var hipo:DropDownList;
		public var chk_taquillas:CheckBox;

		private var f:Form;

		private var btnConfirmar:Button;

		private var btnCerrar:Button;
		public function ReporteFechaModal()
		{
			super(300);
			view.layout = new VerticalLayout;
			desde = new myDate;
			desde.selectedDate = new Date;
			hasta = new myDate;
			hasta.selectedDate = new Date;
			
			addTitle("Buscar reporte de:");
			
			f = new Form;
			view.addElement(f);
			
			addField(desde,"Fecha Inicio:");
			addField(hasta,"Fecha Final:");
			
			hipo = new DropDownList;
			hipo.labelField = "Hipodromo";
			hipo.dataProvider = new ArrayList(Global.banca.hipodromos.datos);
			
			addField(hipo,"Hipodromos:");
			
			chk_taquillas = new CheckBox;
			addField(chk_taquillas,"Taquillas:");
			
			var h:HGroup = new HGroup;		
			view.addElement(h);
			
			btnConfirmar = new Button();
			btnConfirmar.label = 'Confirmar';
			btnConfirmar.height = 30;
			btnConfirmar.width = view.width * 0.6 - 3;
			h.addElement(btnConfirmar);
			
			btnCerrar = new Button();
			btnCerrar.label = 'Cerrar';
			btnCerrar.height = 30;
			btnCerrar.width = view.width * 0.4 - 3;
			btnCerrar.setStyle("chromeColor",CANCEL_COLOR_BUTTON);
			h.addElement(btnCerrar);
			
			addEventListener(Event.ADDED_TO_STAGE,onAdded);
		}
		
		protected function onAdded(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE,onAdded);
			btnConfirmar.addEventListener(MouseEvent.CLICK,confirmarClick);
			btnCerrar.addEventListener(MouseEvent.CLICK,cerrarClick);
			addEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
		}
		
		protected function onRemoved(event:Event):void {
			btnConfirmar.removeEventListener(MouseEvent.CLICK,confirmarClick);
			btnCerrar.removeEventListener(MouseEvent.CLICK,cerrarClick);
			removeEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
			addEventListener(Event.ADDED_TO_STAGE,onAdded);
		}
		
		protected function cerrarClick(event:MouseEvent):void {
			closeModal(Alert.NO);
		}
		
		protected function confirmarClick(event:MouseEvent):void {
			closeModal(Alert.YES);
		}
		
		override protected function keyUpHandler(event:KeyboardEvent):void {
			super.keyUpHandler(event);
		}
		
		
		protected function addField(e:IVisualElement,label:String):void {
			var fi:FormItem = new FormItem;
			f.addElement(fi);
			fi.height = 25;
			fi.label = label;
			
			fi.addElement(e);
		}
	}
}