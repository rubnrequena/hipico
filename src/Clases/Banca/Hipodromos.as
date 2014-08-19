package Clases.Banca
{
	import mx.utils.StringUtil;

	public class Hipodromos
	{
		public static const HIPODROMOS:String = "Hipodromos";
		
		public function Hipodromos() {
			_hipodromos = Global.banca.sql('SELECT * FROM '+HIPODROMOS,VOHipodromo).data;
		}
		
		private var _hipodromos:Array;
		public function get datos():Array { return _hipodromos; }
		
		public function insertar (hipodromo:String,ganador:int):void {
			hipodromo = StringUtil.trim(hipodromo.toUpperCase());
			Global.banca.insertar(HIPODROMOS,{Hipodromo:hipodromo,Ganador:ganador});
			_hipodromos = Global.banca.sql('SELECT * FROM '+HIPODROMOS,VOHipodromo).data;
		}
		public function remover (hipodromo:String):void {
			Global.banca.eliminar(HIPODROMOS,{Hipodromo:hipodromo});
			_hipodromos = Global.banca.sql('SELECT * FROM '+HIPODROMOS,VOHipodromo).data;
		}
		
		public function ganador (hipodromo:String):Number {
			var i:int;
			for (i = 0; i < _hipodromos.length; i++) {
				if (hipodromo==_hipodromos[i].Hipodromo) return _hipodromos[i].Ganador; 	
			}
			return 0;
		}
	}
}