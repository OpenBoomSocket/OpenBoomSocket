<cfcomponent displayname='reviewQueue' hint='Manages review queue information' >
<!--- SELECT --->	
	<!--- Condensed View get all content elements under review --->
	<cffunction name="getDirectiveElements" access="public" returntype="query" hint="get all content elements w/ a directive">
	<cfset var q_getDirectiveElements = "">
	<cfset var byPerson = "(version.supervisorid = #session.user.id# OR version.ownerid = #session.user.id#)">
		<cftry>
			<cfquery name="q_getDirectiveElements" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT version.versionid, version.version, version.label, version.supervisorid, version.datemodified, version.datecreated, version.formobjectitemid, version.instanceitemid, version.parentid, version.ownerid, VersionStatus.versionstatusid, VersionStatus.status AS VersionStatus, VersionStatus.colorcode, formobject.label AS FormObjectLabel, UsersOwners.lastName AS ownerLastName, UsersOwners.firstName AS ownerFirstName, UsersOwners.initials AS ownerInitials, UsersSupervisors.lastName AS supervisorLastName, UsersSupervisors.firstName AS supervisorFirstName, UsersSupervisors.initials AS supervisorInitials, UsersCreators.firstName as creatorFirstName, UsersCreators.lastName as creatorLastName, UsersCreators.initials as creatorInitials, versiondirective.versiondirectivename, versiondirective.versiondirectiveid
				FROM version INNER JOIN
					versiondirective ON versiondirective.versiondirectiveid = version.versiondirectiveid INNER JOIN
					VersionStatus ON version.versionStatusID = VersionStatus.versionstatusid INNER JOIN
					Users UsersOwners ON UsersOwners.Usersid = version.ownerid INNER JOIN
					Users UsersSupervisors ON UsersSupervisors.Usersid = version.supervisorid INNER JOIN
					Users UsersCreators ON UsersCreators.usersid = version.creatorid INNER JOIN
					formobject ON formobject.formobjectid = version.formobjectitemid
				WHERE (version.archive <> 1 OR version.archive IS NULL)
					AND version.versiondirectiveid <> '' 
					AND version.versiondirectiveid IS NOT NULL
					AND (#byPerson#)
				ORDER BY version.versiondirectiveid, formobjectitemid
			</cfquery>
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn q_getDirectiveElements>
	</cffunction>
	<!--- Get Directives --->
	<cffunction name="getDirectives" access="public" returntype="query" hint="get all content elements ">
		<cfargument name="versionstatusid" type="numeric" required="no">
		<cfargument name="isDefault" type="boolean" required="no">
		<cfset var q_getDirectives = "">
		<cftry>
			<cfquery name="q_getDirectives" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT versiondirectiveid, versiondirectivename
				FROM versiondirective
				WHERE 1 = 1
				<cfif isDefined('arguments.versionstatusid') AND isNumeric(arguments.versionstatusid)>
					AND versionstatusid = #arguments.versionstatusid#
				</cfif>
				<cfif isDefined('arguments.isDefault')>
					AND isDefault = <cfif arguments.isDefault>1<cfelse>0</cfif>
				</cfif>
			</cfquery>
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn q_getDirectives>		
	</cffunction>
	<!--- Get Recently Modified --->
	<cffunction name="getRecentElements" access="public" returntype="query" hint="get top 5 last modified items">
		<cfargument name="directiveVersions" type="string" required="no">
		<cfset var q_getRecentElements = "">
		<cftry>
			<cfquery name="q_getRecentElements" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT TOP 5 version.versionid, version.version, version.parentid, version.label, version.datemodified, version.instanceitemid, formobject.formobjectid, formobject.label AS FormObjectLabel, UsersOwners.initials AS ownerInitials, VersionStatus.status, VersionStatus.colorcode
				FROM version INNER JOIN
					VersionStatus ON version.versionStatusID = VersionStatus.versionstatusid INNER JOIN
					formobject ON formobject.formobjectid = version.formobjectitemid INNER JOIN
					Users UsersOwners ON UsersOwners.Usersid = version.ownerid
				WHERE (version.archive <> 1 OR version.archive IS NULL)
				<cfif isDefined('arguments.directiveVersions') AND LEN(TRIM(arguments.directiveVersions))>
					AND versionid NOT IN(#arguments.directiveVersions#)
				</cfif>
				ORDER BY version.datemodified desc
			</cfquery>
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn q_getRecentElements>	
	</cffunction>
	
	<!--- Condensed View get all content elements under review --->
	<cffunction name="getCondensedElements" access="public" returntype="query" hint="get all content elements">
		<cfargument name="instanceid" type="string" required="yes">
		<cfargument name="viewall" type="string" required="yes">
		<cfargument name="sortBy" type="string" required="yes">
		<cfargument name="statusFilter" type="string" required="no">
		<cfargument name="viewByStatus" type="boolean" required="yes">		
		<cfset var byObject = "">
		<cfset var byPerson = "">
		<cfset var varSortBy = "">
		<cfset var q_VersionSets = "">
		
		<!---WHERE clauses--->
		<cfset byObject = "(version.archive IS NULL OR version.archive = 0)">
			<cfif isDefined("arguments.instanceid") AND Len(arguments.instanceid)>
				<cfset byObject = "(version.archive IS NULL OR version.archive = 0) AND version.instanceitemid = #url.instanceid#">
			</cfif>
		<cfset byPerson = "(version.supervisorid = #session.user.id# OR version.ownerid = #session.user.id# OR version.creatorid = #session.user.id#)">
			<cfif isDefined("arguments.viewall") AND Len(arguments.viewall)>
				<cfset byPerson = "0=0">
			</cfif>
		
		<cftry>
			<cfquery name="q_VersionSets" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT     Distinct version.formobjectitemid, version.parentid
				FROM         version INNER JOIN
							  VersionStatus ON version.versionStatusID = VersionStatus.versionstatusid INNER JOIN
							  Users UsersOwners ON UsersOwners.Usersid = version.ownerid INNER JOIN
							  Users UsersSupervisors ON UsersSupervisors.Usersid = version.supervisorid INNER JOIN
							  Users UsersCreators ON UsersCreators.usersid = version.creatorid INNER JOIN
							  formobject ON formobject.formobjectid = version.formobjectitemid
				WHERE 	(#byObject#) AND (#byPerson#)		
				<cfif isDefined('arguments.statusFilter') AND Len(arguments.statusFilter)> AND (VersionStatus.VersionStatusId = #arguments.statusFilter#)</cfif>
				AND version.versionstatusid <> 100002
				ORDER BY formobjectitemid
		</cfquery>
	<cfcatch type="database">
		<cfrethrow>
	</cfcatch>
	</cftry>
	<cfreturn q_VersionSets>
	</cffunction>
	
	<!--- Version Inventory: get all content elements under review --->
	<cffunction name="getAllContentElements" access="public" returntype="query" hint="get all content elements">
		<cfargument name="instanceid" type="string" required="yes">
		<cfargument name="viewall" type="string" required="yes">
		<cfargument name="sortBy" type="string" required="yes">
		<cfargument name="statusFilter" type="string" required="no">
		<cfargument name="viewByStatus" type="boolean" required="yes">		
		<cfset var byObject = "">
		<cfset var byPerson = "">
		<cfset var varSortBy = "">
		<cfset var q_reviewQueue = "">
		
		<!---WHERE clauses--->
		<cfset byObject = "(version.archive IS NULL OR version.archive = 0)">
			<cfif isDefined("arguments.instanceid") AND Len(arguments.instanceid)>
				<cfset byObject = "(version.archive IS NULL OR version.archive = 0) AND version.instanceitemid = #url.instanceid#">
			</cfif>
		<cfset byPerson = "(version.supervisorid = #session.user.id# OR version.ownerid = #session.user.id# OR version.creatorid = #session.user.id#)">
			<cfif isDefined("arguments.viewall") AND Len(arguments.viewall)>
				<cfset byPerson = "0=0">
			</cfif>
			
		<!---ORDER BY clauses--->
		<!---Look to see if a sort function has been selected--->
		<cfif isDefined('arguments.sortBy') AND Len(arguments.sortBy)>
			<cfif arguments.sortBy EQ "labelasc">
				<cfset varSortBy = "formobject.label, version.label ASC">
			</cfif>
			<cfif arguments.sortBy EQ "labeldesc">
				<cfset varSortBy = "formobject.label, version.label DESC">
			</cfif>
			<cfif arguments.sortBy EQ "datecreatedasc">
				<cfset varSortBy = "formobject.label, version.datecreated ASC">
			</cfif>
			<cfif arguments.sortBy EQ "datecreateddesc">
				<cfset varSortBy = "formobject.label, version.datecreated DESC">
			</cfif>
			<cfif arguments.sortBy EQ "datemodifiedasc">
				<cfset varSortBy = "formobject.label, version.datemodified ASC">
			</cfif>
			<cfif arguments.sortBy EQ "datemodifieddesc">
				<cfset varSortBy = "formobject.label, version.datemodified DESC">
			</cfif>
			<cfif arguments.sortBy EQ "supervisorInitialsasc">
				<cfset varSortBy = "formobject.label, UsersSupervisors.initials ASC">
			</cfif>
			<cfif arguments.sortBy EQ "supervisorInitialsdesc">
				<cfset varSortBy = "formobject.label, UsersSupervisors.initials DESC">
			</cfif>
			<cfif arguments.sortBy EQ "ownerInitialsasc">
				<cfset varSortBy = "formobject.label, UsersOwners.initials ASC">
			</cfif>
			<cfif arguments.sortBy EQ "ownerInitialsdesc">
				<cfset varSortBy = "formobject.label, UsersOwners.initials DESC">
			</cfif>
			<cfif arguments.sortBy EQ "creatorInitialsasc">
				<cfset varSortBy = "formobject.label, UsersCreators.initials ASC">
			</cfif>
			<cfif arguments.sortBy EQ "creatorInitialsdesc">
				<cfset varSortBy = "formobject.label, UsersCreators.initials DESC">
			</cfif>
			<cfif arguments.sortBy EQ "versionasc">
				<cfset varSortBy = "formobject.label, version.version ASC">
			</cfif>
			<cfif arguments.sortBy EQ "versiondesc">
				<cfset varSortBy = "formobject.label, version.version DESC">
			</cfif>
			<cfif arguments.sortBy EQ "statusasc">
				<cfset varSortBy = "formobject.label, version.versionStatus ASC">
			</cfif>
			<cfif arguments.sortBy EQ "statusdesc">
				<cfset varSortBy = "formobject.label, version.versionStatus DESC">
			</cfif>
		<cfelse>
			<cfset varSortBy = "formobject.label, VersionStatus.status, version.datemodified DESC">
		</cfif>
		
		<cftry>
			<cfquery name="q_reviewQueue" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT     version.*, VersionStatus.status AS VersionStatus, VersionStatus.colorcode, formobject.label AS FormObjectLabel, 
							UsersOwners.lastName AS ownerLastName, UsersOwners.firstName AS ownerFirstName, UsersOwners.initials AS ownerInitials,
							UsersSupervisors.lastName AS supervisorLastName, UsersSupervisors.firstName AS supervisorFirstName, UsersSupervisors.initials AS supervisorInitials,
							UsersCreators.firstName as creatorFirstName, UsersCreators.lastName as creatorLastName, UsersCreators.initials as creatorInitials
				FROM         version INNER JOIN
							  VersionStatus ON version.versionStatusID = VersionStatus.versionstatusid INNER JOIN
							  Users UsersOwners ON UsersOwners.Usersid = version.ownerid INNER JOIN
							  Users UsersSupervisors ON UsersSupervisors.Usersid = version.supervisorid INNER JOIN
							  Users UsersCreators ON UsersCreators.usersid = version.creatorid INNER JOIN
							  formobject ON formobject.formobjectid = version.formobjectitemid
				WHERE 	(#byObject#) AND (#byPerson#)		
				<cfif isDefined('arguments.statusFilter') AND Len(arguments.statusFilter)> AND (VersionStatus.VersionStatusId = #arguments.statusFilter#)</cfif>
				<!--- only pull one instance of each item for condensed view --->	
				<cfif arguments.ViewByStatus eq false>
					AND (version.parentid = version.instanceitemid)
				</cfif>
				ORDER BY #varSortBy#
		</cfquery>
	<cfcatch type="database">
		<cfrethrow>
	</cfcatch>
	</cftry>
	<cfreturn q_reviewQueue>
	</cffunction>
	
	<!--- get all versions of one element--->
	<cffunction name="getVersions" access="public" returntype="query" hint="get all content elements">
		<cfargument name="parentid" type="numeric" required="yes">
		<cfargument name="formobjectitemid" type="numeric" required="yes">
		<cfargument name="getPublished" type="boolean" required="no">
		<cfset var q_Versions = "">
		
		<cftry>
			<cfquery name="q_Versions" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT     version.*, VersionStatus.status AS VersionStatus, VersionStatus.colorcode, 
					formobject.label AS FormObjectLabel, UsersOwners.lastName AS ownerLastName, UsersOwners.firstName AS ownerFirstName, 
					UsersOwners.initials AS ownerInitials, UsersSupervisors.lastName AS supervisorLastName, 
					UsersSupervisors.firstName AS supervisorFirstName, UsersSupervisors.initials AS supervisorInitials, 
					UsersCreators.firstName as creatorFirstName, UsersCreators.lastName as creatorLastName, 
					UsersCreators.initials as creatorInitials
				FROM         version INNER JOIN
							  VersionStatus ON version.versionStatusID = VersionStatus.versionstatusid INNER JOIN
							  Users UsersOwners ON UsersOwners.Usersid = version.ownerid INNER JOIN
							  Users UsersSupervisors ON UsersSupervisors.Usersid = version.supervisorid INNER JOIN
							  Users UsersCreators ON UsersCreators.usersid = version.creatorid INNER JOIN
							  formobject ON formobject.formobjectid = version.formobjectitemid
				WHERE 	(version.archive IS NULL OR version.archive = 0) AND version.parentid = #arguments.parentid# AND version.formobjectitemid = #arguments.formobjectitemid#	
				<cfif isDefined("arguments.getPublished") AND NOT arguments.getPublished>
					AND version.versionstatusid <> 100002
				</cfif>
				ORDER BY version ASC
			</cfquery>
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
		</cftry>		
		<cfreturn q_Versions>
	</cffunction>
	
	<!--- get all version status --->
	<cffunction name="getAllStatus" access="public" returntype="query" hint="get all version status levels">
	<cfset var q_Status = "">
		<cftry>
			<cfquery name="q_Status" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT * FROM versionstatus
				ORDER BY ordinal ASC
			</cfquery>
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
		</cftry>	
	<cfreturn q_Status>
	</cffunction>
	
	<!--- get formobjectlabel --->
	<cffunction name="getFormObjectLabel" access="public" returntype="string" hint="get formobject label">
	<cfargument name="formobjectid" required="yes">
	<cfset var returnthis = "">
		<cftry>
			<cfquery name="q_FormObject" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT label FROM formobject
				Where formobjectid = #arguments.formobjectid#
			</cfquery>
			<cfset returnthis = q_FormObject.label>
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
		</cftry>
	<cfreturn returnthis>
	</cffunction>
	
	<!--- get all possible owners for specific item (must have permissions for the formobject)--->
	<cffunction name="q_getUsers" access="public" returntype="query" hint="get list of possible owners for a content element">	
	<cfargument name="formobjectid" required="yes">
	<cfargument name="versionsupid" required="yes">
		<cfset var q_userNames = "">	
		
		<cftry>
			<!--- pull users that are either: users w/ formobject add/edit or the instance supervisor --->
			<cfquery datasource="#application.datasource#" name="q_userNames" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT DISTINCT users.initials,users.usersid
				FROM Users INNER JOIN userpermission ON Users.Usersid = userpermission.userid
				WHERE (userpermission.formobjectid = #arguments.formobjectid# AND userpermission.addedit = 1)
				OR users.usersid = #arguments.versionsupid#
			</cfquery>
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
		</cftry>			
		<cfreturn q_userNames>
	</cffunction>
	
	<!--- get review queue formobjectid --->
	<cffunction name="getRQformobjectid" access="public" returntype="query" hint="get all version status levels">
		<cfset var q_RQformobjectid = "">
		
		<cftry>
			<cfquery name="q_RQformobjectid" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT formobjectid FROM formobject
				Where formobjectname = 'Review Queue'
				ORDER BY ordinal ASC
			</cfquery>
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
		</cftry>
	<cfreturn q_RQformobjectid>
	</cffunction>
	
	<cffunction name="getPreview" access="public" returntype="string" hint="get version preview">
	<cfargument name="versionid" type="numeric" required="yes">
	<cfargument name="formobjectid" type="numeric" required="yes">
		<cfset var dontShow = "hidden,submit,button,reset,formatonly,cancel,image,custominclude,useMappedContent">
		<cfset var q_getForm = "">
		<cfset var q_getDatatable = "">
		<cfset var SpecInstanceID = 0>
		<cfset var q_getPreview = "">
		<cfset var versionInfo = "">
		<cfset var returnthis = "">
	
		<cftry>
			<cfquery datasource="#application.datasource#" name="q_getForm" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT  datadefinition, tabledefinition
				FROM   formobject INNER JOIN formEnvironment ON formobject.formEnvironmentID = formEnvironment.formEnvironmentID
				WHERE  (formobject.formobjectid = #arguments.formobjectid#)
			</cfquery>
			<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="XML2CFML"
				input="#q_getform.datadefinition#"
				output="a_formelements">
			<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="XML2CFML"
				input="#q_getform.tabledefinition#"
				output="a_tableelements">
			
			<cfquery name="q_getDatatable" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT datatable
				FROM formobject
					Inner Join Version on version.formobjectitemid = formobject.formobjectid
				Where version.versionid = #arguments.versionid#
			</cfquery>
			<cfset SpecInstanceID="#q_getDatatable.datatable#id">
			
			<!--- pull content for preview --->
			<cfquery name="q_getPreview" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT *
				FROM #q_getDatatable.datatable#
				Where #SpecInstanceID# = (SELECT instanceitemid FROM version where versionid = #arguments.versionid#)
			</cfquery>
		
			<cfsavecontent variable="versionInfo">
				<cfoutput>
					<table width="100%" cellspacing="0" cellpadding="3" border="1">
						<cfloop index="x" from="1" to="#arrayLen(a_formelements)#">
							<cfif NOT listFindNoCase(dontShow,a_formelements[x].inputtype)>
							<tr <cfif x MOD 2>bgcolor="##F4F4F4"<cfelse>bgcolor="##EBEBEB"</cfif>>
								<td width="20%" valign="top" nowrap><strong>#a_formelements[x].objectlabel#</strong> </td>
								<td width="80%" valign="top"><cfif findNoCase("~",evaluate('q_getPreview.#a_formelements[x].fieldname#'))><cfloop list="#evaluate('q_getPreview.#a_formelements[x].fieldname#')#" index="thisItem">#listLast(thisItem,"~")#<br /></cfloop><cfelse><cfif a_formelements[x].inputtype EQ "password"><cfloop from="1" to="#Len(listLast(evaluate('q_getPreview.#a_formelements[x].fieldname#'),'~'))#" index="p">*</cfloop><cfelse>#listLast(evaluate("q_getPreview.#a_formelements[x].fieldname#"),"~")#</cfif></cfif>&nbsp;</td>
							</tr>
							</cfif>
						</cfloop>
					</table>
				</cfoutput>
			</cfsavecontent>
			<cfset returnthis = versionInfo>
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
		</cftry>	
		<cfreturn returnthis>
	</cffunction>

<!--- UPDATE --->

	<!--- update status --->
	<cffunction name="updateElementStatus" access="public" returntype="numeric" hint="update content element status">
		<cfargument name="versionstatusid" type="numeric" required="yes">
		<cfargument name="versionid" type="numeric" required="yes">
		<cfargument name="formobjectitemid" type="numeric" required="yes">	
		<cfargument name="parentid" type="numeric" required="yes">
		<cfset var returnthis = arguments.versionid>	
		<cfset var q_updateStuff = "">
		<cfset var q_updateLiveVersion = "">
		
		<cftry>
			<cfquery datasource="#application.datasource#" name="q_updateStuff" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				UPDATE version
				SET versionstatusid = #arguments.versionstatusid#,
					DateModified = #CreateODBCDateTime(Now())#
					<cfif isDefined('arguments.versiondirectiveid') AND isNumeric(arguments.versiondirectiveid)>
						,versiondirectiveid = <cfif arguments.versiondirectiveid neq 0>#arguments.versiondirectiveid#<cfelse>NULL</cfif>
					</cfif>
				WHERE versionid = #arguments.versionid#
			</cfquery>
			<!--- if setting this to "published" --->
			<cfif arguments.versionstatusid eq 100002>
				<!--- Set current live instance to be approved only --->
				<cfquery datasource="#application.datasource#" name="q_updateStuff" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					UPDATE version
					SET versionstatusid = 100001,
						DateModified = #CreateODBCDateTime(Now())#
					WHERE formobjectitemid = #arguments.formobjectitemid# AND parentid = #arguments.parentid# AND versionStatusID = 100002 AND versionid <> #arguments.versionid#
				</cfquery>
				<!--- update pagecomponent assignment to new live version --->
				<cfquery name="q_updateLiveVersion" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					UPDATE pagecomponent SET contentObjectId = (SELECT instanceItemId FROM version WHERE versionid = #arguments.versionid#) WHERE contentObjectId IN (SELECT instanceItemId FROM version WHERE formobjectitemid = #arguments.formobjectitemid# AND parentid = #arguments.parentid#)
				</cfquery>
				<!--- don't want review q dashboard/condensed dropdown to retain this row since doesn't display published items --->
				<cfset returnthis = 0>
			</cfif>	
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
		</cftry>
		<cfreturn returnthis>	
	</cffunction>
	
	<!--- update owner --->
	<cffunction name="updateElementOwner" access="public" returntype="numeric" hint="update content element owner">
		<cfargument name="formobject" type="numeric" required="yes">
		<cfargument name="ownerid" type="numeric" required="yes">	
		<cfargument name="versionid" type="numeric" required="yes">
		<cfset var returnthis = arguments.versionid>
		<cfset var q_getSupa = "">
		<cfset var q_updateStuff = "">
		
		<cftry>
			<cfquery datasource="#application.datasource#" name="q_getSupa" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT supervisorid
				FROM supervisorRelationship
				WHERE formobject=#arguments.formobject# AND userid = #arguments.ownerid#
			</cfquery>
			<cfif NOT q_getSupa.recordcount>
				<cfquery name="q_getSupa" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT supervisorid
					FROM sitesettings
				</cfquery>
			</cfif>
			<cfquery datasource="#application.datasource#" name="q_updateStuff" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				UPDATE version
				SET ownerid = #arguments.ownerid#, 
					supervisorid = #q_getSupa.supervisorid#,
					DateModified = #CreateODBCDateTime(Now())#
				WHERE versionid = #arguments.versionid#
			</cfquery>
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
		</cftry>	
		<cfreturn returnthis>		
	</cffunction>

<!--- DELETE & ReOrder--->
	
<!--- delete version --->
	<cffunction name="delVersions" access="public" returntype="boolean" hint="delete versions">
		<cfargument name="versionids" type="string" required="no">
		<cfargument name="baseStruct" type="struct" required="no">
		<cfset var returnthis=0>
		<cfset var counter="">
		<cfset var q_deleteVersions="">
		<cfset var CleanIDs="">
		
		<cfif NOT isDefined('arguments.versionids') AND NOT isDefined('arguments.baseStruct')>
			<cfthrow type="exception" message="No version id supplied." detail="You must supply either a version structure or a list of version ids.">
		</cfif>
		
		<cftry>
			<cfif isDefined('arguments.versionids') AND Len(arguments.versionids)>
				<cfloop list="#arguments.versionids#" index="counter">
					<cfif isNumeric(counter) AND counter>
						<cfset CleanIDs = ListAppend(CleanIDs,counter)>
					</cfif>
					<cfquery name="q_deleteVersions" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						UPDATE version
						SET archive = 1,
							DateModified = #CreateODBCDateTime(Now())#
						WHERE versionid IN (#CleanIDs#)
					</cfquery>
				</cfloop>
				<cfset returnthis = ListLen(CleanIDs)>
			<cfelse>
				<cfquery name="q_deleteVersions" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					UPDATE version
					SET archive = 1,
						DateModified = #CreateODBCDateTime(Now())#
					WHERE versionid < #arguments.basestruct.versionid#
						AND parentid = #arguments.basestruct.parentid#
						AND formobjectitemid = #arguments.basestruct.formobjectitemid#
				</cfquery>
				<cfset returnthis = 1>
			</cfif>				
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
		</cftry>	
		<cfreturn returnthis>
	</cffunction>
	
<!--- Reorder Versions --->
	<cffunction name="reOrderVersions" access="public" returntype="boolean" hint="delete versions">
		<cfargument name="formobjectitemid" type="numeric" required="yes">
		<cfargument name="parentid" type="numeric" required="yes">
		<cfset var q_liveVersions = "">
		<cfset var q_PublishedVersion = "">
		<cfset var q_allVersions = "">
		<cfset var q_deleteVersions = "">
		<cfset var q_updatePageComponent = "">
		<cfset var returnthis=0>
		<cfset var newParentid=0>
		<cfset var newPageCompInstance=0>
		<cfset var InstanceItemIDList="">
		
		<cftry>
			<!--- grab all live versions, order by versionid--->
			<cfquery name="q_liveVersions" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT versionid,instanceitemid
				From Version
				WHERE parentid = #arguments.parentid#
				AND formobjectitemid = #arguments.formobjectitemid#
				AND (archive <> 1 OR archive IS NULL)
				ORDER BY versionid
			</cfquery>
			
			<!--- only reorder if still have live versions --->
			<cfif q_liveVersions.recordcount>
				<!--- new parentid will be the oldeset (first item in q_liveVersion) version's instanceitemid --->
				<cfset newParentid = q_liveVersions.instanceitemid>
				<cfset returnthis=newParentid>
				
				<!--- new pagecomponent.instanceid will be either published version or oldest non-archived version --->
				<cfquery name="q_PublishedVersion" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT instanceitemid
					From Version
					WHERE parentid = #arguments.parentid#
					AND formobjectitemid = #arguments.formobjectitemid#
					AND (archive <> 1 OR archive IS NULL)
					AND VersionStatusID = 100002
				</cfquery>
				<cfif q_PublishedVersion.recordcount gt 0>
					<cfset newPageCompInstance = q_PublishedVersion.instanceitemid>
				<cfelse>
					<cfset newPageCompInstance = q_liveVersions.instanceitemid>
				</cfif>
				
				<!--- grab all instanceids (live and archived) for page component update before we reorder --->
				<cfquery name="q_allVersions" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT versionid,instanceitemid
					From Version
					WHERE parentid = #arguments.parentid#
					AND formobjectitemid = #arguments.formobjectitemid#
					ORDER BY versionid
				</cfquery>
				<cfset InstanceItemIDList = ValueList(q_allVersions.instanceitemid)>
				
				<!--- loop thru and reorder/update live versions --->
				<cfloop query="q_liveVersions">
					<cfquery name="q_deleteVersions" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						UPDATE version
						SET version = #q_liveVersions.currentrow#,
							parentid = #newParentid#,
							DateModified = #CreateODBCDateTime(Now())#
						WHERE versionid = #q_liveVersions.versionid#
					</cfquery>
				</cfloop>
				
				<!--- update the pagecomponent to reflect new instance--->			
				<cfquery name="q_updatePageComponent" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					UPDATE pagecomponent SET contentObjectId = #newPageCompInstance# WHERE contentObjectId IN (#InstanceItemIDList#)
				</cfquery>
			</cfif>
			
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
		</cftry>
		<cfreturn returnthis>
	</cffunction>

	<cffunction access="public" name="insertVersion" output="false" returntype="boolean" displayname="insertVersion">
		<cfargument name="versionid" type="numeric" required="yes">
		<cfargument name="instanceitemid" type="numeric" required="yes">
		<cfargument name="label" type="string" required="yes">
		<cfargument name="formobjectitemid" type="numeric" required="yes">
		<cfargument name="ownerid" type="numeric" required="yes">
		<cfargument name="supervisorid" type="numeric" required="yes">
		<cfargument name="versionstatusid" type="numeric" required="yes">
		<cfargument name="parentid" type="numeric" required="yes">
		<cfargument name="creatorid" type="numeric" required="yes">
		<cfargument name="dateToPublish" type="string" required="no">
		<cfargument name="dateToExpire" type="string" required="no">
		<cfargument name="versiondirectiveid" type="string" required="no">
		<cfargument name="version" type="numeric" required="0" default="1">
		<cfset returnthis = true>
		<cftry>						
			<cfquery name="q_InsertVersion" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				INSERT INTO Version
				(versionid, instanceitemid, label, formobjectitemid, ownerid, supervisorid, version, versionstatusid, datecreated, datemodified, parentid, creatorid
				<cfif IsDefined('arguments.dateToPublish') AND len(Trim(arguments.dateToPublish)) AND arguments.dateToExpire NEQ 'NULL'>
					, dateToPublish
				</cfif>
				<cfif IsDefined('arguments.dateToExpire') AND len(Trim(arguments.dateToExpire)) AND arguments.dateToExpire NEQ 'NULL'>
					, dateToExpire
				</cfif> 
				<cfif isDefined("arguments.versiondirectiveid") AND isNumeric(Trim(arguments.versiondirectiveid))>
					,versiondirectiveid
				</cfif>)
				VALUES
				(#arguments.versionid#, #arguments.instanceitemid#, '#arguments.label#', #arguments.formobjectitemid#, #arguments.ownerid#, #arguments.supervisorid#, #arguments.version#, #arguments.versionstatusid#, #createODBCDateTime(now())#, #createODBCDateTime(now())#, #arguments.parentid#, #arguments.creatorid#
				<cfif IsDefined('arguments.dateToPublish') AND len(Trim(arguments.dateToPublish)) AND arguments.dateToExpire NEQ 'NULL'>
					, #arguments.dateToPublish#
				</cfif>
				<cfif IsDefined('arguments.dateToExpire') AND len(Trim(arguments.dateToExpire)) AND arguments.dateToExpire NEQ 'NULL'>
					, #arguments.dateToExpire#
				</cfif>
				<cfif isDefined("arguments.versiondirectiveid") AND isNumeric(Trim(arguments.versiondirectiveid))>
					, <cfif Trim(arguments.versiondirectiveid) neq 0>#Trim(arguments.versiondirectiveid)#<cfelse>NULL</cfif>
				</cfif>)
			</cfquery>
				<cfcatch type="database">
					<cfset returnthis = false>
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn returnthis>
	</cffunction>
	
	<cffunction access="public" name="UpdateVersion" output="false" returntype="boolean" displayname="UpdateVersion">
		<cfargument name="ownerid" type="numeric" required="no">
		<cfargument name="supervisorid" type="numeric" required="no">
		<cfargument name="versionstatusid" type="numeric" required="no">
		<cfargument name="label" type="string" required="no">
		<cfargument name="dateToPublish" type="string" required="no">
		<cfargument name="dateToExpire" type="string" required="no">
		<cfargument name="versiondirectiveid" type="string" required="no">		
		<cfargument name="parentid" type="numeric" required="no">
		<cfargument name="alreadyPublished" type="boolean" required="no" default="0">
		<cfargument name="archive" type="boolean" required="no">
		<cfargument name="formobjectitemid" type="numeric" required="no">
		<cfargument name="instanceitemid" type="numeric" required="no">
		<cfargument name="versionid" type="numeric" required="no">
		<cfset var q_UpdateVersion = "">
		<cfset var success = 1>
		<cftry>			
			 <cfquery name="q_UpdateVersion" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				UPDATE Version
				SET datemodified= <cfqueryparam cfsqltype="cf_sql_date" value="#createODBCDateTime(now())#">
					<cfif isDefined('arguments.archive') AND arguments.archive>
						, archive= <cfqueryparam cfsqltype="cf_sql_bit" value="1">
					</cfif>
					<cfif isDefined('arguments.versionstatusid') AND arguments.versionstatusid>
						, versionstatusid= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.versionstatusid#">
					</cfif>					
					<cfif isDefined("arguments.ownerid") AND len(arguments.ownerid)>
						, ownerid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ownerid#"> 
					</cfif>
					<cfif isDefined("arguments.supervisorid") AND len(arguments.supervisorid)>
						, supervisorid= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.supervisorid#"> 
					</cfif>
					<cfif isDefined("arguments.label") AND len(arguments.label)>
						, label = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.label#">
					</cfif>
					<cfif isDefined("arguments.dateToPublish") AND len(trim(arguments.dateToPublish)) AND arguments.dateToExpire NEQ 'NULL'>
						, dateToPublish = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.dateToPublish#">
					</cfif>
					<cfif isDefined("arguments.dateToExpire") AND len(trim(arguments.dateToExpire)) AND arguments.dateToExpire NEQ 'NULL'>
						, dateToExpire = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.dateToExpire#">
					</cfif>
					<cfif isDefined("arguments.versiondirectiveid") AND isNumeric(Trim(arguments.versiondirectiveid))>
						, versiondirectiveid = <cfif Trim(arguments.versiondirectiveid) neq 0>#Trim(arguments.versiondirectiveid)#<cfelse>NULL</cfif>
					</cfif>					
				WHERE 1=1
				<cfif isDefined('arguments.formobjectitemid') AND arguments.formobjectitemid>
					AND formobjectitemid= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formobjectitemid#">
				</cfif>
				<cfif isDefined('arguments.instanceitemid') AND arguments.instanceitemid> 
					AND instanceitemid=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.instanceitemid#">
				</cfif>
				<cfif isDefined('arguments.alreadyPublished') AND arguments.alreadyPublished>
					AND versionStatusID = 100002
				</cfif>
				<cfif isDefined('arguments.parentid') AND arguments.parentid>
					AND parentid = #arguments.parentid#
				</cfif>
				<cfif isDefined('arguments.versionid') AND arguments.versionid>
					AND versionid = #arguments.versionid#
				</cfif>
			</cfquery>
				<cfcatch type="database">
					<cfset success = 0>
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn success>
	</cffunction>
	
	<cffunction access="public" name="deleteVersions" output="false" returntype="boolean" displayname="deleteVersions">
		<cfargument name="deleteInstanceIDList" type="string" required="yes">
		<cfargument name="formobjectitemid" type="numeric" required="yes">
		<cfset var q_deleteVersions = "">
		<cfset var success = 1>
		<cftry>
			 <cfquery name="q_deleteVersions" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				UPDATE version
				SET archive = 1
				WHERE instanceitemid IN (#arguments.deleteInstanceIDList#) AND formobjectitemid = #arguments.formobjectitemid#
			</cfquery>
				<cfcatch type="database">
					<cfset success = 0>
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn success>
	</cffunction>
	
	<cffunction access="public" name="getVersionRecord" output="false" returntype="query" displayname="getVersionParent">
		<cfargument name="instanceItemID" type="numeric" required="no">
		<cfargument name="formobjectitemid" type="numeric" required="no">
		<cfargument name="parentid" type="numeric" required="no">
		<cfargument name="selectClause" type="string" required="yes" default="*">
		<cfset var q_getParent = "">
		<cftry>
			 <cfquery name="q_getParent" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT #arguments.selectClause#
				FROM version
				WHERE 1=1
				<cfif isDefined('arguments.formobjectitemid') AND arguments.formobjectitemid>
					AND formobjectitemid = #arguments.formobjectitemid# 
				</cfif>
				<cfif isDefined('arguments.instanceItemID') AND arguments.instanceItemID>
					AND instanceItemID = #trim(arguments.instanceItemID)#
				</cfif>
				<cfif isDefined('arguments.parentid') AND arguments.parentid>
					AND parentid = #trim(arguments.parentid)#
				</cfif>
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_getParent>
	</cffunction>
		
</cfcomponent>