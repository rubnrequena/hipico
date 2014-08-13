package UI.Main
{
	import UI.shared.ModalSkin;
	
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	import mx.events.EffectEvent;
	
	import spark.effects.Animate;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
	
	public class PanelAcercaDe extends ModalSkin
	{
		private var acercaDe:PanelAcercaDeUI;
		
		public function PanelAcercaDe()
		{
			super();
			
			acercaDe = new PanelAcercaDeUI;
			view.addElement(acercaDe);
			acercaDe.btnAtras.addEventListener(MouseEvent.CLICK,btnAtras_click);
			
			anim = new Animate(view);
			anim.duration = 500;
			mp = new Vector.<MotionPath>;
			mp.push(new SimpleMotionPath("z",200,0));
			mp.push(new SimpleMotionPath("alpha",0,1));
			anim.motionPaths = mp;
			anim.play();
		}
		
		protected function btnAtras_click(event:MouseEvent):void {
			closeModal(Alert.OK);
		}
		private var anim:Animate;
		private var mp:Vector.<MotionPath>;

		override public function closeModal(detalle:int=-1, data:*=null):void {
			anim = new Animate(view);
			anim.disableLayout=true;
			mp = new Vector.<MotionPath>;
			mp.push(new SimpleMotionPath("z",null,-200));
			mp.push(new SimpleMotionPath("alpha",1,0));
			anim.motionPaths = mp;
			anim.addEventListener(EffectEvent.EFFECT_END,closeAnim_end);
			anim.play();
		}
		
		protected function closeAnim_end(event:EffectEvent):void {
			anim.removeEventListener(EffectEvent.EFFECT_END,closeAnim_end);
			anim=null; mp=null;
			super.closeModal();
		}
	}
}