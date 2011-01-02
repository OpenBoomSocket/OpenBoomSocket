<!--- i_preconfirm.cfm --->
<cfif isDefined("deleteinstance") AND trim(deleteinstance) EQ 100000>
	<cfset request.stopprocess="confirm">
	<cfoutput>
		<table width="550" border="0" cellspacing="0" cellpadding="10" class="errortext" align="center">
		<tr>
			<td style="color:##FFFFFF;"><h1 style="color:##FFFFFF;">Access Denied!</h1> 
			You are not allowed to delete the DP user account!
			<p align="center"><a href="/admintools/index.cfm?i3currenttool=#application.tool.users#" style="color:##FFFFFF;">&lt; Return to Users &gt;</a></p>
		  </td>
		</tr>
		</table>
	</cfoutput>
</cfif>
