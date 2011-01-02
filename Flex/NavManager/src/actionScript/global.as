// ActionScript file
import mx.core.Application;

[Bindable]
public var serverURL:String;
[Bindable]
public var sitemapping:String;

[Embed(source="/assets/linkButton.jpg")]
public var LinkButton:Class;

[Embed(source="/assets/icon_addGroup.gif")]
public var AddGroupButton:Class;

[Embed(source="/assets/icon_editGroup.gif")]
public var EditGroupButton:Class;

[Embed(source="/assets/icon_addItem.gif")]
public var AddItemButton:Class;

public function initApp():void{
	Security.allowDomain('*');
	if((parameters.serverURL != null) && (parameters.serverURL != "")){
		serverURL = parameters.serverURL;
	}else{
		serverURL = "http://iopensource.d-p.com";
	}
	if((parameters.sitemapping != null) && (parameters.sitemapping != "")){
		sitemapping = parameters.sitemapping;
	}else{
		sitemapping = "dpopensource";
	}
	flash.system.Security.allowDomain(serverURL);
	Application.application.dbManager.navRO.getNavGroups();
	Application.application.dbManager.navRO.getPages();
	Application.application.dbManager.navRO.getnavAddresses();
	Application.application.dbManager.uploadRO.getUploadCategories();
	//navTreePod.navTree.setStyle("defaultLeafIcon",LinkButton);
	//navTreePod.navTree.setStyle("folderClosedIcon",LinkButton);
	//navTreePod.navTree.setStyle("folderOpenIcon",LinkButton);
}