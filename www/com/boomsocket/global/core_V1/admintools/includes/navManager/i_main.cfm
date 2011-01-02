<cfset q_getNavGroups = NavObj.getNavGroups()>
<table width="600" border="0" cellspacing="1" cellpadding="0" class="tooltable"><tbody>
	<tr>
	  <td width="142" colspan="3" class="toolheader">Navigation Manager v2.0a</td>
	</tr>
	</tbody>
	<tr>
	  <td colspan="3" align="left" valign="top" class="successmsg"><p>Please Select
		a Navigation group from the list below:</p>
		<ul>
			<cfloop query="q_getNavGroups">
				<cfoutput><li><a href="#request.page#?i3currenttool=#session.i3currenttool#&navGroupid=#q_getNavGroups.dynamicnavigationgroupid#">#q_getNavGroups.groupname#</a></li></cfoutput>
			</cfloop>
	</ul></td>
		</tr>
</table>