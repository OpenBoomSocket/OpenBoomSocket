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
<cfmodule template="#application.customTagPath#/formvalidation.cfm"
 validatelist="#trim(form.validatelist)#">

<cfif isDefined("request.isError") AND request.isError eq 1>
	<div id="errorBlock">
		<h2>Errors found...</h2>
		<ul>
			<cfloop list="#request.errorMsg#" index="error" delimiters="||">
				<li>#error#</li>
			</cfloop>
		</ul>
	</div>
<cfelse>
	<cfinvoke component="#APPLICATION.cfcPath#.socketInstaller" method="importPlugin" returnvariable="returnStruct">
		<cfinvokeargument name="pluginname" value="#thisSocket#">
		
		<!--- EOM :: Custom aruguments for the custom installation of the socket --->
		<cfinvokeargument name="formEnvironmentID" value="#FORM.formEnvironmentID#">
		<cfinvokeargument name="toolcategoryid" value="#FORM.toolcategoryid#">
		<cfinvokeargument name="tablename" value="#FORM.newdatatable#">
		<cfinvokeargument name="tableLabel" value="#FORM.label#">
		<cfinvokeargument name="useWorkFlow" value="#FORM.useWorkFlow#">
		<cfinvokeargument name="useOrdinal" value="#FORM.useOrdinal#">
		<cfinvokeargument name="bulkdelete" value="#FORM.bulkdelete#">
		<cfinvokeargument name="singleRecord" value="#FORM.singleRecord#">
		<cfinvokeargument name="useVanityURL" value="#FORM.useVanityURL#">
		<cfinvokeargument name="isNavigable" value="#FORM.isNavigable#">
	</cfinvoke>
	<!--- EOM :: NOTE :: TODO :: If something went wrong in the creation of the record, display and error message --->
	
	<cfif len(trim(returnStruct.errorMsg))>
		<cfif isDefined('request.errorMsg') AND len(trim(request.errorMsg))>
			<cfset request.errorMsg = request.errorMsg&'br />'&returnStruct.errorMsg>
		<cfelse>
			<cfset request.errorMsg = returnStruct.errorMsg>
		</cfif>
	</cfif>
</cfif>
<!--- EOM :: Uncomment this line:: --->  
<!---<cflocation url="#request.page#">--->		
