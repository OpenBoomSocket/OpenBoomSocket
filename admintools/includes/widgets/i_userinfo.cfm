<cfoutput>
	<div id="adminDateLine">#dateFormat(now(),"mmmm d, yyyy")# #timeFormat(now(),"h:mm tt")#</div>
	<div id="adminUserData">Welcome #SESSION.user.name#, you are logged in.</div>
</cfoutput>