package renderers
{
	import mx.controls.ComboBox;
	import mx.core.Application;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	import mx.collections.ArrayCollection;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	public class UsageRenderer extends ComboBox
	{
		// Define the constructor and set properties.
		public function UsageRenderer(){
			this.labelField= "pagename";
			this.addEventListener(Event.CHANGE,viewPage);
		}

		// Override the set method for the data property.
		override public function set data(value:Object):void {
			super.data = value;
			if(value!=null){
				var arrayDP:ArrayCollection = new ArrayCollection();
				for(var i:Number=0 ; i<value[DataGridListData(listData).dataField].serverInfo.initialData.length ; i++){
					var item:Object = new Object();
					item.pageid = value[DataGridListData(listData).dataField].serverInfo.initialData[i][0];
					if(value[DataGridListData(listData).dataField].serverInfo.initialData[i][1] != null){
						item.pagename = value[DataGridListData(listData).dataField].serverInfo.initialData[i][1];
					}else{
						item.pagename = "";
						item.pageid = 0;
					}
					arrayDP.addItem(item)
				}
				if(arrayDP.getItemAt(0).pagename != ""){
					var headeritem:Object = new Object();
					headeritem.pagename = "View Pages";
					headeritem.pageid = 0;
					arrayDP.addItemAt(headeritem,0);
				}
				dataProvider = arrayDP;
				this.labelField = "pagename";
			}
			super.invalidateDisplayList();
		}
		private function viewPage(eventObj:Event):void{
			if(this.selectedItem.pageid > 0){
				var thisRequest:URLRequest = new URLRequest(Application.application.serverURL+"/"+"admintools/index.cfm?i3currenttool=124&editpageid="+this.selectedItem.pageid);
				navigateToURL(thisRequest,"_self");
			}
		}
	}
}