<!--- Custom tag designed to manage seeds for PKs in tables --->
<cfparam name="attributes.datasource" default="#application.datasource#">
<cfif NOT isDefined("attributes.tablename")>
	<h2>ERROR: You must provide a tablename to use this custom Tag!</h2>
	<cfabort>
</cfif>
<!--- New Stored Proc Call --->
<cfquery datasource="#attributes.datasource#" name="q_getNextID" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	 exec dbo.dp_NextID  @TableName = '#attributes.tablename#'
</cfquery>

<!--- New Stored Proc Call 
<cfset ltable = '#Application.datasource#' &'.'& '#attributes.tablename#'>
<cfquery datasource="#attributes.datasource#" name="q_getNextID" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	 exec dbo.dp_NextID  @TableName = '#ltable#'
</cfquery>--->


<cfparam name="attributes.returnVar" default="newID">

<cfset "caller.#attributes.returnVar#"=q_getNextID.ID>