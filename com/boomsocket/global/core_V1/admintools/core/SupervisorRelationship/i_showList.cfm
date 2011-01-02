<cfsilent>
<!--- set up sort 
		ps - don't even ask ;P --->
<cfparam name="sortSUPERVISORID" default="ASC">
<cfparam name="sortUSERID" default="ASC">
<cfparam name="sortFORMOBJECT" default="ASC">
<cfif isDefined("url.sort")>
  <cfset thisSort=URLDecode(listLast(url.sort,"="))>
  <cfset "sort#listFIRST(thisSort," ")#"=listLast(thisSort," ")>
  <cfset hasURLSort=1>
  <cfelse>
  <cfset hasURLSort=0>
</cfif>
<cfif sortSUPERVISORID EQ "ASC">
  <cfset SUPERVISORIDsort="users.lastname ASC, users.FirstName ASC">
  <cfelse>
  <cfset SUPERVISORIDsort="users.lastname DESC, users.FirstName DESC">
</cfif>
<cfif sortUSERID EQ "ASC">
  <cfset USERIDsort="users1.lastname ASC, users1.FirstName ASC">
  <cfelse>
  <cfset USERIDsort="users1.lastname DESC, users1.FirstName DESC">
</cfif>
<cfif sortFORMOBJECT EQ "ASC">
  <cfset FORMOBJECTsort="formobject.label ASC">
  <cfelse>
  <cfset FORMOBJECTsort="formobject.label DESC">
</cfif>
<cfif hasURLSort>
  <cfset showlistsort=evaluate("#listFIRST(thisSort," ")#sort")>
  <cfelse>
  <cfset showlistsort="#SUPERVISORIDsort#, #USERIDsort#, #FORMOBJECTsort#">
</cfif>
<!--- end set up sort --->
<!--- Build sort string --->
<cfset newQueryString="">
<cfset whereClause="">
<cfif listLen(CGI.QUERY_STRING,"&")>
  <cfloop list="#CGI.QUERY_STRING#" index="q" delimiters="&">
    <cfif listFirst(q,"=") NEQ "sort" AND listFirst(q,"=") NEQ "i3currenttool">
      <cfset newQueryString=listAppend(newQueryString,q,"&")>
    </cfif>
  </cfloop>
</cfif>
<cfset searchableList="users1.lastname~ownerLastName,users1.FirstName~ownerFirstName,users.lastname~supervisorLastName,users.firstname~supervisorFirstName,formobject.label~label">
<cfloop list="#searchableList#" index="i">
  <cfif isDefined("url.#listLast(i,'~')#") AND len(evaluate('url.#listLast(i,'~')#'))>
    <cfif len(whereclause)>
      <cfset whereclause=urlDecode(whereclause)&" AND ">
    </cfif>
    <cfset whereClause=whereclause&"#listFirst(i,'~')# LIKE '%#evaluate('url.#listLast(i,'~')#')#%'">
  </cfif>
  <cfparam name="#listLast(i,'~')#" default="">
</cfloop>
<cfquery name="q_getSupervisors" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
	SELECT
		users1.lastname AS ownerLastName, 
		users1.FirstName AS ownerFirstName, 
		users.lastname AS supervisorLastName, 
		users.FirstName AS supervisorFirstName,
		formobject.label, 
		SupervisorRelationship.SupervisorRelationshipid, 
		SupervisorRelationship.datecreated, 
		SupervisorRelationship.datemodified
	FROM
		SupervisorRelationship INNER JOIN
			formobject ON SupervisorRelationship.formobject = formobject.formobjectid INNER JOIN
				Users ON Users.Usersid = SupervisorRelationship.supervisorid INNER JOIN
				Users Users1 ON Users1.Usersid = SupervisorRelationship.userid
<cfif len(trim(whereClause))>
	WHERE 
		#preservesinglequotes(whereClause)#
</cfif>			
	ORDER BY 
		#showlistsort#
</cfquery>


</cfsilent>
<cfoutput>
<div id="socketformheader">
  <h2>Supervisor</h2>
</div>
<div style="clear: both;" ;=""></div>
<div class="subtoolheader" style="padding-bottom: 0pt;">
  <div id="leftBtns" style="float: left; width: 50%;">
    <form action="index.cfm" method="post" style="margin-bottom: 0px; margin-left: 0px; margin-right: 0px; margin-top: 0px; page-break-before: avoid; page-break-after: avoid;">
        <input type="hidden" name="i3currenttool" value="#application.tool.SupervisorRelationship#">
        <input type="hidden" name="SRstep" value="add">
        <input type="hidden" name="displayForm" value="1">
        <input type="image" value="Add a New Supervisor" src="#application.globalPath#/media/images/icon_addFile.gif" alt="Add new Supervisor" style="border: 1px ridge ##dadada; margin-top: 2px;">
    </form>
  </div>
  <div style="float: right; width: 50%;">
  <!--- Search Bar --->
