<!--- News Pod --->
<!--- This pod can be used to display news which you code an aggregator for, or hard code into this display --->
<strong><font size="2" color="##000000">From DP</font></strong>
<h3>No News Today</h3>
<cfif findNoCase('window',SERVER.OS.Name)>
	<!--- Show disk usage stat --->
	<p><strong><font size="2" color="##000000">Disk Usage: <cfoutput>#application.byteConvert(application.FolderSize(application.installpath))#</cfoutput></font></strong></p>
</cfif>