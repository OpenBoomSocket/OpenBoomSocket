<!--- ADMIN: i_precommit.cfm --->
<!--- Note: a different version exists in i3Global includes so be aware if any modifications need to be made in both places --->

<cfif NOT isDefined("deleteinstance")>
<!--- adding or updating guest table (not handled by composite form b/c write to foreign table not checked--->
	<!--- all possible guest table name fields should be guest firstname & lastname --->
	<cfset allGuestNameFields = "guestname,guestaccessname,guestaddressname,guestemailaddressname,guestphonename,#form.tablename#">
	
	<!--- name fields to FORM scope (to be used by dbaction to add/update)--->
	<cfset thisGuestName = FORM.firstname>
	<cfif isDefined('FORM.middleinitial') AND Len(FORM.middleinitial)>
		<cfset thisGuestName = thisGuestName & " " & FORM.middleinitial>
	</cfif>
	<cfset thisGuestName = thisGuestName & " " & FORM.lastname>
	<cfloop list="#allGuestNameFields#" index="namefield">
		<cfset "FORM.#namefield#" = thisGuestName>
	</cfloop>
	<cfset FORM.datemodified = CreateODBCDateTime(now())>
	
	<!--- if form.guestuuid exists, check to see if name matches up. if so, update guest, otherwise cut new record --->
	<!--- CMC & BDW discussion: future functionality?- check for cookie of comma delimited list of guestuuids & see if it matches any previous user by firstname, lastname, and any email entered for that guest- problem: same person comes back in w/ different email will cut new guest record- but if their uuid doesn't match, will cut new record anyway --->
	<cfset action = "insert">
	<cfif isDefined('COOKIE.guestuuid') AND Len(Trim(COOKIE.guestuuid)) AND isDefined('FORM.guestid') AND isNumeric(Trim(FORM.guestid))>
		<cfset guestObj = CreateObject('component','#application.CFCpath#.guest')>
		<cfset q_guestInfo = guestObj.getGuest(guestid=Trim(FORM.guestid))>
        
		<cfif q_guestInfo.RecordCount>
			<cfset action = "update">
        </cfif>
        <cfdump var="#q_guestInfo#">
        <cfabort>
		<!--- if firstname, lastname, & possibly middleinitial(if in form) match, set action to update (default is insert, set above
		<cfif isDefined('form.firstname') AND (Trim(FORM.firstname) eq q_guestInfo.firstname) AND isDefined('FORM.lastname') AND (Trim(FORM.lastname) eq q_guestInfo.lastname)>
			<cfif NOT isDefined('FORM.middleinitial') OR (Trim(FORM.middleinitial) eq q_guestInfo.middleinitial)>
				<cfset action = "update">
			</cfif>
		</cfif>
		 --->
	</cfif>
	
	<cfif action eq "update">
		<cfmodule template="#application.customTagPath#/dbaction.cfm" 
			action="UPDATE"
			tablename="guest" 
			datasource="#application.datasource#"
			primarykeyfield="guestid"
			assignidfield="guestid">
			<cfset thisGuestid = FORM.guestid>
	<cfelseif action eq "insert">
		<cfset form.datecreated = CreateODBCDateTime(now())>
		<cfset form.guestUUID = CreateUUID()>
		<cfmodule template="#application.customTagPath#/dbaction.cfm" 
			action="INSERT" 
			tablename="guest"  
			datasource="#application.datasource#" 
			assignidfield="guestid">		
			<cfset thisGuestid = insertid>
			<cfset form.guestid = thisGuestid>
	</cfif>
</cfif>