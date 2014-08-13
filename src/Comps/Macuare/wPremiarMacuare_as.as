
import Common.Misc;

import VOs.Macuare_Datos;

import appkit.responders.NResponder;

import flash.events.MouseEvent;

import mx.collections.ArrayList;
import mx.core.IVisualElementContainer;
import mx.events.CalendarLayoutChangeEvent;
import mx.managers.PopUpManager;
import mx.utils.object_proxy;

import spark.components.HGroup;
import spark.components.TextInput;

private var carrera:Object;
private var macuares:Array;

private function onComplete():void {
	fecha.addEventListener(CalendarLayoutChangeEvent.CHANGE,fecha_change,false,0,true);
}
protected function fecha_change(event:CalendarLayoutChangeEvent):void {
	var carreras:ArrayList = new ArrayList(Global.macuare.macuares.leer({fecha:this.fecha.fechaSelecionada}));
	hipodromos.dataProvider = carreras;
}

protected function btnSiguiente_click_paso1 (event:MouseEvent):void {
	carrera = {Fecha:fecha.fechaSelecionada,Hipodromo:hipodromos.selectedItem.hipodromo};
	carrera.Carrera = Global.banca.carreras.numCarreras(carrera.Fecha,carrera.Hipodromo);
	this.currentState= "paso2";
	macuares = Global.macuare.sql('SELECT * FROM Macuares JOIN Carreras ON Macuares.macuareId = Carreras.macuareId WHERE Macuares.fecha = "'+fecha.fechaSelecionada+'"',Macuare_Datos).data;
	if (macuares.length>0) {
		var i:int; var inicio:int=99;
		for (i = 0; i < macuares.length; i++) {
			if (macuares[i].inicio<inicio) inicio = macuares[i].inicio;
		}
		var txt:TextInput;
		var j:int;
		var r2:Array = [1,4,5,2,1,8,9,2]; //temp
		for (j = inicio-1; j < carrera.Carrera; j++) {
			txt = new TextInput;
			txt.setStyle("fontSize",20);
			txt.width = 40;
			//txt.text = r2[j-(inicio-1)]; // temp
			txt.prompt = Misc.fillZeros(j+1,2);
			g1.addElement(txt);
		}
		for (j = inicio-1; j < carrera.Carrera; j++) {
			txt = new TextInput;
			txt.setStyle("fontSize",20);
			txt.width = 40;
			//txt.text = r2[j-(inicio-1)];  temp
			txt.prompt = Misc.fillZeros(j+1,2);
			g2.addElement(txt);
		}
		for (j = inicio-1; j < carrera.Carrera; j++) {
			txt = new TextInput;
			txt.setStyle("fontSize",20);
			txt.width = 40;
			//txt.text = r2[j-(inicio-1)];  temp
			txt.prompt = Misc.fillZeros(j+1,2);				
			g3.addElement(txt);
		}
		delete carrera.Carrera;
		//Leer ganadores
		/*var ganadores:Array = Global.macuare.sql('SELECT Ganador.Carrera, Ganador.Nombre gn, Carreras.Nombre cn, Ganador.Fecha, Carreras.Numero FROM Ganador JOIN Carreras ON Ganador.Nombre = Carreras.Nombre WHERE Ganador.Fecha = "'+carrera.Fecha+'" AND Carreras.Fecha = "'+carrera.Fecha+'" ORDER BY Ganador.Carrera').data;
		if (ganadores.length==carrera.Carrera) {
			for (i = inicio-1; i < ganadores.length; i++) {
				(g1.getElementAt(i-(inicio-1)) as TextInput).text = ganadores[i].Numero;
			}
		} else {
			Alert.show("Faltan ganadores");
		}*/
	}
}
private var mac:Macuare_Datos;
private var mac2:Macuare_Datos;
private	var ganadoresMacuare:Array;
private var ganadoresMacuarito:Array;
private var retirados:Array;
protected function btnSiguiente_click_paso2 (event:MouseEvent):void {
	var resultadosMacuare:Array = ejemplaresMacuares(0);
	var resultadosMacuarito:Array = ejemplaresMacuares(1);
	retirados = Global.banca.carreras.leer({Fecha:carrera.Fecha,Hipodromo:carrera.Hipodromo,Retirado:true});
	this.currentState="paso3";
	//Leer ventas
	jugado = 0;
	premiosTotal=0;
	mac = datosMacuares("Macuare");
	if (mac) {
		var ventasMacuare:Array;
		ventasMacuare = Global.macuare.ventas.leer({Fecha:carrera.Fecha,eliminado:false,mDatoId:mac.mDatoId});
		ventasMacuare = filtrarRetirados(ventasMacuare,mac.inicio);
		ganadoresMacuare = extraerGanadores(ventasMacuare,resultadosMacuare,mac.paga);
		dgGanadores.dataProvider = new ArrayList(ganadoresMacuare);
	}
	mac2 = datosMacuares("Macuarito");
	if (mac2) {
		var ventasMacuarito:Array;
		ventasMacuarito = Global.macuare.ventas.leer({Fecha:carrera.Fecha,eliminado:false,mDatoId:mac2.mDatoId});
		if (ventasMacuarito) {
			ganadoresMacuarito = extraerGanadores(ventasMacuarito,resultadosMacuarito,mac2.paga);
			dgGanadores0.dataProvider = new ArrayList(ganadoresMacuarito);
		}
	}
}
protected function btnSiguiente_click_paso3 (event:MouseEvent):void {
	guardarGanadores();
	var i:int; var p:int;
	var premios:Array = Global.macuare.sql('SELECT Premios.mDatoId,jugado,premio,bancaId,fecha,hipodromo,taquilla,descripcion FROM Premios JOIN Carreras ON Carreras.mDatoId = Premios.mDatoId WHERE Fecha = "'+carrera.Fecha+'" AND Hipodromo = "'+carrera.Hipodromo+'"').data;
	var plen:int = premios?premios.length:0;
	
	var premiados:Array = Global.macuare.premios.premiados({fecha:carrera.Fecha,hipodromo:carrera.Hipodromo});
	var prlen:int = premiados?premiados.length:0;
	var taquillas:Array = Global.macuare.premios.leer({fecha:carrera.Fecha},"bancaID,taquilla","bancaID,taquilla");
	var tlen:int = taquillas?taquillas.length:0;
	
	var tq_premios:Array; var tq_premiados:Array;
	var c:Object = {fecha:carrera.Fecha,hipodromo:carrera.Hipodromo};
	for (i = 0; i < tlen; i++) {
		tq_premios = []; tq_premiados = [];
		for (p=0;p<plen;p++) {
			if (taquillas[i].bancaID==premios[p].bancaID && taquillas[i].taquilla==premios[p].taquilla) { 
				tq_premios.push(premios[p]); 
			}
		}
		for (p=0;p<prlen;p++) {
			if (taquillas[i].bancaID==premiados[p].bancaID && taquillas[i].taquilla==premiados[p].taquilla) {
				tq_premiados.push(premiados[p]);
			}
		}
		Global.net.macuare.premios_enviar(c,tq_premios,tq_premiados,taquillas[i].bancaID,taquillas[i].taquilla);
	}
	/* MACUARE
	jugadas.macuareEnviaGanadores(ganadoresMacuare,ganadoresMacuarito,macuares,carrera.toObject(),jugado,premiosTotal,function (clientes:int):void {
		Alert.show("Clientes recibidos: "+clientes);
	});*/
}
private function establecerChance(caballos:int):int {
	for (var i:int = 0; i < chancesMacuare.length; i++) {
		if (caballos >= chancesMacuare[i].minimo && caballos <= chancesMacuare[i].maximo) { return chancesMacuare[i].chance; }
	}
	return 0;
}
//Establecer un chance a cada carrera Ej: [2,1,3,2,2,1,4]
private var chancesMacuare:Array;
private function get establecerChances():Array {
	chancesMacuare = Global.macuare.chances;
	var ejemplaresXCarrera:Array;
	//ejemplaresXCarrera = Global.db.Leer_Multi(Tablas.Carreras,[{Fecha:carrera.Fecha}],null,"Carrera, COUNT(*) Cantidad","Carrera","Carrera").toArray();
	ejemplaresXCarrera = Global.banca.carreras.leer({Fecha:carrera.Fecha,Hipodromo:carrera.Hipodromo},"Carrera, COUNT(*) Cantidad","Carrera","Carrera");
	var c:Array=new Array; var i:int;
	for (i = 0; i < ejemplaresXCarrera.length; i++) { c.push(establecerChance(ejemplaresXCarrera[i].Cantidad)); }
	return c;
}
//GANADORES
private var jugado:Number;
private var premiosTotal:Number;
private function extraerGanadores(ventas:Array,ejemplares:Array,paga:Number):Array {
	var chances:Array = establecerChances; var i:int; var prm:Number;
	var chance:int; var venta:Array; var vlen:int = ventas?ventas.length:0; 
	var ganador:Boolean; var ganadores:Array = new Array;
	for (i = 0; i < vlen; i++) {
		venta = (ventas[i].ejemplares as String).split(",");
		for (var col:int = 0; col < venta.length; col++) {
			ganador=false;
			for (var fila:int = 0; fila < chances[col]; fila++) {
				if (ejemplares[fila][col]==venta[col]) { ganador=true; }
			}
			if (!ganador) break;
		}
		jugado+= Number(ventas[i].monto);
		if (ganador) {
			prm = Number(ventas[i].monto)*paga;
			ventas[i].premio = prm;
			premiosTotal+= prm;
			ganadores.push(ventas[i]);
		}
	}
	return ganadores;
}
private function ejemplaresMacuares (inicio:int=0):Array {
	var resultados:Array = new Array; var temp:Array; var i:int; var j:int; var txt:TextInput;
	for (i = 0; i < 3; i++) {
		var hg:HGroup = resultadosGroup.getElementAt(i) as HGroup;
		temp=new Array;
		for (j = inicio; j < hg.numElements; j++) {
			txt = hg.getElementAt(j) as TextInput;
			temp.push(txt.text);
		}
		resultados.push(temp);
	}
	return resultados;
}
private function datosMacuares (desc:String):Macuare_Datos {
	var m:Macuare_Datos;
	for (var i:int = 0; i < macuares.length; i++) {
		m = macuares[i];
		if (desc==m.descripcion) { return m; }
	}
	m = null;
	return m;
}
private function reinciarGanadores():void {
	Global.macuare.premios.eliminarPremios(carrera.Fecha,carrera.Hipodromo);
}
private function guardarGanadores():void {
	reinciarGanadores();
	
	var i:int; var j:int;
	var g:Array = [];
	if (ganadoresMacuare)
		g = g.concat(ganadoresMacuare);
	if (ganadoresMacuarito)
		g = g.concat(ganadoresMacuarito);
	if (g.length>0)
		Global.macuare.insertarUnion("Premiados",g);
	
	var premios:Array = [];
	var premio:Object; var tickets:Array;
	var ticketsLen:int;
	for (i = 0; i < Global.banca.bancas.numBancas; i++) {
		tickets = Global.macuare.sql('SELECT mDatoId,taquilla,fecha,hipodromo, bancaID, SUM(monto) monto FROM Ventas WHERE fecha = "'+fecha.fechaSelecionada+'" AND bancaID = '+Global.banca.bancas.bancas[i].ID+' GROUP BY taquilla,bancaID,mDatoId').data;
		ticketsLen = tickets?tickets.length:0;
		for (j = 0; j < ticketsLen; j++) {
			premio = {};
			premio.premio = premiosBanca(Global.banca.bancas.bancas[i].ID,tickets[j].mDatoId,tickets[j].taquilla);
			premio.jugado = tickets[j].monto;
			premio.mDatoId = tickets[j].mDatoId;
			premio.fecha = tickets[j].fecha;
			premio.hipodromo = tickets[j].hipodromo;
			premio.bancaID = tickets[j].bancaID;
			premio.taquilla = tickets[j].taquilla;
			premios.push(premio);
		}
	}
	Global.macuare.insertarUnion("Premios",premios);	
}
private function premiosBanca(banca:int,mDatoId:int,taquilla:String):Number {
	var p:Number=0; var i:int; var len:int;
	len = ganadoresMacuare?ganadoresMacuare.length:0;
	for (i = 0; i < len; i++) { 
		if (ganadoresMacuare[i].bancaID==banca && ganadoresMacuare[i].mDatoId==mDatoId && ganadoresMacuare[i].taquilla==taquilla) {
			p += Number(ganadoresMacuare[i].premio); 
		}
	}
	len = ganadoresMacuarito?ganadoresMacuarito.length:0;
	for (i = 0; i < len; i++) { 
		if (ganadoresMacuarito[i].bancaID==banca && ganadoresMacuarito[i].mDatoId==mDatoId && ganadoresMacuarito[i].taquilla==taquilla) {
			p += Number(ganadoresMacuarito[i].premio); 
		}
	}
	return p;
}
//RETIRADOS
private function filtrarRetirados(tickets:Array,inicio:int):Array {
	var ejemplares:Array; var rlen:int = retirados?retirados.length:0; var len:int = tickets?tickets.length:0;
	var i:int; var j:int; var k:int;
	for (i = 0; i < len; i++) {
		ejemplares = (tickets[i].ejemplares as String).split(",");
		for (j = 0; j < ejemplares.length; j++) {
			for (k = 0; k < rlen; k++) {
				if (j+inicio == retirados[k].Carrera && ejemplares[j]==retirados[k].Numero) {
					ejemplares[j] = int(ejemplares[j])+1;
				}
			}
		}
		tickets[i].ejemplares = ejemplares.join(",");
	}
	return tickets;
}