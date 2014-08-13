/**
 * Created by Ruben on 25-03-2014.
 */
package Clases.Banca {
import flash.data.SQLColumnSchema;
import flash.data.SQLSchemaResult;
import flash.data.SQLTableSchema;

public class Dividendos {

    private var _dividendos:Vector.<VODividendo>;

    public function Dividendos() {
        var data:Array = Global.banca.sql("SELECT * FROM Dividendos",VODividendo).data;
        _dividendos = new Vector.<VODividendo>();
        if (data) {
            for (var i:int=0;i<data.length;i++) {
                _dividendos.push(data[i]);
            }
        }
    }
    public function dividendo (banca:int,hipodromo:String,dividendo:Number,empate:Boolean=false):Number {
        var i:int;
        for (i=0;i<_dividendos.length;i++) {
            if (_dividendos[i].bancaID == banca && _dividendos[i].hipodromos.indexOf(hipodromo) > -1) {
                 return _dividendos[i].dividendo(dividendo,empate);
            }
        }
        return 0;
    }
    public function insertar (dividendo:VODividendo):Number {
        _dividendos.push(dividendo);
        return Global.banca.sql("INSERT INTO Dividendos (bancaID,hipodromos,tope,empate,rangos) VALUES ("+ dividendo.bancaID+",'"+dividendo.hipodromos+"',"+dividendo.tope+","+dividendo.empate+",'"+dividendo.rangos+"')").lastInsertRowID;
    }
    public function remover (dividendoID:int):Boolean {
        var i:int = dividendoByID(dividendoID);
        if (i>-1){
            Global.banca.eliminar("Dividendos",{divID:dividendoID});
            _dividendos.splice(i,1);
            return true;
        }
        return false;
    }
    private function dividendoByID (divID:int):int {
        for (var i:int = 0; i < _dividendos.length; i++) {
            if (_dividendos[i].divID==divID) return i;
        }
        return -1;
    }
}
}
