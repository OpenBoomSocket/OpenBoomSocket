<!--- FRONTEND: fe_preshowform.cfm --->
<cfif isDefined('URL.clearUser') AND Trim(URL.clearUser)>
	<cfcookie name = "guestuuid"
	   value = "0"
	   expires = "NOW"> 
	<cfcookie name = "rememberme"
	   value = "0"
	   expires = "NOW">
</cfif>

<cfset prefill = 0>
<!--- check to see if guest cookie exists & remember me cookie set, is so, prefill form --->
<cfif isDefined('COOKIE.guestuuid') AND Len(Trim(COOKIE.guestuuid))>
	<!--- get all guest pertinent info & assign to FORM scope --->
	<cfset guestObj = CreateObject('component','#application.CFCpath#.guest')>
	<cfset q_guestInfo = guestObj.getGuest(guestuuid=Trim(COOKIE.guestuuid))>
	<cfif q_guestInfo.recordcount>
		<cfset FORM.guestid = Trim(q_guestInfo.guestid)>
	</cfif>
	
	<!--- if cookie.rememberme = 1, set form fields for pre-fill--->
	<cfif isDefined('COOKIE.rememberme') AND Trim(COOKIE.rememberme) eq 1 AND q_guestInfo.recordcount>
		<cfset prefill = 1>
		<cfset q_guestAccess = guestObj.getGuestAccess(guestid=Trim(q_guestInfo.guestid))>
		<cfset q_guestAddress = guestObj.getGuestAddress(guestid=Trim(q_guestInfo.guestid),limit=1)>
		<cfset q_guestEmail = guestObj.getGuestEmail(guestid=Trim(q_guestInfo.guestid),limit=1)>
		<cfset q_guestPhone = guestObj.getGuestPhone(guestid=Trim(q_guestInfo.guestid),limit=1)>
		
		<cfset guestQueries = "q_guestInfo,q_guestAddress,q_guestEmail,q_guestPhone">
		<cfloop list="#guestQueries#" index="thisQuery">
			<cfset colList = evaluate('#thisQuery#.columnlist')>
			<cfloop list="#colList#" index="column">
				<!--- don't set form variables for composite table ids (ie: guestAddressID) b/c want to cut new record, not update (countryid is an exception b/c its not a composite table)--->
				<cfif LCase(Right(column,2)) neq 'id' OR LCase(column) eq 'countryid'>
					<cfset "FORM.#column#" = evaluate("#thisQuery#.#column#")>
				</cfif>
			</cfloop>
		</cfloop>
		<cfset FORM.rememberme = "1">
	</cfif>
</cfif>

<!--- if prefilling form, give user the ability to say they are not the same user --->
<cfif prefill>
	<cfoutput><div class="guestPrefillNotUser">If you are not #FORM.firstname# #FORM.lastname# please click <a href="#request.thispage#?clearUser=1">here</a>.</div></cfoutput>
</cfif>

<cfset request.formstep = "showform">
<cfinclude template="#application.customtagpath#/formprocess.cfm">


