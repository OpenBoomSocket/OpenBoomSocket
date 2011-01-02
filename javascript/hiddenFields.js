<script type="text/javascript">
	//var formName = "#CF_FORMNAME#";
	function fillHidden(){
		//var theForm = document.getElementbyId(formName);
		var theForm = document.getElementsByTagName('form')[0];
		var elements = new Array();
	<cfloop from="1" to="#CF_ELEMENT_COUNT#" index="i">
		elements[#i#] = document.createElement('input');
		elements[#i#].type = "hidden";
		elements[#i#].id = "#CF_ID#";
		elements[#i#].name = "#CF_ID#";
		elements[#i#].value = "#CF_VALUE#";
	</cfloop>
		for(i=0 ; i<elements.length ; i++){
			theForm.appendChild(elements[i]);
		}
	}
	fillHidden();
</script>