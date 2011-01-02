<!--------------------------------------------------------------------------------------!>
	EDIT HISTORY ::::::::::::: 
									:: 02.15.2010 Initial Creation EOM (Emile Melbourne)
	FILENAME ::::::::::::::::: spryWidget.cfm
	DEPENDANCIES ::::::::::::: 
	DESCRIPTION :::::::::::::: 
	ATTRIBUTES ::::::::::::::: 
<---------------------------------------------------------------------------------------->

<cfparam name="ATTRIBUTES.files"	>

<!----------------------------------------------------------------!>
	If array is passed in as varable, first convert to list
<------------------------------------------------------------------>
<cfif	IsArray(ATTRIBUTES.files)>
	<cfset ATTRIBUTES.files = ArrayToList(ATTRIBUTES.files)>
</cfif>

<cfif ATTRIBUTES.files NEQ "">
	<cfswitch expression=#thisTag.ExecutionMode#>
		<cfcase value= 'start'>
			<!----------------------------------------------------------------!>
				Add Head tag if not already added
			<------------------------------------------------------------------>
			
			<cfloop from="1" to="#ListLen(ATTRIBUTES.files)#" index="i" >
				<cfset filepath 		= LCase(ListGetAt(ATTRIBUTES.files, i))>
				<cfset filename 		= ReReplaceNoCase(filepath, "^.*/([^/\.]+)\.\D+", "\1", "ALL")>
				<cfset fileExtension = ReReplaceNoCase(filepath, "^.*\.", "", "ALL")>

				<cfif NOT isDefined('REQUEST.adobeSpry#filename#_#fileExtension#')>
					<cfset 'REQUEST.adobeSpry#filename#_#fileExtension#' = True >
					
					<!----------------------------------------------------------------!>
						Link the CSS style and the Spry Validation TextField JavaScript library
					<------------------------------------------------------------------>
					<cfif FileExists(ExpandPath('#filepath#'))>
						<cfif fileExtension EQ "css">
							<cfset HTMLheader = '<link href="#filepath#" rel="stylesheet" type="text/css" />'>
						<cfelseif fileExtension EQ "js">
							<cfset HTMLheader = '<script src="#filepath#" type="text/javascript"></script>'>
						</cfif>
					</cfif>
					
					<cfparam name="HTMLheader" default="">
					<cfhtmlhead text="#HTMLheader#">
				</cfif>
			</cfloop>
		</cfcase>
		<cfcase value='end'>
			<!--- End tag processing --->
		</cfcase>
	</cfswitch>
</cfif>
