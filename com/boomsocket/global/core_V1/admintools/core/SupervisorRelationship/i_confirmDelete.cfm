<body leftmargin="8" topmargin="8" rightmargin="8" bottommargin="8" marginwidth="8" marginheight="8" onLoad="self.focus ();" bgcolor="#333333">
<table border="0" cellpadding="5" cellspacing="1" width="550" align="" class="tooltable">
	<tr>
		<td class="toolheader">Confirm Item Deletion</td>
	</tr>
	<tr>
		<td class="formiteminput"><p>Are you sure you wish to delete the following items from the database?</p>
		<ul>
		<cfloop list="#form.deleteInstance#" index="i">
			<li><cfoutput>#ListLast(i, "~")#</cfoutput>
		</cfloop>
		 </ul>
		</td>
	</tr>
	<tr>
		<td align="center" class="formiteminput">
		<table>
		<cfoutput>
			<tr>
				<td align="center"><form action="index.cfm" method="Post">
				<input type="hidden" value="showForm" name="formstep">
				<input type="hidden" value="100053" name="instanceid">
				<input type="hidden" value="designer" name="tablename">
				<input type="submit" value="Back to Form" class="submitbutton" style="width:120px;">
				</form></td>
				<td align="center"><form action="index.cfm" method="Post" name="delete">
				<input type="hidden" name="SRstep" value="deleteAction">
				<cfset deleteList = "">
				<cfloop list="#form.deleteInstance#" index="i">
					<cfset deleteList = #listAppend(deleteList, ListFirst(i, "~"))#>
				</cfloop>
				<input type="Hidden" name="deleteInstance" value="#deleteList#">
				<input type="Submit" value="Yes, Delete Now" class="deletebutton" style="width:120px;">
				</form></td>
			</tr>
		</cfoutput>
		</table>
		</td>
	</tr>
</table>
</body>