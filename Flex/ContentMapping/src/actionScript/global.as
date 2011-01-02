// ActionScript file
import mx.core.Application;
import mx.events.ResizeEvent;
import mx.collections.ArrayCollection;
import mx.utils.ObjectUtil;
import mx.managers.PopUpManager;
import mx.core.IFlexDisplayObject;
import views.SavedNotice;
import flash.events.Event;
import mx.controls.Alert;
import mx.events.DragEvent;
import mx.managers.DragManager;
import mx.core.IUIComponent;
import mx.controls.TabBar;
import mx.effects.Move;
import views.SaveDataDialog;
import mx.events.IndexChangedEvent;
import flash.events.MouseEvent;
import flash.system.Security;
import mx.events.StateChangeEvent;
import mx.events.ChildExistenceChangedEvent;
import mx.core.UIComponent;
import flash.utils.Timer;
import flash.events.TimerEvent;

[Bindable]
public var showMappings:Boolean = false;
[Bindable]
public var imagePopUp:IFlexDisplayObject;
[Bindable]
public var serverURL:String;

public function initApp():void{
	Security.allowDomain('*');
	if((parameters.serverURL != null) && (parameters.serverURL != "")){
		serverURL = parameters.serverURL;
	}else{
		serverURL = "http://idptestbed.d-p.com";
	}
	flash.system.Security.allowDomain(serverURL);
	if((parameters.formobjectid != null) && (parameters.formobjectid != "")){
		dataObj.toolID = parameters.formobjectid;
	}else{
		dataObj.toolID = 103; // page tool
	}
	if((parameters.sitemapping != null) && (parameters.sitemapping != "")){
		dataObj.sitemapping = parameters.sitemapping;
	}else{
		dataObj.sitemapping = "dptestbed";
	}
	if((parameters.cfcpath != null) && (parameters.cfcpath != "")){
		dataObj.cfcpath = parameters.cfcpath;
	}else{
		dataObj.cfcpath = "CFC.coreV5";
	}
	if((parameters.thisInstance != null) && (parameters.thisInstance != "")){
		dataObj.instanceMasterID = Number(parameters.thisInstance);
		currentState = "instanceView";
	}else{
		dataObj.instanceMasterID = 0;
		currentState = "admin";
	}
	if((parameters.titletext != null) && (parameters.titletext != "")){
		dataObj.instanceMasterName=parameters.titletext;
	}
	if((parameters.associaterole != null) && (parameters.associaterole != 0)){
		dataObj.instanceRole = "associate";
		dataObj.headerText = "Objects are contained by mapped items.";
		dataObj.actionText = "contained by";
	}else{
		dataObj.instanceRole = "master";
		dataObj.headerText = "Objects contain mapped items.";;
		dataObj.actionText = "containing";
	}
	// moved from local to corev51 use extension
	dbObj.mappingRO['source']=dataObj.sitemapping+'.components.contentmapping';
	dbObj.formRO.getToolInfo({toolid:dataObj.toolID,dataSource:dataObj.sitemapping});
	// get the rules for this form based on role
	if(dataObj.instanceRole == "master"){
		dbObj.mappingRO.getFormObjects({masterformobjectid:dataObj.toolID});
	}else{
		dbObj.mappingRO.getFormObjects({associateformobjectid:dataObj.toolID});
	}
	dbObj.mappingRO.getAllInstances({formobjectid:dataObj.toolID});
	selectionAcc.addEventListener(ChildExistenceChangedEvent.CHILD_ADD, stateChange);
}
public function stateChange():void{
	trace("sc "+currentState);
	if(currentState == "admin"){
		selectionAcc.getHeaderAt(1).enabled=false;
		selectionAcc.getHeaderAt(2).enabled=false;
	}
}

