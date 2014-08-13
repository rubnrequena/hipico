package Comps.verJugadas.Remate.com
{
	import flash.events.Event;
	
	import mx.graphics.SolidColorStroke;
	
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.VGroup;
	import spark.primitives.Line;
	
	public class Headers extends Group
	{
		public var casillas:int;
		public var montoWidth:int;
		public var montoLabel:String;
		public var mesaWith:int;
		public var mesaLabel:String;
		
		public function Headers() {
			super();
		}
		
		public function drawHeaders():void {
			removeAllElements();
			
			percentHeight = 100;
			percentWidth = 100;
			setStyle("verticalAling","middle");
			
			var lbl:Label;
			
			lbl = new Label;
			lbl.height = 40;
			lbl.text = "#";
			lbl.width = 45;
			lbl.setStyle("textAlign","center");
			lbl.setStyle("verticalAlign","bottom");
			addElement(lbl);
			
			lbl = new Label;
			lbl.text = "Ejemplar";
			lbl.height = 40;
			lbl.x = 50;
			lbl.setStyle("verticalAlign","bottom");
			addElement(lbl);
			
			var cs:HGroup =new HGroup;
			
			cs.right = 0;
			cs.height = 40;
			cs.gap = 0;
			for (var i:int = 0; i < casillas; i++) {
				cs.addElement(buildCasilla(i+1,montoWidth,mesaWith,montoLabel,mesaLabel));	
			}
			addElement(cs);
		}
		
		protected function buildCasilla (casilla:int,montoWidth:int,mesaWith:int,montoLabel:String,mesaLabel:String):Group {
			var g:Group = new Group;			
			var lbl:Label; var line:Line;
			g.height = 40;
			
			var stroke:SolidColorStroke = new SolidColorStroke(0,1,0.4);
			
			lbl = new Label;
			lbl.text = "CASILLA"+casilla;
			lbl.setStyle("color","#FFFFFF");
			lbl.setStyle("backgroundColor","#527ab2");
			lbl.setStyle("textAlign","center");
			lbl.setStyle("paddingTop",2);
			lbl.height = 20;
			lbl.percentWidth = 100;
			g.addElement(lbl);
			
			lbl = new Label;
			lbl.text = "MONTO";
			lbl.setStyle("color","#FFFFFF");
			lbl.setStyle("textAlign","center");
			lbl.setStyle("backgroundColor","#527ab2");
			lbl.setStyle("paddingTop",2);
			lbl.setStyle("fontSize",14);
			lbl.height = 20;
			lbl.y = 20;
			lbl.width = montoWidth;
			g.addElement(lbl);
			
			lbl = new Label;
			lbl.text = "JUGADOR";
			lbl.setStyle("color","#FFFFFF");
			lbl.setStyle("backgroundColor","#527ab2");
			lbl.setStyle("textAlign","center");
			lbl.setStyle("paddingTop",2);
			lbl.setStyle("fontSize",14);
			lbl.height = 20;
			lbl.y = 20;
			lbl.x = montoWidth;
			lbl.width = mesaWith;
			g.addElement(lbl);
			
			line = new Line;
			line.width = 0;
			line.height = 23;
			line.x = montoWidth;
			line.y = 17;
			line.stroke = stroke;
			g.addElement(line);			
			
			line = new Line;
			line.width = 0;
			line.height = 40;
			line.stroke = stroke;
			line.x = 0;
			g.addElement(line);
			
			line = new Line;
			line.width = (montoWidth+mesaWith)-1;
			line.height = 0;
			line.y = 17;
			line.stroke = stroke;
			g.addElement(line);
			
			return g;
		}
	}
}