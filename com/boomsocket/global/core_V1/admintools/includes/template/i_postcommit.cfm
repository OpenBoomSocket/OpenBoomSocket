<!--- i_postcommit.cfm 
This template handles management of containers within
a template, adding, editing and deleting as identified
in the template code by [[mycontainer]]
--->

<!--- Set up the switch var and templateid to use --->
<cfif isDefined("instanceid")>
	<cfset thisTemplateID=instanceid>
	<cfset pageaction="edit">
<cfelseif isDefined("insertID")>
	<cfset thisTemplateID=insertID>
	<cfset pageaction="add">
<cfelse>
	<cfset thisTemplateID=deleteinstance>
	<cfset pageaction="delete">
</cfif>

<!--- Parse out container identifiers --->
<cfif pageaction NEQ "delete">
	<cfscript>
		regexString = '\[{1,1}\[{1,1}[a-zA-Z0-9 _]{1,}\^[0-9]{1,}\]{1,1}\]{1,1}';
		start=1;
		thisContainerList="";
		str=form.html;
		while (start GT 0) {
			thiscontainer=REFindNoCase(regexString,str,start,1);
			if (thiscontainer.pos[1]) {
				thiscontainerList=listAppend(thiscontainerList,trim(mid(str,thiscontainer.pos[1]+2,thiscontainer.len[1]-4)));
				start=val(thiscontainer.pos[1]+thiscontainer.len[1]);
			} else {
				start=0;
			}
		}
	</cfscript>
