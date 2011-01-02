<!-- saved from url=(0014)about:internet -->
<cfsavecontent variable="javascript">
<cfoutput>
<script type="text/javascript">

function testfunction() 
{
  if(document.getElementById("8_1") == null)
  	alert("yes");
	
  row = 1;

  while (document.getElementById(row+"_1") != null || document.getElementById(row+"_2") !=null)
  {
  	var text;
  	label = document.getElementById(row+"_1");
  	input = document.getElementById(row+"_2");
	if (label == null)
	{
		if((input.childNodes).length <= 2)
			alert(row+" is empty");
	}
	else if (input == null)
	{
		for (i=0; i < (label.childNodes).length;i++)
		{
			if((label.childNodes[i]).nodeName == "text")
			{
				text = (label.childNodes[i]).nodeName;
			alert(row+" "+ text);
			}
		}
		if((label.childNodes).length <= 2)
			alert(row+" is empty");
	}
	else 
	{
		if((label.childNodes).length <= 1 && (input.childNodes).length <= 1)
			alert(row+" is empty");
			text = label.lastChild;
				alert(row + " " +text.nodeValue);
	}
	row++;
  }
}
</script>
</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#javascript#">

<cfif isdefined("FORM.addRow") AND FORM.addRow>
	
</cfif>

<cfset rowNum=0>
<cfset colNum=0> 
<!--- for viewing puposes only called through Tool Template tool --->
<cfif isDefined('templateName') AND isDefined('sourceFolder')>
	<!--- read in table and datat def files --->
</cfif>
<!--- get table definition --->
<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="XML2CFML"
        input="#q_getform.tabledefinition#"
        output="a_tableelements">
<!--- get data definitions --->
<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="XML2CFML"
        input="#q_getform.datadefinition#"
        output="a_formelements">
<!--- Loop over formelements, creating local vars for output in table --->
<cfloop index="a" from="1" to="#arrayLen(a_formelements)#">
	<cfparam name="field#a_formelements[a].gridposvalue#" default="">
	<cfparam name="pos#a_formelements[a].gridposvalue#" default="">
	<cfset "field#a_formelements[a].gridposvalue#"=listAppend(evaluate("field#a_formelements[a].gridposvalue#"),a_formelements[a].fieldname,"|")>
	<cfparam name="pos#a_formelements[a].gridposlabel#" default="">
	<cfif listFindNoCase("submit,reset,hidden,button,formatonly,image,custominclude,cancel,useMappedContent","#a_formelements[a].inputtype#")>
		<cfparam name="pos#a_formelements[a].gridposlabel#" default="">
	<cfelse>
		<cfset "pos#a_formelements[a].gridposlabel#"=listAppend(evaluate("pos#a_formelements[a].gridposlabel#"),a_formelements[a].objectlabel,"|")>
	</cfif>
	<cfsavecontent variable="tempVar">
		<cfoutput>
		<cfswitch expression="#a_formelements[a].inputtype#">
		<!--- ###[BUILD TEXT INPUT]### --->
			<cfcase value="text">
				<input type="text" name="#a_formelements[a].fieldname#" size="#a_formelements[a].width#" class="#a_formelements[a].inputstyle#" maxlength="#a_formelements[a].maxlength#" value="#a_formelements[a].defaultvalue#">
			</cfcase>
		<!--- ###[BUILD TEXT TEXTAREA]### --->
			<cfcase value="textarea">
				<textarea cols="#a_formelements[a].width#" rows="#a_formelements[a].height#" name="#a_formelements[a].fieldname#" class="#a_formelements[a].inputstyle#">#a_formelements[a].defaultvalue#</textarea>
			</cfcase>
			<cfcase value="hidden">
				<input type="hidden" name="#a_formelements[a].fieldname#" value="#a_formelements[a].defaultvalue#">
			</cfcase>
			<cfcase value="password">
				<input type="password" name="#a_formelements[a].fieldname#" size="#a_formelements[a].width#" class="#a_formelements[a].inputstyle#" maxlength="#a_formelements[a].maxlength#" value="">
			</cfcase>
		<!--- ###[BUILD RADIO BUTTON ARRAY]### --->
			<cfcase value="radio">

<cfif structKeyExists(evaluate("a_tableelements[#listFirst(a_formelements[a].gridposvalue,'_')#].cell_#listLast(a_formelements[a].gridposvalue,'_')#"),"nowrap") AND evaluate("a_tableelements[#listFirst(a_formelements[a].gridposvalue,'_')#].cell_#listLast(a_formelements[a].gridposvalue,'_')#.nowrap") EQ 1>
	<cfset nowrap=1>
<cfelse>
	<cfset nowrap=0>
