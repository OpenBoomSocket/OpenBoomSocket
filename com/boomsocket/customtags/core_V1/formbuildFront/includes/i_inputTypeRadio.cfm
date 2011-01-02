<cfoutput><cfif structKeyExists(evaluate("a_tableelements[#listFirst(a_formelements[a].gridposvalue,'_')#].cell_#listLast(a_formelements[a].gridposvalue,'_')#"),"nowrap") AND evaluate("a_tableelements[#listFirst(a_formelements[a].gridposvalue,'_')#].cell_#listLast(a_formelements[a].gridposvalue,'_')#.nowrap") EQ 1>
	<cfset nowrap=1>
<cfelse>
	<cfset nowrap=0>
</cfif>

<input type="hidden" name="#a_formelements[a].fieldname#" id="#a_formelements[a].fieldname#_hidden" value="">
<cfif a_formelements[a].lookuptype eq "query"><!--- must return 2 query vars: lookupdisplay, lookupkey --->
<cfset thisQuery=a_formelements[a].lookupquery>
<cfquery datasource="#application.datasource#" name="q_getlist" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	#preserveSingleQuotes(thisQuery)#
</cfquery>
<cfif isDefined("request.q_customQuery_#a_formelements[a].fieldname#")>
	<cfset q_getlist=evaluate("request.q_customQuery_#a_formelements[a].fieldname#")>