public function setTabCondition(eventObj:Event):void{
	if(Application.application.dataObj.needToSave && (mainSelectionList.selectedIndex>=0) && (ruleListing.selectedIndex>=0)){
		dataObj.selectionEvent = eventObj;
		displayDialog();
		return;
	}
	if((String(eventObj.target.id) == "mainSelectionList") && (mainSelectionList.selectedIndex>=0)){
		dataObj.currentMasterIndex = mainSelectionList.selectedIndex;
		selectionAcc.getHeaderAt(1).enabled = true;
		selectionAcc.selectedIndex = 1;
		selectionAcc.getHeaderAt(0).label = 'Selection: "'+mainSelectionList.selectedItem[dataObj.nameFieldMaster]+'"';
	}
	if((mainSelectionList.selectedIndex>=0) && (ruleListing.selectedIndex>=0)){
		showMappings = true;
		dataObj.instanceCase = "associate";
		if(dataObj.instanceRole == "master"){
			dbObj.mappingRO.getMappedInstanceIDs({masterFormobjectid:dataObj.toolID,masterForminstanceid:mainSelectionList.selectedItem[dataObj.idFieldMaster],associateFormobjectid:ruleListing.selectedItem.formobjectid});
		}else{
			dbObj.mappingRO.getMappedInstanceIDs({masterFormobjectid:ruleListing.selectedItem.formobjectid,associateForminstanceid:mainSelectionList.selectedItem[dataObj.idFieldMaster],associateFormobjectid:dataObj.toolID});
		}
		if(String(eventObj.target.id) == "ruleListing"){
			selectionAcc.getHeaderAt(2).enabled = true;
			dataObj.currentRuleIndex = ruleListing.selectedIndex;
			assigmentBox.label = assigmentBox.label.replace("place",ruleListing.selectedItem.formobjectname);
			selectionAcc.selectedIndex = 2;
			if(dataObj.instanceRole == "master"){
				selectionAcc.getHeaderAt(1).label = 'Assigned Content Type: "'+ruleListing.selectedItem.formobjectname+'"';
			}else{
				selectionAcc.getHeaderAt(1).label = 'Assign to Page Type: "'+ruleListing.selectedItem.formobjectname+'"';
			}
		}
	}else{
		showMappings = false;
	}
}
public function getInstancesForAssignment():void{
	if(ruleListingCB.selectedIndex>0){
		dataObj.instanceCase = "associate";
		if(dataObj.instanceRole == "master"){
			dbObj.mappingRO.getMappedInstanceIDs({masterFormobjectid:dataObj.toolID,masterForminstanceid:dataObj.instanceMasterID,associateFormobjectid:ruleListingCB.selectedItem.formobjectid});
		}else{
			dbObj.mappingRO.getMappedInstanceIDs({masterFormobjectid:ruleListingCB.selectedItem.formobjectid,associateForminstanceid:dataObj.instanceMasterID,associateFormobjectid:dataObj.toolID});
		}
	}else if(ruleListingCB.selectedIndex==0){
		dataObj.availableDataList = new ArrayCollection();
	}
}
private var newData:Boolean = true;
public function widthAdj(eventObj:Event):void{
	if(mainSelectionList.dataProvider.length > 0 && newData){
		mainSelectionList.width=mainSelectionList.width*1.2;
		newData = false;
	}
}
private function sendMappings():void{
	var MappingData:Object = new Object();
	if(dataObj.instanceRole == "master"){
		MappingData.masterformobjectid = dataObj.toolID;
	}else{
		MappingData.associateformobjectid = dataObj.toolID;
	}
	if((currentState == null) || (currentState == "admin")){
		if(dataObj.instanceRole == "master"){
			MappingData.associateformobjectid = ruleListing.dataProvider.getItemAt(dataObj.currentRuleIndex).formobjectid;
			MappingData.masterforminstanceid = mainSelectionList.dataProvider.getItemAt(dataObj.currentMasterIndex)[dataObj.idFieldMaster];
		}else{
			MappingData.masterformobjectid = ruleListing.dataProvider.getItemAt(dataObj.currentRuleIndex).formobjectid;
			MappingData.associateforminstanceid = mainSelectionList.dataProvider.getItemAt(dataObj.currentMasterIndex)[dataObj.idFieldMaster];
		}
	}else{
		if(dataObj.instanceRole == "master"){
			MappingData.associateformobjectid = ruleListingCB.selectedItem.formobjectid;
			MappingData.masterforminstanceid = dataObj.instanceMasterID;
		}else{
			MappingData.masterformobjectid = ruleListingCB.selectedItem.formobjectid;
			MappingData.associateforminstanceid = dataObj.instanceMasterID;
		}
	}
	
	var selectionMapList:String = "";
	for(var i:Number=0 ; i<dataMapping.dataProvider.length ; i++){
		if(dataMapping.dataProvider.getItemAt(i).isMapped){
			if(selectionMapList.length){
				selectionMapList +=","+dataMapping.dataProvider.getItemAt(i)[dataObj.idFieldAssociate];
			}else{
				selectionMapList = dataMapping.dataProvider.getItemAt(i)[dataObj.idFieldAssociate];
			}
		}
	}
	if(dataObj.instanceRole == "master"){
		MappingData.associateforminstanceidList = selectionMapList;
	}else{
		MappingData.masterforminstanceidList = selectionMapList;
	}
	if(imagePopUp != null){
		PopUpManager.removePopUp(imagePopUp);
		imagePopUp = null;
	}
	imagePopUp=PopUpManager.createPopUp(this, views.SavedNotice, false);
	imagePopUp.x = 200;
	imagePopUp.y = 100;
	if(selectionMapList.length){
		dbObj.mappingRO.insertUpdateMappings(MappingData);
	}else{
		dbObj.mappingRO.deleteMappings(MappingData);
	}
	Application.application.dataObj.needToSave = false;
}
public function shuffle(direction:String):void{
	var newOrderedOptions:ArrayCollection;
	if(dataMapping.selectedIndex >= 0){
		var selection:Number;
		switch(direction){
			case "up":
				selection=(dataMapping.selectedIndex-1)>0?(dataMapping.selectedIndex-1):0;
				newOrderedOptions=dataObj.shuffleUp(dataMapping.dataProvider as ArrayCollection,dataMapping.selectedIndex);
			break;
			case "down":
				selection=(dataMapping.selectedIndex+1)==dataMapping.dataProvider.length?(dataMapping.dataProvider.length-1):(dataMapping.selectedIndex+1);
				newOrderedOptions=dataObj.shuffleDown(dataMapping.dataProvider as ArrayCollection,dataMapping.selectedIndex);
			break;
			default:
				selection=dataMapping.selectedIndex;
				newOrderedOptions=dataObj.availableDataList;
			break;
		}
		dataMapping.dataProvider=newOrderedOptions;
		dataMapping.selectedIndex=selection;
		dataMapping.selectedIndices=[selection];
	}
}
public function updateChecks():void{
	for(var i:Number=0 ; i<dataObj.availableDataList.length ; i++){
		dataObj.availableDataList.getItemAt(i).isMapped = selectionCB.selected;
	}
	if((selectionCB != null) && (currentState == null) || (currentState == "admin")){
		selectionCB.selected?selectionCB.label="UnCheck All "+Application.application.ruleListing.selectedItem.formobjectname+"s":selectionCB.label="Check All "+Application.application.ruleListing.selectedItem.formobjectname+"s";
	}else{
		selectionCB.selected?selectionCB.label="UnCheck All "+Application.application.ruleListingCB.selectedItem.formobjectname+"s":selectionCB.label="Check All "+Application.application.ruleListingCB.selectedItem.formobjectname+"s";
	}
	dataMapping.dataProvider = dataObj.availableDataList;
}
public function manageTabs(eventObj:Object):void{
	if(!showMappings){
		selectionManager.selectedIndex = 0;
	}
}
public function whatIsThis():void{
	trace("yo"+this);
}
public function displayDialog():void{
	if(imagePopUp != null){
		PopUpManager.removePopUp(imagePopUp);
		imagePopUp = null;
	}
	imagePopUp=PopUpManager.createPopUp(this, views.SaveDataDialog, false);
	imagePopUp.x = 80;
	imagePopUp.y = 100;
}
public function respondToDialog():void{
	
}
public function manageFolds():void{
	if(!(mainSelectionList.selectedIndex>=0) && (selectionAcc.selectedIndex > 0)){
		var t:Timer = new Timer(500,1)
		t.addEventListener(TimerEvent.TIMER_COMPLETE,changeback);
//		t.start();
	}else if((selectionAcc.selectedIndex == 2) && !(ruleListing.selectedIndex >=0 ) && (selectionAcc.selectedIndex > 1)){
		var tt:Timer = new Timer(500,1)
		tt.addEventListener(TimerEvent.TIMER_COMPLETE,changeback2);
//		t.start();
	}
}
public function changeback(eventObj:Object):void{
	selectionAcc.selectedIndex = 0;
}
public function changeback2(eventObj:Object):void{
	selectionAcc.selectedIndex = 1;
}