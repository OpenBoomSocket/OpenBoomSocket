	<cfif NOT isDefined('FORM.parentid') AND isDefined('URL.parentid')>
		<cfset FORM.parentid = URL.parentid>
	</cfif>
	<cfif NOT isDefined('FORM.addChildField') AND isDefined('URL.addChildField')>
		<cfset FORM.addChildField = URL.addChildField>
	</cfif>
	<cfif NOT isDefined('FORM.formobjectid') AND isDefined('URL.formobjectid')>
		<cfset FORM.formobjectid = URL.formobjectid>
	</cfif>
	<cfquery datasource="#application.datasource#" name="q_getDef" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT datadefinition
		FROM formobject
		WHERE formobjectid = #APPLICATION.stripAllBut(FORM.parentid,"0-9")#
	</cfquery>
	<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="XML2CFML"
		input="#q_getDef.datadefinition#"
		output="a_formelements">
	<cfloop index="i" from="1" to="#arrayLen(a_formelements)#">
		<cfif structfind(a_formelements[i],"fieldname") eq trim(FORM.addChildField)>
			<cfset x=i>
		</cfif>
	</cfloop>
	<cfscript>
		form.fieldname="#a_formelements[x].fieldname#";
		form.objectlabel="#a_formelements[x].objectlabel#";
		form.datatype="#a_formelements[x].datatype#";
		form.length="#a_formelements[x].length#";
		form.pk="#a_formelements[x].pk#";
		form.required="#a_formelements[x].required#";
		form.validate="#a_formelements[x].validate#";
		form.inputtype="#a_formelements[x].inputtype#";
		form.maxlength="#a_formelements[x].maxlength#";
		form.height="#a_formelements[x].height#";
		form.width="#a_formelements[x].width#";
		form.lookuptype="#a_formelements[x].lookuptype#";
		form.lookuplist="#a_formelements[x].lookuplist#";
		form.lookupquery="#a_formelements[x].lookupquery#";
		form.lookuptable="#a_formelements[x].lookuptable#";
		form.lookupkey="#a_formelements[x].lookupkey#";
		form.lookupdisplay="#a_formelements[x].lookupdisplay#";
		form.lookupmultiple="#a_formelements[x].lookupmultiple#";
		form.defaultvalue="#a_formelements[x].defaultvalue#";
		form.inputstyle="";
		form.gridposlabel="";
		form.gridposvalue="";
		form.commit="#a_formelements[x].commit#";
		form.arrayposition=x;
		if(structkeyexists(a_formelements[x],"SOURCEFORMOBJECTID") AND (a_formelements[x].SOURCEFORMOBJECTID GT 0)){
			form.SOURCEFORMOBJECTID = "#a_formelements[x].SOURCEFORMOBJECTID#";
			if(structkeyexists(a_formelements[x],"FOREIGNKEY")){
				form.FOREIGNKEY = "#a_formelements[x].FOREIGNKEY#";
				form.COMMITFOREIGNTABLE = "#a_formelements[x].COMMITFOREIGNTABLE#";
				form.ISMASTERTABLE = "#a_formelements[x].ISMASTERTABLE#";
			}
		}
		form.toolaction="DEShowForm";
		edit=trim(FORM.addChildField);
		formobjectid=form.formobjectid;
	</cfscript>

<cfinclude template="../run.cfm">
			
