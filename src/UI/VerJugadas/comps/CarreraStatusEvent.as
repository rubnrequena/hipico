package UI.VerJugadas.comps
{
	import flash.events.Event;
	
	public class CarreraStatusEvent extends Event
	{
		public static const STATUS_CHANGE:String = "statusChange";
		
		protected var _banca:int;
		protected var _carrera:Object;
		protected var _status:Boolean;
		protected var _tipo:String;
		public function CarreraStatusEvent(type:String, banca:int, carrera:Object, status:Boolean, tipo:String)
		{
			super(type, false,false);
			_banca = banca;
			_carrera = carrera;
			_status = status;
			_tipo = tipo;
		}

		public function get tipo():String
		{
			return _tipo;
		}

		public function get status():Boolean
		{
			return _status;
		}

		public function get carrera():Object
		{
			return _carrera;
		}

		public function get banca():int
		{
			return _banca;
		}

	}
}