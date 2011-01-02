<cfif thisTag.executionmode EQ 'start'>
	<cfset defaulttoolaction="SelectForm">
	<cfif isDefined("form.toolaction")>
		<cfset toolaction=form.toolaction>
	<cfelseif isDefined("url.toolaction")>
		<cfset toolaction=url.toolaction>
	<cfelse>
		<cfset toolaction=defaulttoolaction>
	</cfif>
	<cfswitch expression="#toolaction#">
		<cfcase value="SelectForm">
			<cfset request.defaultcall=1>
			<cfinclude template="includes/i_SelectForm.cfm">
		</cfcase>
		<cfcase value="CreateChild">
			<cfset request.defaultcall=1>
			<cfinclude template="includes/i_CreateChild.cfm">
		</cfcase>
		<cfcase value="DTShowForm">
			<cfset request.defaultcall=1>
			<cfinclude template="includes/i_DTShowForm.cfm">
		</cfcase>
		<cfcase value="ShowFormCustom">
			<cfset request.defaultcall=1>
			<cfinclude template="includes/i_showFormCustom.cfm">
		</cfcase>
		<cfcase value="customPost">
			<cfset request.defaultcall=1>
			<cfinclude template="includes/i_customPost.cfm">
		</cfcase>
		<cfcase value="customDelete">
			<cfset request.defaultcall=1>
			<cfinclude template="includes/i_customDelete.cfm">
		</cfcase>
		<cfcase value="DTpost">
			<cfset request.defaultcall=1>
			<cfinclude template="includes/i_DTpost.cfm">
		</cfcase>
		<cfcase value="DEShowForm">
			<cfset request.defaultcall=1>
			<cfinclude template="includes/i_DEShowForm.cfm">
		</cfcase>
		<cfcase value="DEpost">
			<cfset request.defaultcall=1>
			<cfinclude template="includes/i_DEpost.cfm">
		</cfcase>
		<cfcase value="gridwindow">
			<cfset request.defaultcall=1>
			<cfset request.admintemplate="popup">
			<cfinclude template="includes/i_gridwindow.cfm">
		</cfcase>
		<cfcase value="cellproperties">
			<cfset request.defaultcall=1>
			<cfset request.admintemplate="popup">
			<cfset request.headerText="Table Cell Properties">
			<cfinclude template="includes/i_cellproperties.cfm">
		</cfcase>
		<cfcase value="cellpropertiesPost">
			<cfset request.defaultcall=1>
			<cfinclude template="includes/i_cellpropertiesPost.cfm">
		</cfcase>
		<cfcase value="shufflelayout">
			<cfset request.defaultcall=1>
			<cfset request.admintemplate="popup">
			<cfset request.headerText="Shuffle Table Layout">
			<cfinclude template="includes/i_shufflelayout.cfm">
		</cfcase>
		<cfcase value="shufflelayoutPost">
			<cfset request.defaultcall=1>
			<cfinclude template="includes/i_shufflelayoutPost.cfm">
		</cfcase>
		<cfcase value="deletefield">
			<cfset request.defaultcall=1>
			<cfinclude template="includes/i_deletefield.cfm">
		</cfcase>
		<cfcase value="deleteobject">
			<cfset request.defaultcall=1>
			<cfinclude template="includes/i_deleteobject.cfm">
		</cfcase>
		<cfcase value="createform">
			<cfset request.defaultcall=1>
			<cfinclude template="includes/i_createform.cfm">
		</cfcase>
		<cfcase value="createformPost">
			<cfset request.defaultcall=1>
			<cfinclude template="includes/i_createformPost.cfm">
		</cfcase>
		<cfcase value="addtochild">
			<cfset request.defaultcall=1>
			<cfinclude template="includes/i_addtochild.cfm">
		</cfcase>
		<cfcase value="ordinalForm">
			<cfset request.defaultcall=1>
			<cfinclude template="includes/i_ordinalForm.cfm">
		</cfcase>
		<cfcase value="viewToolTemplates">
			<cfset request.defaultcall=1>
			<cfset request.admintemplate="popup">
			<cfset request.headerText="Socket Tool Templates">
			<cfinclude template="includes/i_buildSocketListing.cfm">
		</cfcase>
		<cfcase value="previewToolForm">
			<cfset request.defaultcall=1>
			<cfset request.admintemplate="popup">
			<cfinclude template="includes/i_showFormPreview.cfm">
		</cfcase>
	</cfswitch>
</cfif>