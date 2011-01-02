<!--- Complete form process --->
<!--- if old file and wants deleted --->
<cfif isDefined("form.deleteFile")>
	<cffile action="DELETE"
	        file="#form.deleteFile#">
</cfif>

<cfquery name="q_getForm" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT  *
	FROM   formobject INNER JOIN formEnvironment ON formobject.formEnvironmentID = formEnvironment.formEnvironmentID
	WHERE  (formobject.formobjectid = #listFirst(formobjectid)#)
</cfquery>
<cfif isDefined("form.editfieldkeyvalue")>
	<cfquery name="q_updateKeyField" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		UPDATE  formobject 
		SET editfieldkeyvalue = '#trim(form.editfieldkeyvalue)#', editfieldsortorder = '#trim(form.editfieldsortorder)#', editfieldkeyvalue2 = '#trim(form.editfieldkeyvalue2)#', editfieldsortorder2 = '#trim(form.editfieldsortorder2)#'
		WHERE  formobjectid = #listFirst(formobjectid)#
	</cfquery>
</cfif>
<!--- check the table to see if this table has any records in it --->
<cfif (q_getForm.formEnvironmentID EQ 105) OR (q_getForm.formEnvironmentID EQ 107)>
	<cfset q_checkForSingleRecord.RecordCount = -1>
<cfelseif q_getForm.formobjectid NEQ q_getForm.parentid>
	<cfquery name="q_getFormParent" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT  formEnvironmentID
		FROM   formobject 
		WHERE  (formobject.formobjectid = #listFirst(formobjectid)#)
	</cfquery>
	<cfif (q_getFormParent.formEnvironmentID EQ 105) OR (q_getFormParent.formEnvironmentID EQ 107)>
		<cfset q_checkForSingleRecord.RecordCount = -1>
	</cfif>
<cfelse>
	<cfquery name="q_checkForSingleRecord" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		select * from #q_getForm.datatable# where #q_getForm.datatable#id >= 1
	</cfquery>
</cfif>
<!--- If there are no records in this table we need to add a null recordset --->
<cfif q_getForm.singleRecord EQ 1 AND q_checkForSingleRecord.RecordCount EQ 0>
	<!--- first just insert the first row record --->
	<cfquery name="q_updateSingeRecordTable" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		insert into #q_getForm.datatable# (#q_getForm.datatable#ID) VALUES (100000)
	</cfquery>
	<!--- then update the TableID record for this table --->
	<cfquery name="q_updateSingeRecordTableID" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		UPDATE TableID
		SET ID = ID + 1
		WHERE (TableName = '#q_getForm.datatable#')
	</cfquery>
</cfif>
<!--- 12/14/2006 DRK add greeking text to fill in dummy record(s) START --->
<!--- this insert moved from i_createformPost to include dummy entry, will be wrapped in an if --->
<!--- 12/16/2006 BDW Temporarily Commented out Until DRK can Debug... --->
<cfif isDefined('SESSION.createfieldcount')>
	<!--- get data definitions --->
	<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML"
			input="#q_getform.datadefinition#"
			output="a_formelements">
	<cfquery name="q_seedID" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT ID FROM TableID WHERE TableName = '#q_getForm.datatable#'
	</cfquery>
	<cfset ignorelist="datecreated,datemodified,parentid,ordinal">
	<cfset stopCount = val(SESSION.createfieldcount-1)>
	<cfloop from="0" to="#stopCount#" index="i">
		<cfset fieldcount = 0>
		<cfloop from="1" to="#arraylen(a_formelements)#" index="j">
		<cfif (NOT listfindnocase(ignorelist,a_formelements[j].fieldname)) AND (NOT findnocase(#q_getForm.datatable#&"ID",a_formelements[j].fieldname)) AND (a_formelements[j].commit EQ 1)>
			<cfsavecontent variable="greekblock"><p>Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. </p><p>Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.</p><p>Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi.</p><p>Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat.</p><p>Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis.</p><p>At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, At accusam aliquyam diam diam dolore dolores duo eirmod eos erat, et nonumy sed tempor et et invidunt justo labore Stet clita ea et gubergren, kasd magna no rebum. sanctus sea sed takimata ut vero voluptua. est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat.</p><p>Consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus.</p><p>Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.</p><p>Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.</p><p>Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. </p><p>Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat.</p><p>Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis.</p><p>At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, At accusam aliquyam diam diam dolore dolores duo eirmod eos erat, et nonumy sed tempor et et invidunt justo labore Stet clita ea et gubergren, kasd magna no rebum. sanctus sea sed takimata ut vero voluptua. est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat.</p><p>Consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus.</p><p>Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. </p><p>Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. </p><p>Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi.</p><p>Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat.</p><p>At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, At accusam aliquyam diam diam dolore dolores duo eirmod eos erat, et nonumy sed tempor et et invidunt justo labore Stet clita ea et gubergren, kasd magna no rebum. sanctus sea sed takimata ut vero voluptua. est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat.</p><p>Consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus.</p><p>Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum</p>
		</cfsavecontent>
			<cfset thisValue = "">
			<cfif  a_formelements[j].datatype EQ "nvarchar" OR a_formelements[j].datatype EQ "varchar">
				<cfset thisValue = "'#mid(greekblock,4,val(a_formelements[j].length/3))#'">
			</cfif>
			<cfif  a_formelements[j].datatype EQ "ntext" OR a_formelements[j].datatype EQ "text" >
				<cfset thisValue = "'#left(greekblock,600)#'">
			</cfif>
			<cfif findnocase(trim(a_formelements[j].fieldname),"#q_getForm.datatable#name")>
				<cfset thisValue = "'{Test Data} #q_getform.label# #val(i+1)#'">
			</cfif>
			<cfif findnocase(trim(a_formelements[j].fieldname),"sekeyname")>
				<cfquery name="q_getName" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT #q_getForm.datatable#name
					FROM #q_getForm.datatable#
					WHERE #q_getForm.datatable#id = #val(q_seedID.ID+i)#
				</cfquery>
				<cfset thisValue = "#replacenocase(evaluate("q_getName.#q_getForm.datatable#name")," ","-","all")#">
				<cfset thisValue = "#replacenocase(thisValue,"{","")#">
				<cfset thisValue = "'#replacenocase(thisValue,"}","")#'">
			</cfif>
			<cfif  a_formelements[j].datatype EQ "int">
				<cfif findnocase("id",a_formelements[j].fieldname)>
					<cfset thisValue = 100000>
				<cfelse>
					<cfset thisValue = randrange(1,10)>
				</cfif>
			</cfif>
			<cfif a_formelements[j].datatype EQ "bit">
				<cfif  findnocase("archive",a_formelements[j].fieldname)>
					<cfset thisValue = 0>
				<cfelse>
					<cfset thisValue = 1>
				</cfif>
			</cfif>
			<cfif a_formelements[j].datatype EQ "float" >
				<cfset thisValue = 1.0>
			</cfif>
			<cfif a_formelements[j].datatype EQ "datetime" >
				<cfset thisValue = createODBCdatetime(now())>
			</cfif>
			<cfif len(trim(thisValue))>
				<cfset fieldcount = fieldcount + 1>
				<cfif fieldcount EQ 1>
					<cfquery name="q_updateNewColumn" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						INSERT INTO #q_getForm.datatable#
						(#a_formelements[j].fieldname#, #q_getForm.datatable#id, datecreated, datemodified)
						VALUES (#preservesinglequotes(thisValue)#, #val(q_seedID.ID+i)#, #createODBCDateTime(Now())#, #createODBCDateTime(Now())#)
					</cfquery>
					<cfquery name="q_updateNewColumnID" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						UPDATE TableID SET ID = #val(q_seedID.ID+i+1)# WHERE (TableName = '#q_getForm.datatable#')
					</cfquery>
				<cfelse>
					<cfquery name="q_updateNewColumn" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						UPDATE #q_getForm.datatable#
						SET #a_formelements[j].fieldname# = #preservesinglequotes(thisValue)#
						WHERE #q_getForm.datatable#id = #val(q_seedID.ID+i)#
					</cfquery>
				</cfif>
			</cfif>
		</cfif>
		</cfloop>
		<cfif q_getForm.useOrdinal>
			<cfquery name="q_getNextOrdinal" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT top 1 ordinal
				FROM #q_getForm.datatable#
				ORDER BY ordinal DESC
			</cfquery>
			<cfif q_getNextOrdinal.recordcount and isNumeric(q_getNextOrdinal.ordinal)>
				<cfset newOrdinal = val(q_getNextOrdinal.ordinal + 1)>
			<cfelse>
				<cfset newOrdinal = 1>
			</cfif>
			<cfquery name="q_updateNewColumn" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				UPDATE #q_getForm.datatable#
				SET ordinal = #newOrdinal#
				WHERE #q_getForm.datatable#id = #val(q_seedID.ID+i)#
			</cfquery>
		</cfif>
		<cfif q_getForm.useWorkFlow>
			<cfquery name="q_getLabel" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT #q_getForm.datatable#name AS label
				FROM #q_getForm.datatable#
				WHERE #q_getForm.datatable#id = #val(q_seedID.ID+i)#
			</cfquery>
			<cfquery name="q_getNextVersion" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT top 1 versionid
				FROM version
				ORDER BY versionid DESC
			</cfquery>
			<cfif q_getNextVersion.recordcount>
				<cfset newVersionID = val(q_getNextVersion.versionid + 1)>
			<cfelse>
				<cfset newVersionID = 100000>
			</cfif>
			<cfquery name="q_updateNewColumn" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				INSERT INTO version
				(versionid, label, datecreated, datemodified, parentid, instanceitemid, version, ownerid, supervisorid, versionStatusID, formobjectitemid, creatorid)
				VALUES (#newVersionID#, '#q_getLabel.label#', #createODBCDateTime(Now())#, #createODBCDateTime(Now())#, #val(q_seedID.ID+i)#, #val(q_seedID.ID+i)#, 1, #SESSION.user.id#, #APPLICATION.supervisorid#, 100002, #q_getForm.formobjectid#, #SESSION.user.id#)
			</cfquery>
			<cfquery name="q_updateNewColumnID" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				UPDATE TableID SET ID = #newVersionID# WHERE (TableName = 'version')
			</cfquery>
		</cfif>
		<cfif isDefined('q_getForm.isNavigable') AND q_getForm.isNavigable EQ 1>
			<cfset form.datemodified = CreateODBCDateTime(now())>
			<cfset form.datecreated = CreateODBCDateTime(now())>
			<cfset form.navitemaddressname = '{Test Data} #q_getform.label# #val(i+1)#'>
			<cfset form.formobjecttableid = listFirst(formobjectid)>
			<cfset form.objectinstanceid = val(q_seedID.ID+i)>
			<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
				 datasource="#application.datasource#"
				 tablename="navitemaddress"
				 assignidfield="navitemaddressid">
		</cfif>
	</cfloop>
	<!--- get rid of session scope used to create greeking stuff --->
	<cfset structDelete(SESSION,"createfieldcount")>
</cfif>
<!--- 12/14/2006 DRK add greeking text to fill in dummy record END --->

<!--- If this is an Admintool, write permissions to the administrator --->
<cfif findNoCase("admin",form.formenvironmentname,1)>
	<cfquery name="q_clearPerms" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		DELETE from userpermission
		WHERE formobjectid = #listFirst(formobjectid)# AND userid = 100000
	</cfquery>
	<cfquery name="q_addPerms" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		INSERT INTO userpermission (userid, formobjectid, addedit, access, remove, approve)
		VALUES (100000, #listFirst(formobjectid)#, 1, 1, 1, 1)
	</cfquery>
	<!--- query for this users tool permissions --->
			<cfquery datasource="#application.datasource#" name="q_authenticate" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT Users.Usersid, userpermission.access, userpermission.addEdit, userpermission.approve, userpermission.remove, userpermission.formobjectid, Users.firstName, UserType.roleid
				FROM Users INNER JOIN userpermission ON Users.Usersid = userpermission.userid
					INNER JOIN usertype ON Users.usertypeid = UserType.usertypeid
				WHERE (Users.Usersid = 100000)
			</cfquery>
		<!--- store session structure containing all permissions for user --->
			<cfif q_authenticate.recordcount>
				<cfset user=structNew()>
				<cfset user.name=q_authenticate.firstname>
				<cfset user.id=q_authenticate.usersid>
				<cfset user.liveEdit=0>
				<cfset user.accessLevel=q_authenticate.roleid>
				<cfset tools=arrayNew(2)>
				<cfloop query="q_authenticate">
					<cfset rights=structNew()>
					<cfset rights.access=q_authenticate.access>
					<cfset rights.addedit=q_authenticate.addedit>
					<cfset rights.remove=q_authenticate.remove>
					<cfset tools[q_authenticate.currentrow][1]=q_authenticate.formobjectid>
					<cfset tools[q_authenticate.currentrow][2]=rights>
				</cfloop> 
				<cfset user.tools=tools>
				<cflock scope="SESSION" timeout="5" type="EXCLUSIVE">
					<cfset session.user=user>
				</cflock>
			</cfif>
</cfif>
<!--- reset nav based on permissions --->
<!--- <cfset session.allNavigation = APPLICATION.navObj.getAllNavigation(usePermissions=1)>
<cfset session.navXML_1000 = APPLICATION.navUtilObj.getNavXML(alphaordering=0,groupid=1000,q_querydata=session.allNavigation)>
<cfset session.navData_1000 = APPLICATION.navUtilObj.buildListingNav(navDataSource=XMLParse(SESSION.navXML_1000).XMLRoot.XMLChildren,textOnly=0,classBase="adminnavlist",topOnly=0,editmode=0)> --->
<!--- get data definitions --->
<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="XML2CFML"
        input="#q_getform.datadefinition#"
        output="a_formelements">

<!--- BUILD FORM IF REQUIRED--->
<cfif IsDefined('q_getForm.generatefile') AND q_getForm.generatefile GTE 1>
		<cfsavecontent variable="formbuild">
			<cfset request.createflatfile=1>
			<cfif len(q_getform.formaction)>
				<cfset thisAction=q_getform.formaction>
			<cfelse>
				<cfset thisAction="#chr(35)#request.page#chr(35)#">
			</cfif>
			<cfoutput>
			#chr(60)#cfoutput#chr(62)#
				<!--- Loop over formelements setting default values --->
				<cfloop index="a" from="1" to="#arrayLen(a_formelements)#">
					#chr(60)#cfparam name="form.#a_formelements[a].fieldname#" default="#a_formelements[a].defaultvalue#"#chr(62)#
				</cfloop>
				<cfinclude template="/customtags/#application.customtagpath#/formbuild.cfm">
			#chr(60)#/cfoutput#chr(62)#
			</cfoutput>
		</cfsavecontent>
</cfif>
<cfoutput>
	<script language="JavaScript"> 
		window.location.href="/admintools/index.cfm?i3currentool=#session.i3currenttool#&initializeApp=1";
	 </script>
 </cfoutput>

