<!--- This include is designed to be called before loading 
a dynamic form to allow user to pick an existing record to edit
 --->
<!--- set delete flag DO NOT DELETE THIS COMMENT--->
<cfset request.deletePerms=1>

<cfif isDefined("url.successMsg")>
<cfif url.successMsg EQ 1>
	<cfset successMsg="<p>Success! Create action completed.</p>">
<cfelseif url.successMsg EQ 2>
	<cfset successMsg="<p>Success! Update action completed.</p>">
<cfelseif url.successMsg EQ 3>
	<cfset successMsg="<p>Success! Delete action completed.</p>">
</cfif>
</cfif>

<cfquery datasource="#application.datasource#" name="q_getTools" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT label, formobjectid, datecreated, datemodified, formname
	FROM formobject 
<cfif session.i3currenttool eq application.tool.toolbuilder>
	WHERE parentid = formobjectid
	<cfif isDefined('url.toollevel')>
		<cfif url.toollevel EQ 0>
		AND (formobjectid >= 100000)
		<cfelse>
		AND (formobjectid < 100000)
		</cfif>
	<cfelse>
		AND (formobjectid >= 100000)
	</cfif>
<cfelse>
	WHERE parentid <> formobjectid
</cfif>	
	ORDER BY label ASC
</cfquery>

<cfparam name="maxRecords" default=72>
<cfparam name="maxRows" default="3">
<cfset rowNum=0>
<cfset colNum=0>

<cfset request.filterImages="/images/formInstanceFilter">
<cfsavecontent variable="toolleveljs">
	<cfoutput>
		<script type="text/javascript">
			function changeLevel(){
				var urlVars = "?";
				<cfloop list="" index="item">
					<cfif listFirst(item,'=') NEQ toollevel>
						<cfif len(urlVars GT 1)>
				urlVars += '&#item#';
						<cfelse>
				urlVars += '#item#';
						</cfif>
					</cfif>
				</cfloop>
				urlVars += '&toollevel='+document.getElementById('toolFilter').value;
				window.location.href = '#REQUEST.page#'+urlVars;
			}
		</script>
	</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#toolleveljs#">
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
		<cfset searchQueryString=listAppend(searchQueryString,q,"&")>
	</cfloop>
</cfif>

<cfset keyvalue="label,formobjectid,datecreated,datemodified">
<cfset displayvalue="Tool Name,Tool ID,Date Created,Date Modified">
<cfloop list="#keyvalue#" index="s">
	<cfset "sort#s#"="DESC">
</cfloop>
<cfif isDefined("url.sort")>
	<cfset sortvalue=urldecode(url.sort)>
	<cfset "sort#listFirst(urldecode(url.sort),' ')#"=listLast(urldecode(url.sort)," ")>
<cfelse>
	<cfset sortvalue="label">
</cfif>	

<div id="socketformheader">
	<h2><cfif session.i3currenttool eq application.tool.toolbuilder>Socket Tool Builder<cfelse>Form Builder</cfif></h2>
</div><div style="clear:both;"></div>
<cfoutput>
<div class="subtoolheader">
	<cfif session.i3currenttool eq application.tool.toolbuilder>
	<a href="#request.page#?toolaction=DTShowForm&formobjectid=" title="Create a New Standard Socket Tool"><img src="#application.globalPath#/media/images/icon_addSocket.gif" border="0"/></a>
	<a href="#request.page#?toolaction=ShowFormCustom&formobjectid=" title="Create a New Custom Socket Tool"><img src="#application.globalPath#/media/images/icon_customTool.gif" border="0"/></a>
	<a href="#request.page#?toolaction=ordinalForm" title="Modify order of Tools"><img src="#application.globalPath#/media/images/icon_ordinal.gif" border="0"/></a>
	<a target="_blank" style="cursor:pointer;" onclick="javascript:newWin=window.open('#request.page#?toolaction=viewToolTemplates','SocketTemplate','resizable,scrollbars=yes,height=600,width=850');newWin.focus();" title="Show Tool Templates"><img width="28" height="23" src="#application.globalPath#/media/images/icon_tooltemplate.gif" border="0"/></a>
	<select id="toolFilter" onchange="javascript:changeLevel();" style="margin-bottom:6px;">
		<option value="0" <cfif isDefined('url.toollevel') and url.toollevel EQ 0>selected=SELECTED</cfif>>Custom Tools</option>
		<option value="1" <cfif isDefined('url.toollevel') and url.toollevel EQ 1>selected=SELECTED</cfif>>Core Tools</option>
	</select>
	</cfif>
