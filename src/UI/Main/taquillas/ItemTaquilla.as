package UI.Main.taquillas
{
	import UI.shared.DefaultItem;
	
	public class ItemTaquilla extends DefaultItem
	{
		public function ItemTaquilla() {
			super();
			columnas = [
				{name:"taquillaID",width:100},
				{name:"nombre",percentWidth:100},
				{name:"bancaString",percentWidth:100},
				{name:"tipoString",width:150},
				{name:"activaString",width:150}
			];
		}
	}
}