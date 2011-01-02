package valueobjects
{
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;
	
	public class Form extends Object
	{
		[Bindable]
		public var formname:String = "";
		[Bindable]
		public var formnotes:String = "";
		[Bindable]
		public var formid:String = "";
		[Bindable]
		public var parentid:String = "";
		[Bindable]
		public var items:ArrayCollection = new ArrayCollection();
		
		public function Form()
		{
			super();
		}
		public static function toForm(obj:Object):valueobjects.Form{
			var newForm:valueobjects.Form = new valueobjects.Form();
			if(obj.formname != null){
				newForm.formname = String(obj.formname);
			}
			if(obj.formnotes != null){
				newForm.formnotes = String(obj.formnotes);
			}
			if(obj.formid != null){
				newForm.formid = String(obj.formid);
			}
			if(obj.parentid != null){
				newForm.parentid = String(obj.parentid);
			}
			if(obj.items != null){
				newForm.items = obj.items;
			}
			return newForm;
		}
	}
}