<!---     <form action="index.cfm" method="get" name="form1" id="form1" style="margin: 0px; float: right;">
      <script type="text/javascript">
			function swapField(o){
				for(i=0 ; i<o.options.length ; i++){
					document.getElementById(o.options[i].value).style.display = "none";
				}
				document.getElementById(o.value).style.display = "inline";
			}
		</script>
      <input name="search" value="1" type="hidden">
      <input name="selectaction" value="detailView" type="hidden">
      <input name="formname" value="Users" type="hidden">
      <select id="searchField" onchange="javascript:swapField(this);" style="position: relative; top: -7px;">
        <option value="search_supervisorfirstname">supervisorfirstname</option>
        <option value="search_supervisorlastname">supervisorlastname</option>
        <option value="search_ownerFirstName">ownerFirstName</option>
        <option value="search_ownerLastName">ownerLastName</option>
      </select>
      <div id="search_LASTNAME" style="display: inline;">
        <input name="LASTNAME" size="25" style="position: relative; top: -7px;" type="text">
      </div>
      <div id="search_FIRSTNAME" style="display: none;">
        <input name="FIRSTNAME" size="25" style="position: relative; top: -7px;" type="text">
      </div>
      <div id="search_DATECREATED" style="display: none;">
        <input name="DATECREATED" size="25" style="position: relative; top: -7px;" type="text">
      </div>
      <div id="search_DATEMODIFIED" style="display: none;">
        <input name="DATEMODIFIED" size="25" style="position: relative; top: -7px;" type="text">
      </div>
      <div id="search_USERTYPEID" style="display: none;">
        <input name="USERTYPEID" size="25" style="position: relative; top: -7px;" type="text">
      </div>
      <input name="Search" value="Search" src="#application.globalPath#/media/images/icon_search.gif" type="image">
    </form> --->
  </div>
  <div style="clear: both;"></div>
</div>
<table id="socketindextable" border="0" cellpadding="0" cellspacing="0">
  <tbody>
    <tr>
      <td colspan="2" align="right">2 Records Found.</td>
    </tr>
    <script language="JavaScript" type="text/javascript">
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
    <tr>
      <td colspan="2" valign="top"><input name="formstep" value="confirm" type="hidden">
        <input value="" name="deleteInstance" type="hidden">
        <form action="index.cfm" method="post" name="deleteEntries" id="deleteEntries">
          <input type="hidden" name="SRstep" value="confirmDelete">
          <input type="hidden" name="i3currenttool" value="#application.tool.SupervisorRelationship#">
          <table width="100%" border="0" cellpadding="0" cellspacing="1">
            <tr class="columnheaderrow">
              <td><cfmodule template="#application.customTagPath#/previous_next.cfm" query="#q_getSupervisors#" query_name="thisList" page_size="30">
                &nbsp; </td>
              <cfset i="SUPERVISORID">
              <td><a href="index.cfm?sort=<cfif isDefined('sort#i#') AND evaluate('sort#i#') EQ 'ASC'>#urlencodedformat('#i# DESC')#<cfelse>#urlencodedformat('#i# ASC')#</cfif>&i3currenttool=#session.i3currenttool#<cfif len(newQueryString)>&#newQueryString#</cfif>"><strong>Supervisor</strong></a></td>
              <cfset i="USERID">
              <td><a href="index.cfm?sort=<cfif isDefined('sort#i#') AND evaluate('sort#i#') EQ 'ASC'>#urlencodedformat('#i# DESC')#<cfelse>#urlencodedformat('#i# ASC')#</cfif>&i3currenttool=#session.i3currenttool#<cfif len(newQueryString)>&#newQueryString#</cfif>"><strong>Users</strong></a></td>
              <cfset i="FORMOBJECT">
              <td><a href="index.cfm?sort=<cfif isDefined('sort#i#') AND evaluate('sort#i#') EQ 'ASC'>#urlencodedformat('#i# DESC')#<cfelse>#urlencodedformat('#i# ASC')#</cfif>&i3currenttool=#session.i3currenttool#<cfif len(newQueryString)>&#newQueryString#</cfif>"><strong>Tool</strong></a></td>
            </tr>
            <cfloop query="thisList">
				<cfif thisList.currentRow MOD 2>
					<cfset rowClass="evenrow">
				<cfelse>
					<cfset rowClass="oddrow">
				</cfif>
              <tr class="#rowClass#">
                <td class="deleteRow"><input type="checkbox" name="deleteInstance" value="#thisList.SupervisorRelationshipid#~Supervisor:&nbsp;#ucase(left(thisList.supervisorFirstName,1))#. #thisList.supervisorLastName# / Owner:&nbsp;#ucase(left(thisList.ownerFirstName,1))#. #thisList.ownerLastName# / Tool:&nbsp;#thisList.label#" style="margin: 0px 0px 0px 0px;"></td>
                <td>#thisList.supervisorLastName#, #thisList.supervisorFirstName#</td>
                <td>#thisList.ownerLastName#, #thisList.ownerFirstName#</td>
                <td>#thisList.label#</td>
              </tr>
            </cfloop>
            <tr>
              <td class="formiteminput" align="center" colspan="4"><input type=button value="Check All" onclick="this.value=check(this.form.deleteInstance)" class="submitbutton" style="width:100">
                <input type="submit" name="deleteEm" value="Delete Selected" class="submitbutton" style="width:130">
              </td>
            </tr>
            <cfif page_count GT 1>
              <tr>
                <td class="formitemlabelreq" align="center" colspan="4"><div id="pagingControls">&lt;#prev_link#
                    Page #page_no# of #page_count# : #pages_link# #next_link#&gt;</div></td>
              </tr>
            </cfif>
          </table>
        </form></td>
    </tr>
  </tbody>
</table>
</div>
</div>
</cfoutput>