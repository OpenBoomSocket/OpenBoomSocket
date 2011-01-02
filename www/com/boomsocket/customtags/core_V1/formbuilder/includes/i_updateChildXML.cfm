<!--- Get XML data definition for child form --->
	<cfquery datasource="#application.datasource#" name="q_getChildDef" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT datadefinition
		FROM formobject
		WHERE formobjectid = #q_getAllChildren.formobjectid#
	</cfquery>
<!--- Deserialize definition --->
	<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="XML2CFML"
		input="#q_getChildDef.datadefinition#"
		output="a_formelements">
<!--- loop over array structure until we find the fieldname to be edited --->
	<cfloop index="i" from="1" to="#arrayLen(a_formelements)#">
		<cfif structfind(a_formelements[i],"fieldname") eq trim(form.edit)>
			<cfset x=i>
		</cfif>
	</cfloop>
<!--- Update the selected field in the structure --->
	<cfscript>
		a_formelements[x].fieldname=trim(form.fieldname);
	//	a_formelements[x].objectlabel=trim(form.objectlabel);
		a_formelements[x].datatype=trim(form.datatype);
		a_formelements[x].length=trim(form.length);
		a_formelements[x].pk=trim(form.pk);
	//	a_formelements[x].required=trim(form.required);
	//	a_formelements[x].validate=trim(form.validate);
	//	a_formelements[x].inputtype=trim(form.inputtype);
	//	a_formelements[x].maxlength=trim(form.maxlength);
	//	a_formelements[x].height=trim(form.height);
	//	a_formelements[x].width=trim(form.width);
	//	a_formelements[x].lookuptype=trim(form.lookuptype);
	//	a_formelements[x].lookuplist=trim(form.lookuplist);
	//	a_formelements[x].lookupquery=trim(form.lookupquery);
	//	a_formelements[x].lookuptable=trim(form.lookuptable);
	//	a_formelements[x].lookupkey=trim(form.lookupkey);
	//	a_formelements[x].lookupdisplay=trim(form.lookupdisplay);
	//	a_formelements[x].lookupmultiple=trim(form.lookupmultiple);
		a_formelements[x].defaultvalue=trim(form.defaultvalue);
	//	a_formelements[x].inputstyle=trim(form.inputstyle);
	//	a_formelements[x].gridposlabel=trim(replaceNoCase(form.gridposlabel,",","_"));
	//	a_formelements[x].gridposvalue=trim(replaceNoCase(form.gridposvalue,",","_"));
		a_formelements[x].commit=trim(form.commit);
	</cfscript>
<!--- Serialize the structure --->
	<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="CFML2XML"
		input="#a_formelements#"
		output="datadefinition">
<!--- Insert XML structure back into DB --->
	<cfquery datasource="#application.datasource#" name="q_updateChildDef" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		UPDATE formobject 
		SET datadefinition='#datadefinition#'
		WHERE formobjectid = #q_getAllChildren.formobjectid#
	</cfquery>
