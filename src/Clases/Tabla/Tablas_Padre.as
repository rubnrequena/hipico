package Clases.Tabla
{
	import sr.modulo.Modulo;
	
	import flash.data.SQLResult;

	public class Tablas_Padre
	{
		public static const TABLAS_PADRE:String = "Tablas_Padre";

		private var s:String;
		
		public function Tablas_Padre() {
		}
		
		public function insertar (fecha:String,hipodromo:String,carreras:Array):void {
			
		}
		
		public function leer (fecha:String,hipodromo:String=null,carrera:int=0,banca:int=0):Array {
			fecha=fecha.split("-").join("");
			s = 'SELECT * FROM '+TABLAS_PADRE+' WHERE FHC = "'+Modulo.fhc(fecha,hipodromo,carrera)+'"';
			if (banca>0)
				s += ' AND BancaID = '+banca.toString();
			return Global.tablas.sql(s,VOTablas_Padre).data;
		}
		public function isCarreraAbierta(fhc:String,banca:int):Boolean {
			var r:SQLResult = Global.tablas.sql('SELECT * FROM '+TABLAS_PADRE+' WHERE FHC = "'+fhc+'" AND BancaID = '+banca);
			if (r.data) return r.data[0]["Abierta"];
			return false
		}
		public function leerCarreraFH(fecha:String,hipodromo:String=""):Array {
			fecha=fecha.split("-").join("");
			if (hipodromo.length>0) fecha += hipodromo;
			s = 'SELECT * FROM '+TABLAS_PADRE+' WHERE FHC LIKE "'+fecha+'%"';;
			return Global.tablas.sql(s).data;
		}
		public function carreras_taquillas (fhc:String,status:Boolean):void {
			Global.tablas.actualizar(TABLAS_PADRE,{Abierta:status},{FHC:fhc});
		}
		public function carreras_taquillas_banca (fhc:String,status:Boolean,banca:int):void {
			Global.tablas.actualizar(TABLAS_PADRE,{Abierta:status},{FHC:fhc,BancaID:banca});
		}
		public function actualizarPorcentaje(fhc:String,retirado:Boolean,numero:int):void {
			var em:Array = Global.tablas.sql('SELECT * FROM Tablas WHERE FHC = "'+fhc+'" AND Numero = '+numero+' ORDER BY BancaID').data;
			var tb:Array = Global.tablas.sql('SELECT * FROM Tablas_Padre WHERE FHC = "'+fhc+'" ORDER BY BancaID').data;
			var m:int;
			if (tb && em) {
				for (var i:int = 0; i < tb.length; i++) {
					m = int(em[i].Monto)*0.70;
					if (em[i].Retirado==true)
						tb[i].Paga = int(tb[i].Paga)-m;
					else
						tb[i].Paga = int(tb[i].Paga)+m;
				}
				Global.tablas.sql('DELETE FROM Tablas_Padre WHERE FHC = "'+fhc+'"');
				Global.tablas.insertarUnion("Tablas_Padre",tb);
			}
		}
	}
}