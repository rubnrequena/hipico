package events
{
	import flash.events.Event;
	
	public class Evento extends Event
	{
		private var _data:*;
		public function Evento(type:String,data:*,bubbles:Boolean=false)
		{
			_data = data;
			super(type, bubbles, false);
		}

		public function get data():*
		{
			return _data;
		}

	}
}