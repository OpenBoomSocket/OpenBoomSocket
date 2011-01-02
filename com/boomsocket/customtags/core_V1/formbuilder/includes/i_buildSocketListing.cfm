<!--- i_builSocketListing.cfm 5/17/07 --->
<cfinvoke component="#APPLICATION.cfcPath#.util.plugin" method="getPluginStatus" returnvariable="q_socketlist" />
<cfinvoke component="#APPLICATION.cfcPath#.util.plugin" method="getPluginStatus" directory="tooltemplate" returnvariable="q_templatelist" />
<cfset selectClause="socketcategoryid, socketcategoryname, socketlisting">
<cfset fromClause="socketcategory">
<cfinvoke component="#APPLICATION.cfcPath#.forminstance" method="getFormData" returnvariable="q_socketCategory">
	<cfinvokeargument name="selectClause" value="#selectClause#">
	<cfinvokeargument name="fromClause" value="#fromClause#">
</cfinvoke>
<cfoutput>
<style type="text/css">
	##socketSelection{
	}
	body{
		
	}
	##socketsListing{
		float: left;
		margin-bottom: 25px;
		height: 100%;
	}
	##socketDetails{
		float: left;
		height: 100%;
		margin: 0px auto;
		margin-left: 25px;
	}
	##socketDetails h3{
		margin-top:5px;
	}
	##socketToolTemplate{
		display: inline;
		height: 100%;
	}
	##buttonBar{
		margin-top: 25px;
		padding: 0px;
		width: 100%;
	}
	##buttonBar div{
		float: left;
		margin: 1px;
	}
</style>
<script type="text/javascript">
	var currentCat = "";
	var socketValue = "";
	function showCatListing(){
		var thisCat = document.getElementById('socketcatlisting').value;
		if(currentCat != ""){
			document.getElementById('socketsListing_'+currentCat).style.display="none";
		}
		if(thisCat != ""){
			document.getElementById('socketsListing_'+thisCat).style.display="block";
		}
		currentCat = thisCat;
	}
	function showDetails(thisSocket){
		socketValue = thisSocket;
		document.getElementById('detailFrame').src = '#request.page#?toolaction=previewToolForm&templateName='+socketValue.split('|')[0]+'&sourceFolder='+socketValue.split('|')[1];
		document.getElementById('socketDetails').style.width = "635px";
		document.getElementById('socketDetails').style.height = "470px";
		document.getElementById('templateChoice').style.display="block";
		document.getElementById('templateChoice').style.width="65px;";
	}
	function manageWindows(){
		window.opener.location.href='#request.page#?toolaction=DTShowForm&templateName='+socketValue.split('|')[0]+'&sourceFolder='+socketValue.split('|')[1]+'&formobjectid=';
		window.close();
	}
</script>
<div id="socketToolTemplate">
<div id="socketsListing">
<select id="socketcatlisting" name="socketcatlisting" onchange="javascript:showCatListing()" >
	<option value="">Select Category</option>
	<cfloop query="q_socketCategory">
	<option value="#q_socketCategory.socketcategoryid#">#q_socketCategory.socketcategoryname#</option>
	</cfloop>
	<option value="0">Miscellaneous</option>
</select>
</cfoutput>
<cfloop query="q_templatelist">
	<cfset blah = queryAddRow(q_socketlist,1)>
	<cfloop list="#q_templatelist.columnlist#" index="thisCol">
		<cfset blah = querySetCell(q_socketlist, thisCol, evaluate("q_templatelist.#thisCol#"))>
	</cfloop>
</cfloop>
<cfset socketNameList = valueList(q_socketList.name)>
<!--- <cfdump var="#q_socketlist#"> --->
<cfoutput>
<h3>Available Sockets</h3>
<cfloop query="q_socketCategory">
	<div id="socketsListing_#q_socketCategory.socketcategoryid#" class="socketsListing" style="display: none;">
	<cfloop list="#q_socketCategory.socketlisting#" index="thisSocket">
		<cfif findNoCase(thisSocket,socketNameList)>
			<!--- remove this socket from master list --->
			<cfset socketNameList = replaceNoCase(socketNameList, thisSocket, '', 'all')>
			<cfset q_pluginInfo = querynew("socketid,socketname,datemodified,creator,version,formobjectid")>
			<cfset queryAddRow(q_plugininfo,1)>
			<cffile action="read" file="#APPLICATION.installpath#\admintools\#listlast(q_socketlist.directory,'\')#\#thisSocket#\info\info.xml" variable="infoXML">
			<cfset infoXML = xmlParse(infoXML)>
			<cfif isDefined('infoXML.xmlRoot.toolname') AND len(trim(infoXML.xmlRoot.toolname.xmlText))>
				<cfset q_pluginInfo.socketname = infoXML.xmlRoot.toolname.xmlText>
			<cfelse>
				<cfset q_pluginInfo.socketname = thisSocket>
			</cfif>
			<cfset rootDir = listlast(q_socketlist.directory,'\')>
			<a onclick="javascript:showDetails('#thisSocket#|#rootDir#')" style="cursor: pointer;">#q_pluginInfo.socketname#</a>
		</cfif>
	</cfloop>
	</div>
</cfloop>
<!--- list sockets not contained in categories --->
<div id="socketsListing_0" class="socketsListing" style="display: none;">
	<cfloop query="q_socketlist">
		<cfif listContains(socketNameList, q_socketlist.name)>
			<cfset q_pluginInfo = querynew("socketid,socketname,datemodified,creator,version,formobjectid")>
			<cfset queryAddRow(q_plugininfo,1)>
			<cffile action="read" file="#APPLICATION.installpath#\admintools\#listlast(q_socketlist.directory,'\')#\#q_socketlist.name#\info\info.xml" variable="infoXML">
			<cfset infoXML = xmlParse(infoXML)>
			<cfif isDefined('infoXML.xmlRoot.toolname') AND len(trim(infoXML.xmlRoot.toolname.xmlText))>
				<cfset q_pluginInfo.socketname = infoXML.xmlRoot.toolname.xmlText>
			<cfelse>
				<cfset q_pluginInfo.socketname = thisSocket>
			</cfif>
			<cfset rootDir = listlast(q_socketlist.directory,'\')>
			<a onclick="javascript:showDetails('#q_socketlist.name#|#rootDir#')" style="cursor: pointer;">#q_pluginInfo.socketname#</a>
		</cfif>
	</cfloop>
</div><div id="buttonBar"><div id="templateChoice" onclick="manageWindows()" class="submitbutton" style="cursor:pointer; display:none;">Use Template</div><div onclick="javascript:window.close();" class="submitbutton" style="cursor:pointer;">Cancel</div></div></div>
</cfoutput>
<cfoutput>
<div id="socketDetails"><h3>Preview Socket</h3><iframe id="detailFrame" style="border: none;" width="100%" height="90%"></iframe></div>
</div><div style="clear:both;"></div></cfoutput>