</cfif>
<cfswitch expression="#pageaction#">
	<cfcase value="add">
		<!--- insert the containers into the db, append the id to it's container --->
		<cfloop list="#thisContainerList#" index="thisIdentifier">
			<cfset form.templateid=thisTemplateID>
			<cfset form.identifier=listFirst(thisIdentifier,"^")>
			<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
						 datasource="#application.datasource#"
						 tablename="container"
						 assignidfield="containerid">
			<!--- replace the identifier string with identifier^insertid in the file var --->
			<cfset form.html=replaceNoCase(form.html,"add [[#thisIdentifier#]]","[[#form.identifier#^#insertid#]]","ALL")>
			<cfset form.wireframe=replaceNoCase(form.wireframe,"add [[#thisIdentifier#]]","[[#form.identifier#^#insertid#]]","ALL")>
		</cfloop>
		<!--- write the file --->
		<cffile action="WRITE"
		        file="#application.templatepath#\#form.templatefilename#"
		        output="#form.html#"
		        addnewline="No">
		<cfset form.templateID = thisTemplateID>
		<cfmodule template="#application.customTagPath#/dbaction.cfm" 
			action="UPDATE"
			tablename="template" 
			datasource="#application.datasource#"
			primarykeyfield="templateid"
			assignidfield="templateid">
	</cfcase>
	<cfcase value="edit">
		<!--- start the new list --->
		<cfset containerIDlist="">
		<cfloop list="#thisContainerList#" index="thisIdentifier">
			<cfset form.templateid=thisTemplateID>
			<cfif listLen(thisIdentifier,"^") GT 1 AND listLast(thisIdentifier,"^") NEQ 0>
				<cfset form.containerid=listLast(thisIdentifier,"^")>
			<cfelseif listLen(thisIdentifier,"^") GT 1 AND listLast(thisIdentifier,"^") EQ 0>
				<cfset form.containerid="">
			<cfelse>
				<cfset form.containerid="">
			</cfif>
			<cfset form.identifier=listFirst(thisIdentifier,"^")>
				<cfif len(trim(form.identifier))><!--- be sure this identifier is not empty --->
					<cfif len(form.containerid)><!--- update old containers --->
						<!--- container.containerid, container.templateid dual key to allow containers to be assigned to mult templates --->			 
							<!--- get all templates using this container id --->
							<cfquery name="q_getTemplates" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
								SELECT templateid
								FROM container 
								WHERE containerid = #Trim(FORM.containerid)#
							</cfquery>			 
							<!--- only update where containerid & template id are equal to form vars--->
							<cfif listfindnocase(ValueList(q_getTemplates.templateid),Trim(form.templateid))>								
								<cfmodule template="#application.customTagPath#/dbaction.cfm" action="UPDATE"
										 datasource="#application.datasource#"
										 tablename="container"
										 whereclause="containerid = #Trim(FORM.containerid)# AND templateid = #Trim(FORM.templateid)#">
							<!--- if different templateid, add new container using same containerid --->
							<cfelse>
								<cfquery name="q_dupeContainer" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
									INSERT INTO container(containerid,templateid,identifier)
									Values(#Trim(FORM.containerid)#,
										#Trim(FORM.templateid)#,
										'#Trim(FORM.identifier)#'
									)
								</cfquery>	
							</cfif>						
						<!--- end update --->
					<cfelse><!--- add new containers --->
						<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
									 datasource="#application.datasource#"
									 tablename="container"
									 assignidfield="containerid">
						<cfset form.containerid=insertid>
					</cfif>
				</cfif>
			<cfset containerIDlist=listAppend(containerIDlist,"#form.containerid#")>
			<!--- replace the identifier string with identifier^insertid in the file var --->
			<cfset form.html=replaceNoCase(form.html,"[[#thisIdentifier#]]","[[#form.identifier#^#form.containerid#]]","ALL")>
			<cfset form.wireframe=replaceNoCase(form.wireframe,"[[#thisIdentifier#]]","[[#form.identifier#^#form.containerid#]]","ALL")>
		</cfloop>
		<cfif listLen(containerIDlist)>
			<!--- get deletable pagecomponentids --->
			<cfquery name="q_getDelPageComponents" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
				SELECT pagecomponent.pagecomponentid 
				FROM pagecomponent INNER JOIN container ON pagecomponent.containerid=container.containerid
				WHERE pagecomponent.containerid NOT IN (#containerIDlist#) AND container.templateid=#thisTemplateID#
			</cfquery>
			<cfif q_getDelPageComponents.recordcount>
				<cfmodule template="#application.customTagPath#/dbaction.cfm" action="DELETE"
							 datasource="#application.datasource#"
							 tablename="pagecomponent"
							 whereclause="pagecomponentid IN (#valueList(q_getDelPageComponents.pagecomponentid)#)">
			</cfif>
			<!---delete container for this template that are no longer assigned --->
			<cfmodule template="#application.customTagPath#/dbaction.cfm" action="DELETE"
							 datasource="#application.datasource#"
							 tablename="container"
							 whereclause="(templateid = #instanceid# AND containerid NOT IN (#containerIDlist#))">
		</cfif>
		<!--- write the file --->
		<cffile action="WRITE"
		        file="#application.templatepath#\#form.templatefilename#"
		        output="#form.html#"
		        addnewline="No">
		<cfset form.templateID = thisTemplateID>
		<cfmodule template="#application.customTagPath#/dbaction.cfm" 
			action="UPDATE"
			tablename="template" 
			datasource="#application.datasource#"
			primarykeyfield="templateid"
			assignidfield="templateid">
	</cfcase>
	<cfcase value="delete">
	<cfloop list="#thisTemplateID#" index="thisTemplateDel">
		<!--- Delete all associated containers and delete template file --->
		<cfquery name="q_getTemplateFile" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT templatefilename
			FROM template 
			WHERE templateid = #thisTemplateDel#
		</cfquery>
			<cfmodule template="#application.customTagPath#/dbaction.cfm" action="DELETE"
						 datasource="#application.datasource#"
						 tablename="container"
						 whereclause="templateid = #thisTemplateDel#">	
		<!--- Delete all associated containers and delete template file --->				 
			<cfmodule template="#application.customTagPath#/dbaction.cfm" action="DELETE"
						 datasource="#application.datasource#"
						 tablename="pagecomponent"
						 whereclause="containerid NOT IN (SELECT containerid FROM container)">	
	</cfloop>
	</cfcase>
</cfswitch>