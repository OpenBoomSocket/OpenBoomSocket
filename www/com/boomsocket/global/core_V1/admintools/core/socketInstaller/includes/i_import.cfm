<!------------------------------------------------- >

	ORIGINAL AUTHOR ::::::::: Darin Kay (DK)
	CREATION DATE ::::::::::: unknown
	LAST MODIFIED AUTHOR :::: EOM
	LAST MODIFIED DATE :::::: 6/22/2008
	EDIT HISTORY :::::::::::: 
								  :: 6/22/2008 Initial Creation :: Emile Melbourne - EOM
	FILENAME :::::::::::::::: i_import.cfm
	DESCRIPTION ::::::::::::: 
---------------------------------------------------->
<cfloop list="#FORM.importname#" index="thisSocket">
	<cfinvoke component="#APPLICATION.cfcPath#.util.plugin" method="importPlugin" returnvariable="returnStruct">
		<cfinvokeargument name="pluginname" value="#thisSocket#">
	</cfinvoke>
	
	<cfif len(trim(returnStruct.errorMsg))>
		<cfif isDefined('request.errorMsg') AND len(trim(request.errorMsg))>
			<cfset request.errorMsg = request.errorMsg&'br />'&returnStruct.errorMsg>
			<cfelse>
			<cfset request.errorMsg = returnStruct.errorMsg>
		</cfif>
	</cfif>
</cfloop>
<cflocation url="#request.page#">
