<cfoutput>
	<cfquery name="q_getRoles" datasource="#application.datasource#">
		SELECT *
		FROM guestrole
	</cfquery>
	<script type="text/javascript">
		var roleHash = new Array();
		<cfloop query="q_getRoles">
		<cfquery name="q_children" datasource="#application.datasource#">
			SELECT childid
			FROM guestroleparentchild
			WHERE parentid = #q_getRoles.guestroleid#
		</cfquery>
		roleHash['#q_getRoles.guestroleid#']= '#valueList(q_children.childid)#';
		</cfloop>
		function showCurrent(){
			var selectionList = roleHash[document.getElementById('parentrole').value.split('~')[0]];
			var children = document.getElementById('childrole').options;
			for(i=0 ; i<children.length ; i++){
				//alert(children[i].value.split('~')[0]);
				if((children[i].value.length > 0) && (selectionList.indexOf(children[i].value.split('~')[0]) != -1)  && (children[i].value.split('~')[0] != document.getElementById('parentrole').value.split('~')[0])){
					children[i].selected='selected';
				}else{
					children[i].selected=null;
				}
			}
		}
	</script>
</cfoutput>