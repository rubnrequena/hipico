/**
 * Created by Ruben on 25-03-2014.
 */
package UI.VerJugadas.comps.ganador {
import appkit.responders.NResponder;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.core.IVisualElementContainer;
import mx.events.FlexEvent;
import mx.events.SandboxMouseEvent;

public class DividendoPopUp extends DividendoPopUpUI {
    public static const DIVIDENDO:String="popUp_dividendo";

    public function DividendoPopUp(empate:Boolean=false) {
        super();
        NResponder.addNative(this,FlexEvent.CREATION_COMPLETE,onCreationComplete,1);
        NResponder.addNative(this,Event.REMOVED_FROM_STAGE,onRemoved,1);
        currentState = empate?"empate":"normal";
    }
		
    protected function onCreationComplete(event:FlexEvent):void {
        NResponder.addNative(dividendoButton,MouseEvent.CLICK,dividendoButton_click);
        NResponder.addNative(dividendoInput,FlexEvent.ENTER,dividendoIntputs_enter);
		NResponder.addNative(cerrarButton,MouseEvent.CLICK,cerrar_click);
        if (currentState=="empate")
            NResponder.addNative(dividendoInput2,FlexEvent.ENTER,dividendoIntputs_enter);

        dividendoInput.setFocus();
    }
	
	private function cerrar_click(e:MouseEvent):void {
		(parent as IVisualElementContainer).removeElement(this);
	}
	
    protected function dividendoIntputs_enter (event:FlexEvent):void {
        if (currentState=="normal") {
            if (dividendoInput.text && !isNaN(Number(dividendoInput.text))) {
                NResponder.dispatch(DIVIDENDO,[Number(dividendoInput.text)],this);
            } else {

            }
        } else {
            if (event.target.id=="dividendoInput") {
                dividendoInput2.setFocus();
                return;
            } else {
                if (dividendoInput.text && !isNaN(Number(dividendoInput.text))) {
                    if (dividendoInput2.text && !isNaN(Number(dividendoInput2.text))) {
                        NResponder.dispatch(DIVIDENDO, [Number(dividendoInput.text), Number(dividendoInput2.text)], this);
                    }
                }
            }
        }
        (parent as IVisualElementContainer).removeElement(this);
    }

    protected function dividendoButton_click(event:MouseEvent):void {
        if (currentState=="normal") {
            NResponder.dispatch(DIVIDENDO,[Number(dividendoInput.text)],this);
        } else {
            NResponder.dispatch(DIVIDENDO,[Number(dividendoInput.text),Number(dividendoInput2.text)],this);
        }
        (parent as IVisualElementContainer).removeElement(this);
    }

    protected function onRemoved(event:Event):void {
        NResponder.remove(MouseEvent.CLICK,dividendoButton_click,dividendoButton);
        NResponder.remove(FlexEvent.ENTER,dividendoIntputs_enter,dividendoInput);
        NResponder.remove(FlexEvent.ENTER,dividendoIntputs_enter,dividendoInput2);
    }
}
}