</cfif>
	<!--- display table, rows/cols determined by recordcount vs. number of rows wanted --->
	<!--- set up the number of records to ouput, to the query recordcount, and number of rows wanted --->
	<cfset maxRecords=q_getlist.recordcount>
	<cfset maxRows=3>
	<!--- loop thru rows wanted, setting up the number of rows/cols according to recordcount --->
	<cfloop from="1" to="#maxRows#" step="1" index="colCt">
		<cfif q_getlist.recordcount GT round(maxRecords*((round(100/maxRows)*(colCt-1))/100))>
			<cfset rowNum=round(q_getlist.recordcount/colCt)>
			<cfset colNum=colCt>
		</cfif>
	</cfloop>
	<cfparam name="rowNum" default="0">
	<cfparam name="colNum" default="0">
	<cfif val(rowNum*colNum) LT maxRecords><cfset rowNum=rownum+1></cfif>
	<cfif nowrap>
		<cfset rowNum=1>
		<cfset colNum=maxRecords>
	</cfif>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<cfloop from="1" to="#rowNum#" index="thisRow">
	<tr>
		<cfloop from="1" to="#colNum#" index="thisCol">
		<!--- Get class for nested tables --->
		<cfset a1=listFirst(a_formelements[a].gridposvalue,'_')>
		<cfset a2=listLast(a_formelements[a].gridposvalue,'_')>
			<td valign="top" class="#evaluate("a_tableelements[#a1#].cell_#a2#.class")#"<cfif nowrap> nowrap="nowrap"</cfif>>
				<cfset thisHereRecord=val(thisRow+((thisCol-1)*rowNum))>
				<cfif thisHereRecord LTE maxRecords><input type="radio" name="#a_formelements[a].fieldname#" id="#a_formelements[a].fieldname#" value="#q_getlist.lookupkey[thisHereRecord]#~#q_getlist.lookupdisplay[thisHereRecord]#"<cfif q_getlist.lookupkey[thisHereRecord] EQ listfirst(evaluate('form.#a_formelements[a].fieldname#'),"~")> checked</cfif> #javascriptFunction#<cfif a_formelements[a].readonly EQ 1> readonly="readonly"</cfif><cfif len(a_formelements[a].tabindex)> tabindex="#a_formelements[a].tabindex#"</cfif>> #q_getlist.lookupdisplay[thisHereRecord]#<cfelse>&nbsp;</cfif>
			</td>
		</cfloop>
	</tr>
	</cfloop>
	</table>
	<!--- /display table, rows/cols determined by recordcount vs. number of rows wanted --->
<cfelseif a_formelements[a].lookuptype eq "table"><!--- must return 2 query vars: lookupdisplay, lookupkey --->
	<cfquery datasource="#application.datasource#" name="q_getlist" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT #a_formelements[a].lookupkey# AS lookupkey, #a_formelements[a].lookupdisplay# AS lookupdisplay FROM #a_formelements[a].lookuptable# ORDER BY #a_formelements[a].lookupdisplay# ASC
	</cfquery>
	<!--- display table, rows/cols determined by recordcount vs. number of rows wanted --->
	<!--- set up the number of records to ouput, to the query recordcount, and number of rows wanted --->
	<cfset maxRecords=q_getlist.recordcount>
	<cfset maxRows=3>
	<!--- loop thru rows wanted, setting up the number of rows/cols according to recordcount --->
	<cfloop from="1" to="#maxRows#" step="1" index="colCt">
		<cfif q_getlist.recordcount GT round(maxRecords*((round(100/maxRows)*(colCt-1))/100))>
			<cfset rowNum=round(q_getlist.recordcount/colCt)>
			<cfset colNum=colCt>
		</cfif>
	</cfloop>
	<cfparam name="rowNum" default="0">
	<cfparam name="colNum" default="0">
	<cfif val(rowNum*colNum) LT maxRecords><cfset rowNum=rownum+1></cfif>
	<cfparam name="tableattributes" default="">
	<cfif nowrap>
		<cfset rowNum=1>
		<cfset colNum=maxRecords>
	</cfif>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<cfloop from="1" to="#rowNum#" index="thisRow">
	<tr>
		<cfloop from="1" to="#colNum#" index="thisCol">
			<!--- Get class for nested tables --->
			<cfset a1=listFirst(a_formelements[a].gridposvalue,'_')>
			<cfset a2=listLast(a_formelements[a].gridposvalue,'_')>
			<td valign="top" class="#evaluate("a_tableelements[#a1#].cell_#a2#.class")#"<cfif nowrap> nowrap="nowrap"</cfif>>
				<cfset thisHereRecord=val(thisRow+((thisCol-1)*rowNum))>
				<cfif thisHereRecord LTE maxRecords><input type="radio" name="#a_formelements[a].fieldname#" id="#a_formelements[a].fieldname#" value="#q_getlist.lookupkey[thisHereRecord]#~#q_getlist.lookupdisplay[thisHereRecord]#"<cfif q_getlist.lookupkey[thisHereRecord] EQ listfirst(evaluate('form.#a_formelements[a].fieldname#'),"~")> checked</cfif> #javascriptFunction#<cfif a_formelements[a].readonly EQ 1> readonly="readonly"</cfif><cfif len(a_formelements[a].tabindex)> tabindex="#a_formelements[a].tabindex#"</cfif>> #q_getlist.lookupdisplay[thisHereRecord]#<cfelse>&nbsp;</cfif>
			</td>
		</cfloop>
	</tr>
	</cfloop>
	</table>
	<!--- /display table, rows/cols determined by recordcount vs. number of rows wanted --->
<cfelse><!--- must be a 2 delimiter list (key,value;) --->
	<!--- display table, rows/cols determined by recordcount vs. number of rows wanted --->
	<!--- set up the number of records to ouput, to the query recordcount, and number of rows wanted --->
	<cfset maxRecords=listLen(a_formelements[a].lookuplist,";")>
	<cfset maxRows=3>
	<!--- loop thru rows wanted, setting up the number of rows/cols according to recordcount --->
	<cfloop from="1" to="#maxRows#" step="1" index="colCt">
		<cfif listLen(a_formelements[a].lookuplist,";") GT round(maxRecords*((round(100/maxRows)*(colCt-1))/100))>
			<cfset rowNum=round(listLen(a_formelements[a].lookuplist,";")/colCt)>
			<cfset colNum=colCt>
		</cfif>
	</cfloop>
	<cfparam name="rowNum" default="0">
	<cfparam name="colNum" default="0">
	<cfif val(rowNum*colNum) LT maxRecords><cfset rowNum=rownum+1></cfif>
	<cfparam name="tableattributes" default="">
	<cfif nowrap>
		<cfset rowNum=1>
		<cfset colNum=maxRecords>
	</cfif>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<cfloop from="1" to="#rowNum#" index="thisRow">
	<tr>
		<cfloop from="1" to="#colNum#" index="thisCol">
		<!--- Get class for nested tables --->
		<cfset a1=listFirst(a_formelements[a].gridposvalue,'_')>
		<cfset a2=listLast(a_formelements[a].gridposvalue,'_')>
			<td valign="top" class="#evaluate("a_tableelements[#a1#].cell_#a2#.class")#"<cfif nowrap> nowrap="nowrap"</cfif>>
				<cfset thisHereRecord=val(thisRow+((thisCol-1)*rowNum))>
				<cfif thisHereRecord LTE maxRecords><input type="radio" name="#a_formelements[a].fieldname#" id="#a_formelements[a].fieldname#" value="#listFirst(listGetAt(a_formelements[a].lookuplist,thisHereRecord,';'),',')#~#listLast(listGetAt(a_formelements[a].lookuplist,thisHereRecord,';'),',')#"<cfif listContainsNoCase(evaluate('form.#a_formelements[a].fieldname#'),"#listFirst(listGetAt(a_formelements[a].lookuplist,thisHereRecord,';'),',')#")> checked</cfif> #javascriptFunction#<cfif a_formelements[a].readonly EQ 1> readonly="readonly"</cfif><cfif len(a_formelements[a].tabindex)> tabindex="#a_formelements[a].tabindex#"</cfif>> #listLast(listGetAt(a_formelements[a].lookuplist,thisHereRecord,';'),',')#<cfelse>&nbsp;</cfif>
			</td>
		</cfloop>
	</tr>
	</cfloop>
	</table>
	<!--- /display table, rows/cols determined by recordcount vs. number of rows wanted --->
</cfif></cfoutput>