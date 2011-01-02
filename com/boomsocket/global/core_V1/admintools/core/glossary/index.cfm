<cfobject component="#application.CFCPath#.glossary" name="glossary">
<cfparam name="URL.groupBy" default="false">
<!--- prototype may pass searchStr as url value --->
<cfparam name="form.searchStr" default="">
<cfif isDefined('url.searchStr') AND Len(url.searchStr)>
	<cfset form.searchStr = url.searchStr>
</cfif>
<cfmodule template="#application.customTagPath#/htmlshell.cfm" css="admintools.css" bgcolor="E6E6E6" padding="0" onload="self.focus();">		
		<cfoutput>
			<table width="99%" border="0" cellspacing="0" cellpadding="0" align="center" class="tooltable">
			  <tr>
				<td class="toolheader" colspan="2">Glossary of Terms</td>
			  </tr>
			  <tr>
				<td class="subtoolheader"><cfif URL.groupBy>
					<a href="#request.page#?groupBy=false" style="color:##ffffff;">View Alphabetical</a>
				<cfelse>
					<a href="#request.page#?groupBy=true" style="color:##ffffff;">View By Category</a>
				</cfif></td>
				<td class="subtoolheader" align="right">
					<form action="#request.page#<cfif isDefined('url.view') AND url.view eq 'Glossary'>?view=Glossary</cfif>" method="post">
						<input type="text" size="15" name="searchStr" value="#form.searchStr#">
						<input type="submit" value="search" class="submitbutton">
					</form>
				</td>
			  </tr>
			  <tr>
				<td colspan="2">#glossary.showTerms(URL.groupBy,form.searchStr)#</td>
			  </tr>
			</table>
		</cfoutput>
</cfmodule>


