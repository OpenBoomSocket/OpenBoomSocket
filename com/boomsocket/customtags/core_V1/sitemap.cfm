<!--- columns determined by max items are to be displayed per col, max cols---------------------------------------------->
<cfif thisTag.executionMode EQ "start">
	<cfparam name="attributes.clearFloats" default="1">
	<cfparam name="attributes.allTBpages" default="">
	<cfparam name="attributes.contentwidth" default="500">
	<cfparam name="attributes.sectionorderby" default="sitesectionname">
	<cfparam name="attributes.pageorderby" default="pagetitle">
	<!--- create sitemap object --->
	<cfscript>
		sitemap = CreateObject('component', '#APPLICATION.CFCPath#.sitemap');
		SectionPaths = sitemap.getAllSectionPaths(orderby=attributes.sectionorderby);	
	</cfscript>
	<!--- if application.sitemapIgnoreList exists, use this instead --->
	<cfif isDefined('application.sitemapIgnoreList')>
		<cfset hidePages = application.sitemapIgnoreList>
	<cfelse>	
		<!--- need to use ids instead in case pagenames duped in mult sections, ids from installer
		<cfset hidePages = "prototypePrint.cfm,error404.cfm,CSSMockup.cfm,friendlyDownload.cfm,printable.cfm"> --->
		<cfset hidePages = "100007,100006,100008">
	</cfif>	
	
	<!--- create a list holding all pageids that have tool-based info (position in list = position in allTBpages array)--->
	<cfset allTBpageids = "">
	<cfif isArray(attributes.allTBpages)>
		<cfloop from="1" to="#ArrayLen(attributes.allTBpages)#" index="i">
			<cfset allTBpageids = ListAppend(allTBpageids,attributes.allTBpages[i].pageid)>
		</cfloop>
	</cfif>
	
	<!--- populate ArrTopSections to hold info about each top level section --------------------------->
	<cfset totalnumitems = 0>
	<cfset numTopLevelSections = 0>
	<cfset ArrTopSections = ArrayNew(1)>
	
	<cfloop list="#SectionPaths#" index="i">
		<cfset thisSectionPath="#listFirst(i,":")#">
		<cfset thisSectionId="#listLast(i,":")#">
		<cfset isTopLevelSection = 0>
		<cfif #ListLen(thisSectionPath, "\")# LTE 1><cfset isTopLevelSection = 1></cfif>
		<cfif isTopLevelSection>
			<cfset numTopLevelSections = numTopLevelSections+1>
			<cfset "TopLevelSection#thisSectionId#" = StructNew()>
			<cfset "TopLevelSection#thisSectionId#.sectionid" = thisSectionId>
			<cfset "TopLevelSection#thisSectionId#.numItems" = 1><!--- this includes the section itself--->
			<cfset "TopLevelSection#thisSectionId#.isNewColumn" = 0>
			<cfset totalnumitems = totalnumitems + 1>
			
			<!--- loop thru all pages in this section --->
			<cfset pages = sitemap.getPages(sectionid=#thisSectionId#,orderby=attributes.pageorderby)>
			<cfset numPages = 0>
			<cfset numTBpages = 0>
			<cfloop query="pages">
				<cfif NOT ListFindNoCase(hidePages,pages.pageid)>
					<cfset numPages = numPages + 1>		
					<!--- if tool based page, add to num items in this section --->
					<cfset tbArrayPosition =  listfind(allTBpageids,#pages.pageid#)>
					<cfif tbArrayPosition>
						<cfset ToolBasedItems = sitemap.getToolBasedItems(dbtable=attributes.allTBpages[tbArrayPosition].dbtable,fields=attributes.allTBpages[tbArrayPosition].fields,where=attributes.allTBpages[tbArrayPosition].where,orderby=attributes.allTBpages[tbArrayPosition].orderby,hasworkflow=attributes.allTBpages[tbArrayPosition].hasworkflow)>
						<cfloop query="ToolBasedItems">
							<cfset numTBpages = numTBpages + 1>
						</cfloop>
					</cfif>
				</cfif>
			</cfloop>
			<cfset "TopLevelSection#thisSectionId#.numItems" = evaluate("TopLevelSection"&thisSectionId&".numItems") + numPages + numTBpages>
			<cfset totalnumitems = totalnumitems + numPages + numTBpages>
			
			<cfset addtoarray = ArrayAppend(ArrTopSections, evaluate("TopLevelSection"&thisSectionId))>
			<cfset CurrArrayPosition = ArrayLen(ArrTopSections)>
		<cfelse><!--- subsection of previous top level section so add these items to previous--->
			<!--- increment num items by 1 to include this subsection--->
			<cfset ArrTopSections[#CurrArrayPosition#].numItems = ArrTopSections[#CurrArrayPosition#].numItems + 1>
			<cfset totalnumitems = totalnumitems + 1>
			<!--- loop thru all pages in this section --->
			<cfset pages = sitemap.getPages(sectionid=#thisSectionId#,orderby=attributes.pageorderby)>
			<cfset numPages = 0>
			<cfset numTBpages = 0>
			<cfloop query="pages">
				<cfif NOT ListFindNoCase(hidePages,pages.pageid)>
					<cfset numPages = numPages + 1>
					<!--- it tool based page, add to num items in this section --->
					<cfset tbArrayPosition =  listfind(allTBpageids,#pages.pageid#)>
					<cfif tbArrayPosition>
						<cfset ToolBasedItems = sitemap.getToolBasedItems(dbtable=attributes.allTBpages[tbArrayPosition].dbtable,fields=attributes.allTBpages[tbArrayPosition].fields,where=attributes.allTBpages[tbArrayPosition].where,orderby=attributes.allTBpages[tbArrayPosition].orderby,hasworkflow=attributes.allTBpages[tbArrayPosition].hasworkflow)>
						<cfloop query="ToolBasedItems">
							<cfset numTBpages = numTBpages + 1>
						</cfloop>
					</cfif>
				</cfif>
			</cfloop>
			<cfset ArrTopSections[#CurrArrayPosition#].numItems = ArrTopSections[#CurrArrayPosition#].numItems + numPages + numTBpages>
			<cfset totalnumitems = totalnumitems + numPages + numTBpages>
		</cfif>
	</cfloop>
	
	<cfif ArrayLen(ArrTopSections)>		
		<!--- numItemsColumn may change in order to keep at max cols defined-------------------------------->
		<cfset numColumns = 1>
		<!--- if specified num Columns, match what they specified --->
		<cfif isDefined('attributes.numCols')>
			<cfset numColumns = attributes.numCols>
			<cfset attributes.numItemsColumn = Round(totalnumitems/attributes.numCols)>
		<!--- otherwise if specified num Items per column, determin numColumns --->
		<cfelseif isDefined('attributes.numItemsColumn')>
			<cfif totalnumitems gt attributes.numItemsColumn>			
				<cfset numColumns = Round(totalnumitems/attributes.numItemsColumn)>
			</cfif>			
		<cfelse><!--- Didn't specify num Items per Column or Num Columns: Default num Cols = 2 --->
			<cfset numColumns = 2>
			<cfset attributes.numItemsColumn = Round(totalnumitems/2)>
		</cfif>
		
		<!--- determine which top level sections will start a new column --------------------------------->
		<cfset numItemsThisCol=0>
		<cfset numActualColumns = 0>
		<cfloop from="1" to="#ArrayLen(ArrTopSections)#" index="i">
			<cfset numItemsThisCol = numItemsThisCol + ArrTopSections[i].numItems>			
			<cfif i eq 1 OR numItemsThisCol gt attributes.numItemsColumn>
				<!--- CMC MOD 7/17/06: if 1st Section has enough items for 1 col, set second section as new col --->
				<cfif i eq 1 AND numItemsThisCol gt attributes.numItemsColumn AND ArrayLen(ArrTopSections) gt 1>
					<cfset ArrTopSections[i+1].isNewColumn = 1>
				</cfif>				
				<cfset ArrTopSections[i].isNewColumn = 1>
				<cfset numItemsThisCol=ArrTopSections[i].numItems>
				<cfset numActualColumns = numActualColumns + 1>
				<!--- reset numItemsThisCol for next column --->
				<cfset numItemsThisCol=0>				
			</cfif>	
		</cfloop>
		<cfset smColWidth = Int(attributes.contentWidth/numActualColumns)>
		
		<!--- output sitemap --->	
		<cfoutput>
		<cfset CurrentTopSection = 0>
		<cfset loopcount = 1>
		<cfloop list="#SectionPaths#" index="i">
			<cfset thisSectionPath="#listFirst(i,":")#">
			<cfset thisSectionLabel="#listGetAt(i,2,":")#">
			<cfset thisSectionId="#listLast(i,":")#">
			<cfset isTopLevelSection = 0>
			<cfif #ListLen(thisSectionPath, "\")# LTE 1><cfset isTopLevelSection = 1></cfif>
			<cfif isTopLevelSection eq 1><cfset CurrentTopSection = CurrentTopSection+1></cfif>
			
			<cfif ArrTopSections[CurrentTopSection].isNewColumn AND thisSectionId eq ArrTopSections[CurrentTopSection].sectionid>
				<cfif loopcount gt 1></ul></div></cfif><div class="sitemapCol" style="float:left;padding:10px;width:#smColWidth#px;"><ul>
			</cfif> 
				<cfif #ListLen(thisSectionPath, "\")# GT 1><ul class="sitemapSubSection"></cfif><!--- subsection level --->				
					<li type="disc" <cfif #ListLen(thisSectionPath, "\")# GT 2>style="margin-left:#(ListLen(thisSectionPath, "\")-2) * 10#px;"</cfif><cfif #ListLen(thisSectionPath, "\")# GT 1>class="sitemapSubSection"<cfelse>class="sitemapSection"</cfif>>#thisSectionLabel#</li>				
				<!--- page level --->
				<cfset pages = sitemap.getPages(sectionid=#thisSectionId#,orderby=attributes.pageorderby)>
				<cfif pages.recordcount>
					<ul>
					<cfloop query="pages">
						<cfif NOT ListFindNoCase(hidePages,pages.pageid)>
							<li class="sitemapPage" type="circle"><a href="/#ReplaceNoCase(thisSectionPath,'\','/','all')#/#pages.pagename#"><cfif Len(pages.pagetitle)>#pages.pagetitle#<cfelse>#pages.pagename#</cfif></a></li>
							<!--- if this page is tool based, get sublinks --->
							<cfset tbArrayPosition =  listfind(allTBpageids,#pages.pageid#)>
							<cfif tbArrayPosition>
								<!--- get all tool based items & output --->
								<cfset ToolBasedItems = sitemap.getToolBasedItems(dbtable=attributes.allTBpages[tbArrayPosition].dbtable,fields=attributes.allTBpages[tbArrayPosition].fields,where=attributes.allTBpages[tbArrayPosition].where,orderby=attributes.allTBpages[tbArrayPosition].orderby,hasworkflow=attributes.allTBpages[tbArrayPosition].hasworkflow)>
								<cfif ToolBasedItems.recordcount>
									<ul>
										<cfloop query="ToolBasedItems">
											<!--- reformat link so variables will be read --->
											<cfset linklabel = evaluate("ToolBasedItems." & attributes.allTBpages[tbArrayPosition].linklabel)>
											<cfset linkqs = "">
											<cfloop list="#attributes.allTBpages[tbArrayPosition].linkqs#" delimiters="&" index="i">
												<cfset thisAttribute = ListFirst(i,"=")>
												<cfset thisValue = ListLast(i,"=")>										
												<cfset linkqs = linkqs & thisAttribute & "=">
												<cfif Left(thisValue,1) eq "[">
													<cfset linkqs = linkqs & evaluate("ToolBasedItems." & ReplaceNoCase(thisValue,"[","","all")) & "&">
												<cfelse>
													<cfset linkqs = linkqs & thisValue & "&">
												</cfif>
											</cfloop>
											<cfset linkpage = "">
											<cfloop list="#attributes.allTBpages[tbArrayPosition].linkpage#" delimiters="/" index="i">																						
												<cfif Left(i,1) eq "[">
													<cfset linkpage = linkpage & evaluate("ToolBasedItems." & ReplaceNoCase(i,"[","","all"))>
												<cfelse>
													<cfset linkpage = linkpage & i & "/">
												</cfif>
											</cfloop>
											<cfif Left(attributes.allTBpages[tbArrayPosition].linkpage,1) eq '/'>
												<cfset linkpage = '/' & linkpage>
											</cfif>
											<cfif Right(attributes.allTBpages[tbArrayPosition].linkpage,1) eq '/'>
												<cfset linkpage = linkpage & '/'>
											</cfif>
											<cfif Len(linkqs)>
												<cfset linkpage = linkpage & '&' & linkqs>
											</cfif>
											<li><a href="#linkpage#">#linklabel#</a></li>
											
										</cfloop>
									</ul>
								</cfif>
							</cfif>
						</cfif>
					</cfloop>
					</ul>
				</cfif>
				<cfif #ListLen(thisSectionPath, "\")# GT 1></ul></cfif>	
			<cfset loopcount = loopcount+1>
		</cfloop></div>
		<cfif attributes.clearFloats>
			<div style="clear:both;"></div>
		</cfif>
		</cfoutput>
	</cfif>
</cfif>