<cffile action="read" file="#APPLICATION.installpath#\admintools\#URL.sourceFolder#\#URL.templateName#\data\objectdefinition.xml" variable="getFormXML">
<cfset getFormXML = XMLparse(getFormXML)>
<cfif isDefined('getFormXML.XMLRoot.tablerows')>
	<cfset form.tablerows = getFormXML.XMLRoot.tablerows.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.tablecolumns')>
	<cfset form.tablecolumns = getFormXML.XMLRoot.tablecolumns.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.label')>
	<cfset form.label = getFormXML.XMLRoot.label.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.tablepadding')>
	<cfset form.tablepadding = getFormXML.XMLRoot.tablepadding.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.tablespacing')>
	<cfset form.tablespacing = getFormXML.XMLRoot.tablespacing.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.tablewidth')>
	<cfset form.tablewidth = getFormXML.XMLRoot.tablewidth.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.tablealign')>
	<cfset form.tablealign = getFormXML.XMLRoot.tablealign.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.tableclass')>
	<cfset form.tableclass = getFormXML.XMLRoot.tableclass.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.formEnvironmentID')>
	<cfset form.formEnvironmentID = getFormXML.XMLRoot.formEnvironmentID.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.datatable')>
	<cfset form.datatable = getFormXML.XMLRoot.datatable.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.datatable')>
	<cfset form.newdatatable = getFormXML.XMLRoot.datatable.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.formobjectid')>
	<cfset form.formobjectid = ''>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.bulkdelete')>
	<cfset form.bulkdelete = getFormXML.XMLRoot.bulkdelete.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.singlerecord')>
	<cfset form.singlerecord = getFormXML.XMLRoot.singlerecord.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.showconfirm')>
	<cfset form.showconfirm = getFormXML.XMLRoot.showconfirm.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.successmsg')>
	<cfset form.successmsg = getFormXML.XMLRoot.successmsg.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.successredirect')>
	<cfset form.successredirect = getFormXML.XMLRoot.successredirect.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.successemail')>
	<cfset form.successemail = getFormXML.XMLRoot.successemail.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.formname')>
	<cfset form.formname = getFormXML.XMLRoot.formname.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.formfilename')>
	<cfset form.formfilename = getFormXML.XMLRoot.formfilename.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.formaction')>
	<cfset form.formaction = getFormXML.XMLRoot.formaction.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.formmethod')>
	<cfset form.formmethod = getFormXML.XMLRoot.formmethod.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.preshowform')>
	<cfset form.preshowform = getFormXML.XMLRoot.preshowform.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.prevalidate')>
	<cfset form.prevalidate = getFormXML.XMLRoot.prevalidate.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.preconfirm')>
	<cfset form.preconfirm = getFormXML.XMLRoot.preconfirm.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.postconfirm')>
	<cfset form.postconfirm = getFormXML.XMLRoot.postconfirm.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.precommit')>
	<cfset form.precommit = getFormXML.XMLRoot.precommit.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.postcommit')>
	<cfset form.postcommit = getFormXML.XMLRoot.postcommit.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.toolcategoryid')>
	<cfset form.toolcategoryid = getFormXML.XMLRoot.toolcategoryid.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.useWorkFlow')>
	<cfset form.useWorkFlow = getFormXML.XMLRoot.useWorkFlow.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.useMappedContent')>
	<cfset form.useMappedContent = getFormXML.XMLRoot.useMappedContent.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.useOrdinal')>
	<cfset form.useOrdinal = getFormXML.XMLRoot.useOrdinal.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.compositeForm')>
	<cfset form.compositeForm = getFormXML.XMLRoot.compositeForm.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.useVanityURL')>
	<cfset form.useVanityURL = getFormXML.XMLRoot.useVanityURL.XmlText>
</cfif>
<cfif isDefined('getFormXML.XMLRoot.isNavigable')>
	<cfset form.isNavigable = getFormXML.XMLRoot.isNavigable.XmlText>
</cfif>
<cffile action="read" file="#APPLICATION.installpath#\admintools\#URL.sourceFolder#\#URL.templateName#\info\info.xml" variable="getInfoXML">
<cfset getInfoXML = XMLparse(getInfoXML)>
<cfif isDefined('getInfoXML.XMLRoot.description')>
	<cfset form.description = getInfoXML.XMLRoot.description.XmlText>
</cfif>
