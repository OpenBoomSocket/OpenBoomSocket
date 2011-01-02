package managers
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class DataManager
	{
		public var toolList:ArrayCollection = new ArrayCollection();
		public var catList:ArrayCollection = new ArrayCollection();
		public var selectedTools:ArrayCollection = new ArrayCollection();
		public var podList:ArrayCollection = new ArrayCollection(/*[{label:'Industry',data:100013,fields:'industryname',table:'industry'},
			{label:'Profile',data:100015,fields:'profilename',table:'profile'},
			{label:'Areas of Expertise',data:100012,fields:'areasofexpertisename',table:'areasofexpertise'},
			{label:'Event',data:100020,fields:'eventname',table:'event'},
			{label:'Whitepapers',data:100011,fields:'whitepapername',table:'whitepaper'},
			{label:'Company Profile',data:100014,fields:'companyprofilename',table:'companyprofile'}]*/);
		public var catSelect:String = "toolcategoryname, toolcategoryid";
		public var catFrom:String = "toolcategory";
		public var catWhere:String = "toolcategoryid <> 100001 AND toolcategoryid <> 100004";
		public var listSelect:String = "*";
		public var listFrom:String = "formobject";
		public var listWhere:String = "formobjectid <> parentid AND isNull(datatable,'0') <> '0'";
		public var listOrder:String = "label";
		public var toolSelect:String = "TOP 6 ";
		public var toolOrder:String = "datecreated DESC";
		public var toolIDs:String = "";
		
		public function DataManager(){
			
		}
	}
}