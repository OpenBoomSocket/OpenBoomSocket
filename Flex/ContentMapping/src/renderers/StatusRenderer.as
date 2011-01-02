package renderers
{
	import mx.controls.Label;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;

	public class StatusRenderer extends Label
	{
		// Define the constructor and set properties.
		public function StatusRenderer(){
			
		}

		// Override the set method for the data property.
		override public function set data(value:Object):void {
			super.data = value;
			if(value!=null){
				switch(String(value[DataGridListData(listData).dataField])) {
					case "Published":
						text = value[DataGridListData(listData).dataField];
						setStyle("color", 0x006600);
					break;
					case "Pending":
						text = value[DataGridListData(listData).dataField];
						setStyle("color", 0xFF9933);
					break;
					case "Approved":
						text = value[DataGridListData(listData).dataField];
						setStyle("color", 0x00CCCC);
					break;
					case "Approved & Scheduled":
						text = value[DataGridListData(listData).dataField];
						setStyle("color", 0x993399);
					break;
					case "Rejected":
						text = value[DataGridListData(listData).dataField];
						setStyle("color", 0xCC0000);
					break;
					default:
						text = value[DataGridListData(listData).dataField];
						setStyle("color", 0x000000);
					break;
				}
			}
			super.invalidateDisplayList();
		}
	}
}