</cfif>
				<cfif a_formelements[a].lookuptype eq "query"><!--- must return 2 query vars: lookupdisplay, lookupkey --->
					<cfset thisQuery=a_formelements[a].lookupquery>
						<cfquery datasource="#application.datasource#" name="q_getlist" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							#preserveSingleQuotes(thisQuery)#
						</cfquery>
						<cfif isDefined("request.q_customQuery_#a_formelements[a].fieldname#")>
							<cfset q_getlist=evaluate("request.q_customQuery_#a_formelements[a].fieldname#")>
						</cfif>
					<!--- display table, rows/cols determined by recordcount vs. number of rows wanted --->
					<!--- set up the number of records to ouput, to the query recordcount, and number of rows wanted --->
					<cfset maxRecords=q_getlist.recordcount>
					<cfset maxRows=3>
					<!--- loop thru rows wanted, setting up the number of rows/cols according to recordcount --->
					<cfloop from="1" to="#maxRows#" step="1" index="colCt">
						<cfif q_getlist.recordcount GT round(maxRecords*((round(100/maxRows)*(colCt-1))/100))>
							<cfset rowNum=round(q_getlist.recordcount/colCt)>
							<cfset colNum=colCt>
						</cfif>
					</cfloop>
					<cfif val(rowNum*colNum) LT maxRecords><cfset rowNum=rownum+1></cfif>
					<cfif nowrap>
						<cfset rowNum=1>
						<cfset colNum=maxRecords>
					</cfif>
					<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<cfloop from="1" to="#rowNum#" index="thisRow">
					<tr>
						<cfloop from="1" to="#colNum#" index="thisCol">
							<td class="formitemlabelreq" valign="top"<cfif nowrap> nowrap="nowrap"</cfif>>
								<cfset thisHereRecord=val(thisRow+((thisCol-1)*rowNum))>
								<cfif thisHereRecord LTE maxRecords><input type="radio" name="#a_formelements[a].fieldname#" value="#q_getlist.lookupkey[thisHereRecord]#"> #q_getlist.lookupdisplay[thisHereRecord]# <cfelse>&nbsp;</cfif>
							</td>
						</cfloop>
					</tr>
					</cfloop>
					</table>
					<!--- /display table, rows/cols determined by recordcount vs. number of rows wanted --->
						
				<cfelseif a_formelements[a].lookuptype eq "table"><!--- must return 2 query vars: lookupdisplay, lookupkey --->
					<cfquery datasource="#application.datasource#" name="q_getlist" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						SELECT #a_formelements[a].lookupkey# AS lookupkey, #a_formelements[a].lookupdisplay# AS lookupdisplay FROM #a_formelements[a].lookuptable#
					</cfquery>
					<!--- display table, rows/cols determined by recordcount vs. number of rows wanted --->
					<!--- set up the number of records to ouput, to the query recordcount, and number of rows wanted --->
					<cfset maxRecords=q_getlist.recordcount>
					<cfset maxRows=3>
					<!--- loop thru rows wanted, setting up the number of rows/cols according to recordcount --->
					<cfloop from="1" to="#maxRows#" step="1" index="colCt">
						<cfif q_getlist.recordcount GT round(maxRecords*((round(100/maxRows)*(colCt-1))/100))>
							<cfset rowNum=round(q_getlist.recordcount/colCt)>
							<cfset colNum=colCt>
						</cfif>
					</cfloop>
					<cfif val(rowNum*colNum) LT maxRecords><cfset rowNum=rownum+1></cfif>
					<cfif nowrap>
						<cfset rowNum=1>
						<cfset colNum=maxRecords>
					</cfif>
					<cfparam name="tableattributes" default="">
					<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<cfloop from="1" to="#rowNum#" index="thisRow">
					<tr>
						<cfloop from="1" to="#colNum#" index="thisCol">
							<td valign="top"<cfif nowrap> nowrap="nowrap"</cfif>>
								<cfset thisHereRecord=val(thisRow+((thisCol-1)*rowNum))>
								<cfif thisHereRecord LTE maxRecords><input type="radio" name="#a_formelements[a].fieldname#" value="#q_getlist.lookupkey[thisHereRecord]#"> #q_getlist.lookupdisplay[thisHereRecord]# <cfelse>&nbsp;</cfif>
							</td>
						</cfloop>
					</tr>
					</cfloop>
					</table>
					<!--- /display table, rows/cols determined by recordcount vs. number of rows wanted --->
				<cfelse><!--- must be a 2 delimiter list (key,value;) --->
					<!--- display table, rows/cols determined by recordcount vs. number of rows wanted --->
					<!--- set up the number of records to ouput, to the query recordcount, and number of rows wanted --->
					<cfset maxRecords=listLen(a_formelements[a].lookuplist,";")>
					<cfset maxRows=3>
					<!--- loop thru rows wanted, setting up the number of rows/cols according to recordcount --->
					<cfloop from="1" to="#maxRows#" step="1" index="colCt">
						<cfif listLen(a_formelements[a].lookuplist,";") GT round(maxRecords*((round(100/maxRows)*(colCt-1))/100))>
							<cfset rowNum=round(listLen(a_formelements[a].lookuplist,";")/colCt)>
							<cfset colNum=colCt>
						</cfif>
					</cfloop>
					<cfif val(rowNum*colNum) LT maxRecords><cfset rowNum=rownum+1></cfif>
					<cfparam name="tableattributes" default="">
					<cfif nowrap>
						<cfset rowNum=1>
						<cfset colNum=maxRecords>
					</cfif>
					<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<cfloop from="1" to="#rowNum#" index="thisRow">
					<tr>
						<cfloop from="1" to="#colNum#" index="thisCol">
							<td valign="top"<cfif nowrap> nowrap="nowrap"</cfif>>
								<cfset thisHereRecord=val(thisRow+((thisCol-1)*rowNum))>
								<cfif thisHereRecord LTE maxRecords><input type="radio" name="#a_formelements[a].fieldname#" value="#listFirst(listGetAt(a_formelements[a].lookuplist,thisHereRecord,';'),',')#"> #listLast(listGetAt(a_formelements[a].lookuplist,thisHereRecord,';'),',')# <cfelse>&nbsp;</cfif>
							</td>
						</cfloop>
					</tr>
					</cfloop>
					</table>
					<!--- /display table, rows/cols determined by recordcount vs. number of rows wanted --->
				</cfif>
			</cfcase>
		<!--- ###[BUILD CHECKBOX]### --->
			<cfcase value="checkbox">
