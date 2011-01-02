<!--- This include is designed to be called before loading 
a dynamic form to allow user to pick an existing record to edit
 --->
<cfif thistag.executionmode is "START">
<cfset defaultSelectaction="detailView">
<cfset AmbiguousList="ParentID,DateCreated,DateModified,Ordinal">
<cfparam name="selectaction" default="#defaultSelectaction#">

<cfparam name="maxRecords" default=60>
<cfparam name="maxRows" default="3">
<cfset rowNum=0>
<cfset colNum=0>

<cfset request.filterImages="/images/formInstanceFilter">

<!--- Build sort string --->
<cfset newQueryString="">
<cfif listLen(CGI.QUERY_STRING,"&")>
	<cfloop list="#CGI.QUERY_STRING#" index="q" delimiters="&">
		<cfif listFirst(q,"=") NEQ "sort">
			<cfset newQueryString=listAppend(newQueryString,q,"&")>
		</cfif>
	</cfloop>
</cfif>
<!--- Build search string --->
<cfset searchQueryString="">
<cfif listLen(CGI.QUERY_STRING,"&")>
	<cfloop list="#CGI.QUERY_STRING#" index="q" delimiters="&">
		<cfif listFirst(q,"=") NEQ "selectaction">
			<cfset searchQueryString=listAppend(searchQueryString,q,"&")>
		</cfif>
	</cfloop>
</cfif>



<cfif selectaction eq "detailView">
	<cfset keyvalue=request.q_getForm.editFieldKeyValue2>
	<cfloop list="#keyvalue#" index="s">
		<cfset "sort#s#"="DESC">
	</cfloop>
	<cfif isDefined("url.sort")>
		<cfset sortvalue=urldecode(url.sort)>
		<cfset "sort#listFirst(urldecode(url.sort),' ')#"=listLast(urldecode(url.sort)," ")>
	<cfelse>
		<cfset sortvalue=request.q_getForm.editFieldSortOrder2>
	</cfif>	
<cfelse>
	<cfset keyvalue=request.q_getForm.editFieldKeyValue>
	<cfset sortvalue=request.q_getForm.editFieldSortOrder>	
</cfif>

<table border="0" cellspacing="0" cellpadding="0" width="98%">
<cfparam name="form.search" default="">

	<cfoutput>
	 <tr valign="top">
		<td class="toolheader" colspan="2">#request.q_getForm.label#</td>
	  </tr>
	  <tr valign="top">
					<td class="subtoolheader" align="left" valign="top"><table border="0" cellspacing="0" cellpadding="0"><tr><td valign="top"><cfif selectaction EQ "listing"><a href="#request.page#?selectaction=detailView&#searchQueryString#" title="View Details"><img src="/admintools/media/images/icon_detailView.gif" border="0"></a>&nbsp;<cfelse><a href="#request.page#?selectaction=listing&#searchQueryString#" title="View as List"><img src="/admintools/media/images/icon_listView.gif" border="0"></a>&nbsp;</cfif></td><td valign="top">
						<form action="#request.page#" method="post">
							<input type="hidden" name="formstep" value="showform">
							<input type="hidden" name="displayForm" value="1">				
							<input type="image" value="Add a New #request.q_getForm.label#" src="#application.globalPath#/media/images/icon_addFile.gif" alt="Add new #request.q_getForm.label#">&nbsp;
						</form></td>
						<cfif request.q_getForm.useOrdinal eq 1><td valign="top">
						<form action="#request.page#" method="post">
							<input type="hidden" name="formstep" value="ordinalForm">
							<input type="hidden" name="formobjectid" value="#request.q_getForm.formobjectid#">
							<input type="image" value="Modify order of #request.q_getForm.label#" src="#application.globalPath#/media/images/icon_ordinal.gif" alt="Modify order of #request.q_getForm.label#">&nbsp;
						</form></td>
						</cfif>
						<cfif isDefined('request.q_getForm.useMappedContent') AND request.q_getForm.useMappedContent eq 1><td valign="top">
						<form action="javascript:window.open('/admintools/includes/i_ContentMapping.cfm','MapContent','menubar=no,statusbar=no,resizable,width=600,height=400');window.location(#request.page#)" method="post">
							<input type="hidden" name="formstep" value="showform">
							<input type="hidden" name="displayForm" value="1">
							<input type="image" value="Modify mappings of #request.q_getForm.label# items" src="#application.installurl#/admintools/media/images/icon_mapping.gif" title="Modify mappings for #request.q_getForm.label# items">&nbsp;
						</form></td>
						</cfif>
						</tr></table>
					</td>
					<td class="subtoolheader" nowrap align="right" valign="top">
						<table border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="subtoolheader" valign="top" align="right"><form action="#request.page#" method="get" name="form1" id="form1">
								<input type="Hidden" name="search" value="1">
								<input type="Hidden" name="selectaction" value="#selectaction#">
								<input type="hidden" name="formname" value="#request.q_getForm.formname#">
							<cfloop list="#request.q_getForm.editFieldKeyValue#" index="i">
							<!--- loop to find label --->
							<cfloop index="t" from="1" to="#arrayLen(request.a_formelements)#">
								<cfif structFind(request.a_formelements[t],"fieldname") eq i>
									<cfset thisKey=request.a_formelements[t].objectlabel>
									<cfbreak>
								<cfelse>
									<cfset thisKey=i>
								</cfif>
							</cfloop>
							#application.stripHTML(thisKey)# <input type="text" name="#i#" <cfif isdefined("url.#i#")>value="#evaluate('url.#i#')#" </cfif>size="15" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: 11px;"><br />
							</cfloop></td>
								<td class="subtoolheader" valign="top"><input name="submit" type="submit" value="Search" class="submitbutton" style="width: 72px;" >
							</form><br /><span></span></td>
							</tr>
						</table>						 
				    </td>
	  		</tr>
	</cfoutput>



