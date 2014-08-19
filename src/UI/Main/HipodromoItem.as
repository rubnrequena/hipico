package UI.Main
{
	import UI.shared.DefaultItem;
	
	public class HipodromoItem extends DefaultItem
	{
		public function HipodromoItem()
		{
			super();
			columnas = [
				{name:"Hipodromo",percentWidth:100},
				{name:"Ganador",width:30}
			];
		}
	}
}