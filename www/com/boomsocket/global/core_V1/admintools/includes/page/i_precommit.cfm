<!--- i_precommit.cfm --->
<!--- loop through posted data and reassign pagecomponents to new containers --->
<cfif NOT isDefined("form.deleteinstance") AND isDefined("instanceid")>
	<cfif isDefined("form.reassign")>
		<cfloop list="#form.fieldnames#" index="i">
			<cfif listFirst(i,"$") eq "assign">
				<cfif len(evaluate(i))><!--- if a assignment val is passed update --->
					<cfquery datasource="#application.datasource#" name="q_updateContainers" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
						UPDATE pagecomponent
						SET containerid = #listLast(i,"$")#
						WHERE (pageid = #trim(form.pageid)#) AND (containerid = #evaluate(i)#)
					</cfquery>
					<cfset oldContainerList=listDeleteAt(oldContainerList,listFind(oldContainerList,evaluate(i)))>
				</cfif>
			</cfif>
		</cfloop>
		<cfif listLen(oldContainerList)><!--- If any stray containers, delete em --->
			<cfquery datasource="#application.datasource#" name="q_updateContainers" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
				DELETE FROM pagecomponent
				WHERE (pageid = #trim(form.pageid)#) AND (containerid IN (#oldContainerList#))
			</cfquery>
		</cfif>
		<!--- Continue on to master form commit... --->
	<cfelse>
		<!--- Display container reassignment form and stop processing of master form --->
		<cfif NOT len(trim(form.oldtemplateid))>
			<cfset form.oldtemplateid=0>
		</cfif>
		<cfif form.templateid NEQ form.oldtemplateid>
			<cfquery datasource="#application.datasource#" name="q_getOldContainers" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
				SELECT template.templatename, container.identifier, container.containerid
				FROM container INNER JOIN template ON container.templateid = template.templateid
				WHERE template.templateid = #trim(form.oldtemplateid)#
			</cfquery>
			<cfquery datasource="#application.datasource#" name="q_getNewContainers" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
				SELECT template.templatename, container.identifier, container.containerid
				FROM container INNER JOIN template ON container.templateid = template.templateid
				WHERE template.templateid = #trim(form.templateid)#
			</cfquery>
			<cfoutput>
			
<script language="JavaScript">
	function dupeCheck(checkThis) {
	var currentCheck=eval('document.assignForm.'+checkThis+'.value');
		<cfloop list="#valueList(q_getNewContainers.containerid)#" index="thisCheckID">
		if (checkThis == 'assign$#thisCheckID#') {
			if ((<cfset putOrHere=0><cfloop list="#valueList(q_getNewContainers.containerid)#" index="thisCheckID2"><cfif thisCheckID2 NEQ thisCheckID><cfif NOT putOrHere><cfset putOrHere=1><cfelse> || <cfset putOrHere=1></cfif>(document.assignForm.assign$#thisCheckID2#.value == currentCheck)</cfif></cfloop>)  && (currentCheck != '')) {
				alert('Sorry, that value has already been assigned.');
				document.assignForm.assign$#thisCheckID#.focus();
			}
		}
		</cfloop>
	}
</script>

				<form action="#request.page#" method="post" name="assignForm">
				<cfmodule template="#application.customtagpath#/embedfields.cfm" ignore="formstep">
				<input type="Hidden" name="formstep" value="commit">
				<input type="Hidden" name="oldContainerList" value="#valueList(q_getOldContainers.containerid)#">
				<input type="Hidden" name="reassign" value="yes">
				<table width="450" border="0" cellspacing="1" cellpadding="5">
					<tr>
						<td class="toolheader" colspan="2">Reassign Containers</td>
					</tr>
					<tr>
						<td class="formitemlabel" colspan="2">You have elected to change the template for this page which means if you do not reassign the containers the content assignment to this page will be dropped and you will have to reassign the content later.</td>
					</tr>
					<cfloop query="q_getNewContainers">
						<tr>
							<td class="formitemlabel" width="15%" nowrap>#q_getNewContainers.identifier#:</td>
							<td class="formiteminput" width="85%">
								<select name="assign$#q_getNewContainers.containerid#" onblur="javascript: dupeCheck(this.name);">
									<option value="">None
									<cfloop query="q_getOldContainers">
										<option value="#q_getOldContainers.containerid#">#q_getOldContainers.identifier#
									</cfloop>
								</select>
							</td>
						</tr>
					</cfloop>
						<tr>
							<td class="formiteminput" align="center" colspan="2"><input type="Submit" class="submitbutton" value="Post Assignments"></td>
						</tr>
				</table>
				</form>
			</cfoutput>
			<cfset request.stopprocess="commit">
		</cfif>
	</cfif>
</cfif>
