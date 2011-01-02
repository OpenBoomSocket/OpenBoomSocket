<!--- 
	MOD ERJ: 2-13-06
	Moved all the logic and code inside of <cfcase> tags into there own includes. So most of the logic is now inside
	the folder ../formbuidFront/includes/
	/coreV5/formbuildFront/includes/i_inputTypeSelect.cfm
 --->
<!--- jlw 6/9/2004 fix for image buttons --->
<cfparam name="submitrow" default="1">
<cfif thistag.executionmode is "START">
<cfset thisIncludePath = "#application.customTagPath#/formbuildFront/includes">
<cfif NOT isDefined("q_getForm.recordcount")>
	ERROR: To include this tag: formbuild.cfm, you must have the query: q_getForm available.
	<cfabort>
</cfif>
<!--- variable determines what mode this page is in flat file or dynamic --->
<cfparam name="request.createflatfile" default="0">

<!--- get table definition --->
<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML"
        input="#q_getform.tabledefinition#"
        output="a_tableelements">
<!--- get data definitions --->
<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML"
        input="#q_getform.datadefinition#"
        output="a_formelements">
<cfif arrayLen(a_tableelements) GTE 2>
	<cfset request.defaultCellClass=a_tableelements[2].cell_2.class>
<cfelse>
	<cfset request.defaultCellClass=a_tableelements[1].cell_2.class>
