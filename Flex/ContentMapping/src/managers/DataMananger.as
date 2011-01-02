package managers
{
	import mx.collections.ArrayCollection;
	import valueobjects.FormItem;
	import valueobjects.Form;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.formatters.DateFormatter;
	import mx.controls.Alert;
	import renderers.*;
	import mx.core.ClassFactory;
	import mx.core.Application;
	import mx.utils.ObjectUtil;
	import flash.events.Event;
	
	public class DataMananger
	{
		//set up public data values
		[Bindable]
		public var sitemapping:String = "dp06sis";
		[Bindable]
		public var cfcpath:String = "CFC.corve5";
		[Bindable]
		public var toolID:Number = 100000;
		[Bindable]
		public var toolName:String = "ToolName";
		[Bindable]
		public var nameFieldMaster:String = "name";
		[Bindable]
		public var idFieldMaster:String = "id";
		[Bindable]
		public var masterToolData:Object = new Object();
		[Bindable]
		public var nameFieldAssociate:String = "name";
		[Bindable]
		public var idFieldAssociate:String = "id";
		[Bindable]
		public var associateToolData:Object = new Object();
		[Bindable]
		public var mainListData:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var availableDataList:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var mappedDataList:Array = new Array();
		[Bindable]
		public var ruleSet:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var associateID:Number = 100000;
		[Bindable]
		public var instanceCase:String = "master";
		public var dbTools:ArrayCollection;
		[Bindable]
		public var toolset:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var fieldList:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var dataFilterList:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var instanceMaster:Object ={name:"instance name",id:0};
		[Bindable]
		public var instanceMasterID:Number = new Number();
		[Bindable]
		public var instanceMasterName:String = "";
		[Bindable]
		public var instanceRole:String = "associate";
		[Bindable]
		public var headerText:String;
		[Bindable]
		public var actionText:String;
		[Bindable]
		public var needToSave:Boolean=false;
		[Bindable]
		public var selectionEvent:Event;
		[Bindable]
		public var currentMasterIndex:Number;
		[Bindable]
		public var currentRuleIndex:Number;
		
		/**
		 * DataManager constructor function
		 */
		public function DataManager():void{
			
		}
		/**
		 * manage ordinal type shuffle 
		 */
		public function shuffleUp(originalArray:ArrayCollection, index:Number):ArrayCollection{
			var tempArray:ArrayCollection = new ArrayCollection();
			if(index>0){
				for(var i:Number=0 ; i<originalArray.length ; i++){
					if(i == (index-1)){
						tempArray.addItem(originalArray.getItemAt(index));
					}else if(i == index){
						tempArray.addItem(originalArray.getItemAt(index-1));
					}else{
						tempArray.addItem(originalArray.getItemAt(i));
					}
					
				}
			}else{
				tempArray=originalArray;
			}
			return tempArray;
		}
		
		/**
		 * manage ordinal type shuffle 
		 */
		public function shuffleDown(originalArray:ArrayCollection, index:Number):ArrayCollection{
			var tempArray:ArrayCollection = new ArrayCollection();
			if(index<(originalArray.length-1)){
				for(var i:Number=0 ; i<originalArray.length ; i++){
					if(i == (index+1)){
						tempArray.addItem(originalArray.getItemAt(index));
					}else if(i == index){
						tempArray.addItem(originalArray.getItemAt(index+1));
					}else{
						tempArray.addItem(originalArray.getItemAt(i));
					}
				}
			}else{
				tempArray=originalArray;
			}
			return tempArray;
		}
		public function buildDBArrayCollection(dbAC:ArrayCollection):void{
			toolset = new ArrayCollection();
			dbTools = new ArrayCollection();
			for(var formIndex:Number = 0 ; formIndex < 1 ; formIndex++){
				var form:valueobjects.Form = new valueobjects.Form();
				form.formname = dbAC.getItemAt(formIndex).formobjectname;
				form.formnotes = "";
				form.formid = dbAC.getItemAt(formIndex).formobjectid;
				form.items = new ArrayCollection();
				for each(var itemNode:XML in XMLList(dbAC.getItemAt(formIndex).datadefinition).children()){
					var itemObj:valueobjects.FormItem = new valueobjects.FormItem();
					for each(var itemValueNode:XML in itemNode.children()){
						itemObj[itemValueNode.name()] = itemValueNode.text()
					}
					form.items.addItem(itemObj);
				}
				dbTools.addItem(form);
			}
			for(var index:Number=0 ; index<dbTools.length ; index++){
				toolset.addItem(dbTools.getItemAt(index));
			}
			buildDG(String(dbAC.getItemAt(0).editFieldKeyValue2).split(','));
		}
		private function buildDG(fieldArray:Array):void{
			// reset datagrid
			var tempCols:Array = new Array();
			if(Application.application.dataMapping.columns.length>2){
				if(instanceCase == "associate"){
					tempCols[0]=Application.application.dataMapping.columns[0];
					tempCols[1]=Application.application.dataMapping.columns[1];
					Application.application.dataMapping.columns = tempCols;
				}else{
					tempCols[0]=Application.application.mainSelectionList.columns[0];
					Application.application.mainSelectionList.columns = tempCols;
				}
			}
			for(var index:Number=0 ; index<fieldArray.length ; index++){
				if((String(idFieldAssociate).toLowerCase().indexOf(String(fieldArray[index]).toLowerCase())== -1) && (String(nameFieldAssociate).toLowerCase().indexOf(String(fieldArray[index]).toLowerCase())== -1)
					&& (String(idFieldMaster).toLowerCase().indexOf(String(fieldArray[index]).toLowerCase())== -1) && (String(nameFieldMaster).toLowerCase().indexOf(String(fieldArray[index]).toLowerCase())== -1)){
					var thisDGC:DataGridColumn = new DataGridColumn();
					var thisFieldListItem:Object = new Object();
					thisDGC.dataField = String(fieldArray[index]).toLowerCase();
					if(String(fieldArray[index]).toLowerCase().indexOf("date") != -1){
						dateFormat(String(fieldArray[index]).toLowerCase());
						if(String(fieldArray[index]).toLowerCase().indexOf("datecreated") != -1){
							thisDGC.sortCompareFunction=dateSortDatecreated;
						}else if(String(fieldArray[index]).toLowerCase().indexOf("datemodfied") != -1){
							thisDGC.sortCompareFunction=dateSortModified;
						}
					}
					thisFieldListItem.dataField = String(fieldArray[index]).toLowerCase();
					if(String(fieldArray[index]).toLowerCase() != "ordinal"){
						thisDGC.headerText = toolset.getItemAt(0).items.getItemAt(getIndexFromArrayCollection(toolset.getItemAt(0).items,'FIELDNAME',fieldArray[index])).OBJECTLABEL
						thisFieldListItem.headerText = toolset.getItemAt(0).items.getItemAt(getIndexFromArrayCollection(toolset.getItemAt(0).items,'FIELDNAME',fieldArray[index])).OBJECTLABEL
						fieldList.addItem(thisFieldListItem);
					}else{
						thisDGC.headerText = "Ordinal";
					}
					tempCols = new Array();
					if(instanceCase == "associate"){
						tempCols=Application.application.dataMapping.columns;
						tempCols.push(thisDGC);
						Application.application.dataMapping.columns=tempCols;
					}else{
						tempCols=Application.application.mainSelectionList.columns;
						tempCols.push(thisDGC);
						Application.application.mainSelectionList.columns=tempCols;
					}
				}
			}
		}
		private function dateFormat(formatfield:String):void{
			var formatter:DateFormatter = new DateFormatter();
			formatter.formatString="MM/DD/YYYY HH:NN:SS";
			for(var i:Number=0 ; i<availableDataList.length ; i++){
				availableDataList.getItemAt(i)[formatfield] = formatter.format(availableDataList.getItemAt(i)[formatfield]);
			}
		}
		public function dateSortDatecreated(obj1:Object, obj2:Object):Number{
			if(Date.parse(obj1.datemodified) < Date.parse(obj2.datemodified)){
				return -1;
			}else if(Date.parse(obj2.datemodified) < Date.parse(obj1.datemodified)){
				return 1;
			}else{
				return 0;
			}
		}
		public function dateSortModified(obj1:Object, obj2:Object):Number{
			if(Date.parse(obj1.datemodified) < Date.parse(obj2.datemodified)){
				return -1;
			}else if(Date.parse(obj2.datemodified) < Date.parse(obj1.datemodified)){
				return 1;
			}else{
				return 0;
			}
		}
		public function getIndexFromArrayCollection(dataObj:ArrayCollection, fieldname:String, selectedValue:String):Number{
			var thisIndex:Number = -1;
			for(var i:Number= 0; i < dataObj.length; i++){
				if(String(dataObj.getItemAt(i)[fieldname]).toLowerCase() == String(selectedValue).toLowerCase()){
					thisIndex = i;
					break;
				}
			}
			return thisIndex;
		}
	}
}