<cfif structKeyExists(evaluate("a_tableelements[#listFirst(a_formelements[a].gridposvalue,'_')#].cell_#listLast(a_formelements[a].gridposvalue,'_')#"),"nowrap") AND evaluate("a_tableelements[#listFirst(a_formelements[a].gridposvalue,'_')#].cell_#listLast(a_formelements[a].gridposvalue,'_')#.nowrap") EQ 1>
	<cfset nowrap=1>
<cfelse>
	<cfset nowrap=0>
</cfif>

				<cfif a_formelements[a].lookuptype eq "query"><!--- must return 2 query vars: lookupdisplay, lookupkey --->
					<cfset thisQuery=a_formelements[a].lookupquery>
						<cftry>
						<cfquery datasource="#application.datasource#" name="q_getlist" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							#preserveSingleQuotes(thisQuery)#
						</cfquery>
						<cfcatch>
							Error: Your query screwed up.
						</cfcatch>
						</cftry>
						<cfif isDefined("request.q_customQuery_#a_formelements[a].fieldname#")>
							<cfset q_getlist=evaluate("request.q_customQuery_#a_formelements[a].fieldname#")>
						</cfif>
					<!--- display table, rows/cols determined by recordcount vs. number of rows wanted --->
					<!--- set up the number of records to ouput, to the query recordcount, and number of rows wanted --->
					<cfset maxRecords=q_getlist.recordcount>
					<cfset maxRows=3>
					<!--- loop thru rows wanted, setting up the number of rows/cols according to recordcount --->
					<cfloop from="1" to="#maxRows#" step="1" index="colCt">
						<cfif q_getlist.recordcount GT round(maxRecords*((round(100/maxRows)*(colCt-1))/100))>
							<cfset rowNum=round(q_getlist.recordcount/colCt)>
							<cfset colNum=colCt>
						</cfif>
					</cfloop>
					<cfif val(rowNum*colNum) LT maxRecords><cfset rowNum=rownum+1></cfif>
					<cfif nowrap>
						<cfset rowNum=1>
						<cfset colNum=maxRecords>
					</cfif>
					<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<cfloop from="1" to="#rowNum#" index="thisRow">
					<tr>
						<cfloop from="1" to="#colNum#" index="thisCol">
							<td class="formitemlabelreq" valign="top"<cfif nowrap> nowrap="nowrap"</cfif>>
								<cfset thisHereRecord=val(thisRow+((thisCol-1)*rowNum))>
								<cfif thisHereRecord LTE maxRecords><input type="checkbox" name="#a_formelements[a].fieldname#" value="#q_getlist.lookupkey[thisHereRecord]#"> #q_getlist.lookupdisplay[thisHereRecord]# <cfelse>&nbsp;</cfif>
							</td>
						</cfloop>
					</tr>
					</cfloop>
					</table>
					<!--- /display table, rows/cols determined by recordcount vs. number of rows wanted --->
				<cfelseif a_formelements[a].lookuptype eq "table"><!--- must return 2 query vars: lookupdisplay, lookupkey --->
					<cfquery datasource="#application.datasource#" name="q_getlist" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						SELECT #a_formelements[a].lookupkey# AS lookupkey, #a_formelements[a].lookupdisplay# AS lookupdisplay FROM #a_formelements[a].lookuptable#
					</cfquery>
					<!--- display table, rows/cols determined by recordcount vs. number of rows wanted --->
					<!--- set up the number of records to ouput, to the query recordcount, and number of rows wanted --->
					<cfset maxRecords=q_getlist.recordcount>
					<cfset maxRows=3>
					<!--- loop thru rows wanted, setting up the number of rows/cols according to recordcount --->
					<cfloop from="1" to="#maxRows#" step="1" index="colCt">
						<cfif q_getlist.recordcount GT round(maxRecords*((round(100/maxRows)*(colCt-1))/100))>
							<cfset rowNum=round(q_getlist.recordcount/colCt)>
							<cfset colNum=colCt>
						</cfif>
					</cfloop>
					<cfif val(rowNum*colNum) LT maxRecords><cfset rowNum=rownum+1></cfif>
					<cfparam name="tableattributes" default="">
					<cfif nowrap>
						<cfset rowNum=1>
						<cfset colNum=maxRecords>
					</cfif>
					<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<cfloop from="1" to="#rowNum#" index="thisRow">
					<tr>
						<cfloop from="1" to="#colNum#" index="thisCol">
							<td valign="top"<cfif nowrap> nowrap="nowrap"</cfif>>
								<cfset thisHereRecord=val(thisRow+((thisCol-1)*rowNum))>
								<cfif thisHereRecord LTE maxRecords><input type="checkbox" name="#a_formelements[a].fieldname#" value="#q_getlist.lookupkey[thisHereRecord]#"> #q_getlist.lookupdisplay[thisHereRecord]# <cfelse>&nbsp;</cfif>
							</td>
						</cfloop>
					</tr>
					</cfloop>
					</table>
					<!--- /display table, rows/cols determined by recordcount vs. number of rows wanted --->
				<cfelse><!--- must be a 2 delimiter list (key,value;) --->
					<!--- display table, rows/cols determined by recordcount vs. number of rows wanted --->
					<!--- set up the number of records to ouput, to the query recordcount, and number of rows wanted --->
					<cfset maxRecords=listLen(a_formelements[a].lookuplist,";")>
					<cfset maxRows=3>
					<!--- loop thru rows wanted, setting up the number of rows/cols according to recordcount --->
					<cfloop from="1" to="#maxRows#" step="1" index="colCt">
						<cfif listLen(a_formelements[a].lookuplist,";") GT round(maxRecords*((round(100/maxRows)*(colCt-1))/100))>
							<cfset rowNum=round(listLen(a_formelements[a].lookuplist,";")/colCt)>
							<cfset colNum=colCt>
						</cfif>
					</cfloop>
					<cfif val(rowNum*colNum) LT maxRecords><cfset rowNum=rownum+1></cfif>
					<cfparam name="tableattributes" default="">
					<cfif nowrap>
						<cfset rowNum=1>
						<cfset colNum=maxRecords>
					</cfif>
					<table width="100%" border="0" cellspacing="0" cellpadding="0">					
					<cfloop from="1" to="#rowNum#" index="thisRow">
					<tr>
						<cfloop from="1" to="#colNum#" index="thisCol">
							<td valign="top"<cfif nowrap> nowrap="nowrap"</cfif>>
								<cfset thisHereRecord=val(thisRow+((thisCol-1)*rowNum))>
								<cfif thisHereRecord LTE maxRecords><input type="checkbox" name="#a_formelements[a].fieldname#" value="#listFirst(listGetAt(a_formelements[a].lookuplist,thisHereRecord,';'),',')#"> #listLast(listGetAt(a_formelements[a].lookuplist,thisHereRecord,';'),',')# <cfelse>&nbsp;</cfif>
							</td>
						</cfloop>
					</tr>
					</cfloop>
					</table>
					<!--- /display table, rows/cols determined by recordcount vs. number of rows wanted --->
				</cfif>
			</cfcase>
		<!--- ###[BUILD SELECT]### --->
			<cfcase value="select">
				<select name="#a_formelements[a].fieldname#" size="#a_formelements[a].lookupmultiple#"<cfif a_formelements[a].lookupmultiple GT 1> Multiple</cfif>><option value="">Select-----</option>
					<cfif a_formelements[a].lookuptype eq "query"><!--- must return 2 query vars: lookupdisplay, lookupkey --->
						<cfset thisQuery=a_formelements[a].lookupquery>
						<cftry>
						<cfquery datasource="#application.datasource#" name="q_getlist" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							#preserveSingleQuotes(thisQuery)#
						</cfquery>
						<cfcatch type="Any">
							<strong>THE QUERY YOU specified is invalid:<br></strong> <pre>#preserveSingleQuotes(thisQuery)#</pre>
						</cfcatch>
						</cftry>
						<cfif isDefined("request.q_customQuery_#a_formelements[a].fieldname#")>
							<cfset q_getlist=evaluate("request.q_customQuery_#a_formelements[a].fieldname#")>
						</cfif>
						<cfif isDefined('q_getlist') AND q_getlist.recordcount>
							<cfloop query="q_getlist">
								<option value="#q_getlist.lookupkey#">#q_getlist.lookupdisplay#</option> 
							</cfloop>
						</cfif>
					<cfelseif a_formelements[a].lookuptype eq "table"><!--- must return 2 query vars: lookupdisplay, lookupkey --->
						<cfquery datasource="#application.datasource#" name="q_getlist" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							SELECT #a_formelements[a].lookupkey# AS lookupkey, #a_formelements[a].lookupdisplay# AS lookupdisplay FROM #a_formelements[a].lookuptable#
						</cfquery>
						<cfloop query="q_getlist">
							<option value="#q_getlist.lookupkey#">#q_getlist.lookupdisplay#</option> 
						</cfloop>
					<cfelse><!--- must be a 2 delimiter list (key,value;) --->
						<cfloop list="#a_formelements[a].lookuplist#" index="item" delimiters=";">
							<option value="#listFirst(item,',')#">#listLast(item,',')#</option>  
						</cfloop>
					</cfif>
				</select>
			</cfcase>
		<!--- ###[BUILD BUTTON]### --->
			<cfcase value="button">
				<input type="button" name="#a_formelements[a].fieldname#" width="#a_formelements[a].width#" height="#a_formelements[a].height#" class="#a_formelements[a].inputstyle#" value="#a_formelements[a].defaultvalue#">
			</cfcase>
		<!--- ###[SUBMIT BUTTON]### --->
			<cfcase value="submit">
				<cfif structKeyExists(a_formelements[a],"submitbuttonimage") AND len(a_formelements[a].submitbuttonimage)>
					<input type="image" name="#a_formelements[a].fieldname#" style="width:#a_formelements[a].width#; height:#a_formelements[a].height#;"  class="#a_formelements[a].inputstyle#" src="/#a_formelements[a].submitbuttonimage#">
				<cfelse>
					<input type="submit" name="#a_formelements[a].fieldname#" style="width:#a_formelements[a].width#; height:#a_formelements[a].height#;"  class="#a_formelements[a].inputstyle#" value="#a_formelements[a].defaultvalue#">
				</cfif>
			</cfcase>
		<!--- ###[CANCEL BUTTON]### --->
			<cfcase value="cancel">
				<cfif structKeyExists(a_formelements[a],"cancelbuttonimage") AND len(a_formelements[a].cancelbuttonimage)>
					<input type="image" name="#a_formelements[a].fieldname#" style="width:#a_formelements[a].width#; height:#a_formelements[a].height#;"  class="#a_formelements[a].inputstyle#" src="/#a_formelements[a].cancelbuttonimage#">
				<cfelse>
					<input type="button" name="#a_formelements[a].fieldname#" style="width:#a_formelements[a].width#; height:#a_formelements[a].height#;"  class="#a_formelements[a].inputstyle#" value="#a_formelements[a].defaultvalue#">
				</cfif>
			</cfcase>
		<!--- ###[RESET BUTTON]### --->
			<cfcase value="reset">
				<input type="reset" name="#a_formelements[a].fieldname#" style="width:#a_formelements[a].width#; height:#a_formelements[a].height#;"  class="#a_formelements[a].inputstyle#" value="#a_formelements[a].defaultvalue#">
			</cfcase>
		<!--- ###[DISPLAY HTML FORMATTING ONLY]### --->
			<cfcase value="formatonly">
				#a_formelements[a].formatonly#
			</cfcase>
		<!--- ###[INCLUDE CUSTOM FILE]### --->
			<cfcase value="custominclude">
				<cftry>
					<cfif FileExists('#application.installpath#/#a_formelements[a].custominclude#')>
					 	<cfinclude template="/#application.sitemapping#/#a_formelements[a].custominclude#">
					<cfelseif FileExists('#ExpandPath(application.globalPath)#/#a_formelements[a].custominclude#')>
						<cfinclude template="#application.globalPath#/#a_formelements[a].custominclude#">
					<cfelse>
						<cfthrow type="i3SiteTools.error" message="Missing Include" detail="Could not find a working or global copy of the /#application.installpath#/#a_formelements[a].custominclude#">
					</cfif>
					<cfcatch type="Any">
						<h3 style="color:##cc0000;">ERROR! Something blew up in your custom include:<br> #a_formelements[a].custominclude#</h3><p>#cfcatch.Message# - #cfcatch.Detail#</p>
					</cfcatch>
				</cftry>
			</cfcase>
		<!--- ###[IMAGE]### --->
			<cfcase value="image">
				<input type="image" name="#a_formelements[a].fieldname#" style="width:#a_formelements[a].width#; height:#a_formelements[a].height#;"  class="#a_formelements[a].inputstyle#" src="/#a_formelements[a].imagebuttonpath#">
			</cfcase>
		<!--- ###[FILE UPLOAD FIELD]### --->
			<cfcase value="filechooser">
				<cfset "form.#a_formelements[a].fieldname#"="">
				<cfmodule template="#application.customTagPath#/filechooser.cfm" categoryid="#a_formelements[a].uploadcategoryid#" fieldname="#a_formelements[a].fieldname#">
			</cfcase>
			<!--- ###[GUEST ROLE FIELD]### --->
			<cfcase value="guestrolechooser">
				<select name="#a_formelements[a].fieldname#" class="#a_formelements[a].inputstyle#" size="#a_formelements[a].lookupmultiple#"<cfif a_formelements[a].lookupmultiple GT 1> multiple="multiple"</cfif>>
				<option value="">Select Role</option>
				<cfinvoke component="#application.cfcpath#.util.categoryindent" method="doIndentFromSelfJoin">
					<cfinvokeargument name="ID" value="#a_formelements[a].uploadcategoryid#">
					<cfinvokeargument name="idColumn" value="guestroleid">
					<cfinvokeargument name="displayColumn" value="guestrolename">
					<cfinvokeargument name="parentIdColumn" value="parentid">
					<cfinvokeargument name="childIdColumn" value="childid">
					<cfinvokeargument name="tableName" value="guestrole">
					<cfinvokeargument name="jointableName" value="guestroleparentchild">
					<cfinvokeargument name="dbName" value="#application.datasource#">
					<cfinvokeargument name="orderByColumn" value="guestrolename">
					<cfinvokeargument name="pickLevel" value="parent">
					<cfinvokeargument name="nameLengthLimit" value="24">
				</cfinvoke>
				</select>
			</cfcase>
		<!--- ###[SEARCH ENGINE KEY FIELD]### --->
			<cfcase value="sekeyname">
				<input name="#a_formelements[a].fieldname#" type="text" size="#a_formelements[a].width#" class="#a_formelements[a].inputstyle#">
			</cfcase>
		<!--- ###[SEARCH ENGINE PAGE TITLE FIELD]### --->
			<cfcase value="bs_PageTitle">
				<input name="#a_formelements[a].fieldname#" type="text" size="#a_formelements[a].width#" class="#a_formelements[a].inputstyle#">
			</cfcase>
		<!--- ###[CALENDAR POPUP FIELD]### --->
			<cfcase value="calendarPopup">
				<cfsavecontent variable="jsInsertCal">
                	<cfoutput>
						<script type="text/javascript" src="#application.GlobalPath#/javascript/CalendarPopup.js"></script>
					</cfoutput>
                </cfsavecontent>
                <cfhtmlhead text="#jsInsertCal#">
				<script type="text/javascript">
                    var cal_#a_formelements[a].fieldname# = new CalendarPopup("bsCaldiv_#a_formelements[a].fieldname#");
                    cal_#a_formelements[a].fieldname#.setCssPrefix("BSCal");
                </script>
                <input name="#a_formelements[a].fieldname#" id="#a_formelements[a].fieldname#" type="text" size="#a_formelements[a].width#" class="#a_formelements[a].inputstyle#" maxlength="#a_formelements[a].maxlength#" value=""<cfif a_formelements[a].readonly EQ 1> readonly="readonly"</cfif><cfif len(a_formelements[a].tabindex)> tabindex="#a_formelements[a].tabindex#"</cfif>>
                <a href="##" onclick="cal_#a_formelements[a].fieldname#.select(document.getElementById('#a_formelements[a].fieldname#'),'anchor_#a_formelements[a].fieldname#','MM/dd/yyyy'); return false;" name="anchor_#a_formelements[a].fieldname#" id="anchor_#a_formelements[a].fieldname#">Select Date</a><div id="bsCaldiv_#a_formelements[a].fieldname#" style="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></div>
			</cfcase>
			<!--- ###[Color Picker POPUP FIELD]### --->
			<cfcase value="colorPicker">
				<cfoutput>
					<input name="#a_formelements[a].fieldname#" id="#a_formelements[a].fieldname#" type="text" size="#a_formelements[a].width#" class="#a_formelements[a].inputstyle#" maxlength="#a_formelements[a].maxlength#" value=""<cfif a_formelements[a].readonly EQ 1> readonly="readonly"</cfif><cfif len(a_formelements[a].tabindex)> tabindex="#a_formelements[a].tabindex#"</cfif>>
					<a href="##" title="Click To Change Color" name="anchor1" id="anchor1">Select Color<div id="#a_formelements[a].fieldname#Color" style="background-color: ##fff; width: 60px; height: 20px; padding: 0; margin: 0; border: solid 1px ##000;"/></a>
				</cfoutput>
			</cfcase>
			<!--- ###[DISPLAY FCKEditor EDITOR]### --->
			<cfcase value="WYSIWYGBasic">
				<form>
				<cfif isDefined("application.wysiwyg") AND application.wysiwyg EQ "fckeditor">
					<cfscript>
						fckEditor = createObject("component", "#application.globalPath#/fckeditor/#application.fckVersion#/fckeditor");								
						fckEditor.basePath		= "#application.globalPath#/fckeditor/#application.fckVersion#/";
						fckEditor.instanceName	= "#a_formelements[a].fieldname#";
						fckEditor.value			= "";
						fckEditor.width			= "#a_formelements[a].width#";
						fckEditor.height		= "#a_formelements[a].height#";
						fckEditor.toolbarSet	= "Basic";
						fckEditor.create(); // create the editor.
					</cfscript>
				</cfif>
			</cfcase>
			<cfcase value="WYSIWYGSimple">
			<form>
				<cfif isDefined("application.wysiwyg") AND application.wysiwyg EQ "fckeditor">
					<cfscript>
						fckEditor = createObject("component", "#application.globalPath#/fckeditor/#application.fckVersion#/fckeditor");								
						fckEditor.basePath		= "#application.globalPath#/fckeditor/#application.fckVersion#/";
						fckEditor.instanceName	= "#a_formelements[a].fieldname#";
						fckEditor.value			= "";
						fckEditor.width			= "#a_formelements[a].width#";
						fckEditor.height		= "#a_formelements[a].height#";
						fckEditor.toolbarSet	= "Simple";
						fckEditor.create(); // create the editor.
					</cfscript>
				</cfif>
			</cfcase>
			<cfcase value="WYSIWYGDefault">
			<form>
				<cfif isDefined("application.wysiwyg") AND application.wysiwyg EQ "fckeditor">
					<cfscript>
						fckEditor = createObject("component", "#application.globalPath#/fckeditor/#application.fckVersion#/fckeditor");								
						fckEditor.basePath		= "#application.globalPath#/fckeditor/#application.fckVersion#/";
						fckEditor.instanceName	= "#a_formelements[a].fieldname#";
						fckEditor.value			= "";
						fckEditor.width			= "#a_formelements[a].width#";
						fckEditor.height		= "#a_formelements[a].height#";
						fckEditor.toolbarSet	= "Default";
						fckEditor.create(); // create the editor.
					</cfscript>
				</cfif>
			</cfcase>
			<cfdefaultcase>&nbsp;</cfdefaultcase>
		</cfswitch>
		</cfoutput>
	</cfsavecontent>
	<!--- this dummlist was set in hopes that presetting the var would help the listappend --->
	<cfset thisDummList=evaluate("pos#a_formelements[a].gridposvalue#")>
	<cfset "pos#a_formelements[a].gridposvalue#"=listAppend(thisDummList,tempVar,"|")>

