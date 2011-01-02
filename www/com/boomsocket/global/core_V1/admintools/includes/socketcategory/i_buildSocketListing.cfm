<!--- i_builSocketListing.cfm 5/17/07 --->
<cfinvoke component="#APPLICATION.cfcPath#.util.plugin" method="getPluginStatus" returnvariable="q_socketlist" />
<cfinvoke component="#APPLICATION.cfcPath#.util.plugin" method="getPluginStatus" directory="tooltemplate" returnvariable="q_templatelist" />
<cfloop query="q_templatelist">
	<cfset blah = queryAddRow(q_socketlist,1)>
	<cfloop list="#q_templatelist.columnlist#" index="thisCol">
		<cfset blah = querySetCell(q_socketlist, thisCol, evaluate("q_templatelist.#thisCol#"))>
	</cfloop>
</cfloop>
<!--- <cfdump var="#q_socketlist#"> --->
<cfoutput>
<p>Use the Multiselect to select the sockets for this category.</p>
<select id="socketlisting" name="socketlisting" multiple="multiple" size="<cfif q_socketlist.recordcount GT 10>10<cfelse>#q_socketlist.recordcount#</cfif>">
<cfloop query="q_socketlist">
	<cfset q_pluginInfo = querynew("socketid,socketname,datemodified,creator,version,formobjectid")>
	<cfset queryAddRow(q_plugininfo,1)>
	<cffile action="read" file="#APPLICATION.installpath#\admintools\sockets\#q_socketlist.name#\info\info.xml" variable="infoXML">
	<cfset infoXML = xmlParse(infoXML)>
	<cfif isDefined('infoXML.xmlRoot.toolname') AND len(trim(infoXML.xmlRoot.toolname.xmlText))>
		<cfset q_pluginInfo.socketname = infoXML.xmlRoot.toolname.xmlText>
	<cfelse>
		<cfset q_pluginInfo.socketname = q_socketlist.name>
	</cfif>
	<cfset rootDir = listlast(q_socketlist.directory)>
	<option value="#q_socketlist.name#" <cfif isDefined('form.socketlisting') AND listFindNoCase(form.socketlisting,q_socketlist.name)>selected="selected"</cfif>>#q_pluginInfo.socketname#</option>
</cfloop>
</select>
</cfoutput>