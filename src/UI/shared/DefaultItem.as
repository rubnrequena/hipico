package UI.shared
{
	import spark.components.Label;
	import spark.components.supportClasses.ItemRenderer;
	import spark.layouts.HorizontalLayout;
	
	public class DefaultItem extends ItemRenderer
	{
		protected var columnas:Array = [];
		protected var labels:Vector.<Label>;
		private var i:int;
		private var len:int;

		public function DefaultItem() {
			super();
			percentWidth = 100;
			mouseChildren=false;
			layout = new HorizontalLayout;
		}
		override protected function createChildren():void {
			super.createChildren();
			len = columnas.length;
			labels = new <Label>[]; var l:Label; var p:String;
			for (i = 0; i < len; i++) {
				l = new Label;
				l.styleName = "defaultItem";
				l.height = 30;
				for (p in columnas[i]) {
					l[p]=columnas[i][p];
				}
				labels.push(l);
				addElement(l);
			}
		}
		
		override public function set data(value:Object):void {
			super.data = value;
			if (value) {
				for (i = 0; i < len; i++) {
					labels[i].text = value[columnas[i].name];	
				}
			}
		}
	}
}