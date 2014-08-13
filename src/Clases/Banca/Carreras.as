package Clases.Banca
{
	import libVOs.infoCarrera;
	
	import sr.modulo.Modulo;

	public class Carreras
	{
		public static const CARRERAS:String = "Carreras";
		
		private var s:String;
		public function Carreras() { }
		
		public function leerFHC (fecha:String,hipodromo:String="",carrera:int=0,agrupar:String="",columnas:String="*"):Array {
			if (agrupar.length>0) agrupar = " GROUP BY "+agrupar;
			s = 'SELECT '+columnas+' FROM '+CARRERAS+' WHERE FHC LIKE "'+Modulo.fhc(fecha,hipodromo,carrera)+'%"'+agrupar+' ORDER BY Numero';
			return Global.banca.sql(s).data;
		}
		public function eliminar (campos:Object):void {
			Global.banca.sql(Modulo.buildDelete(CARRERAS,campos));		
		}
		public function numCarreras (fecha:String,hipodromo:String):uint {
			var d:Array = Global.banca.sql(Modulo.buildSelect("Carreras","Carrera",{Fecha:fecha,Hipodromo:hipodromo},"Carrera","Carrera DESC")).data;
			if (d) return uint(d[0].Carrera);
			return 0;
		}
		public function leer (campos:Object,columnas:String="*",agrupar:String=null,ordenar:String=""):Array {
			return Global.banca.sql(Modulo.buildSelect(CARRERAS,columnas,campos,agrupar,ordenar)).data;
		}
		public function leerNumCarreras (fecha:String):Array {
			return Global.banca.sql('SELECT * FROM (SELECT Hipodromo, Carrera FROM Carreras WHERE Fecha = "'+fecha+'" ORDER BY Carrera ASC) GROUP BY Hipodromo').data;
		}
		public function hipodromosDia(fecha:String):Array {
			return leerFHC(fecha,"",0,"Hipodromo");
		}
		public function insertar (fecha:String,hipodromo:String,carreras:Array):void {
			var i:int; var j:int;
			var carrera:Array;
			var _carreras:Array = new Array;
			var ejemplar:Object;
			for (i = 0; i < carreras.length; i++) {
				carrera = carreras[i] as Array;
				for (j = 0; j < carrera.length; j++) {
					ejemplar = new Object;
					ejemplar.Numero = carrera[j].Numero;
					ejemplar.Nombre = Modulo.normalize(carrera[j].Nombre);
					ejemplar.FHC = Modulo.fhc(fecha,hipodromo,(i+1));
					ejemplar.Fecha = fecha;
					ejemplar.Hipodromo = hipodromo;
					ejemplar.Carrera = i+1;
					ejemplar.Retirado = false;
					_carreras.push(ejemplar);
				}
				
			}
			Global.banca.insertarUnion(CARRERAS,_carreras);
		}
		public function retirarEjemplar(fhc:String,numero:int,retirado:Boolean):void {
			Global.banca.actualizar(CARRERAS,{Retirado:retirado},{FHC:fhc,Numero:numero});
		}
	}
}