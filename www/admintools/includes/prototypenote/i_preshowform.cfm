<!--- i_preshowform.cfm --->
<script language="javascript">
<!--
// getElementsByClass Returns an array of elements with the given class
// see http://www.grauw.nl/articles/xhtml/jsemail.php
function getElementsByClass(elem, classname) {
    classes = new Array();
    alltags = document.getElementsByTagName(elem);
    for (i=0; i<alltags.length; i++){
        if (alltags[i].className == classname){
            classes[classes.length] = alltags[i];
		}
	}
    return classes;
}

<!--- changes testedby to be either required or not required 
		(if test phase = 1 (complete), required else not required)--->
function testedByToggle(testphase) {
	var reqFields=getElementsByClass('td','formitemlabelreq');
	var nonreqFields=getElementsByClass('td','formitemlabel');
	var validatelist=document.getElementsByName("validatelist");
	var valList = validatelist[0].value.split(';');	
	
	if (testphase == '1~complete'){
		//update class
		for(i=0; i<nonreqFields.length; i++){
			if(nonreqFields[i].innerHTML.indexOf("Tested By") != -1){
				nonreqFields[i].className="formitemlabelreq";
			}	
		}
	
		//add to validatelist
		if(validatelist[0].value.indexOf('testedby,required') == -1){
			validatelist[0].value += ';testedby,required';
		}
	}else{
		//update class
		for(i=0; i<reqFields.length; i++){
			if(reqFields[i].innerHTML.indexOf("Tested By") != -1){
				reqFields[i].className="formitemlabel";
			}	
		}
		//remove from validatelist
		var newList = new Array();
		for (var i=0 ; i<valList.length ;i++){
			if(valList[i] != "testedby,required"){
				newList.push(valList[i]);
			}
		}
		validatelist[0].value = newList.join(';');
	}	
}
-->
</script>
<!--- CMC 04/18/06: set form.pageid = the page id you are editing so autoselected in page dropdown --->
<cfparam name="form.pageid" default="">
<cfif isDefined('URL.targetPageID') AND isNumeric(Trim(URL.targetPageID)) AND NOT Len(Trim(form.pageid))>
	<cfset form.pageid = URL.targetPageID>
</cfif>