<!--- for viewing puposes only called through Tool Template tool --->
<cfif isDefined('URL.templateName') AND isDefined('URL.sourceFolder')>
	<cfif fileExists("#APPLICATION.installpath#\admintools\#URL.sourceFolder#\#URL.templateName#\data\objectdefinition.xml")>
		<cffile action="read" file="#APPLICATION.installpath#\admintools\#URL.sourceFolder#\#URL.templateName#\data\objectdefinition.xml" variable="getFormXML">
		<cfset getFormXML = XMLparse(getFormXML)>
		<!--- <cfdump var="#getFormXML.XMLRoot#"> --->
		<cfset q_getForm.tablerows = getFormXML.XMLRoot.tablerows.XmlText>
		<cfset q_getForm.tablecolumns = getFormXML.XMLRoot.tablecolumns.XmlText>
		<cfset q_getForm.label = getFormXML.XMLRoot.label.XmlText>
		<cfset q_getForm.tablepadding = getFormXML.XMLRoot.tablepadding.XmlText>
		<cfset q_getForm.tablespacing = getFormXML.XMLRoot.tablespacing.XmlText>
		<cfset q_getForm.tablewidth = getFormXML.XMLRoot.tablewidth.XmlText>
		<cfset q_getForm.tablealign = getFormXML.XMLRoot.tablealign.XmlText>
		<cfset q_getForm.tableclass = getFormXML.XMLRoot.tableclass.XmlText>
		<cfset q_getForm.tablealign = getFormXML.XMLRoot.tablealign.XmlText>
		<cfset formobjectid="">
		<cfset q_getForm.omitfieldlist = "">
	<cfelse>
	</cfif>
	<cffile action="read" file="#APPLICATION.installpath#\admintools\#URL.sourceFolder#\#URL.templateName#\data\datadefinition.xml" variable="datadefinition">
	<cfset q_getForm.datadefinition = datadefinition>
	<cffile action="read" file="#APPLICATION.installpath#\admintools\#URL.sourceFolder#\#URL.templateName#\data\tabledefinition.xml" variable="tabledefinition">
	<cfset q_getForm.tabledefinition = tabledefinition>
	<cfset showFormOnly=1>
	<cfoutput>
		<style type="text/css">
			body{
				background-color: ##ffffff;
			}
		</style>
	</cfoutput>
	<cfinclude template="#APPLICATION.customTagPath#/formbuilder/includes/i_buildTable.cfm">
</cfif>