package UI.Main.taquillas
{
	import Clases.MD5;
	
	import VOs.VOTaquilla;
	
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.events.CloseEvent;

	public class TaquillasInsertar extends TaquillaInsertarUI
	{
		
		
		public function TaquillasInsertar(taquilla:VOTaquilla=null) {
			super();
			_taquilla = taquilla;
		}		
		override protected function createChildren():void {
			super.createChildren();
			banca.dataProvider = new ArrayList(Global.banca.bancas.bancas);
			banca.labelField = "Nombre";
			banca.requireSelection = true;
			
			tipo.dataProvider = new ArrayList(VOTaquilla.TIPOS);
			tipo.requireSelection = true;
			
			if (_taquilla) {
				taquillaID.text = _taquilla.taquillaID;
				nombre.text = _taquilla.nombre;
				var i:int;
				for (i = 0; i < banca.dataProvider.length; i++) {
					if (banca.dataProvider.getItemAt(i).ID==_taquilla.banca) banca.selectedIndex=i;
				}
				tipo.selectedIndex=_taquilla.tipo;
			} else {
				taquillaID.text = hex;
			}
			addEventListener(MouseEvent.CLICK,onClick);
		}
		protected function onClick(event:MouseEvent):void {
			switch(event.target.name) {
				case "cancelar": {
					closeModal();
					break;
				}
				case "confirmar": {
					closeModal(1);
					break;
				}
			}
		}		
		override public function closeModal(detalle:int=-1, data:*=null):void {
			if (detalle==1) {
				data = new VOTaquilla;
				data.taquillaID = taquillaID.text;
				data.nombre = nombre.text.toUpperCase();
				data.banca = banca.selectedItem.ID;
				data.contrasena = pass.text!=""?MD5.hash(pass.text.toLowerCase()):_taquilla.contrasena;
				data.activa = activa.selected;
				data.tipo = tipo.selectedIndex;
				if (pass.text.length>0) {
					var i:int;
					for (i = 0; i < Global.banca.taquillas.numTaquillas; i++) {
						if (Global.banca.taquillas.taquillas[i].contrasena==data.contrasena) {
							Alert.show("Contraseña ya existe por favor inserte una diferente","Error",4,null,function (e:CloseEvent):void {
								pass.setFocus();
							});
							return;
						}
					}
				}
			}
			removeEventListener(MouseEvent.CLICK,onClick);
			super.closeModal(detalle,data);
		}		
		private var _hex:String = "0123456789abcdef";
		private var _taquilla:VOTaquilla;
		private function get hex():String {
			var hex:String=""; var i:int;
			for (i = 0; i < 6; i++) {
				hex += _hex.charAt(int(Math.random()*15));
			}
			return hex;
		}
	}
}