<cfoutput><!--- build radio button array --->
<input type="hidden" name="#a_formelements[a].fieldname#" id="#a_formelements[a].fieldname#" value="">
<cfif a_formelements[a].lookuptype eq "query"><!--- must return 2 query vars: lookupdisplay, lookupkey --->
<cfset thisQuery=a_formelements[a].lookupquery>
#open#cfquery datasource="#application.datasource#" name="q_getlist"#close#
#preserveSingleQuotes(thisQuery)#
#open#/cfquery#close#
#open#cfif isDefined("request.q_customQuery_#a_formelements[a].fieldname#")#close#
#open#cfset q_getlist=evaluate("request.q_customQuery_#a_formelements[a].fieldname#")#close#
#open#/cfif#close#
#open#!--- GEOMOD 030305 ---#close#
#open#!--- display table, rows/cols determined by recordcount vs. number of rows wanted ---#close#
#open#!--- set up the number of records to ouput, to the query recordcount, and number of rows wanted ---#close#
#open#cfset maxRecords=q_getlist.recordcount#close#
#open#cfset maxRows=3#close#
#open#!--- loop thru rows wanted, setting up the number of rows/cols according to recordcount ---#close#
#open#cfloop from="1" to="#pound#maxRows#pound#" step="1" index="colCt"#close#
	#open#cfif q_getlist.recordcount GT round(maxRecords*((round(100/maxRows)*(colCt-1))/100))#close#
		#open#cfset rowNum=round(q_getlist.recordcount/colCt)#close#
		#open#cfset colNum=colCt#close#
	#open#/cfif#close#
