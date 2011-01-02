<cfoutput>	
<table border="0" cellpadding="3" cellspacing="1" width="550" align="" class="tooltable">

	<tr>
		<td colspan="2" class="toolheader">
		Supervisor
		</td>
	</tr>
	<tr>
		<td class="formitemlabel"><strong>Supervisor</strong> </td>
		<td class="formitemlabel"><cfloop list="#form.supervisorid#" index="thisSupervisor">#listLast(thisSupervisor,"~")#<br></cfloop></td>
	</tr>
	<tr>
		<td class="formitemlabel"><strong>Users</strong> </td>
		<td class="formitemlabel"><cfloop list="#form.userid#" index="thisuser">#listLast(thisuser,"~")#<br></cfloop></td>
	</tr>
	<tr>
		<td class="formitemlabel"><strong>Tools</strong> </td>
		<td class="formitemlabel"><cfloop list="#form.formobject#" index="thisformobject">#listLast(thisformobject,"~")#<br></cfloop></td>
	</tr>
	
<!--- remove the labels --->
<cfinclude template="i_killLabels.cfm">
	
	<tr>
		<td align="center" colspan="2">
			<table>
				<tr>
					<td align="center">&nbsp;</td>
					<td align="center">
						<form action="index.cfm" method="Post">
						<input type="hidden" name="i3currenttool" value="#application.tool.SupervisorRelationship#">
						<input type="hidden" name="SRstep" value="addSupervisors">
						<input type="hidden" value="#form.supervisorid#" name="supervisorid">
						<input type="hidden" value="#form.userid#" name="userid">
						<input type="hidden" value="#form.formobject#" name="formobject">
						<input type="Submit" value="Submit Form" class="submitbutton" style="width:100px;">
						</form>
					</td>
				</tr>

			</table>
		</td>
	</tr>
</table>
</cfoutput>	
