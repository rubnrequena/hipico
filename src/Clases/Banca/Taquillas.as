package Clases.Banca
{
	import Clases.MD5;
	import Clases.network.HipicoActividad;
	import Clases.network.netManager;
	
	import VOs.VOTaquilla;

	public class Taquillas
	{
		private var _taquillas:Vector.<VOTaquilla>;
		public function get taquillas():Vector.<VOTaquilla> {
			return _taquillas;
		}

		private var _numTaquillas:int;
		public function get numTaquillas():int {
			return _numTaquillas;
		}

		public function Taquillas() {
			var data:Array = Global.banca.sql('SELECT * FROM Taquillas',VOTaquilla).data;
			_numTaquillas = data?data.length:0;
			var i:int; _taquillas = new Vector.<VOTaquilla>(_numTaquillas);
			for (i = 0; i < _numTaquillas; i++) {
				_taquillas[i] = data[i];
			}
		}
		
		public function insertar (taquilla:VOTaquilla):void {
			var o:Object = taquilla.toObject;
			Global.banca.insertar("Taquillas",o);
			_taquillas.push(taquilla);
			_numTaquillas++;
			
			if (!Global.isAdmin) {
				netManager.ACTIVIDAD.send(
					taquilla.taquillaID,
					taquilla.tipo,
					taquilla.bancaString,
					HipicoActividad.TAQ_REGISTRO,
					taquilla.nombre
				);				
			}
		}
		public function modificar (taquilla:VOTaquilla):void {
			var upd:Array = [];
			var b:Boolean=false;
			var oldValue:int = getIndex(taquilla.taquillaID);
			if (taquilla.nombre!=_taquillas[oldValue].nombre) upd.push('nombre = "'+taquilla.nombre+'"');
			if (taquilla.banca!=_taquillas[oldValue].banca) {
				upd.push('banca = '+taquilla.banca); b = true;
			}
			if (taquilla.tipo!=_taquillas[oldValue].tipo) upd.push('tipo = '+taquilla.tipo);
			if (taquilla.contrasena!=_taquillas[oldValue].contrasena) upd.push('contrasena = "'+taquilla.contrasena+'"');
			if (taquilla.activa!=_taquillas[oldValue].activa) upd.push('activa = '+taquilla.activa);
			if (upd.length>0) {
				Global.banca.sql('UPDATE Taquillas SET '+upd.join(', ')+' WHERE taquillaID = "'+taquilla.taquillaID+'"');
				_taquillas[oldValue] = taquilla;
			}
			
			if (b && !Global.isAdmin) {
				netManager.ACTIVIDAD.send(
					taquilla.taquillaID,
					taquilla.tipo,
					taquilla.bancaString,
					HipicoActividad.TAQ_CAMBIO_BANCA,
					taquilla.nombre
				);				
			}
		}
		public function buscar (pass:String):VOTaquilla {
			var i:int;
			pass = MD5.hash(pass);
			for (i = 0; i < _numTaquillas; i++) {
				if (_taquillas[i].contrasena==pass) { return _taquillas[i]; }
			}
			return null;
		}
		public function getTaquilla (taquillaID:String):VOTaquilla {
			var i:int;
			for (i = 0; i < _numTaquillas; i++) {
				if (_taquillas[i].taquillaID==taquillaID) return _taquillas[i];
			}
			return null;
		}
		public function getIndex (taquillaID:String):int {
			var i:int;
			for (i = 0; i < _numTaquillas; i++) {
				if (_taquillas[i].taquillaID==taquillaID) return i;
			}
			return -1;
		}
	}
}