#open#/cfloop#close#
#open#cfparam name="rowNum" default="0"#close#
#open#cfparam name="colNum" default="0"#close#
#open#cfif val(rowNum*colNum) LT maxRecords#close##open#cfset rowNum=rownum+1#close##open#/cfif#close#
<table width="100%" border="0" cellspacing="0" cellpadding="0">
#open#cfloop from="1" to="#pound#rowNum#pound#" index="thisRow"#close#
<tr>
	#open#cfloop from="1" to="#pound#colNum#pound#" index="thisCol"#close#
		#open#!--- Get class for nested tables ---#close#
			#open#cfset a1=listFirst(a_formelements[a].gridposvalue,'_')#close#
			#open#cfset a2=listLast(a_formelements[a].gridposvalue,'_')#close#
				<td valign="top" class="#pound#evaluate("a_tableelements[#pound#a1#pound#].cell_#pound#a2#pound#.class")#pound#">
			#open#cfset thisHereRecord=val(thisRow+((thisCol-1)*rowNum))#close#
			#open#cfif thisHereRecord LTE maxRecords#close#<input type="radio" name="#a_formelements[a].fieldname#" id="#a_formelements[a].fieldname#" value="#pound#q_getlist.lookupkey[thisHereRecord]#pound#~#pound#q_getlist.lookupdisplay[thisHereRecord]#pound#"#open#cfif listcontainsnocase(evaluate('form.#a_formelements[a].fieldname#'),"#pound#q_getlist.lookupkey[thisHereRecord]#pound#")#close# checked#open#/cfif#close# #javascriptFunction#<cfif a_formelements[a].readonly EQ 1> readonly="readonly"</cfif><cfif len(a_formelements[a].tabindex)> tabindex="#a_formelements[a].tabindex#"</cfif>> #pound#q_getlist.lookupdisplay[thisHereRecord]#pound##open#cfelse#close#&nbsp;#open#/cfif#close# 
		</td>
	#open#/cfloop#close#
</tr>
#open#/cfloop#close#
</table>
#open#!--- /display table, rows/cols determined by recordcount vs. number of rows wanted ---#close#
<cfelseif a_formelements[a].lookuptype eq "table"><!--- must return 2 query vars: lookupdisplay, lookupkey --->
#open#cfquery datasource="#pound#application.datasource#pound#" name="q_getlist"#close#
	SELECT #a_formelements[a].lookupkey# AS lookupkey, #a_formelements[a].lookupdisplay# AS lookupdisplay FROM #a_formelements[a].lookuptable# ORDER BY #a_formelements[a].lookupdisplay# ASC
#open#/cfquery#close#
#open#!--- GEOMOD 030305 ---#close#
#open#!--- display table, rows/cols determined by recordcount vs. number of rows wanted ---#close#
#open#!--- set up the number of records to ouput, to the query recordcount, and number of rows wanted ---#close#
#open#cfset maxRecords=q_getlist.recordcount#close#
#open#cfset maxRows=3#close#
#open#!--- loop thru rows wanted, setting up the number of rows/cols according to recordcount ---#close#
#open#cfloop from="1" to="#pound#maxRows#pound#" step="1" index="colCt"#close#
	#open#cfif q_getlist.recordcount GT round(maxRecords*((round(100/maxRows)*(colCt-1))/100))#close#
		#open#cfset rowNum=round(q_getlist.recordcount/colCt)#close#
		#open#cfset colNum=colCt#close#
	#open#/cfif#close#
#open#/cfloop#close#
#open#cfparam name="rowNum" default="0"#close#
#open#cfparam name="colNum" default="0"#close#
#open#cfif val(rowNum*colNum) LT maxRecords#close##open#cfset rowNum=rownum+1#close##open#/cfif#close#
#open#cfparam name="tableattributes" default=""#close#
<table width="100%" border="0" cellspacing="0" cellpadding="0">
#open#cfloop from="1" to="#pound#rowNum#pound#" index="thisRow"#close#
<tr>
	#open#cfloop from="1" to="#pound#colNum#pound#" index="thisCol"#close#
	#open#cfset a1=listFirst(a_formelements[a].gridposvalue,'_')#close#
			#open#cfset a2=listLast(a_formelements[a].gridposvalue,'_')#close#
				<td valign="top" class="#pound#evaluate("a_tableelements[#pound#a1#pound#].cell_#pound#a2#pound#.class")#pound#">
			#open#cfset thisHereRecord=val(thisRow+((thisCol-1)*rowNum))#close#
			#open#cfif thisHereRecord LTE maxRecords#close##open#cfset fieldValue="#pound#q_getlist.lookupkey[thisHereRecord]#pound#~#pound#q_getlist.lookupdisplay[thisHereRecord]#pound#"#close#
			#open#cfset thisFormFieldValueList="#evaluate('form.#a_formelements[a].fieldname#')#"#close##open#/cfif#close#
			#open#cfif thisHereRecord LTE maxRecords#close#<input type="radio" name="#a_formelements[a].fieldname#" id="#a_formelements[a].fieldname#" value="#pound#fieldValue#pound#"#open#cfif listcontainsnocase(thisformfieldvaluelist,"#pound#q_getlist.lookupkey[thisHereRecord]#pound#")#close# checked#open#/cfif#close# #javascriptFunction#<cfif a_formelements[a].readonly EQ 1> readonly="readonly"</cfif><cfif len(a_formelements[a].tabindex)> tabindex="#a_formelements[a].tabindex#"</cfif>> #pound#q_getlist.lookupdisplay[thisHereRecord]#pound##open#cfelse#close#&nbsp;#open#/cfif#close#
		</td>
	#open#/cfloop#close#
</tr>
#open#/cfloop#close#
</table>
#open#!--- /display table, rows/cols determined by recordcount vs. number of rows wanted ---#close#
<cfelse><!--- must be a 2 delimiter list (key,value;) --->
#open#!--- GEOMOD 030305 ---#close#
#open#!--- display table, rows/cols determined by recordcount vs. number of rows wanted ---#close#
#open#!--- set up the number of records to ouput, to the query recordcount, and number of rows wanted ---#close#
#open#cfset maxRecords=listLen(a_formelements[a].lookuplist,";")#close#
#open#cfset maxRows=3#close#
#open#!--- loop thru rows wanted, setting up the number of rows/cols according to recordcount ---#close#
#open#cfloop from="1" to="#pound#maxRows#pound#" step="1" index="colCt"#close#
	#open#cfif listLen(a_formelements[a].lookuplist,";") GT round(maxRecords*((round(100/maxRows)*(colCt-1))/100))#close#
		#open#cfset rowNum=round(listLen(a_formelements[a].lookuplist,";")/colCt)#close#
		#open#cfset colNum=colCt#close#
	#open#/cfif#close#
#open#/cfloop#close#
#open#cfparam name="rowNum" default="0"#close#
#open#cfparam name="colNum" default="0"#close#
#open#cfif val(rowNum*colNum) LT maxRecords#close##open#cfset rowNum=rownum+1#close##open#/cfif#close#
#open#cfparam name="tableattributes" default=""#close#
<table width="100%" border="0" cellspacing="0" cellpadding="0">
#open#cfloop from="1" to="#pound#rowNum#pound#" index="thisRow"#close#
<tr>
	#open#cfloop from="1" to="#pound#colNum#pound#" index="thisCol"#close#
		#open#cfset a1=listFirst(a_formelements[a].gridposvalue,'_')#close#
		#open#cfset a2=listLast(a_formelements[a].gridposvalue,'_')#close#
				<td valign="top" class="#pound#evaluate("a_tableelements[#pound#a1#pound#].cell_#pound#a2#pound#.class")#pound#">
			#open#cfset thisHereRecord=val(thisRow+((thisCol-1)*rowNum))#close#
			#open#cfif thisHereRecord LTE maxRecords#close#<input type="radio" name="#a_formelements[a].fieldname#" id="#a_formelements[a].fieldname#" value="#pound#listFirst(listGetAt(a_formelements[a].lookuplist,thisHereRecord,';'),',')#pound#~#pound#listLast(listGetAt(a_formelements[a].lookuplist,thisHereRecord,';'),',')#pound#"#open#cfif listcontainsnocase(evaluate('form.#a_formelements[a].fieldname#'),"#pound#listFirst(listGetAt(a_formelements[a].lookuplist,thisHereRecord,';'),',')#pound#")#close# checked#open#/cfif#close# #javascriptFunction#<cfif a_formelements[a].readonly EQ 1> readonly="readonly"</cfif><cfif len(a_formelements[a].tabindex)> tabindex="#a_formelements[a].tabindex#"</cfif>> #pound#listLast(listGetAt(a_formelements[a].lookuplist,thisHereRecord,';'),',')#pound##open#cfelse#close#&nbsp;#open#/cfif#close#
		</td>
	#open#/cfloop#close#
</tr>
#open#/cfloop#close#
</table>
#open#!--- /display table, rows/cols determined by recordcount vs. number of rows wanted ---#close#
</cfif></cfoutput>