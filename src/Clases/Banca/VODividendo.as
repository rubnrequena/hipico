/**
 * Created by Ruben on 25-03-2014.
 */
package Clases.Banca {
import flash.utils.ByteArray;

public class VODividendo {

    public var divID:int;
    public var bancaID:int;
    public var hipodromos:String;
    public var rangos:String;
    public var empate:Number;
    public var tope:Number;

    public function get listRangos ():Array {
        return JSON.parse(rangos) as Array;
    }
    public function dividendo (dividendo:Number,es_empate:Boolean=false):Number {
        var i:int; var div:Number=0; var rangos:Array = listRangos;
        for (i = 0; i < rangos.length; i++) {
            if (dividendo >= rangos[i].min && dividendo <= rangos[i].max) {
                div = rangos[i].valor;
                if (div<0) {
                    div = dividendo + (div*-1);
                }
                if (es_empate) div += empate;
                if (div>tope) div = tope;
                return div;
            }
        }
        return 0;
    }
    public function VODividendo() {

    }

    public function toObject(...exclude):Object {
        var ba:ByteArray = new ByteArray();
        ba.writeObject(this);
        ba.position=0;
        var o:Object = ba.readObject();
        for each (var e:String in exclude) {
            delete o[e];
        }
        return o;
    }
}
}
