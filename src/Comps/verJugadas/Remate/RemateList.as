package Comps.verJugadas.Remate
{
	import Comps.verJugadas.Remate.EditItemRender;
	
	import events.GridEditorEvent;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import mx.collections.IList;
	import mx.events.FlexEvent;
	
	import spark.components.List;
	import spark.events.GridItemEditorEvent;
	import spark.events.IndexChangeEvent;
	
	[Event(name="enter", type="mx.events.FlexEvent")]
	[Event(name="sesionSaved", type="spark.events.GridItemEditorEvent")]
	[Event(name="cellSesionSaved", type="events.GridEditorEvent")]
	public class RemateList extends List {	
		
		public function header (monto:int,mesa:int,casillas:int):void {
			_montoWidth = monto;
			_mesaWidth = mesa;
			_casillas = casillas;
			dispatchEvent(new Event("updateHeader"));
		}
		
		private var _isEditing:Boolean=false;
		public function get isEditing():Boolean { return _isEditing; }

		public function setCasillasWidth (monto:int,mesa:int):void {
			_montoWidth = monto;
			_mesaWidth = mesa;
			for (var i:int = 0; i < dataGroup.numElements; i++) {
				(dataGroup.getElementAt(i) as EditItemRender).setWidth(monto,mesa);	
			}
			dispatchEvent(new Event("updateHeader"));
		}
		
		private var _montoWidth:int;
		[Bindable]
		public function get montoWidth():int { return _montoWidth; }
		
		public function set montoWidth(value:int):void {
			_montoWidth = value;
			dispatchEvent(new Event("updateHeader"));
			for (var i:int = 0; i < dataGroup.numElements; i++) {
				(dataGroup.getElementAt(i) as EditItemRender).montoWidth = value;	
			}
		}
		private var _montoLabel:String;
		[Bindable]
		public function get montoLabel():String { return _montoLabel; }

		public function set montoLabel(value:String):void {
			_montoLabel = value;
			dispatchEvent(new Event("updateHeader"));
		}
		
		private var _mesaWidth:int;
		[Bindable]
		public function get mesaWidth():int { return _mesaWidth; }

		public function set mesaWidth(value:int):void {
			_mesaWidth = value;
			dispatchEvent(new Event("updateHeader"));
			for (var i:int = 0; i < dataGroup.numElements; i++) {
				(dataGroup.getElementAt(i) as EditItemRender).mesaWidth = value;	
			}
		}

		private var _mesaLabel:String;
		[Bindable]
		public function get mesaLabel():String { return _mesaLabel; }

		public function set mesaLabel(value:String):void {
			_mesaLabel = value;
			dispatchEvent(new Event("updateHeader"));
		}

		
		private var _casillas:int;
		[Bindable]
		public function get casillas():int {
			return _casillas;
			dispatchEvent(new Event("updateHeader"));
		}

		public function set casillas(value:int):void {
			_casillas = value;
			dispatchEvent(new Event("updateHeader"));
		}		
		public function RemateList() {
			super();
			addEventListener(GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_START,onGridItemEditorChange,false,-1);
			addEventListener(GridEditorEvent.CELL_SESSION_SAVED,onSesionSaved,false,0);
			addEventListener("saveSesion",item_saveSesionRequest);
			addEventListener("rangeError",item_rangeError);
		}
		override public function set dataProvider(value:IList):void {
			super.dataProvider = value;
			_isEditing=false;
		}
		protected function onSesionSaved(event:Event):void {
			_isEditing=false;
		}
		protected function onGridItemEditorChange(event:GridItemEditorEvent):void {
			_lastColumnEdited = event.columnIndex;
			_lastRowEdited = event.rowIndex;
			selectedIndex=_lastRowEdited;
			_isEditing=true;
		}
		protected function item_rangeError(event:IndexChangeEvent):void {
			_lastColumnEdited = event.oldIndex==0?-1:event.oldIndex+1; 
			setFocus();
		}
		
		protected function item_saveSesionRequest(event:Event):void {
			if (isEditing) saveSesion();
		}
		
		override protected function keyUpHandler(event:KeyboardEvent):void {
			switch(event.keyCode) {
				case Keyboard.DOWN: { setEditor(_lastRowEdited+1,_lastColumnEdited); break; }
				case Keyboard.UP: { setEditor(_lastRowEdited-1,_lastColumnEdited); break; }
				case Keyboard.LEFT: { setEditor(_lastRowEdited,_lastColumnEdited-1); break; }
				case Keyboard.RIGHT: { setEditor(_lastRowEdited,_lastColumnEdited+1); break; }
				case Keyboard.ENTER: { dispatchEvent(new FlexEvent(FlexEvent.ENTER,false,false)); break; }
			}
		}
		
		private var _lastRowEdited:int=-1;
		public function get lastRowEdited():int { return _lastRowEdited; }
		
		private var _lastColumnEdited:int=-1;
		public function get lastColumnEdited():int { return _lastColumnEdited; }
		
		public function saveSesion():void {
			if (_lastColumnEdited+_lastRowEdited>-1)
				(dataGroup.getElementAt(_lastRowEdited) as EditItemRender).saveSession();
		}
		public function setEditor (fila:int,columna:int):void {
			if (fila>-1 && fila<dataGroup.numElements) {
				if (isEditing) saveSesion();
				ensureIndexIsVisible(fila);
				setTimeout(function ():void { (dataGroup.getElementAt(fila) as EditItemRender).editColumna = columna; },100);
			} else { setFocus(); }
		}


	}
}