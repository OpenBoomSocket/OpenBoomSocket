package valueobjects
{
	import mx.utils.ObjectUtil;
	public class FormItem extends Object
	{
		[Bindable]
		public var id:String = "";
		[Bindable]
		public var DATATYPE:String = "";
		[Bindable]
		public var LOOKUPTYPE:String = "";
		[Bindable]
		public var FIELDNAME:String = "";
		[Bindable]
		public var JAVASCRIPT:String = "";
		[Bindable]
		public var TABINDEX:String = "";
		[Bindable]
		public var JAVASCRIPTHANDLER:String = "";
		[Bindable]
		public var COMMIT:String = "";
		[Bindable]
		public var INPUTSTYLE:String = "";
		[Bindable]
		public var PK:String = "";
		[Bindable]
		public var LOOKUPDISPLAY:String = "";
		[Bindable]
		public var LOOKUPQUERY:String = "";
		[Bindable]
		public var INPUTTYPE:String = "";
		[Bindable]
		public var LENGTH:String = "";
		[Bindable]
		public var OBJECTLABEL:String = "";
		[Bindable]
		public var DEFAULTVALUE:String = "";
		[Bindable]
		public var GRIDPOSVALUE:String = "";
		[Bindable]
		public var MAXLENGTH:String = "";
		[Bindable]
		public var FORMATONLY:String = "";
		[Bindable]
		public var REQUIRED:String = "";
		[Bindable]
		public var UPLOADCATEGORYID:String = "";
		[Bindable]
		public var LOOKUPLIST:String = "";
		[Bindable]
		public var GRIDPOSLABEL:String = "";
		[Bindable]
		public var WIDTH:String = "";
		[Bindable]
		public var LOOKUPKEY:String = "";
		[Bindable]
		public var VALIDATE:String = "";
		[Bindable]
		public var LOOKUPTABLE:String = "";
		[Bindable]
		public var READONLY:String = "";
		[Bindable]
		public var HEIGHT:String = "";
		[Bindable]
		public var LOOKUPMULTIPLE:String = "";
		[Bindable]
		public var SUBMITBUTTONIMAGE:String = "";
		[Bindable]
		public var CANCELBUTTONIMAGE:String = "";
		[Bindable]
		public var CUSTOMINCLUDE:String = "";
		[Bindable]
		public var SEKEYNAMEFIELD:String = "";
		[Bindable]
		public var IMAGEBUTTONPATH:String = "";
		[Bindable]
		public var NOTES:String = "";
		[Bindable]
		public var USEMAPPEDCONTENT:String = "";
		[Bindable]
		public var BS_PAGETITLEFIELD:String = "";
		[Bindable]
		public var COLORPICKER:String = "";
		[Bindable]
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