<cfswitch expression="#selectaction#">
<!--- Display in column view with sort functionality --->
<cfcase value="detailView">
		<!--- build select, from, and where clauses, pr3pp1in for the big query shindig --->
		<cfset selectClause="#request.q_getForm.datatable#.#request.q_getForm.datatable#ID">
		<cfset fromCause="#request.q_getForm.datatable#">
		<cfset newKeyValue="">
		<cfset newKeyValue2="">
		<cfset whereClause="">
		<cfloop list="#request.q_getForm.editFieldKeyValue2#" index="i">
			<cfif right(i,2) EQ "id">
				<!--- see if the table exists --->
				<cfset thisTable=removeChars(i,len(i)-1,2)>
				<cftry>
					<cfquery name="q_test4table" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						SELECT count(#i#) FROM #thisTable#
					</cfquery>
					<cfset tableExists=1>					
				<cfcatch type="Database"><cfset tableExists=0></cfcatch>
				</cftry>
				<cfif tableExists>
					<cfset selectClause=listAppend(selectClause,"#thisTable#.#thisTable#name")>
					<cfset newKeyValue=listAppend(newKeyValue,"#thisTable#name")>
					<cfif thisTable EQ request.q_getForm.datatable>
						<cfset newKeyValue2=listAppend(newKeyValue2,"#thisTable#name")>
					<cfelse>
						<cfset newKeyValue2=listAppend(newKeyValue2,"#thisTable#name")>
					</cfif>
					<cfif request.q_getForm.datatable NEQ thisTable>
						<cfset fromCause=fromCause&" INNER JOIN #thisTable# ON  #request.q_getForm.datatable#.#thisTable#id=#thisTable#.#thisTable#id">
					</cfif>
				</cfif>
			</cfif>
			
			<cfif isDefined("url.#i#") AND len(evaluate('url.'&i))>
				<cfif len(whereClause)>
					<cfset whereClause=urlDecode(whereClause)&" AND ">
				</cfif>
				<cfset whereClause=whereClause&"#i# LIKE '%#evaluate('url.'&i)#%'">
			</cfif>
			
		</cfloop>
		<cfif listLen(newKeyValue)>
			<cfset keyvalue=lcase(newKeyValue)>
		</cfif>

		<!--- if there is no list built, then add the keyvalues onto the selectClause as per original query --->
		<cfif listLen(selectClause) EQ 1>
			<cfset selectClause=listAppend(selectClause,"#request.q_getForm.editFieldKeyValue2#")>
		</cfif>
			<cfif isDefined("url.sort")>
				<cfset orderVar=urldecode(url.sort)>
			<cfelse>
				<cfset orderVar=request.q_getForm.editFieldSortOrder2>
			</cfif>
			<cfloop list="#AmbiguousList#" index="thisAmbItem">
				<cfset orderVar=replaceNoCase(orderVar,"#thisAmbItem# ","#request.q_getForm.datatable#.#thisAmbItem# ")>
			</cfloop>
		<cfquery datasource="#application.datasource#" name="q_getKeyFields" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT #lcase(selectClause)#
			FROM #lcase(fromCause)#
			<cfif len(whereclause)>
			WHERE #preserveSingleQuotes(whereclause)#
			</cfif>
			ORDER BY #orderVar#
		</cfquery>

		<cfif q_getKeyFields.recordcount>
			<cfoutput>
				<tr>
					<td colspan="2" class="subtoolheader" align="right">#q_getKeyFields.recordcount# Record<cfif q_getKeyFields.recordcount GT 1>s</cfif> Found.</td>
				</tr>
			</cfoutput>	
		</cfif>
		
		<cfif q_getKeyFields.recordcount EQ 1 AND isDefined("url.search")>
			<cflocation url="#request.page#?instanceid=#evaluate('q_getKeyFields.#request.q_getForm.datatable#ID')#&formstep=showform">
		</cfif>

	<cfparam name="attributes.page_size" default="#val(maxRecords\3)#">
	<cfmodule template="#application.customTagPath#/previous_next.cfm" query="#q_getKeyFields#" query_name="thisList" page_size="#attributes.page_size#">
	<cfloop from="1" to="#maxRows#" step="1" index="colCt">
		<cfif thisList.recordcount GT round(maxRecords*((round(100/maxRows)*(colCt-1))/100))>
			<cfset rowNum=round(thisList.recordcount/colCt)>
			<cfset colNum=colCt>
		</cfif>
	</cfloop>
	<cfif val(rowNum*colNum) LT maxRecords><cfset rowNum=rownum+1></cfif>
<cfif isDefined("successMsg")>
	<tr>
		<td colspan="2" class="successmsg" align="center">#successMsg#</td>
	</tr>
</cfif>
<!--- set delete flag DO NOT DELETE THIS COMMENT--->
<cfif (IsDefined("session.man#request.q_getForm.formname#del")) AND (evaluate('session.man#request.q_getForm.formname#del') EQ "1") AND request.q_getForm.bulkdelete EQ 1>
	<cfset request.deletePerms=1>
<cfelse>
	<cfset request.deletePerms=0>
</cfif> 
	<cfoutput>
<cfif request.deletePerms>
	<script language="JavaScript">
	var checkflag = "false";
	function check(field) {
	if (checkflag == "false") {
	for (i = 0; i < field.length; i++) {
	field[i].checked = true;}
	checkflag = "true";
	return "Uncheck All"; }
	else {
	for (i = 0; i < field.length; i++) {
	field[i].checked = false; }
	checkflag = "false";
	return "Check All"; }
	}
	</script>
</cfif>
<cfif thisList.recordcount>
	<tr>
		<td colspan="2" valign="top" bgcolor="##FFFFFF">
		<table width="100%" border="0" cellpadding="0" cellspacing="1">
	<form action="#request.page#" method="post" name="deleteEntries" id="deleteEntries">
	<input type="hidden" name="formstep" value="confirm">
	<cfmodule template="#application.customtagpath#/embedfields.cfm" ignore="displayform,confirmedDeleteList,deleteList">
	<tr>
		<td class="formitemlabelreq">&nbsp;</td>
		<cfloop list="#keyvalue#" index="i">
			<!--- this puts the label instead of the column name --->
			<cfloop index="t" from="1" to="#arrayLen(request.a_formelements)#">
				<cfif structFind(request.a_formelements[t],"fieldname") eq i>
					<cfset thisKey=request.a_formelements[t].objectlabel>				
					<cfbreak>
				<cfelse>
					<cfset thisKey=i>
				</cfif>
			</cfloop>
		<td class="formiteminput"<cfif isDefined('url.sort') AND findNoCase(i,url.sort)> style="background-color: 749BAD;"</cfif>><a href="#request.page#?sort=<cfif isDefined('sort#i#') AND evaluate('sort#i#') EQ "ASC">#urlencodedformat("#i# DESC")#<cfelse>#urlencodedformat("#i# ASC")#</cfif><cfif len(newQueryString)>&#newQueryString#</cfif>"><strong>#application.stripHTML(thisKey)#</strong></a></td>
		</cfloop>
	</tr>
	<cfloop query="thisList">
		<tr>
			<td class="formitemlabelreq"><cfif request.deletePerms><input type="checkbox" name="deleteInstance" value="#evaluate('thisList.#request.q_getForm.datatable#id')#" style="margin: 0px 0px 0px 0px;"><cfelse>&nbsp;</cfif></td>
			<cfloop list="#keyvalue#" index="i">
			<!--- this puts the labe instead of the column name --->
			<cfloop index="t" from="1" to="#arrayLen(request.a_formelements)#">
				<cfif structFind(request.a_formelements[t],"fieldname") eq i AND request.a_formelements[t].datatype EQ "datetime">
					<cfset thisVal="#DateFormat(evaluate('thisList.'&i),'m/d/yyyy')# #TimeFormat(evaluate('thisList.'&i),'h:mm TT')#">
					<cfbreak>
				<cfelse>
					<cfset thisVal=evaluate("thisList."&i)>
				</cfif>
			</cfloop>
				<td class="formitemlabelreq"><a href="#request.page#?instanceid=#evaluate('thisList.#request.q_getForm.datatable#ID')#&displayForm=1&formstep=showform">#thisVal#</a></td>
			</cfloop>
		</tr>
	</cfloop>
	<cfif page_count GT 1>
	<tr>
		<td class="formitemlabelreq" align="center" colspan="#val(listLen(request.q_getForm.editFieldKeyValue2)+1)#">
		Page #page_no# of #page_count#  : : :  #prev_link# #pages_link# #next_link#
		</td>
	</tr>
	</cfif>
	<tr>
		<td class="formiteminput" align="center" colspan="#val(listLen(request.q_getForm.editFieldKeyValue2)+1)#"><cfif request.deletePerms><input type=button value="Check All" onclick="this.value=check(this.form.deleteInstance)" class="submitbutton" style="width:100">
<input type="submit" name="deleteEm" value="Delete Selected" class="submitbutton" style="width:130"></form></cfif>
		</td>
	</tr>
	</table>
		
		</td>
	</tr>
<cfelse>
		<tr>
			<td class="formitemlabelreq" colspan="#val(listLen(keyvalue)+1)#"><p>There are currently no items. Click the (+) button above to begin.</p></td>
		</tr>
</cfif>
	</cfoutput>
	</cfmodule>
	
</cfcase>
<!--- href list of item choices --->
<cfcase value="listing">
		<cfset whereClause="">
		<cfloop list="#request.q_getForm.editFieldKeyValue#" index="i">
			<cfif isDefined("url.#i#") AND len(evaluate('url.'&i))>
				<cfif len(whereclause)>
					<cfset whereclause=urlDecode(whereclause)&" AND ">
				</cfif>
				<cfset whereClause=whereclause&"#i# LIKE '%#evaluate('url.'&i)#%'">
			</cfif>
		</cfloop>
		
		<cfquery datasource="#application.datasource#" name="q_getKeyFields" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT #request.q_getForm.datatable#ID as ID, #request.q_getForm.editFieldKeyValue# as theValue
				, sitesection.sitesectionlabel
			FROM #request.q_getForm.datatable#
				<cfif #request.q_getForm.formname# EQ "page">INNER JOIN sitesection ON sitesection.sitesectionid = page.sitesectionid</cfif>
			<cfif len(whereclause)>
			WHERE #preserveSingleQuotes(whereclause)#
			</cfif>
			<cfif isDefined("url.sort")>
			ORDER BY #urldecode(url.sort)#
			<cfelse>
			ORDER BY #request.q_getForm.editFieldSortOrder#
			</cfif>
		</cfquery>
		<cfif q_getKeyFields.recordcount>
			<cfoutput>
				<tr>
					<td colspan="2" class="subtoolheader" align="right">#q_getKeyFields.recordcount# Record<cfif q_getKeyFields.recordcount GT 1>s</cfif> Found.</td>
				</tr>
			</cfoutput>	
		</cfif>
		
		<cfif q_getKeyFields.recordcount EQ 1 AND isDefined("url.search")>
			<cflocation url="#request.page#?instanceid=#evaluate('q_getKeyFields.#request.q_getForm.datatable#ID')#&formstep=showform">
		</cfif>

	<cfparam name="attributes.page_size" default="#maxRecords#">
	<cfmodule template="#application.customTagPath#/previous_next.cfm" query="#q_getKeyFields#" query_name="thisList" page_size="#attributes.page_size#">
	<cfloop from="1" to="#maxRows#" step="1" index="colCt">
		<cfif thisList.recordcount GT round(maxRecords*((round(100/maxRows)*(colCt-1))/100))>
			<cfset rowNum=round(thisList.recordcount/colCt)>
			<cfset colNum=colCt>
		</cfif>
	</cfloop>
	<cfif val(rowNum*colNum) LT maxRecords><cfset rowNum=rownum+1></cfif>
<cfif isDefined("successMsg")>
	<tr>
		<td colspan="2" class="successmsg" align="center">#successMsg#</td>
	</tr>
</cfif>
 <!--- set delete flag DO NOT DELETE THIS COMMENT--->
<cfif (IsDefined("session.man#request.q_getForm.formname#del")) AND (evaluate('session.man#request.q_getForm.formname#del') EQ "1") AND request.q_getForm.bulkdelete EQ 1>
	<cfset request.deletePerms=1>
<cfelse>
	<cfset request.deletePerms=0>
</cfif>
	<cfoutput>
<cfif request.deletePerms>
	<script language="JavaScript">
		var checkflag = "false";
		function check(field) {
		if (checkflag == "false") {
		for (i = 0; i < field.length; i++) {
		field[i].checked = true;}
		checkflag = "true";
		return "Uncheck All"; }
		else {
		for (i = 0; i < field.length; i++) {
		field[i].checked = false; }
		checkflag = "false";
		return "Check All"; }
		}
	</script>
</cfif> 

<cfif isDefined("url.search")>
	<tr>
		<td colspan="2" valign="top" bgcolor="##DADADA">
		<table cellpadding="10" cellspacing="0" border="0">
		<tr>
			<td>
			<cfloop query="q_getKeyFields">
			<cfif #request.q_getForm.formname# EQ "page">
				<a href="#request.page#?instanceid=#q_getKeyFields.ID#&displayForm=1&formstep=showform">#q_getKeyFields.theValue#</a> (#q_getKeyFields.sitesectionlabel#)
			<cfelse>
				<a href="#request.page#?instanceid=#q_getKeyFields.ID#&displayForm=1&formstep=showform">#q_getKeyFields.sitesectionlabel#</a>
			</cfif>
			<br>
		</cfloop>
			</td>
		</tr>
		</table>
		</td>
	</tr>
<cfelse>

<tr>
	<td colspan="2" valign="top">
	<cfif #request.q_getForm.formname# EQ "sitesection">
		<cfquery datasource="#application.datasource#" name="q_getSections" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT sitesectionname,sitesectionid FROM sitesection
		</cfquery>
		<cfparam name="sectionPathList" default="">
		<cfif q_getSections.recordcount>
		<cfloop query="q_getSections">
			<!---Get the path of the section--->
			<cfset thisPath = #application.getSectionPath(q_getSections.sitesectionid,"true")#>
			<cfif sectionPathList EQ "">
				<cfset sectionPathList = thisPath & "." & q_getSections.sitesectionid>
			<cfelse>
				<cfset sectionPathList = sectionPathList & ", " & thisPath& "." & q_getSections.sitesectionid>
			</cfif>
		</cfloop>
		<cfset sectionPathList = " " & sectionPathList>
		<cfset listAsc = ListSort(#sectionPathList#, "textnocase", "asc")>
		<table cellpadding="3" cellspacing="1" border="0" width="100%" bgcolor="##DADADA">
			<cfloop list="#listAsc#" index="i">
			<tr>
				<td>
				<cfif #ListLen(i, "\")# GT 1>
					<cfset loopLength = #ListLen(i, "\")# - 1>
					<cfloop index="a" from="1" to="#loopLength#">
						<img src="/images/spacer.gif" width="10" height="1" border="0">
					</cfloop>
					<cfset thisSection = #ListLast(i, "\")#>
					<cfset thisSection = #ListFirst(thisSection, ".")#>
					<cfset thisSectionID = #ListLast(i, ".")#>
					<a href="#request.page#?instanceid=#thisSectionID#&displayForm=1&formstep=showform">#thisSection#</a>
				<cfelse>
					<cfset thisSection = #ListFirst(i, ".")#>
					<cfset thisSectionID = #ListLast(i, ".")#>
					<a href="#request.page#?instanceid=#thisSectionID#&displayForm=1&formstep=showform">#thisSection#</a>
				</cfif>
				</td>
			</tr>
			</cfloop>
		</table>

		<cfelseif #request.q_getForm.formname# EQ "page">
			<cfquery datasource="#application.datasource#" name="q_getPages" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT pagename, pageid, sitesectionid FROM page
			</cfquery>
			<cfparam name="pagePathList" default="">
			<cfloop query="q_getPages">
				<!---Get the path of the section--->
				<cfset thisPath = #application.getSectionPath(q_getPages.sitesectionid,"true")#>
				<cfif pagePathList EQ "">
					<cfset pagePathList = thisPath & ":" & q_getPages.pageid & ":" & q_getPages.pagename>
				<cfelse>
					<cfset pagePathList = pagePathList & ", " & thisPath& ":" & q_getPages.pageid & ":" & q_getPages.pagename>
				</cfif>
			</cfloop>
			<cfset listAsc = ListSort(#pagePathList#, "textnocase", "asc")>
			<table cellpadding="3" cellspacing="1" border="0" width="100%" bgcolor="##DADADA">
				<cfset loopCount = 0>		
				<cfloop list="#listAsc#" index="i">
				<tr>
					<td>
					<cfset thisSection = #ListLast(i, "\")#>
					<cfset thisSection = #ListFirst(thisSection, ":")#>
					<cfset thisPageID = #ListGetAt(i, 2, ":")#>
					<cfset thisPage = #ListLast(i, ":")#>
					<cfset listLength = #ListLen(i, "\")#>
					<cfif loopCount EQ 0>
						<cfset displaySection = #thisSection#>
						<strong>#thisSection#</strong><br>
					<cfelseif loopCount GT 0>
						<cfif "#TRIM(thisSection)#" NEQ "#TRIM(displaySection)#">
							<cfif listLength GT 1>
								<cfset imgWidth = (10 * (#listLength#-1))>
								<img src="/images/spacer.gif" width="#imgWidth#" height="1" border="0">
							</cfif>
							<strong>#thisSection#</strong><br>
							<cfset displaySection = #thisSection#>
						</cfif>
					</cfif>
					<cfset imgWidth = (10 * #listLength#)>
						<img src="/images/spacer.gif" width="#imgWidth#" height="1" border="0">
					<cfset thisPageID = #ListGetAt(i, 2, ":")#>
					<cfset thisPage = #ListLast(i, ":")#>
					<a href="#request.page#?instanceid=#thisPageID#&displayForm=1&formstep=showform">#thisPage#</a>
					</td>
				</tr>
				<cfset loopCount = incrementValue(loopCount)>
				</cfloop>
			</table>
		<cfelse>
		<p>There are currently no items. Click the (+) button above to begin.</p><p>&nbsp;</p>
		</cfif>
	</cfif>
	</td>
</tr>
</cfif> 
</cfoutput>
	</cfmodule>

</cfcase>

</cfswitch>

</table>
</cfif>