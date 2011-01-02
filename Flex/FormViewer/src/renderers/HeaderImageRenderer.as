package renderers
{
	import mx.controls.Image;
	import mx.containers.Canvas;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import mx.events.FlexEvent;

	public class HeaderImageRenderer extends Canvas
	{
		// Define the constructor and set properties.
		[Event(name="toggleChecked")]
		[Embed(source="/assets/UIelements.swf", symbol="icon_trash")]
		private var GBcanIcon:Class
		private var thisImage:Image
		
		public function HeaderImageRenderer(){
			thisImage = new Image();
			this.addChild(thisImage);
			this.invalidateDisplayList();
			thisImage.source=new GBcanIcon();
			this.toolTip = "Check Items below for deletion";
			this.addEventListener(MouseEvent.CLICK,dispatchToggle);
			this.addEventListener(FlexEvent.CREATION_COMPLETE, updateCB);
			this.buttonMode = true;
			this.useHandCursor = true;
		}

		// Override the set method for the data property.
		override public function set data(value:Object):void {
			
			super.data = value;
			super.invalidateDisplayList();
		}
		private function updateCB(event:Object):void{
			//Alert.show(this.width.toString());
			thisImage.setStyle('left',this.width/2-9);
		}
		private function dispatchToggle(event:Object):void{
			var newEvt:Event = new Event("toggleChecked",true);
			this.dispatchEvent(newEvt);
		}
	}
}