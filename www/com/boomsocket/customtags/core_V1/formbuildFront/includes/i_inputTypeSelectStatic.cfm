<cfoutput><!--- build select --->
<select name="#a_formelements[a].fieldname#" id="#a_formelements[a].fieldname#"<cfif len(a_formelements[a].lookupmultiple)> size="#a_formelements[a].lookupmultiple#"</cfif><cfif a_formelements[a].lookupmultiple GT 1> Multiple</cfif> #javascriptFunction# class="#a_formelements[a].inputstyle#"><option value=""<cfif a_formelements[a].lookupmultiple GT 1> SELECTED</cfif><cfif a_formelements[a].readonly EQ 1> readonly="readonly"</cfif><cfif len(a_formelements[a].tabindex)> tabindex="#a_formelements[a].tabindex#"</cfif>>Select-----</option>
	<cfif a_formelements[a].lookuptype eq "query"><!--- must return 2 query vars: lookupdisplay, lookupkey --->
		<cfset thisQuery=a_formelements[a].lookupquery>
#open#cfquery datasource="#application.datasource#" name="q_getlist"#close#
	#preserveSingleQuotes(thisQuery)#
#open#/cfquery#close#
#open#cfif isDefined("request.q_customQuery_#a_formelements[a].fieldname#")#close#
	#open#cfset q_getlist=evaluate("request.q_customQuery_#a_formelements[a].fieldname#")#close#
#open#/cfif#close#
		#open#cfloop query="q_getlist"#close#
			<option value="#pound#q_getlist.lookupkey#pound#" id="#pound#q_getlist.lookupkey#pound#"#open#cfif listfindnocase(evaluate('form.#a_formelements[a].fieldname#'),q_getlist.lookupkey)#close# selected#open#/cfif#close#>#pound#q_getlist.lookupdisplay#pound#</option> 
		#open#/cfloop#close#
	<cfelseif a_formelements[a].lookuptype eq "table"><!--- must return 2 query vars: lookupdisplay, lookupkey --->
		#open#cfquery datasource="#pound#application.datasource#pound#" name="q_getlist"#close#
			SELECT #a_formelements[a].lookupkey# AS lookupkey, #a_formelements[a].lookupdisplay# AS lookupdisplay FROM #a_formelements[a].lookuptable#  ORDER BY #a_formelements[a].lookupdisplay# ASC
		#open#/cfquery#close#
		#open#cfloop query="q_getlist"#close#
			<option value="#pound#q_getlist.lookupkey#pound#"#open#cfif listfindnocase(evaluate('form.#a_formelements[a].fieldname#'),q_getlist.lookupkey)#close# selected#open#/cfif#close#>#pound#q_getlist.lookupdisplay#pound#</option> 
		#open#/cfloop#close#
	<cfelse><!--- must be a 2 delimiter list (key,value;) --->
		#open#cfloop list="#a_formelements[a].lookuplist#" index="item" delimiters=";"#close#
			<option value="#pound#listFirst(item,',')#pound#"#open#cfif listfindnocase(evaluate('form.#a_formelements[a].fieldname#'),listfirst(item,','))#close# selected#open#/cfif#close#>#pound#listLast(item,',')#pound#</option>
		#open#/cfloop#close#
	</cfif>
</select></cfoutput>