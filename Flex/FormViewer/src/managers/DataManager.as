package managers
{
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;
	import mx.core.Application;
	import valueobjects.FormItem;
	import valueobjects.Form;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.formatters.DateFormatter;
	import mx.controls.Alert;
	import renderers.*;
	import mx.core.ClassFactory;
	import mx.events.ItemClickEvent;
	
	public class DataManager
	{
		[Bindable]
		public var toolname:String;
		[Bindable]
		public var formname:String;
		[Bindable]
		public var toolset:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var dataList:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var fieldList:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var dataFilterList:ArrayCollection = new ArrayCollection();
		public var dbTools:ArrayCollection;
		public var protoTools:ArrayCollection;
		public var protoToolsXML:XMLList = new XMLList();
		private var fileParsed:Boolean = false;
		private var queryparsed:Boolean = false;
  		
		private function combineTools():void{
			toolset = new ArrayCollection();
			for(var index:Number=0 ; index<protoTools.length ; index++){
				toolset.addItem(protoTools.getItemAt(index));
			}
			
		}
		public function buildDBArrayCollection(dbAC:ArrayCollection):void{
			queryparsed = false;
			dbTools = new ArrayCollection();
			for(var formIndex:Number = 0 ; formIndex < 1 ; formIndex++){
				toolname = dbAC.getItemAt(formIndex).formname;
				formname = dbAC.getItemAt(formIndex).formobjectname
				var form:valueobjects.Form = new valueobjects.Form();
				form.formname = dbAC.getItemAt(formIndex).formobjectname;
				form.formnotes = "";
				form.formid = dbAC.getItemAt(formIndex).formobjectid;
				form.bulkdelete = dbAC.getItemAt(formIndex).bulkdelete;
				form.useworkflow = dbAC.getItemAt(formIndex).useWorkFlow;
				form.ordinal = dbAC.getItemAt(formIndex).useOrdinal;
				form.tablename = dbAC.getItemAt(formIndex).datatable;
				form.items = new ArrayCollection();
				for each(var itemNode:XML in XMLList(dbAC.getItemAt(formIndex).datadefinition).children()){
					var itemObj:valueobjects.FormItem = new valueobjects.FormItem();
					for each(var itemValueNode:XML in itemNode.children()){
						//trace(itemValueNode.name()+" "+itemValueNode.text());
						itemObj[itemValueNode.name()] = itemValueNode.text()
					}
					form.items.addItem(itemObj);
				}
				dbTools.addItem(form);
			}
			queryparsed = true;
			for(var index:Number=0 ; index<dbTools.length ; index++){
				toolset.addItem(dbTools.getItemAt(index));
			}
			trace("db done "+toolset.length);
			//trace(ObjectUtil.toString(toolset));
			buildDG(String(dbAC.getItemAt(0).editFieldKeyValue2).split(','));
		}
		private function buildDG(fieldArray:Array):void{
			//trace(ObjectUtil.toString(toolset.getItemAt(0).items));
			var thisDGC:DataGridColumn;
			var thisFieldListItem:Object;
			var tempCols:Array;
			if(toolset.getItemAt(0).bulkdelete == "true" && toolset.getItemAt(0).useworkflow == "false"){
				thisDGC = new DataGridColumn();
				thisFieldListItem = new Object();
				thisDGC.itemRenderer = new ClassFactory(CheckBoxRenderer);
				thisDGC.width=30;
				thisDGC.headerRenderer = new ClassFactory(HeaderImageRenderer);
				thisDGC.sortable = false;
				thisDGC.setStyle('headerStyleName','garbageHeader');
				tempCols = new Array();
				tempCols=Application.application.formGrid.columns;
				tempCols.push(thisDGC);
				Application.application.formGrid.columns=tempCols;
				Application.application.formGrid;
			}else{
				Application.application.deleteBtn.visible = false;
			}
			if(toolset.getItemAt(0).ordinal == "true"){
				Application.application.ordinalBtn.alpha = 1;
				Application.application.ordinalBtn.mouseEnabled = true;
			}else{
				Application.application.ordinalBtn.visible = false;
			}
			for(var index:Number=0 ; index<fieldArray.length ; index++){
				thisDGC = new DataGridColumn();
				if(index == 0){
					thisDGC.width = 300;
				}
				thisFieldListItem = new Object();
				var fieldEnd:String = String(fieldArray[index]).toLowerCase().substr(String(fieldArray[index]).length-2,2);
				var fieldBase:String = String(fieldArray[index]).toLowerCase().substr(0,String(fieldArray[index]).length-2);
				if(fieldEnd == "id" && Application.application.keyList.toLowerCase().indexOf(fieldBase+'name') > -1){
					thisDGC.dataField = fieldBase+'name';
				}else{
					thisDGC.dataField = String(fieldArray[index]).toLowerCase();
				}
				if(String(fieldArray[index]).toLowerCase().indexOf("date") != -1){
					dateFormat(String(fieldArray[index]).toLowerCase());
					thisDGC.width = 170;
					if(String(fieldArray[index]).toLowerCase().indexOf("datecreated") != -1){
						thisDGC.sortCompareFunction=dateSortDatecreated;
					}else if(String(fieldArray[index]).toLowerCase().indexOf("datemodfied") != -1){
						thisDGC.sortCompareFunction=dateSortModified;
					}
				}
				if(toolset.getItemAt(0).items.getItemAt(getIndexFromArrayCollection(toolset.getItemAt(0).items,'FIELDNAME',fieldArray[index])).DATATYPE == "bit"){
					thisDGC.itemRenderer = new ClassFactory(BooleanRenderer);
					thisDGC.setStyle('textAlign','center');
				}
				thisFieldListItem.dataField = String(fieldArray[index]).toLowerCase();
				if(String(fieldArray[index]).toLowerCase() != "ordinal"){
					thisDGC.headerText = toolset.getItemAt(0).items.getItemAt(getIndexFromArrayCollection(toolset.getItemAt(0).items,'FIELDNAME',fieldArray[index])).OBJECTLABEL
					thisFieldListItem.headerText = toolset.getItemAt(0).items.getItemAt(getIndexFromArrayCollection(toolset.getItemAt(0).items,'FIELDNAME',fieldArray[index])).OBJECTLABEL
					fieldList.addItem(thisFieldListItem);
				}else{
					thisDGC.headerText = "Ordinal";
					thisDGC.width=70;
					thisDGC.setStyle('textAlign','center');
				}
				tempCols = new Array();
				tempCols=Application.application.formGrid.columns;
				tempCols.push(thisDGC);
				Application.application.formGrid.columns=tempCols;
			}
			/* if page usage defined - include pointer */
			var tempColsAC:ArrayCollection;
			if(dataList.length && dataList.getItemAt(0).usecount != null){
				tempCols = new Array();
				//tempCols=Application.application.formGrid.columns;
				thisDGC = new DataGridColumn();
				thisDGC.dataField = 'usecount';
				thisDGC.headerText = 'Page Assignment';
				thisDGC.width = 200;
				//thisDGC.setStyle('textAlign','center');
				thisDGC.itemRenderer = new ClassFactory(UsageRenderer);
				trace("col count "+Application.application.formGrid.columns.length);
				for(var colIndex:uint = 0 ; colIndex<Application.application.formGrid.columns.length ; colIndex++){
					tempCols.push(Application.application.formGrid.columns[colIndex]);
					if(toolset.getItemAt(0).bulkdelete == "true" && toolset.getItemAt(0).useworkflow == "false"){
						if(colIndex == 1){
							tempCols.push(thisDGC);
						}
					}else if(colIndex == 0){
						tempCols.push(thisDGC);
					}
				}
				Application.application.formGrid.columns=tempCols;
			}
			/* Check for versioning */
			if(dataList.length && dataList.getItemAt(0).version != null){
				tempCols = new Array();
				//tempCols=Application.application.formGrid.columns;
				/* add status */
				thisDGC = new DataGridColumn();
				thisDGC.dataField = 'status';
				thisDGC.headerText = 'Status';
				thisDGC.width=80;
				thisDGC.setStyle('textAlign','center');
				thisDGC.itemRenderer = new ClassFactory(StatusRenderer);
				for(colIndex = 0 ; colIndex<Application.application.formGrid.columns.length ; colIndex++){
					tempCols.push(Application.application.formGrid.columns[colIndex]);
					if(toolset.getItemAt(0).bulkdelete == "true" && toolset.getItemAt(0).useworkflow == "false" && dataList.getItemAt(0).usecount != null){
						if(colIndex == 2){
							tempCols.push(thisDGC);
						}
					}else if(dataList.getItemAt(0).usecount != null){
						if(colIndex == 1){
							tempCols.push(thisDGC);
						}
					}else if(colIndex == Application.application.formGrid.columns.length-1){
						tempCols.push(thisDGC);
					}
				}
				Application.application.formGrid.columns=tempCols;
				/* add version */
				tempCols = new Array();
				thisDGC = new DataGridColumn();
				thisDGC.dataField = 'version';
				thisDGC.headerText = 'Version';
				thisDGC.width=70;
				thisDGC.setStyle('textAlign','center');
				for(colIndex = 0 ; colIndex<Application.application.formGrid.columns.length ; colIndex++){
					tempCols.push(Application.application.formGrid.columns[colIndex]);
					if(toolset.getItemAt(0).bulkdelete == "true" && toolset.getItemAt(0).useworkflow == "false" && dataList.getItemAt(0).usecount != null){
						if(colIndex == 3){
							tempCols.push(thisDGC);
						}
					}else if(dataList.getItemAt(0).usecount != null){
						if(colIndex == 2){
							tempCols.push(thisDGC);
						}
					}else if(colIndex == Application.application.formGrid.columns.length-1){
						tempCols.push(thisDGC);
					}
				}
				Application.application.formGrid.columns=tempCols;
			}
			dataFilterList = dataList;
			Application.application.formGrid.invalidateDisplayList();
			Application.application.et = new Date();
			//Application.application.searchTime.text += "  "+Math.abs(Application.application.et.valueOf() - Application.application.st.valueOf()) + "ms";
		}
		private function dateFormat(formatfield:String):void{
			var formatter:DateFormatter = new DateFormatter();
			formatter.formatString="MM/DD/YYYY HH:NN:SS";
			for(var i:Number=0 ; i<dataList.length ; i++){
				dataList.getItemAt(i)[formatfield] = formatter.format(dataList.getItemAt(i)[formatfield])
			}
		}
		public function dateSortDatecreated(obj1:Object, obj2:Object):Number{
			if(Date.parse(obj1.datecreated) < Date.parse(obj2.datecreated)){
				return -1;
			}else if(Date.parse(obj2.datecreated) < Date.parse(obj1.datecreated)){
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
	}
}