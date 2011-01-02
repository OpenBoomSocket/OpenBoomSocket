// ActionScript file
import mx.collections.ArrayCollection;
import mx.containers.Accordion;
import mx.core.IFlexDisplayObject;
import mx.managers.PopUpManager;

import views.ConfigurationPod;
import views.ToolList;

[Bindable]
public var sitemapping:String = "dp07prsa";
[Bindable]
public var serverURL:String = "http://idp07prsa.d-p.com";
public var configWin:IFlexDisplayObject;
[Bindable]
public var initialList:String = "100013,100015,100012,100020,100011,100014";

[Event (name="BuildPods")]

private function initApp():void{
	if(parameters.sitemapping != null){
		sitemapping = parameters.sitemapping;
	}
	if(parameters.serverURL != null){
		serverURL = parameters.serverURL;
	}
	if(parameters.initialList != null){
		initialList = parameters.initialList;
		dataObj.toolIDs = initialList;
	}
	if(initialList.length){
		rmtDBObj.formlistRO.getFormData({selectClause:"formobjectid,datatable,editFieldKeyValue",fromClause:"formobject",whereClause:"formobjectid in("+initialList+")"});
	}
	this.addEventListener("BuildPods",buildPods);
	showConfiguration();
	configWin.visible = false;
	rmtDBObj.catlistRO.getFormDataFlex({toolid:108,selectClause:dataObj.catSelect,fromClause:dataObj.catFrom,whereClause:dataObj.catWhere,dataSource:sitemapping});
	rmtDBObj.formlistRO.getToolInfo({permissionbased:1});
}
private function showConfiguration():void{
	if(configWin == null){
		configWin = PopUpManager.createPopUp(this,ConfigurationPod);
		configWin.x = 100;
		configWin.y = 80;
	}
}
private function buildPods(event:Object):void{
	var getAcc:Accordion = ConfigurationPod(configWin).catAcc;
	var tempSelectRaw:ArrayCollection;
	dataObj.toolIDs = "";
	dataObj.selectedTools.removeAll();
	for(var i:uint=0 ; i<getAcc.numChildren ; i++){
		tempSelectRaw = ToolList(getAcc.getChildAt(i)).dataList;
		for(var j:uint=0 ; j<tempSelectRaw.length ; j++){
			if(tempSelectRaw.getItemAt(j).selected){
				dataObj.selectedTools.addItem(tempSelectRaw.getItemAt(j));
				if(dataObj.toolIDs.length >0){
					dataObj.toolIDs += ",";
				}
				dataObj.toolIDs += tempSelectRaw.getItemAt(j).formobjectid;
			}
		}
	}
	dataObj.podList = new ArrayCollection();
	fillpods(dataObj.selectedTools);
	rmtDBObj.toolsRO.writeToolList({toolList:dataObj.toolIDs});
}
public function fillpods(toolList:ArrayCollection):void{
	var keys:String;
	
	for(var k:uint = 0 ; k<toolList.length ;k++){
		if(toolList.getItemAt(k).editFieldKeyValue){
			keys=toolList.getItemAt(k).editFieldKeyValue;
		}else{
			keys=toolList.getItemAt(k).editfieldkeyvalue
		}
		rmtDBObj.formdataRO.getFormDataFlex({toolid:Number(toolList.getItemAt(k).formobjectid),selectClause:dataObj.toolSelect+"["+toolList.getItemAt(k).datatable+"].datecreated,"+toolList.getItemAt(k).datatable+"id,"+keys,fromClause:toolList.getItemAt(k).datatable,orderVars:"["+toolList.getItemAt(k).datatable+"]."+dataObj.toolOrder,dataSource:sitemapping});
	}
}
private function updateListFile():void{
	dataObj.toolIDs = "";
	for(var i:uint=0 ; i < podList.dataProvider.length ; i++){
		if(dataObj.toolIDs.length > 0){
			dataObj.toolIDs += ',';
		}
		dataObj.toolIDs += podList.dataProvider.getItemAt(i).toolID;
	}
	rmtDBObj.toolsRO.writeToolList({toolList:dataObj.toolIDs});
}
