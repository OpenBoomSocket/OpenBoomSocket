<cfoutput><select name="#a_formelements[a].fieldname#" id="#a_formelements[a].fieldname#"<cfif len(a_formelements[a].lookupmultiple)> size="#a_formelements[a].lookupmultiple#"</cfif> #javascriptFunction# class="#a_formelements[a].inputstyle#"<cfif a_formelements[a].lookupmultiple GT 1> multiple="multiple"</cfif><cfif len(a_formelements[a].tabindex)> tabindex="#a_formelements[a].tabindex#"</cfif>><option value=""<!---  commented out by DRK 10/22/2007 <cfif a_formelements[a].lookupmultiple GT 1> SELECTED</cfif> ---><cfif a_formelements[a].readonly EQ 1> readonly="readonly"</cfif>>Select-----</option>
	<cfif a_formelements[a].lookuptype eq "query"><!--- must return 2 query vars: lookupdisplay, lookupkey --->
		<cfset thisQuery=a_formelements[a].lookupquery>
<cfquery datasource="#application.datasource#" name="q_getlist" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	#preserveSingleQuotes(thisQuery)#
</cfquery>
<cfif isDefined("request.q_customQuery_#a_formelements[a].fieldname#")>
	<cfset q_getlist=evaluate("request.q_customQuery_#a_formelements[a].fieldname#")>
</cfif>
		<!--- <cfloop query="q_getlist">
			<option value="#q_getlist.lookupkey#~#q_getlist.lookupdisplay#"<cfif listFindNoCase(listfirst(evaluate('form.#a_formelements[a].fieldname#'),"~"),q_getlist.lookupkey)> selected</cfif>>#q_getlist.lookupdisplay#</option> 
		</cfloop> 
		Dont know why this wasn't working - Ben - leaving the ^^^ commented out just for you ;) --->
		<cfloop query="q_getlist">
			<option value="#q_getlist.lookupkey#~#q_getlist.lookupdisplay#" id="#q_getlist.lookupkey#~#q_getlist.lookupdisplay#"<cfloop list="#evaluate('form.#a_formelements[a].fieldname#')#" index="thisListItem" delimiters=","><cfif listFindNoCase(listfirst(thisListItem,"~"),q_getlist.lookupkey)> selected<cfbreak></cfif></cfloop>>#q_getlist.lookupdisplay#</option> 
		</cfloop>
	<cfelseif a_formelements[a].lookuptype eq "table"><!--- must return 2 query vars: lookupdisplay, lookupkey --->
		<cfquery datasource="#application.datasource#" name="q_getlist" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT #a_formelements[a].lookupkey# AS lookupkey, #a_formelements[a].lookupdisplay# AS lookupdisplay FROM #a_formelements[a].lookuptable#  ORDER BY #a_formelements[a].lookupdisplay# ASC
		</cfquery>
		<cfloop query="q_getlist">
			<option value="#q_getlist.lookupkey#~#q_getlist.lookupdisplay#"<cfif listFindNoCase(listfirst(evaluate('form.#a_formelements[a].fieldname#'),"~"),q_getlist.lookupkey)> selected</cfif>>#q_getlist.lookupdisplay#</option> 
		</cfloop>
	<cfelse><!--- must be a 2 delimiter list (key,value;) --->
		<cfloop list="#a_formelements[a].lookuplist#" index="item" delimiters=";">
			<option value="#listFirst(item,',')#~#listLast(item,',')#"<cfif listFindNoCase(listfirst(evaluate('form.#a_formelements[a].fieldname#'),"~"),listFirst(item,','))> selected</cfif>>#listLast(item,',')#</option>
		</cfloop>
	</cfif>
</select></cfoutput>