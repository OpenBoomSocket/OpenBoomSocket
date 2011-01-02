<!------------------------------------------------- >

ORIGINAL AUTHOR ::::::::: Emile Melbourne (EOM)
	CREATION DATE ::::::::::: 6/22/2008
	LAST MODIFIED AUTHOR :::: EOM
	LAST MODIFIED DATE :::::: 6/22/2008
	EDIT HISTORY :::::::::::: 
		6/22/2008 yyyy-mm-dd Initial Creation EOM
	FILENAME :::::::::::::::: i_importconfirm.cfm
	DESCRIPTION ::::::::::::: 
-----------------------------------------------------> 

<cfoutput>
	<div style="clear:both;"></div>
	<div>
		<h3>:::Import these Sockets:::</h3>
		<ul>
			<cfloop list="#FORM.importname#" index="pluginid">
				<li>#pluginid#</li>
			</cfloop>
		</ul>
		<form name="import" method="post" action="#request.page#">
			<input type="hidden" name="importname" id="importname" value="#FORM.importname#">
			<input type="hidden" name="formAction" id="formAction" value="import">
			<input value="Import" type="submit" class="submitbutton">
			<input value="Cancel" type="button" class="submitbutton" onClick="javascript:window.location='#request.page#';">
		</form>
	</div>
</cfoutput> 