<cfoutput><!--- Search Engine Key field --->
<script type="text/javascript">
// add the onchange event to the name field
	function addChangeFunction(){
		 document.#q_getform.formname#.#a_formelements[a].sekeynamefield#.onchange=function(){ 
			  formatVanity(document.#q_getform.formname#.#a_formelements[a].sekeynamefield#,document.#q_getform.formname#.#a_formelements[a].fieldname#);
		 };
	}
	womAdd('addChangeFunction()');
	womOn();
// function to clean the name
	function formatVanity(currentField, targetField) {
		// spaces to underscores
		var newValue = "";
		var re1 = new RegExp("([ ])", "g");
		newValue = currentField.value.replace(re1, "-");
		// strip specials
		var re2 = new RegExp("([~`!@##$%^&*\(\)\[\]+=|\\:;'<,>.?/])", "g");
		newValue = newValue.replace(re2, "");
		// strip quotes
		var re3 = new RegExp('"', "g");
		newValue = newValue.replace(re3, "");
		targetField.value = newValue;
		// strip ampersand
		var re4 = new RegExp('&', "g");
		newValue = newValue.replace(re4, "");
		targetField.value = newValue;
		// replace double dashes with single dash
		var re5 = new RegExp('--', "g");
		newValue = newValue.replace(re5, "-");
		targetField.value = newValue;		
		var re6 = new RegExp("([®])", "g");
		newValue = newValue.replace(re6, "");
		targetField.value = newValue;
		var re7 = new RegExp('([™])', "g");
		newValue = newValue.replace(re7, "");		
		targetField.value = newValue;
		var re8 = new RegExp("([?|;|:|~|`|!|@|$}%|^|&|*\|,|.|/|\])", "g");
		newValue = newValue.replace(re8, "");
		targetField.value = newValue; 
	}
</script>
<input name="#a_formelements[a].fieldname#" id="#a_formelements[a].fieldname#" type="text" size="#a_formelements[a].width#" class="#a_formelements[a].inputstyle#" value="#evaluate('form.#a_formelements[a].fieldname#')#"></cfoutput>