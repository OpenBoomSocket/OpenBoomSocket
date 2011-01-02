<!--- This include is designed to be called before loading 
a dynamic form to allow user to pick an existing record to edit
 --->


<cfquery datasource="#application.datasource#" name="q_getKeyFields" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT #q_getForm.datatable#ID, #q_getForm.editFieldKeyValue#
	FROM #q_getForm.datatable#
	ORDER BY #q_getForm.editFieldSortOrder#
</cfquery>

<cfset defaultSelectaction="basicSelect">
<cfparam name="selectaction" default="#defaultSelectaction#">

<cfswitch expression="#selectaction#">

<cfcase value="basicSelect">
	<cfoutput>
		<form action="#request.page#" method="post">
			<select name="instanceid" size="1">
				<option value="0">Create New
				<cfloop query="q_getKeyFields">
				<option value="#evaluate('q_getKeyFields.#q_getForm.datatable#ID')#"><cfloop list="#q_getForm.editFieldKeyValue#" index="i">#evaluate('q_getKeyFields.#i#')# </cfloop></option>
				</cfloop>
			</select>
		<input type="hidden" name="formstep" value="showform">
		<input type="hidden" name="displayForm" value="1">
		<cfset buttonwidth=(len(q_getForm.label)*14)>
		<input type="submit" class="submitbutton" value="Add/Modify #q_getForm.label#" style="width:#buttonwidth#;">
		
		</form>
	</cfoutput>
</cfcase>
</cfswitch>
