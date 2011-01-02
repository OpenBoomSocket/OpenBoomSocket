<cfoutput><!--- Search Engine Key field --->
<script type="text/javascript">
// add the onchange event to the name field
	function addBSPageChangeFunction(){
		 document.#q_getform.formname#.#a_formelements[a].bs_pageTitlefield#.onblur=function(){ 
			  formatPageTitle(document.#q_getform.formname#.#a_formelements[a].bs_pageTitlefield#,document.#q_getform.formname#.#a_formelements[a].fieldname#);
		 };
	}
	womAdd('addBSPageChangeFunction()');
	womOn();
// function to clean the name
	function formatPageTitle(currentField, targetField) {
		targetField.value = currentField.value;
	}

</script>
<input name="#a_formelements[a].fieldname#" id="#a_formelements[a].fieldname#" type="text" size="#a_formelements[a].width#" class="#a_formelements[a].inputstyle#" value="#evaluate('form.#a_formelements[a].fieldname#')#"></cfoutput>