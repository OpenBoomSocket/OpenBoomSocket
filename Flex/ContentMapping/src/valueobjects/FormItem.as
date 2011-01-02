package valueobjects
{
	import mx.utils.ObjectUtil;
	[Bindable]
	public class FormItem extends Object
	{
		public var id:String = "";
		public var DATATYPE:String = "";
		public var LOOKUPTYPE:String = "";
		public var FIELDNAME:String = "";
		public var JAVASCRIPT:String = "";
		public var TABINDEX:String = "";
		public var JAVASCRIPTHANDLER:String = "";
		public var COMMIT:String = "";
		public var INPUTSTYLE:String = "";
		public var PK:String = "";
		public var LOOKUPDISPLAY:String = "";
		public var LOOKUPQUERY:String = "";
		public var INPUTTYPE:String = "";
		public var LENGTH:String = "";
		public var OBJECTLABEL:String = "";
		public var DEFAULTVALUE:String = "";
		public var GRIDPOSVALUE:String = "";
		public var MAXLENGTH:String = "";
		public var FORMATONLY:String = "";
		public var REQUIRED:String = "";
		public var UPLOADCATEGORYID:String = "";
		public var LOOKUPLIST:String = "";
		public var GRIDPOSLABEL:String = "";
		public var WIDTH:String = "";
		public var LOOKUPKEY:String = "";
		public var VALIDATE:String = "";
		public var LOOKUPTABLE:String = "";
		public var READONLY:String = "";
		public var HEIGHT:String = "";
		public var LOOKUPMULTIPLE:String = "";
		public var SUBMITBUTTONIMAGE:String = "";
		public var CANCELBUTTONIMAGE:String = "";
		public var CUSTOMINCLUDE:String = "";
		public var SEKEYNAMEFIELD:String = "";
		public var IMAGEBUTTONPATH:String = "";
		public var NOTES:String = "";
		public var USEMAPPEDCONTENT:String = "";
		public var BS_PAGETITLEFIELD:String = "";
		public var CALENDARPOPUP:String = "";
		
		public function FormItem(){
			super();
		}
		public static function toFormItem(obj:Object):valueobjects.FormItem{
			var thisFormItem:valueobjects.FormItem = new valueobjects.FormItem();
			for (var itemValueNode:Object in obj){
				if(String(itemValueNode) != "mx_internal_uid" && itemValueNode != "id"){
					thisFormItem[String(itemValueNode).toUpperCase()] = obj[itemValueNode];
					thisFormItem[String(itemValueNode).toUpperCase()] = (thisFormItem[String(itemValueNode).toUpperCase()] == null)?"":thisFormItem[String(itemValueNode).toUpperCase()];
				}
			}
			return thisFormItem;
		}
		public function toXML():XML{
			var itemXML:XML = new XML(<item></item>);
			itemXML.@id = this.id;
			var properties:Array = ObjectUtil.getClassInfo(this).properties
			for(var i:Number=0 ; i<properties.length ; i++){
				if(properties[i].localName != "id"){
					var itemDataNode:XML = new XML(<node></node>);
					itemDataNode.setName(properties[i].localName);
					if(this[properties[i].localName] != ""){
						itemDataNode.text()[0] = this[properties[i].localName];
					}
					itemXML.appendChild(itemDataNode);
				}
			}
			return itemXML;
		}
	}
}