<cfif session.i3currenttool eq application.tool.formbuilder>
	<cfquery datasource="#application.datasource#" name="q_getParents" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT formobjectid, label
		FROM formobject INNER JOIN formenvironment ON formobject.formenvironmentid = formenvironment.formenvironmentid
		WHERE formobject.parentid = formobject.formobjectid AND formenvironment.formenvironmentname NOT LIKE '%core%' 
		ORDER BY formobject.label ASC
	</cfquery>
	<form action="#request.page#" method="post">
		<input type="Hidden" name="toolaction" value="CreateChild">
		<select name="parentid">
			<option value="">Select a master</option>
			<cfloop query="q_getParents">
				<option value="#q_getParents.formobjectid#">#q_getParents.label#</option>
			</cfloop>
		</select>
		<input type="Submit" value="Create Instance" class="submitbutton" style="width:125;">
	</form>
</cfif>			
</div>
</cfoutput>

	<cfquery datasource="#application.datasource#" name="q_getKeyFields" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT #keyvalue#
		FROM formobject
		<cfif session.i3currenttool eq application.tool.toolbuilder>
		WHERE parentid = formobjectid
		<cfif isDefined('url.toollevel')>
			<cfif url.toollevel EQ 0>
			AND (formobjectid >= 100000)
			<cfelse>
			AND (formobjectid < 100000)
			</cfif>
		<cfelse>
			AND (formobjectid >= 100000)
		</cfif>
		<cfelse>
		WHERE parentid <> formobjectid
		</cfif>
		<cfif isDefined("url.sort")>
		ORDER BY #urldecode(url.sort)#
		<cfelse>
		ORDER BY #sortvalue#
		</cfif>
	</cfquery>
	<cfparam name="attributes.page_size" default="#val(maxRecords\3)#">
	<cfmodule template="#application.customTagPath#/previous_next.cfm" query="#q_getKeyFields#" query_name="thisList" page_size="#attributes.page_size#">
	<cfloop from="1" to="#maxRows#" step="1" index="colCt">
		<cfif thisList.recordcount GT round(maxRecords*((round(100/maxRows)*(colCt-1))/100))>
			<cfset rowNum=round(thisList.recordcount/colCt)>
			<cfset colNum=colCt>
		</cfif>
	</cfloop>
	<cfif val(rowNum*colNum) LT maxRecords>
		<cfset rowNum=rownum+1>
	</cfif>
	<cfoutput>
	<cfif isDefined("successMsg")>
		<cfoutput>
			<div id="successMsgBlock">#successMsg#</div>
		</cfoutput>
	</cfif>
	<table id="socketformtable" border="0" cellspacing="1" cellpadding="3" width="100%" style="margin-left:0;">
	<form action="#request.page#" method="post" name="deleteEntries" id="deleteEntries">
	<input type="hidden" name="formstep" value="confirm">
	<cfmodule template="#application.customtagpath#/embedfields.cfm" ignore="displayform,confirmedDeleteList,deleteList">
	<tr class="columnheaderrow">
		<cfset posCount = 1>
		<cfloop list="#keyvalue#" index="i">
			<td style="padding-left:8px;"><a href="#request.page#?sort=<cfif isDefined('sort#i#') AND evaluate('sort#i#') EQ "ASC">#urlencodedformat("#i# DESC")#<cfelse>#urlencodedformat("#i# ASC")#</cfif><cfif len(newQueryString)>&#newQueryString#</cfif>"><strong>#application.stripHTML(listGetAt(displayValue,posCount))#</strong></a></td>
			<cfset posCount = posCount+1>
		</cfloop>
	</tr>
	<cfloop query="thisList">
		<cfif thisList.currentRow MOD 2>
			<cfset rowClass = "evenrow">
		<cfelse>
			<cfset rowClass = "oddrow">
		</cfif>
		<tr class="#rowClass#">
			<cfloop list="#keyvalue#" index="i">
				<td style="padding-left:8px;"><a href="#request.page#?formobjectid=#evaluate('thisList.formobjectid')#&toolaction=DTShowForm">#evaluate("thisList."&i)#</a></td>
			</cfloop>
		</tr>
	</cfloop>
	<cfif page_count GT 1>
	<tr>
		<td class="formitemlabelreq" align="center" colspan="#listLen(keyvalue)#">
			<div id="pagingControls">&lt;#prev_link# Page #page_no# of #page_count#  :   #pages_link# #next_link#&gt;</div>
		</td>
	</tr>
	</cfif>
	</cfoutput>
</cfmodule>
</table>
