package managers{
	import mx.collections.ArrayCollection;
	import valueObjects.NavItem;
	import mx.collections.XMLListCollection;
	import mx.core.IFlexDisplayObject;
	import mx.managers.PopUpManager;
	import mx.core.Application;
	import mx.utils.ObjectUtil;
	
	public class DataManger	{
		//set up public data values
		[Bindable]
		public var sitemapping:String = "dptestbed";
		[Bindable]
		public var navGroups:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var navItems:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var pages:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var addresses:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var uploadFiles:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var uploadFolders:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var uploadNodes:XML = new XML();
		[Bindable]
		public var navXML:XMLListCollection = new XMLListCollection();
		[Bindable]
		public var currentItem:Object = new Object();
		[Bindable]
		public var currentGroup:Number;
		[Bindable]
		public var imagePopUp:IFlexDisplayObject;
		[Bindable]
		public var imageMode:String;
		[Bindable]
		public var currentOrdinal:Number = 1;
		[Bindable]
		public var fieldSave:String = "";
		
		/**
		 * DataManager constructor function
		 */
		public function DataManager():void{
			
		}
		/**
		 * use parent/child relationships in navigation to build xml for tree view
		 */
		public function buildXMLNodes(currentParent:Object):XML{
			var currentNodes:XML = new XML(<node></node>);
			currentNodes.@label = "NavItems";
			for(var index:Number=0; index<navItems.length; index++){
				if(((currentParent == "root") && (navItems.getItemAt(index).parentid == navItems.getItemAt(index).navitemid)) || ((currentParent != "root") && (navItems.getItemAt(index).parentid == currentParent) && (navItems.getItemAt(index).parentid != navItems.getItemAt(index).navitemid))){
					var thisNode:XML = new XML(<node></node>);
					thisNode.@label = navItems.getItemAt(index).navitemname;
					thisNode.@data = navItems.getItemAt(index).navitemid;
					if(fieldSave.length){
						fieldSave += ',' + navItems.getItemAt(index).navitemid;
					}else{
						fieldSave = navItems.getItemAt(index).navitemid
					}
					currentOrdinal++;
					//thisNode.@isBranch="true";
					var hasChildren:Boolean=false;
					var currentID:String = navItems.getItemAt(index).navitemid;
					for(var index2:Number=0; index2<navItems.length; index2++){
						if(navItems.getItemAt(index2).parentid == currentID){
							hasChildren=true;
							break;
						}
					}
					if(hasChildren){
						var subNodes:XML = buildXMLNodes(currentID);
						thisNode.appendChild(subNodes.children());
					}
					currentNodes.appendChild(thisNode);
				}
			}
			return currentNodes;
		}
		
		/**
		 * use parent/child relationships in upload categories to build xml for tree view
		 */
		public function buildUploadXMLNodes(currentParent:Object):XML{
			var currentNodes:XML = new XML(<node></node>);
			currentNodes.@label = "Directories";
			for(var index:Number=0; index<uploadFolders.length; index++){
				if(uploadFolders.getItemAt(index).parentid == currentParent){
					var thisNode:XML = new XML(<node></node>);
					thisNode.@label = uploadFolders.getItemAt(index).uploadcategorytitle;
					thisNode.@data = uploadFolders.getItemAt(index).uploadcategoryid;
					var hasChildren:Boolean=false;
					var currentID:String = uploadFolders.getItemAt(index).uploadcategoryid;
					for(var index2:Number=0; index2<uploadFolders.length; index2++){
						if(uploadFolders.getItemAt(index2).parentid == currentID){
							hasChildren=true;
							break;
						}
					}
					if(hasChildren){
						var subNodes:XML = buildUploadXMLNodes(currentID);
						thisNode.appendChild(subNodes.children());
					}
					currentNodes.appendChild(thisNode);
				}
			}
			return currentNodes;
		}
		
		public function getIndexFromArrayCollection(dataObj:ArrayCollection, fieldname:String, selectedValue:String):Number{
			var thisIndex:Number = -1;
			for(var i:Number= 0; i < dataObj.length; i++){
				if(dataObj.getItemAt(i)[fieldname] == selectedValue){
					thisIndex = i;
					break;
				}
			}
			return thisIndex;
		}
		public function assignImage(file:Object, mode:String):void{
			if(Application.application.dataObj.imagePopUp != null){
				PopUpManager.removePopUp(Application.application.dataObj.imagePopUp);
				Application.application.dataObj.imagePopUp = null
			}
			switch(mode){
				case "off":
					Application.application.navForm.currentItem.offState = file.uploadpath;
					Application.application.navForm.currentItem.imageOff = file.uploadid;
					Application.application.navForm.offImage.source = file.uploadpath;
				break;
				case "on":
					Application.application.navForm.currentItem.onState = file.uploadpath;
					Application.application.navForm.currentItem.imageOn = file.uploadid;
					Application.application.navForm.onImage.source = file.uploadpath;
				break;
				case "at":
					Application.application.navForm.currentItem.atState = file.uploadpath;
					Application.application.navForm.currentItem.imageAt = file.uploadid;
					Application.application.navForm.atImage.source = file.uploadpath;
				break;
			}
			Application.application.navForm.setData(Application.application.navForm.currentItem);
			//trace(ObjectUtil.toString(Application.application.navForm.currentItem));
		}
		public function updateOrdinal():void{
			for(var i:int = 0 ; i < navXML.length ; i++){
				if(fieldSave.length){
					fieldSave += ',' + navXML.getItemAt(i).@data;
				}else{
					fieldSave = navXML.getItemAt(i).@data;
				}
				if(XML(navXML.getItemAt(i)).children().length()){
					walkTree(XML(navXML.getItemAt(i)));
				}
			}
		}
		public function walkTree(thisNode:XML):void{
			var children:XMLList = thisNode.children();
			for(var i:int = 0 ; i < children.length() ; i++){
				if(fieldSave.length){
					fieldSave += ',' + children[i].@data;
				}else{
					fieldSave = children[i].@data;
				}
				if(XML(children[i]).children().length()){
					walkTree(XML(children[i]));
				}
			}
		}
	}// class
}// package