<!--- i_preshowform.cfm --->
<!--- only show this code for COREV4 & older --->

<cfif application.customtagpath neq "coreV4">
	<!--- Query for all templates & their containers --->
	<cfquery datasource="#application.datasource#" name="q_getContainers" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT templateID, containerID, identifier
		FROM container
		Order By Identifier
	</cfquery>
	<cfquery datasource="#application.datasource#" name="q_getDefaultTemplates" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT sitesectionid, templateid
		FROM sitesection
	</cfquery>
	
	<!--- Loop through templates and add their containers to a JS array --->
	<script type="text/javascript">
	var templateArray = new Array();
	<cfloop query="q_getDefaultTemplates">
	templateArray[<cfoutput>#q_getDefaultTemplates.sitesectionid#</cfoutput>] = "<cfoutput>#q_getDefaultTemplates.templateid#</cfoutput>";
	</cfloop>
	var Containers;
	//create containers array to hold all containers for all templated
		function setUpVars(){
			// if document.getElementById pageid <> "" then editing: dont body content fields or create container array
			if (document.getElementById("pageid").value != ""){
				Containers= new Array(0);
				document.getElementById("page_row5").style.display='none';
				document.getElementById("page_row6").style.display='none';
				document.getElementById("page_row7").style.display='none';
				
			}else{//adding new			
				Containers= new Array(<cfoutput>#q_getContainers.recordcount#</cfoutput>);
				<cfloop query="q_getContainers">
					Containers[<cfoutput>#q_getContainers.currentrow-1#</cfoutput>] = new Array(3);
					Containers[<cfoutput>#q_getContainers.currentrow-1#</cfoutput>][0] = <cfoutput>#q_getContainers.templateid#</cfoutput>;
					Containers[<cfoutput>#q_getContainers.currentrow-1#</cfoutput>][1] = <cfoutput>#q_getContainers.containerid#</cfoutput>;
					Containers[<cfoutput>#q_getContainers.currentrow-1#</cfoutput>][2] = "<cfoutput>#q_getContainers.identifier#</cfoutput>";
				</cfloop>
			}
			// CMC 1/29/07: need to populate container dropdown in case returning from form validation 
			if(document.getElementById("templateid").selectedIndex > 0){
				popContainerSelect();
			}else{
				for(i=0 ; i<document.getElementById('templateid').options.length ; i++){
					if(document.getElementById('templateid').options[i].value.split('~')[0] == templateArray[document.getElementById('sitesectionID').options[0].value.split('~')[0]]){
						document.getElementById('templateid').selectedIndex = i;
						popContainerSelect();
					}
				}
			}
		}
		womAdd('setUpVars()');
	//populate the container to assign dropdown when they select a template
		function popContainerSelect(){
			//get selected templateid
			var templateidval = document.getElementById("templateid").options[document.getElementById("templateid").selectedIndex].value;
			templateidval = templateidval.split("~");
			var templateid = templateidval[0];
			//get all array values where templateid = passedid
			var newOpt;
			//clear out all current children
			document.getElementById("containertoassign").options.length = 0;
			
			for (var i=0; i<Containers.length-1; i++){
				if (Containers[i][0] == templateid){
					//add value=containerid display=identifier to dropdown
					newOpt=document.createElement('option');
					newOpt.value=Containers[i][1];
					newOpt.appendChild(document.createTextNode(Containers[i][2]));
					document.getElementById("containertoassign").appendChild(newOpt);
					//CMC 1/29/07- if returned from form validation, select container previously selected				
					<cfif isDefined('form.containertoassign') AND Trim(form.containertoassign) EQ 1>
						if(<cfoutput>#Trim(form.containertoassign)#</cfoutput> == newOpt.value){
							newOpt.selected = 'selected';
						}
					</cfif>
				}
			}	
		}
	
	
	//if not creating body content, disable containertoassign otherwise activate
		function CreateBConChange(){
			//can't use getElementById to get these radio buttons b/c hidden field w/ same id
			var allInputs = new Array();
			var createbodycontentValue = 0;
			allInputs = document.getElementsByTagName("input");
			for(i=0; i<allInputs.length; i++){
				
				if (allInputs[i].type == "radio" && allInputs[i].name == "createbodycontent" && allInputs[i].checked){
					createbodycontentValue = allInputs[i].value;
				
				}
			}
			if (createbodycontentValue == "0~no"){
				document.getElementById("containertoassign").disabled="true";
				for(i=0; i<allInputs.length; i++){
					if (allInputs[i].type == "radio" && allInputs[i].name == "editoncompletion"){
						allInputs[i].disabled = "true";
					}
				}
			}else{
				document.getElementById("containertoassign").disabled=null;
				for(i=0; i<allInputs.length; i++){
					if (allInputs[i].type == "radio" && allInputs[i].name == "editoncompletion"){
						allInputs[i].disabled = null;
					}
				}
			}
		}
		function changeTemplate(thisItem){
			if(thisItem.length){
				for(i=0 ; i<document.getElementById('templateid').options.length ; i++){
					if(document.getElementById('templateid').options[i].value.split('~')[0] == templateArray[thisItem.split('~')[0]]){
						document.getElementById('templateid').selectedIndex = i;
					}
				}
			}
		}
	</script>
</cfif>
