import Comps.itemGanador;

import flash.events.MouseEvent;

import mx.controls.Alert;

protected function iniciarRemate():void {
	var g:Array;
	var ig:itemGanador;
	for (var i:int = 0; i < bancas.numElements; i++) {
		ig = bancas.getElementAt(i) as itemGanador;
		g = Global.remate.ganadores.leer({FHC:carrera.FHC,BancaID:ig.banca})
		if (g) {
			if (g.length==1) {
				remateEjemplares.selectedIndex = g[0].Numero-1;
			} else {
				empates++;
				remateEjemplares.selectedIndex = g[0].Numero-1;
				remateEjemplares2.selectedIndex = g[1].Numero-1;
			}
			hayGanadorRemate=true;
			ig.tieneGanadorRemate=true;
		}
	}
}
protected function btnEnviarGanadorRemate_clickHandler (event:MouseEvent):void {
	var ganadorSeleccionado:Boolean=false;
	if (remateEjemplares.selectedIndex>-1) {
		if (chkEmpate.selected) { 
			if (remateEjemplares2.selectedIndex==-1) {
				Alert.show("Seleccione ganador(es) del remate","",4,this); return;
			}
		}
	} else {
		Alert.show("Seleccione ganador(es) del remate","",4,this); return;
		return;
	}
	var banca:itemGanador;
	var ganadores:Array = new Array;
	var g:Object;
	for (var i:int = 0; i < bancas.numElements; i++) {
		banca = bancas.getElementAt(i) as itemGanador;
		if (banca.lblBanca.selected) {
			banca.tieneGanadorRemate=true;
			g = carrera.toDB;
			g.BancaID = i+1;
			g.FHC = carrera.FHC;
			g.Nombre = remateEjemplares.selectedItem.Nombre;
			g.Numero = remateEjemplares.selectedItem.Numero;
			ganadores.push(g);
			if (chkEmpate.selected) {
				g = carrera.toDB;
				g.BancaID = i+1;
				g.FHC = carrera.FHC;
				g.Nombre = remateEjemplares2.selectedItem.Nombre;
				g.Numero = remateEjemplares2.selectedItem.Numero;
				ganadores.push(g);
			}
			Global.net.remate.premios_enviar(carrera.toDB,ganadores,banca.banca);
		}
	}
	Global.remate.ganadores.guardar(ganadores);
	hayGanadorRemate=true;
}
protected function set hayGanadorRemate(value:Boolean):void {
	var b:Boolean=true;
	if (value) { b = false;
	} else { 
		for (var i:int = 0; i < bancas.numElements; i++) { if ((bancas.getElementAt(i) as itemGanador).tieneGanadorRemate) { b = false; } }
	}
	remateEjemplares.enabled=b; remateEjemplares2.enabled=b;
}