<!------------------------------------------------- >

ORIGINAL AUTHOR ::::::::: Emile Melbourne (EOM)
	CREATION DATE ::::::::::: 6/22/2008
	LAST MODIFIED AUTHOR :::: EOM
	LAST MODIFIED DATE :::::: 6/22/2008
	EDIT HISTORY :::::::::::: 
								  :: 6/22/2008 Initial Creation EOM
	FILENAME :::::::::::::::: i_uninstall.cfm
	DESCRIPTION ::::::::::::: 
----------------------------------------------------->

<cfloop list="#FORM.uninstallid#" index="thisSocket">
	<cfinvoke component="#APPLICATION.cfcPath#.util.plugin" method="uninstallPlugin" returnvariable="errorMsg">
	<cfinvokeargument name="formObjectID" value="#thisSocket#">
	</cfinvoke>
	<cfif len(trim(errorMsg))>
		<cfif len(trim(request.errorMessage))>
			<cfset request.errorMessage = request.errorMessage&'br />'&errorMsg>
			<cfelse>
			<cfset request.errorMessage = errorMsg>
		</cfif>
	</cfif>
</cfloop>
<cflocation url="#request.page#">
