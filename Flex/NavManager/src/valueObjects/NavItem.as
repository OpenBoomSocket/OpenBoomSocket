package valueObjects
{
	import mx.controls.Text;
	
	public class NavItem
	{
		[Bindable]
		public var active:int = 1;
		[Bindable]
		public var atState:String; // path to at state image
		[Bindable]
		public var catonly:int = 0;
		[Bindable]
		public var datecreated:Date;
		[Bindable]
		public var datemodified:Date;
		[Bindable]
		public var navgroupid:Number;
		[Bindable]
		public var navitemid:Number = 0;
		[Bindable]
		public var filetype:String; // file suffix
		[Bindable]
		public var fieldSave:String; // ordered list of ids for ordinal
		[Bindable]
		public var urlpath:String = ""; // URL link
		[Bindable]
		public var imageAt:String; // image id
		[Bindable]
		public var imageOff:String; // image id
		[Bindable]
		public var imageOn:String; // image id
		[Bindable]
		public var menuwidth:Number;
		[Bindable]
		public var navitemname:String = "";
		[Bindable]
		public var offState:String;
		[Bindable]
		public var onState:String;
		[Bindable]
		public var ordinal:Number;
		[Bindable]
		public var label:String;
		[Bindable]
		public var navitemaddressid:Number;
		[Bindable]
		public var navitemaddressname:String;
		[Bindable]
		public var parentid:Number;
		[Bindable]
		public var pageid:Number;
		[Bindable]
		public var sitesectionid:Number;
		[Bindable]
		public var sitesectionname:String;
		[Bindable]
		public var subxy:String;
		[Bindable]
		public var target:String;
		[Bindable]
		public var uploaddescription:String;
		[Bindable]
		public var uploadidAT:Number;
		[Bindable]
		public var uploadidOFF:Number;
		[Bindable]
		public var uploadidON:Number;
		[Bindable]
		public var width:Number;
		
		public function NavItem(){
			
		}
	}
}