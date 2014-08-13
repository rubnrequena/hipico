/**
 * Created by Ruben on 25-03-2014.
 */
package UI.Main.config {
import Clases.Banca.VODividendo;

import appkit.responders.NResponder;

import flash.events.FocusEvent;
import flash.events.MouseEvent;

import mx.collections.ArrayList;
import mx.controls.Alert;
import mx.events.FlexEvent;

import spark.components.CheckBox;
import spark.components.TextInput;

public class DividendosConfig extends DividendosConfigUI {

    public function DividendosConfig() {
        super();
        NResponder.addNative(this,FlexEvent.CREATION_COMPLETE,onCreationComplete,1);
    }

    protected function nuevoView_creationComplete(event:FlexEvent):void {
        bancaList.dataProvider = new ArrayList(Global.banca.bancas.bancas);
        var chk:CheckBox;
        var o:Object;
        for (var i:int = 0; i < Global.banca.hipodromos.datos.length; i++) {
            o = Global.banca.hipodromos.datos[i];
            chk = new CheckBox();
            chk.label = o.Hipodromo;
            hipodromosGroup.addElement(chk);
        }
        NResponder.addNative(nuevoAtrasButton, MouseEvent.CLICK, nuevoAtrasButton_click);
        NResponder.addNative(nuevoGuardarButton, MouseEvent.CLICK, nuevoGuardarButton_click);
        NResponder.addNative(min2, FocusEvent.FOCUS_IN, min_focusIn);
        NResponder.addNative(min3, FocusEvent.FOCUS_IN, min_focusIn);
    }
    protected function min_focusIn(event:FocusEvent):void {
        var n:Number;
        if (event.target.parent.parent == min2) {
            n = Number(max1.text);
            if (!isNaN(n)) min2.text = String(n + 0.01);
        }
        if (event.target.parent.parent == min3) {
            n = Number(max2.text);
            if (!isNaN(n)) min3.text = String(n + 0.01);
        }
    }
    protected function onCreationComplete(event:FlexEvent):void {
        var divs:Array = Global.banca.sql("SELECT * FROM Dividendos ORDER BY BancaID",VODividendo).data;
        lista.dataProvider = new ArrayList(divs);

        NResponder.addNative(nuevoView,FlexEvent.CREATION_COMPLETE,nuevoView_creationComplete,1);
        NResponder.addNative(agregarButton,MouseEvent.CLICK,agregarButton_onClick);
        NResponder.addNative(removerButton,MouseEvent.CLICK,removerButton_onClick);
    }

    protected function removerButton_onClick (event:MouseEvent):void {
        if (lista.selectedIndex>-1) {
            if (Global.banca.dividendos.remover(lista.selectedItem.divID))
                lista.dataProvider.removeItemAt(lista.selectedIndex);
        }
    }

    protected function agregarButton_onClick (e:MouseEvent):void {
        currentState = "nuevo";
    }

    protected function nuevoGuardarButton_click (event:MouseEvent):void {
        var div:VODividendo = new VODividendo();
        div.bancaID = bancaList.selectedItem.ID;
        div.hipodromos = hipodromosSeleccionados;
        div.empate = parseFloat(empateInput.text);
        div.tope = parseFloat(topeInput.text);
        div.rangos =  divRangos;

        if (!isNaN(div.empate) && !isNaN(div.tope) && div.rangos) {
            var r:Number = Global.banca.dividendos.insertar(div);

            if (r > 0) {
                div.divID = r;
                lista.dataProvider.addItem(div);
            }
            currentState = "lista";
        } else {
            Alert.show("Campos Obligatorios sin completar..");
        }
    }

    protected function nuevoAtrasButton_click(event:MouseEvent):void {
        currentState = "lista";
    }
    private function get hipodromosSeleccionados():String {
        var hs:Array = [];
        for (var i:int = 0; i < hipodromosGroup.numElements; i++) {
            var o:CheckBox = hipodromosGroup.getElementAt(i) as CheckBox;
            if (o.selected) hs.push(o.label);
        }
        return hs.join(",");
    }
    private function get divRangos():String {
        if (rangosInvalidos(min1,min2,min3,max1,max2,max3,val1,val2,val3)) return null;
        var r:Array = [];
        var o:Object;
        o = {min:Number(min1.text),max:Number(max1.text),valor:Number(val1.text.split("+").join("-"))};
        r.push(o);
        o = {min:Number(min2.text),max:Number(max2.text),valor:Number(val2.text.split("+").join("-"))};
        r.push(o);
        o = {min:Number(min3.text),max:Number(max3.text),valor:Number(val3.text.split("+").join("-"))};
        r.push(o);
        return JSON.stringify(r);
    }
    private function rangosInvalidos (...input):Boolean {
        var ti:TextInput;
        for (var i:int = 0; i < input.length; i++) {
            ti = input[i] as TextInput;
            if (isNaN(parseFloat(ti.text))) return true;
        }
        return false;
    }
}
}
