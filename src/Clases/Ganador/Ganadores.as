package Clases.Ganador
{
	import sr.modulo.Modulo;

	public class Ganadores
	{
		public static const GANADORES:String = "Ganadores";
		private var s:String;
		
		public function Ganadores() { }
		
		public function leer (campos:Object,agrupar:String=null,columnas:String="*"):Array {
			s = 'SELECT '+columnas+' FROM '+GANADORES+' WHERE ';
			var cc:Array = new Array;
			if (campos) {
				for (var c:String in campos) {
					cc.push(c+' = '+Modulo.formatString(campos[c]));
				}
			}
			s += cc.join(" AND ");
			if (agrupar) s += ' GROUP BY '+agrupar;
			return Global.ganador.sql(s).data;
		}
		
		public function leerFHC (fecha:String,hipodromo:String="",carrera:int=0,banca:int=0,taquilla:String=null,agrupar:String=null):Array {
			s = 'SELECT * FROM '+GANADORES+' WHERE FHC = "'+Modulo.fhc(fecha,hipodromo,carrera)+'"';
			if (banca>0)
				s += ' AND BancaID = '+banca;
			if (taquilla)	
				s += ' AND Taquilla = "'+taquilla+'"';
			if (agrupar)
				s += ' GROUP BY '+agrupar;
			return Global.ganador.sql(s).data;
		}
		
		public function insertar(nombre:String,numero:String,paga:Number,banca:int,fecha:String,hipodromo:String,carrera:int):void {
			Global.ganador.insertar(GANADORES,{FHC:Modulo.fhc(fecha,hipodromo,carrera),Nombre:nombre,Numero:numero,Paga:paga,Fecha:fecha,Hipodromo:hipodromo,Carrera:carrera,BancaID:banca});
		}
		public function guardar (ganadores:Array):void {
			Global.ganador.insertarUnion(GANADORES,ganadores);
		}
		public function eliminar(carrera:Object,bancaID:int=0):void {
			if (bancaID>0) carrera.BancaID = bancaID;
			Global.ganador.eliminar(GANADORES,carrera);
		}
		public function reiniciar(carrera:Object,bancas:Array):void {
			/*Global.ganador.ganadores.eliminar(carrera,bancaID);
			Global.ganador.premios.eliminar(carrera,bancaID);*/
			var w:Array = new Array;
			for (var i:int = 0; i < bancas.length; i++) {
				w.push("BancaID = "+bancas[i]);
				Global.net.ganador.reiniciarPremios(carrera,bancas[i]);
			}
			Global.ganador.sql('DELETE FROM '+GANADORES+' WHERE FHC = "'+Modulo.fhc(carrera.Fecha,carrera.Hipodromo,carrera.Carrera)+'" AND ('+w.join(" OR ")+')');
			Global.ganador.sql('DELETE FROM '+Premios.PREMIOS+' WHERE FHC = "'+Modulo.fhc(carrera.Fecha,carrera.Hipodromo,carrera.Carrera)+'" AND ('+w.join(" OR ")+')');
			Global.ganador.sql('DELETE FROM '+Premios.PREMIADOS+' WHERE FHC = "'+Modulo.fhc(carrera.Fecha,carrera.Hipodromo,carrera.Carrera)+'" AND ('+w.join(" OR ")+')');
		}
	}
}