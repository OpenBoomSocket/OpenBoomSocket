package renderers
{
	import mx.controls.Label;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;

	public class BooleanRenderer extends Label
	{
		// Define the constructor and set properties.
		public function BooleanRenderer(){
			
		}

		// Override the set method for the data property.
		override public function set data(value:Object):void {
			super.data = value;
			if(value!=null){
				switch(String(value[DataGridListData(listData).dataField])) {
					case "true":
						text = "Yes";
						setStyle("color", 0x006600);
					break;
					case "false":
						text = "No";
						setStyle("color", 0x660000);
					break;
					default:
						text = "-";
					break;
				}
			}
			super.invalidateDisplayList();
		}
	}
}