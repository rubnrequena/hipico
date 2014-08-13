package UI.shared
{
	import mx.graphics.SolidColor;
	
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.SkinnableContainer;
	import spark.primitives.Rect;
	
	import vistas.Modal;
	
	public class ModalSkin extends Modal
	{
		protected const CANCEL_COLOR_BUTTON:uint = 0xFF885F;
		
		protected var bg:Rect;
		protected var view:SkinnableContainer;
		public function ModalSkin(width:int=0,height:int=0)
		{
			super();
			percentHeight = percentWidth = 100;
			setStyle("fontFamily","Verdana");
			
			bg = new Rect;
			bg.fill = new SolidColor(0x000000,0.7);
			bg.percentHeight = bg.percentWidth = 100;
			addElement(bg);
			
			view = new SkinnableContainer;
			view.verticalCenter = view.horizontalCenter = 0;
			view.setStyle("backgroundColor",0xffffff);
			if (width>0) view.width = width;
			if (height>0) view.height = height;
			addElement(view);
		}
		protected function addTitle(text:String,bgColor:uint=0xcccccc,bgAlpha:Number=1):void {
			var bg:Group = new Group;
			bg.percentWidth = 100;
			bg.height = 35;
			
			var r:Rect = new Rect;
			r.percentWidth = 100;
			r.height = 35;
			r.fill = new SolidColor(bgColor,bgAlpha);
			bg.addElement(r);
			
			var lbl:Label = new Label;
			lbl.text = text;
			lbl.height = 35;
			lbl.styleName = "modalTitulo";
			bg.addElement(lbl);
			
			view.addElement(bg);
		}
		override public function set mxmlContent(value:Array):void {
			view.mxmlContent = value;
		}
	}
	
}