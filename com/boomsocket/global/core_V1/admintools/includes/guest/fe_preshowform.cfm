<!--- ADMIN: fe_preshowform.cfm --->

<!--- don't need to check for cookie for pre-fill in admin
check to see if guest cookie exists & remember me cookie set, is so, prefill form
<cfif isDefined('COOKIE.guestuuid') AND Len(Trim(COOKIE.guestuuid))>
	<!--- get all guest pertinent info & assign to FORM scope --->
	<cfset guestObj = CreateObject('component','#application.CFCpath#.guest')>
	<cfset q_guestInfo = guestObj.getGuest(guestuuid=Trim(COOKIE.guestuuid))>
	<cfset FORM.guestid = Trim(q_guestInfo.guestid)>
	
	<!--- if cookie.rememberme = 1, set form fields for pre-fill--->
	<cfif isDefined('COOKIE.rememberme') AND Trim(COOKIE.rememberme) eq 1>
		<cfset q_guestAccess = guestObj.getGuestAccess(guestid=Trim(q_guestInfo.guestid))>
		<cfset q_guestAddress = guestObj.getGuestAddress(guestid=Trim(q_guestInfo.guestid),limit=1)>
		<cfset q_guestEmail = guestObj.getGuestEmail(guestid=Trim(q_guestInfo.guestid),limit=1)>
		<cfset q_guestPhone = guestObj.getGuestPhone(guestid=Trim(q_guestInfo.guestid),limit=1)>
		
		<cfset guestQueries = "q_guestInfo,q_guestAddress,q_guestEmail,q_guestPhone">
		<cfloop list="#guestQueries#" index="thisQuery">
			<cfset colList = evaluate('#thisQuery#.columnlist')>
			<cfloop list="#colList#" index="column">
				<cfif LCase(Right(column,2)) neq 'id'>
					<cfset "FORM.#column#" = evaluate("#thisQuery#.#column#")>
				</cfif>
			</cfloop>
		</cfloop>
		<cfset FORM.rememberme = "1~ ">
	</cfif>
</cfif> --->

<cfset request.formstep = "showform">
<cfinclude template="/CustomTags/#application.customtagpath#/formprocess.cfm">


