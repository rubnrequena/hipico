package UI.Main.taquillas
{
	import UI.shared.ModalOK;
	
	import VOs.VOTaquilla;
	
	import events.CloseEvent;
	
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.controls.DateField;
	
	import spark.components.Button;

	public class TaquillasView extends TaquillasViewUI
	{
		public function TaquillasView() {
			super();
		}
		override protected function createChildren():void {
			super.createChildren();
			header.data = headerData;
			updateList();
			buttons([
				{label:"Insertar",name:"insertar"},
				{label:"Modificar",name:"modificar"},
				{label:"Activar/Desactivar",name:"desactivar"},
				{label:"Cancelar",name:"cancelar"}
			]);
			addEventListener(MouseEvent.CLICK,onClick);
		}
		
		private function updateList():void {
			var i:int;
			var c:Array = new Array(Global.banca.taquillas.numTaquillas);
			for (i = 0; i < Global.banca.taquillas.numTaquillas; i++) {
				c[i]=Global.banca.taquillas.taquillas[i];
			}
			lista.dataProvider = new ArrayList(c);
		}
		protected function onClick(event:MouseEvent):void {
			switch(event.target.name) {
				case "insertar": { 
					insertarTaquilla(); break;
				}
				case "modificar": { 
					modificarTaquilla(); break;
				}
				case "desactivar": { 
					activar_desactivarTaquilla(); break;
				}
				case "cancelar": { 
					popBack(); break;
				}
			}
		}
		
		private function activar_desactivarTaquilla():void {
			if (lista.selectedIndex>-1) {
				var taq:VOTaquilla = lista.selectedItem;
				taq.update("activa",!taq.activa);
				lista.dataProvider.itemUpdated(lista.selectedItem);
			}
		}
		
		private function modificarTaquilla():void {
			var modificar:TaquillasInsertar = new TaquillasInsertar(lista.selectedItem);
			modificar.addCloseEvent(modificar_close);
			vista.modalPopUp(modificar);
		}
		
		private function modificar_close(e:CloseEvent):void {
			if (e.detalle==Alert.YES) {
				Global.banca.taquillas.modificar(e.data);
				updateList();
				lista.dataProvider.itemUpdated(lista.selectedItem);
			}
		}
		
		private function insertarTaquilla():void {
			var insertar:TaquillasInsertar = new TaquillasInsertar;
			insertar.addCloseEvent(insertar_close);
			vista.modalPopUp(insertar);
		}
		
		private function insertar_close(e:CloseEvent):void {
			if (e.detalle==Alert.YES) {
				Global.banca.taquillas.insertar(e.data);
				lista.dataProvider.addItem(e.data);
				
				var fs:FileStream = new FileStream;
				var f:File = File.applicationStorageDirectory.resolvePath("registroActivacion.txt");
				fs.open(f,FileMode.APPEND);
				fs.writeMultiByte(JSON.stringify([DateField.dateToString(new Date,"YY-MM-DD"),e.data],null,2),File.systemCharset);
				fs.close();
				ModalOK.show("USUARIO REGISTRADO CON EXITO",vista);
			}
		}
		protected function buttons (elements:Array):void {
			var b:Button; var i:int; var len:int = elements.length; var p:String;
			for (i = 0; i < len; i++) {
				b = new Button;
				b.height = 30;
				for (p in elements[i]) {
					b[p] = elements[i][p];
				}
				buttonBar.addElement(b);
			}
		}
	}
}