</cfloop> 



<!--- get list of cells that won't be written --->
<cfset spannedcell="">  
      <cfloop index="r" from="1" to="#q_getform.tablerows#">  
          <cfloop index="c" from="1" to="#q_getform.tablecolumns#">  
  <!--- attempt to deal with row and colspans within one cell --->  
              <cfif evaluate("a_tableelements[#r#].cell_#c#.rowspan") GT 1 AND evaluate("a_tableelements[#r#].cell_#c#.colspan") GT 1>  
                   <cfset thisrowcount_=evaluate('a_tableelements[#r#].cell_#c#.rowspan')>  
                   <cfset thiscolcount_=evaluate('a_tableelements[#r#].cell_#c#.colspan')>  
                       <cfloop from="1" to="#thisrowcount_#" index="rr">  
                           <cfloop from="1" to="#thiscolcount_#" index="cc">  
                           <cfif rr GT 1 OR cc GT 1>  
                               <cfset spannedcell=listAppend(spannedcell,"#r+rr-1#_#evaluate(c+cc-1)#",",")>  
                           </cfif>  
                           </cfloop>  
                       </cfloop>  
              <!--- see if this cell has a rowspan --->  
              <cfelseif evaluate("a_tableelements[#r#].cell_#c#.rowspan") GT 1>  
              <!--- add each row past originating row to blocklist for length of span --->  
                  <cfloop from="1" to="#(evaluate("a_tableelements[#r#].cell_#c#.rowspan")-1)#" index="rr">  
                      <cfset spannedcell=listAppend(spannedcell,"#evaluate(r+rr)#_#c#",",")>  
                  </cfloop>  
              <cfelseif evaluate("a_tableelements[#r#].cell_#c#.colspan") GT 1>  
              <!--- see if this cell has a colspan --->  
                  <!--- add each col past originating col to blocklist for length of span --->  
                  <cfloop from="1" to="#(evaluate('a_tableelements[#r#].cell_#c#.colspan')-1)#" index="cc">  
                      <cfset spannedcell=listAppend(spannedcell,"#r#_#evaluate(c+cc)#",",")>  
                  </cfloop>  
              </cfif>  
          </cfloop>  
      </cfloop>
<!--- Build HTML Table taking into account all row and col spans --->
<cfoutput>
<cfif isDefined('showFormOnly')><div id="socketformpreviewhdr"><h3>Preview #q_getform.label# Form</h3></div><div style="clear:both"></div></cfif>
<!--- container table begins --->
<table border="0" cellspacing="0" cellpadding="0">
<tr>
	<td align="left" valign="top">
<table id="socketformpreviewtable" cellpadding="#q_getform.tablepadding#" cellspacing="#q_getform.tablespacing#" width="#q_getform.tablewidth#" align="#q_getform.tablealign#"<cfif len(q_getform.tableclass)> class="#q_getform.tableclass#"</cfif>

	
	

		<cfloop index="r" from="1" to="#q_getform.tablerows#"><!--- arrayLen(a_tableelements) --->
		<cfset rowstarted=0>
		<cfset rowcontains=0>
			<cfloop index="c" from="1" to="#q_getform.tablecolumns#">
			<cfset tableattributes="id='#r#_#c#' name='#r#_#c#'">
				<cfif NOT listFind(spannedcell,"#r#_#c#",",")>
					<cfif NOT rowstarted><tr><td class="socketformpreviewrownum"><strong>#r#</strong></td><cfset rowstarted=1></cfif>
					<!--- write all applicable attributes to table cell --->
						<cfif structKeyExists(evaluate("a_tableelements[#r#].cell_#c#"),"nowrap") AND evaluate("a_tableelements[#r#].cell_#c#.nowrap") EQ 1>
							<cfset tableattributes="#tableattributes# nowrap=""nowrap""">
						</cfif>
						<cfif evaluate("a_tableelements[#r#].cell_#c#.width") GT 1> 
							<cfset tableattributes="#tableattributes# width=#evaluate('a_tableelements[#r#].cell_#c#.width')#">
						</cfif>
						<cfif evaluate("a_tableelements[#r#].cell_#c#.colspan") GT 1> 
							<cfset tableattributes="#tableattributes# colspan=#evaluate('a_tableelements[#r#].cell_#c#.colspan')#">
						</cfif>
						<cfif evaluate("a_tableelements[#r#].cell_#c#.rowspan") GT 1> 
							<cfset tableattributes="#tableattributes# rowspan=#evaluate('a_tableelements[#r#].cell_#c#.rowspan')#">
						</cfif>
						<cfif len(evaluate("a_tableelements[#r#].cell_#c#.align")) GT 1> 
							<cfset tableattributes="#tableattributes# align=#evaluate('a_tableelements[#r#].cell_#c#.align')#">
						</cfif>
						<cfif len(evaluate("a_tableelements[#r#].cell_#c#.valign")) GT 1> 
							<cfset tableattributes="#tableattributes# valign=#evaluate('a_tableelements[#r#].cell_#c#.valign')#">
						</cfif>
						<cfif len(evaluate("a_tableelements[#r#].cell_#c#.class")) GT 1> 
							<cfset tableattributes="#tableattributes# class=#evaluate('a_tableelements[#r#].cell_#c#.class')#">
						</cfif>
					<td #tableattributes#><a href="javascript:void(0);" onclick="javascript: window.open('/admintools/index.cfm?toolaction=cellproperties&thisCell=#r#,#c#&formobjectid=#formobjectid#&cols=#q_getform.tablecolumns#&rows=#q_getform.tablerows#','cellproperties','width=325,height=300,left=200,top=200,screenX=200,screenY=200,resizable')"><img src="#APPLICATION.GlobalPath#/media/images/icon_editCell.gif" alt="Edit Cell #r#,#c#" width="23" height="19" border="0" align="left" /></a><cfif isDefined("pos#r#_#c#")><cfloop list="#evaluate('pos#r#_#c#')#" index="thisItem" delimiters="|">#thisItem# </cfloop><cfelse>&nbsp;</cfif>
					</td>
					<cfset rowcontains=1>
				</cfif>
					<cfif c EQ q_getform.tablecolumns AND (rowcontains EQ 1 OR rowstarted EQ 1)>
					</tr>
						<cfset rowstarted=0>
						<cfset rowcontains=0>
					</cfif>
			</cfloop>
		</cfloop>
	</table>
	<!--- close user defined table --->
	
	<!--- Row Adding and Deleting Buttons link to the previous form which will automatically change row value and submit back to this page--->
	
<!--- 	<div id="rowButtons" align="center">
		<a href="#request.page#?formobjectid=#formobjectid#&toolaction=DTShowForm&addRow=1" id="addRowButton">Add Row</a>
					<a href="#request.page#?formobjectid=#formobjectid#&toolaction=DTShowForm&addRow=-1" id="deleteRowButton">Delete Row</a>
	</div> --->
	
	</td>
	
	<td valign="top" align="right">
		<!--- build and display edit buttons for form elements --->
		<cfif NOT isDefined('showFormOnly')>
		<table id="socketeditfieldtable">
			<tr>
				<td class="toolheader">Edit Fields</td>
			</tr>
			<!--- child form object 'add field' --->
		<cfif listLen(q_getForm.omitfieldlist)>
			<tr>
				<td class="formitemlabel" nowrap>
				<form action="#request.page#" method="post">
					<input type="Hidden" name="toolaction" value="addtochild">
					<input type="Hidden" name="formobjectid" value="#formobjectid#">
					<input type="Hidden" name="parentid" value="#q_getForm.parentid#">
					<select name="addChildField" size="1">
					<cfloop list="#q_getForm.omitfieldlist#" index="thisField">
						<option value="#thisField#">#thisField#</option>
					</cfloop>
					</select>
					<input type="Submit" value="Add" class="submitbutton" style="width:60;">
				</form>
			</td>
		</tr>
		</cfif>
			<cfloop index="r" from="1" to="#arrayLen(a_tableelements)#">
			<cfif r GT q_getform.tablerows>
				<cfset editClass="formbuilderfieldMIA">
			<cfelse>
				<cfset editClass="formiteminput">
			</cfif>
				<cfloop index="c" from="1" to="#q_getform.tablecolumns#">
					<cfif isDefined("field#r#_#c#")>
						<cfloop list="#evaluate('field#r#_#c#')#" index="thisEdit" delimiters="|">
							<tr>
								<td class="#editClass#">
									<a href="#request.page#?toolaction=DEshowform&formobjectid=#formobjectid#&fieldname=#thisEdit#"><img src="#APPLICATION.globalpath#/media/images/icon_editField.gif" width="28" height="23" alt="Edit #thisEdit#" border="0"></a>
									<!--- <a href="#request.page#?toolaction=DEshowform&formobjectid=#formobjectid#&fieldname=#thisEdit#&deletefield=true"> --->  <!--- <img src="#APPLICATION.globalpath#/media/images/icon_deleteFile.gif" onclick="javascript:deleteField('#thisEdit#',#r-1#);"  alt="Delete #thisEdit#" border="0"> ---> <!---  </a> --->
									<a href="#request.page#?toolaction=DEshowform&formobjectid=#formobjectid#&fieldname=#thisEdit#">#thisEdit#</a>
								</td>
							</tr>
						</cfloop>
						
					</cfif>
				</cfloop>
			</cfloop>	
		</table>
		</cfif>
		</td>
		<td valign="top" border="0" align="right">
			<table id= "rightButtons" cellspacing="20">
				<tr>
				<td align="center">
					<input type="button" value="New Field" onclick="javascript:window.open('#request.page#?toolaction=DEShowForm&formobjectid=#formobjectid#','_self');" class="largeSubmitbutton" style="width:85px" tabindex="31">
				</td>
				</tr>
				<tr>
				<td align="center">
					<input type="button" value="Shuffle Fields" onclick="javascript:window.open('#application.installurl#/admintools/index.cfm?toolaction=shufflelayout&formobjectid=#formobjectid#','layoutWindow','height=450,width=450,toolbars=no,resizable=yes,scrollbars=yes,location=no');" class="largeSubmitbutton" style="width:85px" tabindex="30"  />
				</td>
				</tr>
				<tr>
				<!--- JPL 5-14-2008 Changed to different display in Form Builder --->
				<cfif isDefined('q_getform') AND NOT (q_getform.formobjectid eq q_getform.parentid)>
					<td align="center">
						<a href="#request.page#?formobjectid=#formobjectid#&toolaction=DTShowForm"><input type="button" value="Configuration" class="largeSubmitbutton" style="width:85px" tabindex="33"></a>
					</td>
				<cfelse>
					<td align="center">
						<input type="button" value="Finalize Tool >>" onclick="javascript:window.open('#request.page#?toolaction=createform&formobjectid=#formobjectid#','_self');" class="largeSubmitbutton" style="width:85px" tabindex="33">
					</td>
				</cfif>
				
			</table>
		</td>
	</tr>
</table>

<!--- <script type="text/javascript">
testfunction();
</script> --->
<!--- close container table --->
</cfoutput>

