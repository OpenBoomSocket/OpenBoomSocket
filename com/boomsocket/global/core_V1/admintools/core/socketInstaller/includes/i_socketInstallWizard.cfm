<!------------------------------------------------- >

ORIGINAL AUTHOR ::::::::: Emile Melbourne (EOM)
	CREATION DATE ::::::::::: 6/22/2008
	LAST MODIFIED AUTHOR :::: EOM
	LAST MODIFIED DATE :::::: 6/22/2008
	EDIT HISTORY :::::::::::: 
								  :: 6/22/2008 yyyy-mm-dd Initial Creation EOM
	FILENAME :::::::::::::::: i_importWizard.cfm
	DEPENDENCIES :::::::::::: BS_Global/core_V1a/admintools/core/socketinstaller/index.cfm
	DESCRIPTION ::::::::::::: 
-----------------------------------------------------> 
<cfoutput> Install as is or make changes to the install
	
	::: 
	At this point either use DHTML to show a new window or refresh to a new window with the options<br />
	For now refresh and use DHTML and AJAX in the future when we've thought up a great BS AJAX Framework.
	:::
	<!--- Form post back to itself via #REQUEST.page# variable--->
	<form name="import" method="post" action="#REQUEST.page#">
		<input type="hidden" name="importname" id="importname" value="#FORM.importname#">
		<input type="hidden" name="formAction" id="formAction" value="import">
		<input value="Normal Install" name="submitBtn" type="submit" class="submitbutton">
		<input value="Custom Install" name="submitBtn" type="submit" class="submitbutton">
		<input value="Cancel" type="button" class="submitbutton" onClick="javascript:window.location='#REQUEST.page#';">
	</form>
	::: #REQUEST.page#
</cfoutput> 