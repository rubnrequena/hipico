import Clases.Ganador.VOPremiar;

import Comps.itemGanador;

import VOs.VOCarrera;
import VOs.VODividendo;
import VOs.VOEjemplar;

import flash.events.MouseEvent;

import mx.controls.Alert;

protected function iniciarGanador():void {
    var gn:itemGanador; var where:Object = carrera.toDB; var g:Array;
    for (var i:int = 0; i < Global.banca.bancas.numBancas; i++) {
        gn = bancas.getElementAt(i) as itemGanador;
        g = Global.ganador.ganadores.leerFHC(carrera.fecha(),carrera.Hipodromo,carrera.Carrera,gn.banca);
        if (g) {
            gn.ganador = g.length>0?g[0].Paga:0;
            gn.ganador2 = g.length>1?g[1].Paga:0;
            if (g.length==1) {
                ganadorEjemplares.selectedIndex = (g[0].Numero)-1;
            } else if (g.length==2) {
                empates++;
                ganadorEjemplares.selectedIndex = (g[0].Numero)-1;
                ganadorEjemplares2.selectedIndex = (g[1].Numero)-1;
            }
            hayGanador=true;
        } else {
            hayGanador=false;
        }
    }
}
protected function set hayGanador(value:Boolean):void {
    var b:Boolean=true;
    if (value) {
        b = false;
    } else {
        for (var i:int = 0; i < bancas.numElements; i++) {
            if ((bancas.getElementAt(i) as itemGanador).tieneGanador) { b = false; }
        }
    }
    ganadorEjemplares.enabled=b; ganadorEjemplares2.enabled=b; chkEmpate.enabled=b;
}
protected function btnAllDividendos_clickHandler():void {
    var ig:itemGanador;
    var i:int;
    for (i = 0; i < bancas.numElements; i++) { ig = bancas.getElementAt(i) as itemGanador; if (!ig.tieneGanador) { ig.txtDiv.text = allDividendos.text; } }
    if (this.currentState=="empate") {
        for (i = 0; i < bancas.numElements; i++) { ig = bancas.getElementAt(i) as itemGanador; if (!ig.tieneGanador) { ig.txtDiv0.text = allDividendos0.text; } }
    }
}
protected function btnEnviarGanador_clickHandler(event:MouseEvent):void {
	if (ganadorEjemplares.selectedIndex>-1) {
		if (chkEmpate.selected && ganadorEjemplares2.selectedIndex==-1) {
			Alert.show("Seleccione el 2do ejemplar ganador","",4,this); return;
		}
	} else {
		Alert.show("Seleccione ganadores","Ganador",4,this); return;
	}
	var i:int; var _banca:itemGanador; var pr:VOPremiar; var div:VODividendo; 
	var _dividendos:Vector.<VOPremiar> = new Vector.<VOPremiar>;
	for (i = 0; i < bancas.numElements; i++) {
		_banca = bancas.getElementAt(i) as itemGanador;
		if (_banca.lblBanca.selected) {
			if (_banca.tieneGanador==false) {
				pr = new VOPremiar;
				pr.banca = _banca.banca;
				if (_banca.paga>0) {
					div = new VODividendo(ganadorEjemplares.selectedItem.Numero,ganadorEjemplares.selectedItem.Nombre,_banca.paga);
					pr.dividendos.push(div);
				}
				if (chkEmpate.selected && _banca.paga2>0) {
					div = new VODividendo(ganadorEjemplares2.selectedItem.Numero,ganadorEjemplares2.selectedItem.Nombre,_banca.paga2);
					pr.dividendos.push(div);
				}
				if (pr.dividendos.length>0) {
					_dividendos.push(pr);
					_banca.tieneGanador=true;
				} else {
					_banca.dividendoInvalido();
				}
			} else {
				_banca.ganadorRepetido();
			}
		}
	}
	if (_dividendos.length>0) {
		//carrera
		var _carrera:VOCarrera = new VOCarrera;
		_carrera.fecha = carrera.fecha();
		_carrera.hipodromo = carrera.Hipodromo;
		_carrera.carrera = carrera.Carrera;
		//ganadores
		var _ganadores:Vector.<VOEjemplar> = new Vector.<VOEjemplar>;
		_ganadores.push(new VOEjemplar(ganadorEjemplares.selectedItem.Numero,ganadorEjemplares.selectedItem.Nombre));
		if (chkEmpate.selected) {
			_ganadores.push(new VOEjemplar(ganadorEjemplares2.selectedItem.Numero,ganadorEjemplares2.selectedItem.Nombre));
		}
		// dividendo
		Global.ganador.premios.premiar(_dividendos,_carrera,_ganadores,Global.banca.hipodromos.ganador(_carrera.hipodromo));
		hayGanador=true;
	}
}