</cfif>
<!--- Loop over formelements setting default values --->
<cfif (isDefined("instanceID") AND instanceID NEQ 0) OR q_getForm.singleRecord EQ 1>
<!--- we are editing so query for instance of object --->
<cfset formProcessObj = CreateObject('component','#application.cfcpath#.formprocess')>
	<cfif q_getForm.singleRecord EQ 1>
		<cfset q_getInstance = formprocessObj.getName(limit=1,datatable=q_getform.datatable)>
		<cfset instanceid=evaluate("q_getInstance.#q_getform.datatable#ID")>
	<cfelse>
		<cfset q_getInstance = formprocessObj.getName(datatable=q_getform.datatable,instanceString=trim(instanceid))>
	</cfif>
	<cfloop index="a" from="1" to="#arrayLen(a_formelements)#">
		<cfif listFindNoCase(q_getInstance.columnlist,a_formelements[a].fieldname,",")>
			<cfparam name="form.#a_formelements[a].fieldname#" default="#evaluate('q_getInstance.'&a_formelements[a].fieldname)#">
		<cfelse>
			<cfparam name="form.#a_formelements[a].fieldname#" default="#a_formelements[a].defaultvalue#">
		</cfif>
	</cfloop>
	<!--- 12/05/2006 DRK add composite form prefill functionality START --->
	<cfif isDefined('q_getForm.compositeForm') and q_getForm.compositeForm EQ 1>
		<!--- Initialize joinTableList variable --->
		<cfset foreignTableIdList = "">
		<!--- loop through a_formelements to grap foreign keys --->
		<cfloop index="itemIndex" from="1" to="#ArrayLen(a_formelements)#">
			<!--- If FOREIGNKEY exists grab value --->
			<cfif arrayLen(structFindKey(#a_formelements[itemIndex]#,"FOREIGNKEY"))>
				<!--- only add unique ids --->
				<cfif Not findnocase(a_formelements[itemIndex]['SOURCEFORMOBJECTID'], foreignTableIdList)>
					<!--- append new value to current list --->
					<cfset foreignTableIdList = listAppend(foreignTableIdList,a_formelements[itemIndex]['sourceformobjectid'],",")>
				</cfif>
			</cfif>
		</cfloop>
		<!--- arrange list in numeric order --->
		<cfset foreignTableIdList = listSort(foreignTableIdList,"Numeric", "ASC")>
		<!--- Lookup datatable name in formobject table using sourceformobjectid --->
		<cfif listLen(foreignTableIdList)>
			<cfset q_tableList = formProcessObj.getTablesFromIDs(formObjectIds=foreignTableIdList)>
			<!--- loop through the foreign data set --->
			<cfloop query="q_tableList" >
				<!--- check to see if we have values set for these ids --->
				<cfif structFind(form,"#q_tableList.datatable#ID") GT 0>
				<!--- get the foreign table data using only the fields that are used --->
					<cfset selectClause = "">
					<cfset fromClause = q_tableList.datatable>
					<cfset whereClause ="#q_tableList.datatable#ID = "&listFirst(FORM['#q_tableList.datatable#ID'],"~")>
					<!--- build query statements from included fields --->
					<cfloop index="itemIndex" from="1" to="#ArrayLen(a_formelements)#">
						<cfif arrayLen(structFindKey(a_formelements[itemIndex],'SOURCEFORMOBJECTID')) AND (a_formelements[itemIndex]['SOURCEFORMOBJECTID'] EQ q_tableList.formobjectid)>
							<cfif len(trim(selectClause))>
								<cfset selectClause = selectClause&','>
							</cfif>
							<cfset selectClause = selectClause&a_formelements[itemIndex]['FIELDNAME']>
						</cfif>
					</cfloop>
					<!--- grab foreign instance data --->
					<cfset q_foreignInstanceData = formprocessObj.getFormData(selectClause=selectClause,fromClause=fromClause,whereClause=whereClause)>
					<!--- assign foreign data to the FORM scope --->
					<cfloop list="#q_foreignInstanceData.columnlist#" index="fieldName">
						<cfset "form.#fieldName#" =evaluate('q_foreignInstanceData.'&fieldName)>
					</cfloop>
				</cfif>
			</cfloop>
		</cfif>
	</cfif>
	<!--- 12/05/2006 DRK add composite form prefill functionality END --->
<cfelse><!--- set system defaults --->
	<cfloop index="a" from="1" to="#arrayLen(a_formelements)#">
		<cfparam name="form.#a_formelements[a].fieldname#" default="#a_formelements[a].defaultvalue#">
	</cfloop>
</cfif>

		<!--- Loop over formelements, creating local vars for output in table --->
		<cfloop index="a" from="1" to="#arrayLen(a_formelements)#">
			<!---Set a variable for whether this has javascript functionality or not--->
			<cfif LEN(a_formelements[a].javascript) AND LEN(a_formelements[a].javascripthandler)>
				<cfset javascriptFunction = a_formelements[a].javascripthandler & '="' & a_formelements[a].javascript & '"'>
			<cfelse>
				<cfset javascriptFunction = "">
			</cfif>
			<cfparam name="pos#a_formelements[a].gridposlabel#" default="">
			<cfif NOT listFindNoCase("submit,reset,hidden,button,formatonly,image,custominclude,cancel,useMappedContent","#a_formelements[a].inputtype#")>
				<cfset "pos#a_formelements[a].gridposlabel#"=listAppend(evaluate("pos#a_formelements[a].gridposlabel#"),a_formelements[a].objectlabel,"|")>
			<cfelse>
				<cfparam name="pos#a_formelements[a].gridposlabel#" default="">
			</cfif>
			<cfparam name="pos#a_formelements[a].gridposvalue#" default="">
			<cfsavecontent variable="tempVar">
				<cfoutput>
				<cfswitch expression="#a_formelements[a].inputtype#">
				<!--- build text input --->
					<cfcase value="text">
						<input type="text" name="#a_formelements[a].fieldname#" id="#a_formelements[a].fieldname#" size="#a_formelements[a].width#" #javascriptFunction# class="#a_formelements[a].inputstyle#" maxlength="#a_formelements[a].maxlength#" value="#evaluate('form.#a_formelements[a].fieldname#')#"<cfif a_formelements[a].readonly EQ 1> readonly="readonly"</cfif><cfif len(a_formelements[a].tabindex)> tabindex="#a_formelements[a].tabindex#"</cfif>>
					</cfcase>
				<!--- build password input --->
					<cfcase value="password">
						<input type="password" autocomplete="off" name="#a_formelements[a].fieldname#" id="#a_formelements[a].fieldname#" size="#a_formelements[a].width#" #javascriptFunction# class="#a_formelements[a].inputstyle#" maxlength="#a_formelements[a].maxlength#" value="<!--- #evaluate('form.#a_formelements[a].fieldname#')# --->"<cfif len(a_formelements[a].tabindex)> tabindex="#a_formelements[a].tabindex#"</cfif>>
					</cfcase>
				<!--- build text textarea --->
					<cfcase value="textarea">
						<textarea cols="#a_formelements[a].width#" #javascriptFunction# id="#a_formelements[a].fieldname#" rows="#a_formelements[a].height#" name="#a_formelements[a].fieldname#" class="#a_formelements[a].inputstyle#"<cfif a_formelements[a].readonly EQ 1> readonly="readonly"</cfif><cfif len(a_formelements[a].tabindex)> tabindex="#a_formelements[a].tabindex#"</cfif>>#evaluate('form.#a_formelements[a].fieldname#')#</textarea>
					</cfcase>
				<!--- build radio button array --->
					<cfcase value="radio">
						<cfinclude template="#thisIncludePath#/i_inputTypeRadio.cfm">
					</cfcase>
				<!--- build checkbox --->
					<cfcase value="checkbox">
						<cfinclude template="#thisIncludePath#/i_inputTypeCheckbox.cfm">
					</cfcase>
				<!--- build select --->
					<cfcase value="select">
						<cfinclude template="#thisIncludePath#/i_inputTypeSelect.cfm">
					</cfcase>
					<cfcase value="button"><!--- build button --->
						<input type="button" name="#a_formelements[a].fieldname#" id="#a_formelements[a].fieldname#" width="#a_formelements[a].width#" #javascriptFunction# height="#a_formelements[a].height#" class="#a_formelements[a].inputstyle#" value="#evaluate('form.#a_formelements[a].fieldname#')#">
					</cfcase>
					<cfcase value="image"><!--- image button --->
						<cfif q_getForm.useWorkFlow EQ 1>
							<cfset javascriptFunction='onClick="fpSubmit();"'>
						</cfif>
						<input type="image" class="#a_formelements[a].inputstyle#" id="#a_formelements[a].fieldname#" src="#application.installURL#/#a_formelements[a].imagebuttonpath#"<cfif len(javascriptFunction)> #javascriptFunction#</cfif><cfif len(a_formelements[a].tabindex)> tabindex="#a_formelements[a].tabindex#"</cfif>>
					</cfcase>
					<cfcase value="cancel"><!--- cancel button --->
						<cfif q_getForm.useWorkFlow EQ 1>
							<cfset javascriptFunction='onClick="fpSubmit();"'>
						</cfif>
						<cfif len(trim(a_formelements[a].cancelbuttonimage))>
							<input type="image" id="#a_formelements[a].fieldname#" class="#a_formelements[a].inputstyle#" src="#application.installURL#/#a_formelements[a].cancelbuttonimage#"<cfif len(javascriptFunction)> #javascriptFunction#</cfif><cfif len(a_formelements[a].tabindex)> tabindex="#a_formelements[a].tabindex#"</cfif>>
						<cfelse>
							<input type="button" id="#a_formelements[a].fieldname#" value="#evaluate('form.#a_formelements[a].fieldname#')#" class="#a_formelements[a].inputstyle#" #javascriptFunction#>
						</cfif>						
					</cfcase>
					<cfcase value="submit"><!--- submit button --->
					
						<cfset submitRow=listFirst(a_formelements[a].gridposvalue,"_")>
						<cfparam name="a_formelements[a].submitbuttonimage" default="">
						<cfset showDelete="0">
						<cfset showClone="0">
						<cfif IsDefined('instanceID') AND instanceID GTE 1 AND isDefined('q_getForm.parentID') AND IsDefined('q_getForm.formobjectID') AND q_getForm.formobjectID EQ q_getForm.parentID>
							<cfset showClone="1">
						</cfif>						
						<cfif q_getForm.useWorkFlow EQ 1>							
							<cfset javascriptFunction='onClick="fpSubmit();"'>
							<cfset editbuttonvalue="#evaluate('form.#a_formelements[a].fieldname#')#">
							<cfmodule template="#application.customTagPath#/showButtonBar.cfm" 
									editbuttonvalue="#evaluate('form.#a_formelements[a].fieldname#')#"
									editbuttonclass="#a_formelements[a].inputstyle#"
									javascriptcall="#javascriptFunction#" 
									submitbuttonimage="#a_formelements[a].submitbuttonimage#"
									useWorkFlow="1"									
									showDelete="#showDelete#"
									showClone="#showClone#"
									cloneFormname="#q_getform.formname#">
						<cfelse>
							<cfif isDefined("instanceid") AND APPLICATION.getPermissions("remove",attributes.formobjectid) AND q_getForm.singleRecord NEQ 1>
								<cfset showDelete="1">
							</cfif>
							<cfparam name="thisinstanceid" default="">
							<cfif isDefined('instanceid')>
								<cfset thisinstanceid=trim(instanceid)>
							</cfif>
							<cfmodule template="#application.customTagPath#/showButtonBar.cfm" 
									useWorkFlow="0"
									editbuttonclass="#a_formelements[a].inputstyle#"
									javascriptcall="#javascriptFunction#"
									editbuttonvalue="#evaluate('form.#a_formelements[a].fieldname#')#"									
									editbuttonname="#a_formelements[a].fieldname#"
									editbuttonid="#a_formelements[a].fieldname#"
									editbuttontabindex="#a_formelements[a].tabindex#"									
									showDelete="#showDelete#"
									showClone="#showClone#"
									cloneFormname="#q_getform.formname#">
							<!--- <input type="submit" name="#a_formelements[a].fieldname#" id="#a_formelements[a].fieldname#" style="width:#a_formelements[a].width#; height:#a_formelements[a].height#;"  class="#a_formelements[a].inputstyle#" #javascriptFunction# value="#evaluate('form.#a_formelements[a].fieldname#')#"<cfif len(a_formelements[a].tabindex)> tabindex="#a_formelements[a].tabindex#"</cfif>> --->
						</cfif>
					</cfcase>
					<cfcase value="reset"><!--- reset button --->
						<input type="reset" name="#a_formelements[a].fieldname#" id="#a_formelements[a].fieldname#" style="width:#a_formelements[a].width#; height:#a_formelements[a].height#;"  class="#a_formelements[a].inputstyle#" #javascriptFunction# value="#evaluate('form.#a_formelements[a].fieldname#')#">
					</cfcase>
					<cfcase value="formatonly"><!--- display html formatting only --->
						#a_formelements[a].formatonly#
					</cfcase>
					<cfcase value="custominclude">
						<cfinclude template="#thisIncludePath#/i_includeCustomFile.cfm">						
					</cfcase>
					<cfcase value="filechooser"><!--- Include Filechooser Customtag --->
						<cfmodule template="#application.customTagPath#/filechooser.cfm" 
								categoryid="#a_formelements[a].uploadcategoryid#" 
								fieldname="#a_formelements[a].fieldname#" 
								formname="#q_getform.formname#"
								tabindex="#a_formelements[a].tabindex#">
					</cfcase>
					<cfcase value="guestrolechooser">
						<select id="#a_formelements[a].fieldname#" name="#a_formelements[a].fieldname#" class="#a_formelements[a].inputstyle#" #javascriptFunction# size="#a_formelements[a].lookupmultiple#"<cfif a_formelements[a].lookupmultiple GT 1> multiple="multiple"</cfif> >
							<option value="">Select Role</option>	
							<cfinvoke component="#application.cfcpath#.util.categoryindent" method="doIndentFromSelfJoin">
								<cfinvokeargument name="ID" value="#a_formelements[a].uploadcategoryid#">
								<cfinvokeargument name="pickID" value="#evaluate('form.#a_formelements[a].fieldname#')#">
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
					<cfcase value="sekeyname">
						<cfinclude template="#thisIncludePath#/i_sekeynameField.cfm">
					</cfcase>
					<cfcase value="calendarPopup">
						<cfinclude template="#thisIncludePath#/i_calendarPopup.cfm">
					</cfcase>
					<cfcase value="colorPicker">
						<cfinclude template="#thisIncludePath#/i_colorPickerDisplay.cfm">
					</cfcase>
					<cfcase value="bs_pageTitle">
						<cfinclude template="#thisIncludePath#/i_bsPageTitleField.cfm">
					</cfcase>
					<cfcase value="activEdit">
						<cfinclude template="#thisIncludePath#/i_wysiwygActiveEdit.cfm">
					</cfcase>
					<cfcase value="WYSIWYGBasic">
						<cfinclude template="#thisIncludePath#/i_wysiwygBasic.cfm">
					</cfcase>
					<cfcase value="WYSIWYGSimple">
						<cfinclude template="#thisIncludePath#/i_wysiwygSimple.cfm">
					</cfcase>
					<cfcase value="WYSIWYGDefault">
						<cfinclude template="#thisIncludePath#/i_wysiwygDefault.cfm">
					</cfcase>
					<cfcase value="useMappedContent"><!--- using mapped content, so create link --->
						<cfif NOT (isDefined("instanceID") AND instanceID NEQ 0)>
							<cfset SESSION.tempinstanceid = randrange(1,9999)>
						</cfif>
						<script type="text/javascript">
						var contentWindow;
						function openContentWindow(){
							<cfif isDefined('SESSION.tempinstanceid')>
							var text = document.getElementById('#q_getform.datatable#name').value;
							</cfif>
							if(contentWindow == null){
								contentWindow = window.open('/admintools/includes/i_ContentMapping.cfm?thisInstance=<cfif NOT (isDefined("instanceID") AND instanceID NEQ 0)>#SESSION.tempinstanceid#<cfelse>#instanceID#</cfif><cfif isDefined('SESSION.tempinstanceid')>&titletext='+text+'</cfif>&associaterole=1','MapContent','menubar=no,statusbar=no,resizable,width=650,height=400');
								contentWindow.focus();
							}else if(contentWindow.document == null){
								contentWindow = window.open('/admintools/includes/i_ContentMapping.cfm?thisInstance=<cfif NOT (isDefined("instanceID") AND instanceID NEQ 0)>#SESSION.tempinstanceid#<cfelse>#instanceID#</cfif><cfif isDefined('SESSION.tempinstanceid')>&titletext='+text+'</cfif>&associaterole=1','MapContent','menubar=no,statusbar=no,resizable,width=650,height=400');
								contentWindow.focus();
							}else{
								contentWindow.close();
								contentWindow = window.open('/admintools/includes/i_ContentMapping.cfm?thisInstance=<cfif NOT (isDefined("instanceID") AND instanceID NEQ 0)>#SESSION.tempinstanceid#<cfelse>#instanceID#</cfif><cfif isDefined('SESSION.tempinstanceid')>&titletext='+text+'</cfif>&associaterole=1','MapContent','menubar=no,statusbar=no,resizable,width=650,height=400');
								contentWindow.focus();
							}
							//alert(contentWindow.document);
						}
						</script>
						<input type="button" class="contentmappingbutton submitbutton" onclick="openContentWindow()" value="&nbsp;Manage Assignment to Pages&nbsp;">
					</cfcase>
					<cfdefaultcase>&nbsp;</cfdefaultcase>
				</cfswitch>
				</cfoutput>
			</cfsavecontent>
			<cfset "pos#a_formelements[a].gridposvalue#"=listAppend(evaluate("pos#a_formelements[a].gridposvalue#"),tempVar,"|")>
		</cfloop>

<!--- get list of cells that won't be written --->
<cfset spannedcell="">  
      <cfloop index="r" from="1" to="#q_getform.tablerows#">  
          <cfloop index="c" from="1" to="#q_getform.tablecolumns#">  
  <!--- BDW & GDM 2/13/2004 attempt to deal with row and colspans within one cell --->  
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
	
<!--- ***** Build HTML Table taking into account all row and col spans ***** --->
<cfoutput>
<!--- Display Header Treatment if this is an Admin Form --->
<cfif q_getForm.adminonly EQ 1>
	<!--- Clone Mesage Banner --->
	<cfif isDefined('FORM.CloneThisRecord') AND FORM.CloneThisRecord>
		<h2 style="background-color:##009900; color:##FFFFFF; padding: 4px; margin-bottom:0; text-align:center;">This is a copy. Saving will create a new record with the data below.</h2>
	</cfif>
<div id="socketformheader">
	<h2>#q_getform.label#</h2><cfif q_getForm.singleRecord NEQ 1><div id="returnToIndex"><a href="#request.page#?i3currentTool=#session.i3currentTool#">&lt; #q_getform.label# Index</a></div></cfif>
</div><div style="clear:both;"></div>
</cfif>
<!--- Display Error Message Block --->
<cfif isDefined("errorMsgBlock") AND len(trim(errorMsgBlock))>
#errorMsgBlock#
</cfif>
<table id="socketformtable"<cfif len(q_getform.tableborder)> border="#q_getform.tableborder#"</cfif><cfif len(q_getform.tablepadding)> cellpadding="#q_getform.tablepadding#"</cfif><cfif len(q_getform.tablespacing)> cellspacing="#q_getform.tablespacing#"</cfif><cfif len(q_getform.tablewidth)> width="#q_getform.tablewidth#"</cfif><cfif len(q_getform.tablealign)> align="#q_getform.tablealign#"</cfif><cfif len(q_getform.tableclass)> class="#q_getform.tableclass#"</cfif>>
		<cfloop index="r" from="1" to="#q_getform.tablerows#">
		<cfset rowstarted=0>
		<cfset rowcontains=0>
			<cfloop index="c" from="1" to="#q_getform.tablecolumns#">
			<cfset tableattributes="">
				<cfif NOT listFind(spannedcell,"#r#_#c#",",")>
					<cfif NOT rowstarted><tr id="#q_getForm.formname#_row#r#"><cfset rowstarted=1></cfif>
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
						<cfelse>
							<cfif arrayLen(a_tableelements) GTE 2>
								<cfset tableattributes="#tableattributes# class=#a_tableelements[2].cell_2.class#">
							<cfelse>
								<cfset tableattributes="#tableattributes# class=#a_tableelements[1].cell_2.class#">
							</cfif>
						</cfif>
					<td #tableattributes#><cfif isDefined("pos#r#_#c#")><cfloop list="#evaluate('pos#r#_#c#')#" index="thisItem" delimiters="|"><!--- CMC: &nbsp; adds too much space around checkboxes ---><cfif thisItem neq '&nbsp;'>#thisItem#<cfif findnocase('formitemlabelreq',tableattributes)><span class="requiredAsterisk">*</span></cfif></cfif></cfloop><cfelse>&nbsp;</cfif>
					</td>
					<cfset rowcontains=1>
				</cfif>
					<cfif c EQ q_getform.tablecolumns AND (rowcontains EQ 1 OR rowstarted EQ 1)></tr>
						<cfset rowstarted=0>
						<cfset rowcontains=0>
					</cfif>
			</cfloop>
		</cfloop>
		
	</table>
<!--- display hidden form fields not tied to a grid position --->
<cfloop from="1" to="#arrayLen(a_formelements)#" index="x">
	<cfif structFind(a_formelements[x],"inputtype") eq "hidden">
		<cfif len(evaluate('form.#a_formelements[x].fieldname#'))>
			<input type="hidden" name="#a_formelements[x].fieldname#" id="#a_formelements[x].fieldname#" value="#evaluate('form.#a_formelements[x].fieldname#')#">
		<cfelse>
			<input type="hidden" name="#a_formelements[x].fieldname#" id="#a_formelements[x].fieldname#" value="#a_formelements[x].defaultvalue#">
		</cfif>
	</cfif>
</cfloop>
		<input type="hidden" name="formobjectid" id="formobjectid" value="#q_getForm.formobjectid#">
		<cfif isDefined("instanceid") AND instanceID NEQ 0>
			<input type="hidden" name="instanceid" id="instanceid" value="#trim(instanceid)#">
		</cfif>		
</cfoutput>
</cfif>