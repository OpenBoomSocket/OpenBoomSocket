<!-------------------------------------------------

	ORIGINAL AUTHOR ::::::::: Emile Melbourne (EOM)
	CREATION DATE ::::::::::: 6/22/2008
	LAST MODIFIED AUTHOR :::: EOM
	LAST MODIFIED DATE :::::: 6/22/2008
	EDIT HISTORY :::::::::::: 
								  :: 6/22/2008 Initial Creation EOM
	FILENAME :::::::::::::::: i_uninstallconfirm.cfm
	DESCRIPTION ::::::::::::: 
---------------------------------------------------->

<cfoutput>
	<div style="clear:both;"></div>
	<div>
		<h3>:::Un-Install these Sockets:::</h3>
		<ul>
			<cfloop list="#FORM.uninstallid#" index="pluginid">
				<cfquery name="q_plugininfo" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							SELECT formobjectname AS socketname
							FROM formobject
							WHERE formobjectid = #pluginid#	
						</cfquery>
				<li>#q_plugininfo.socketname#</li>
			</cfloop>
		</ul>
		<form name="uninstall" method="post" action="#request.page#">
			<input type="hidden" name="uninstallid" id="uninstallid" value="#FORM.uninstallid#">
			<input type="hidden" name="formAction" id="formAction" value="uninstall">
			<input value="Uninstall" type="submit" class="submitbutton">
			<input value="Cancel" type="button" class="submitbutton" onClick="javascript:window.location='#request.page#';">
		</form>
	</div>
</cfoutput> 