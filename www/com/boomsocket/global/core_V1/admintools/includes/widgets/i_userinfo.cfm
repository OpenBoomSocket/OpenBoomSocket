<cfoutput>
	<div id="userInfoBox">
		<div id="adminUserData">Welcome #SESSION.user.name#!</div>
		<div id="adminDateLine">#dateFormat(now(),"mmmm d, yyyy")# #timeFormat(now(),"h:mm tt")#</div><div style="clear:both;"></div>
	</div>
</cfoutput>