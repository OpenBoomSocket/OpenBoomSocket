package renderers
{
	import mx.controls.CheckBox;
	import mx.containers.Canvas;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	import flash.events.Event;
	import mx.events.FlexEvent;

	public class CheckBoxRenderer extends Canvas
	{
		[Event(name="deleteChecked")]
		private var thisCB:CheckBox
		// Define the constructor and set properties.
		public function CheckBoxRenderer(){
			
			thisCB = new CheckBox();
			this.addChild(thisCB);
			this.invalidateDisplayList();
			this.percentWidth = 100;
			thisCB.setStyle('left',this.width-5);
			thisCB.setStyle('top',2);
			thisCB.addEventListener(Event.CHANGE, throwEvent);
			this.addEventListener(FlexEvent.CREATION_COMPLETE, updateCB);
		}
		private function throwEvent(event:Object):void{
			super.data.markForDeletion = thisCB.selected;
			var newEvt:Event = new Event("deleteChecked",true);
			this.dispatchEvent(newEvt);
		}
		private function updateCB(event:Object):void{
			//Alert.show(this.width.toString());
			thisCB.setStyle('left',this.width/2-8);
			thisCB.setStyle('top',2);
		}
		// Override the set method for the data property.
		override public function set data(value:Object):void {
			super.data = value;
			if(value.markForDeletion == undefined || value.markForDeletion == null){
				value.markForDeletion = false;
				super.data.markForDeletion = value.markForDeletion;
			}
			this.thisCB.selected = value.markForDeletion;
			super.invalidateDisplayList();
		}
	}
}