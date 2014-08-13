package Clases.Ganador
{
	import sr.modulo.Modulo;
	
	import flash.data.SQLResult;
	
	import mx.utils.ObjectUtil;

	public class Carreras_Padre
	{
		public static const CARRERAS_PADRE:String = "Carreras_Padre";

		private var s:String;
		
		public function Carreras_Padre() {
		}
		
		public function insertar (fecha:String,hipodromo:String,carreras:Array):void {
			var carrera:Array;
			var ejemplar:Object; 
			var carreras_padre:Array = new Array;
			var _carreras:Array = new Array;
			var j:int; var c:int; var i:int;
			var guardar:Object;
			for (i = 0; i < carreras.length; i++) {
				for (j = 0; j < Global.banca.bancas.numBancas; j++) {
					guardar = new Object;
					guardar.FHC = Modulo.fhc(fecha,hipodromo,(i+1));
					guardar.Fecha = fecha;
					guardar.Hipodromo = hipodromo;
					guardar.Carrera = i+1;
					guardar.Abierta = Boolean(Global.banca.config.inicioTaquillas);
					guardar.BancaID = j+1;
					carreras_padre.push(guardar);
					
					carrera = carreras[i] as Array;
					for (c = 0; c < carrera.length; c++) {
						ejemplar = new Object;
						ejemplar.Numero = carrera[c].Numero;
						ejemplar.Nombre = Modulo.normalize(carrera[c].Nombre);
						ejemplar.FHC = guardar.FHC;
						ejemplar.Fecha = guardar.Fecha;
						ejemplar.Hipodromo = guardar.Hipodromo;
						ejemplar.Carrera = guardar.Carrera;
						ejemplar.Retirado = false;
						ejemplar.Bloqueado = false;
						ejemplar.BancaID =  j+1;
						_carreras.push(ejemplar);	
					}
				}
			}
			Global.ganador.insertarUnion(CARRERAS_PADRE,carreras_padre);
			Global.ganador.carreras.insertar(_carreras);
			Global.remate.carreras.insertar(_carreras);
		}
		
		public function isCarreraAbierta(carrera:Object,banca:int):Boolean {
			var fhc:String = Modulo.fhc(carrera.Fecha,carrera.Hipodromo,carrera.Carrera);
			var r:SQLResult = Global.ganador.sql('SELECT * FROM Carreras_Padre WHERE FHC = "'+fhc+'" AND BancaID = '+banca);
			if (r.data) return r.data[0]["Abierta"];
			return false
		}
		
		public function eliminar (campos:Object):void {
			Global.ganador.sql(Modulo.buildDelete(CARRERAS_PADRE,campos));		
		}
		public function leer (fecha:String,hipodromo:String=null,carrera:int=0,banca:int=0):Array {
			fecha=fecha.split("-").join("");
			s = 'SELECT * FROM '+CARRERAS_PADRE+' WHERE FHC = "'+Modulo.fhc(fecha,hipodromo,carrera)+'"';
			if (banca>0)
				s += ' AND BancaID = '+banca.toString();
			return Global.ganador.sql(s).data;
		}
		public function leerCarreraFH(fecha:String,hipodromo:String=""):Array {
			fecha=fecha.split("-").join("");
			if (hipodromo.length>0) fecha += hipodromo;
			s = 'SELECT * FROM '+CARRERAS_PADRE+' WHERE FHC LIKE "'+fecha+'%"';
			return Global.ganador.sql(s).data;
		}
		
		public function carreras_ganadorTaquillas (fhc:String,status:Boolean):void {
			Global.ganador.actualizar(CARRERAS_PADRE,{Abierta:status},{FHC:fhc});
		}
		public function carreras_ganadorTaquillas_banca (fhc:String,status:Boolean,banca:int):void {
			Global.ganador.actualizar(CARRERAS_PADRE,{Abierta:status},{FHC:fhc,BancaID:banca});
		}
	}
}