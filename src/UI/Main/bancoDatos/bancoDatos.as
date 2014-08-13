package UI.Main.bancoDatos
{
	import UI.Main.MainView;
	
	import appkit.responders.NResponder;
	
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.SharedObject;
	
	import mx.collections.ArrayList;
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.Label;
	
	import tools.AutoClose;

	public class bancoDatos extends bancoDatosUI {
		private var so:SharedObject;
		public function bancoDatos() {
			super();
			NResponder.addNative(this,FlexEvent.CREATION_COMPLETE,onCreationComplete,1);
		}
		
		private function onCreationComplete(e:FlexEvent):void {
			so = SharedObject.getLocal("Hipico");
			var carpetaBD:File = new File(so.data.carpetaBD);
			if (!carpetaBD.exists) return;
			bancoDatos_list.dataProvider = new ArrayList(carpetaBD.getDirectoryListing().filter(filtrarBD));
			
			NResponder.addNative(bancoDatos_list,MouseEvent.CLICK,list_onClick);
		}
		
		private function filtrarBD(item:File,index:int,data:*):Boolean {
			switch(item.name) {
				case "BDBanca.db":
				case "BDGanador.db":
				case "BDRemate.db":
				case "BDTabla.db":
				case "BDMacuare.db": {
					return true;
					break;
				}
					
				default: {
					return false;
					break;
				}
			}
		}
		
		private function list_onClick(e:MouseEvent):void {
			if (e.target.id=="item") {
				currentState="ask";
				NResponder.addNative(askGroup,MouseEvent.CLICK,askGroup_click);
			}
		}
		
		private function askGroup_click(e:MouseEvent):void {
			if (e.target is Button) {
				if (e.target.name=="confirmar") {
					Global.closeBD(bancoDatos_list.selectedItem.name);
					var f:File = new File(so.data.carpetaBD).resolvePath(bancoDatos_list.selectedItem.name);
					if (f.exists) f.deleteFile();
				}
				currentState="reiniciar";
				NResponder.remove(MouseEvent.CLICK,askGroup_click,askGroup);
				NResponder.addNative(btnOK,MouseEvent.CLICK,btnOK_click,1);
			}
		}
		
		private function btnOK_click(e:MouseEvent):void {
			var app:File = File.applicationDirectory.resolvePath("Hipico.exe");
			var ac:AutoClose = new AutoClose(app);
			ac.close();
		}
	}
}