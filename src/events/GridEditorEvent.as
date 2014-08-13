package events
{
	import flash.events.Event;
	
	public class GridEditorEvent extends Event
	{
		static public const CELL_SESSION_SAVING:String = "cellSessionSaving";
		static public const CELL_SESSION_SAVED:String = "cellSessionSaved";
		
		private var _row:int;
		public function get row():int { return _row; }

		private var _col:int;
		public function get col():int { return _col; }
		
		private var _newValue:String;
		public function get newValue():String { return _newValue; }
		
		private var _oldValue:String; 
		public function get oldValue():String { return _oldValue; }
		
		private var _columnName:String;
		public function get columnName():String { return _columnName; }

		public function GridEditorEvent(type:String, row:int, col:int, newValue:String, oldValue:String, columnName:String,  bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_col = col;
			_row = row;
			_newValue = newValue;
			_columnName = columnName;
			_oldValue = oldValue;
		}
	}
}