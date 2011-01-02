<!-- DevNotes.cfm by hal.helms@teamallaire.com and jeff@grokfusebox.com -->

<!---
<fusedoc fuse="DevNotes.cfm" language="ColdFusion" specification="2.0">
  <responsibilities>
    I recursively build a list of the children of a specified DevNote.
  </responsibilities>
  <properties>
    <history author="hal helms" date="07 Feb 02">
    		Changed database to add field "showNote". Changed code so that, instead of deleting records, it flips the showNote field to FALSE, so that the changes are kept.
    </history>
    <history author="Jeff Peters" date="28 Jan 02" type="update">Version 0.10</history>
    <history author="Jeff Peters" date="06 Jan 02" type="update">Version 0.20</history>  
    <history author="Jeff Peters" date="20 Aug 02" type="update">Version 0.30</history>
    <history author="Jeff Peters" date="22 Aug 02" type="update">Version 0.40 - fixed bug in form submission for tracking by fuseaction.</history>
    <history author="Jeff Peters" date="15 Nov 05" type="update" email="jeff@grokfusebox.com">
      Version 0.50
      Requires udfMakeTree.cfm instead of CFX_Make_Tree.dll 
      Requires DevNotesFindKids.cfm by jeff@grokfusebox.com
      Adds dateEntered to Notes database table
    </history>
  </properties>
  <io>
    <in>
      <number name="noteID" precision="Integer" />
    </in>
    <out>
      <list name="kidList" scope="request" comments="List of child noteIDs"
    </out>
  </io>
</fusedoc>
--->

<!--- Make sure state mgm't is set up --->
<cfif NOT IsDefined( 'application.applicationName' )>
	<cfapplication 
		name="DevNotes" 
		clientmanagement="Yes" 
		sessionmanagement="Yes">
</cfif>

<!--- Append any attributes, form variables, and url variables to the request scope, overwriting if necessary. --->
<cfset lstScopes = "attributes,form">
<cfloop list="#lstScopes#" index="thisScope">
  <cfif IsDefined("#thisScope#")>
    <!--- If no request-scoped variables exist, create one so the request structure exists. --->
    <cfif not isDefined("request")>
      <cfset request.dnRequestExists = 1>
    </cfif>
    <cfset temp=StructAppend(request, Evaluate(thisScope), "Yes")>
  </cfif>
</cfloop>

<cfif isDefined("url.fuseaction")>
  <cfset request.fuseaction = url.fuseaction>
</cfif>

<!--- Set any of the required vars that weren't sent in as attributes. --->
<cfparam name="request.DevNotesDSN" default="DevNotes">
<cfparam name="request.DevTesting" default="1">
<cfparam name="request.loseIdentity" default="FALSE">
<cfparam name="request.deleteNote" default="FALSE">
<cfparam name="request.parentID" default="0">
<cfparam name="request.deleteNote" default="FALSE">
<cfparam name="request.dumpVars" default="FALSE">
<cfparam name="request.attributeToKeyOn" default="url">
<cfparam name="request.noteText" default="">
<cfparam name="request.devID" default="">
<cfparam name="request.fuseaction" default="notInURL">
<cfparam name="request.Notify" default="0">
<cfparam name="request.devAppName" default="#application.installurl#">


<cfif lcase(request.attributeToKeyOn) EQ "url">
  <cfset request.URL = "#cgi.script_name#">
</cfif>

<!--- @COMMENT: Insert a new or related note if one is passed to me.--->
<cfif Len( Trim( request.noteText ) )>
	<cfquery datasource="#request.DevNotesDSN#" name="q_insertNote" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		INSERT INTO Notes
			(noteText,parentID,myLevel,applicationName,author,authorid,attributeToKeyOn,aKeyValue,showNote,notifyReplies,dateEntered)
		VALUES
			('#request.noteText#',#request.parentID#,#request.noteLevel#,'#request.devAppName#','#session.user.name#','#session.user.id#','#request.attributeToKeyOn#','#Evaluate( 'request.' & request.attributeToKeyOn )#',1,#request.Notify#,#Now()#)
		Select @@Identity as newID
	</cfquery>
	<cfmail to="#application.adminemail#" replyto="#application.adminemail#" from="#application.adminemail#" subject="i3SiteTools Prototyping Note" type="html">
		<p>The following note was added to #request.devAppName# by #session.user.name#:</p>
		#request.noteText#
		<p>This note was posted on the following page:<br /><a href="#application.installURL##Evaluate( 'request.' & request.attributeToKeyOn )#">#application.installURL##Evaluate( 'request.' & request.attributeToKeyOn )#</a></p>
	</cfmail>
	<!--- Check to see if any parent notes want a reply --->
	<cfquery name="replyRequestedList" datasource="#request.DevNotesDSN#">
		EXEC dp_getNoteParents #q_insertNote.newid#
	</cfquery>
	<cfif replyRequestedList.RecordCount and ListLen(replyRequestedList.parentIDList)>
		<cfset emailSentTo = ''>
		<cfloop index="thisNoteID" list="#replyRequestedList.parentIDList#">
			<cfquery name="getUserData" datasource="#request.DevNotesDSN#">
				SELECT Users.firstName + ' ' + Users.lastName AS toName, Users.email AS toEmail, Notes.noteText, fromUser.firstName + ' ' + fromUser.lastName AS fromName, fromUser.email AS fromEmail
				FROM Notes 
					INNER JOIN Users 
						ON Notes.authorid = Users.Usersid 
					CROSS JOIN Users fromUser
				WHERE (Users.Usersid IN(
					SELECT authorid
					FROM notes
					WHERE noteid = #thisNoteID# AND Notes.notifyReplies = 1))
				AND (Notes.noteID = #thisNoteID#) AND (fromUser.Usersid = #session.user.id#)
			</cfquery>
			<!--- send the email to this person notifying them of the new message --->
			<cfif FindNoCase(getUserData.toEmail, emailSentTo) EQ 0>
				<cfmail to="#getUserData.toName# <#getUserData.toEmail#>" replyto="#getUserData.fromName# <#getUserData.fromEmail#>" from="#getUserData.fromName# <#getUserData.fromEmail#>" subject="i3SiteTools Prototyping Note Reply" type="html">
					<p>The following note was added as a reply to a note you posted:</p>
					#request.noteText#
					<p>This note was posted on the following page:<br /><a href="#application.installURL##Evaluate( 'request.' & request.attributeToKeyOn )#">#application.installURL##Evaluate( 'request.' & request.attributeToKeyOn )#</a></p>
				</cfmail>
			</cfif>
			<cfset emailSentTo = emailSentTo & ',' & getUserData.toEmail>
		</cfloop>
	</cfif>
	<!--- replyRequestedList.parentIDList --->
	
  <cfset request.noteText = "">
  <cfset request.parentID = 0>
</cfif>


<cfif request.deleteNote>
	<!--- Build a list of the note and its descendants. --->
	<cfset request.kidList = "#request.noteID#">
	<cfmodule template="#application.customTagPath#/DevNotesFindKids.cfm" noteid="#request.noteID#">
  
	<!--- Delete the note and its descendants --->
	<cfquery datasource="#request.DevNotesDSN#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		UPDATE Notes 
		Set showNote = 0
     WHERE noteID IN ( #request.kidList# )
	</cfquery>	
	
  <cfset request.deleteNote = False>
  <cfset request.parentID = 0>
</cfif>

<cfif findnocase("idp",request.devAppName)>
	<cfset request.devAppNameAlt = replaceNoCase(request.devAppName,"idp0","dp0","one")>
<cfelse>
	<cfset request.devAppNameAlt = replaceNoCase(request.devAppName,"dp0","idp0","one")>
</cfif>
<!--- Get notes from DevNotes database --->
<cfquery name="Notes" datasource="#request.DevNotesDSN#">
	SELECT 
		     NoteID as ItemID, 
		     ParentID as ParentItemID, 
		     NoteText as Description,
			 dateEntered as Date
	  FROM Notes 
 	 WHERE applicationName IN ('#request.devAppName#','#request.devAppNameAlt#')
	   AND attributeToKeyOn = '#request.attributeToKeyOn#'
	   AND aKeyValue = '#Evaluate( 'request.' & request.attributeToKeyOn )#'
		AND showNote = 1
ORDER BY NoteID
</cfquery>

<!--- @COMMENT: Display the notes --->
<cfinclude template="udfMakeTree.cfm">
<cfset Notes = maketree(Notes, "ItemID", "ParentItemID")>

<!--- @COMMENT: FORM starts here --->
<cfparam name="request.noteLevel" default="1">
<cfparam name="request.noteID" default="">
<cfparam name="request.parentID" default="0">
<cfif request.parentID is 0>
	<cfset request.noteLevel = 1>
</cfif>
<cfset rootelem = true>
<cfif IsDefined('FORM.post') OR IsDefined('FORM.NOTEID')>
	<cfsavecontent variable="putInHead">
		<cfoutput>
			<script type="text/javascript">
				womAdd('showHideDevNotes()');
			</script>
		</cfoutput>
	</cfsavecontent>
	<cfhtmlhead text="#putInHead#">
</cfif>
<cfoutput>
<br><br>
<div id="devNotesBlock">
	<div id="devNotesOuterBar">
		<div id="devNotesInnerBar">
			<cfif isDefined("session.user")>
				<div id="welcomeText">
					Welcome #session.user.name#!
				</div>
			</cfif>
			<img src="#application.globalPath#/media/images/prototypingDiscussionHdr.gif" width="83" height="18" border="0">
			<a href="javascript:void(0);" onclick="showHideDevNotes();" name="showHideButton">
				<img src="#application.globalPath#/media/images/prototypingShowArrow.gif" width="33" height="18" border="0" id="showArrow2">
				<img src="#application.globalPath#/media/images/prototypingHideArrow.gif" width="33" height="18" border="0" id="hideArrow2" style="display:none;">
			</a>
		</div>
	</div>
	<div id="devnotesbody" style="display:<cfif isDefined('cookie.devNotesOpen') AND cookie.devNotesOpen>block<cfelse>none</cfif>;">
		<div id="devNotesTree">
			<h3 class="devHeaderText">:: Discussion Thread ::</h3>
			<cfloop query="Notes">
				<cfquery datasource="#request.DevNotesDSN#" name="GetLevels" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT myLevel, author FROM Notes WHERE noteID = #ItemID#
				</cfquery>
				<p><img src="#application.globalPath#/media/images/note.png" width="16" height="16" />
				<cfloop from="1" to="#DecrementValue( GetLevels.myLevel )#" index="i">
					&##8212;
				</cfloop>
				&nbsp;+
				<cfif isDefined("session.user")><a title="Follow-up" href="javascript:document.devForm.parentID.value='#ItemID#';document.devForm.isNewNote.value='FALSE';document.devForm.noteLevel.value='#IncrementValue( GetLevels.myLevel )#';document.devForm.submit();"><img src="#application.globalPath#/media/images/prototypingAddNoteIcon.gif" width="16" height="16" border="0" /></a></cfif>
				<cfif isDefined("session.user") AND session.user.name EQ GetLevels.author OR isDefined("session.user") AND session.user.id EQ 100000><a title="Delete" href="javascript:document.devForm.parentID.value='#ItemID#';javascript:document.devForm.noteID.value='#ItemID#';document.devForm.deleteNote.value='1';document.devForm.submit();"><img src="#application.globalPath#/media/images/prototypingDeleteNoteIcon.gif" width="16" height="16" border="0" /></a></cfif>
				&nbsp;&nbsp;&nbsp;(#DateFormat(notes.Date,'mm/dd/yy')#) #GetLevels.author#: <span class="noteDescrp">#Left(Notes.Description, 50)#</span><cfif len(trim(Notes.Description)) GT 50>... <a href="##" onclick="viewNote('noteDescrp_#ItemID#',this)" id="read_#ItemID#">Read</a></cfif><span style="display:none" id="noteDescrp_#ItemID#">#Notes.Description#</span><br>
			  </p>
			</cfloop>
		</div>
		<cfif IsDefined('Session.user')>
			<div id="devNotesForm">
				<form action="#cgi.script_name#?#client.urltoken#" method="post" name="devForm">
					<input type="Hidden" name="isNewNote" value="1">
					<input type="Hidden" name="parentID" value="#request.parentID#">
					<input type="Hidden" name="noteID" value="#request.noteID#">
					<input type="Hidden" name="noteLevel" value="#request.noteLevel#">
					<input type="Hidden" name="deleteNote" value="0">
					<input type="Hidden" name="attributeToKeyOn" value="#request.attributeToKeyOn#">
					<input type="Hidden" name="#request.attributeToKeyOn#" value="#Evaluate( 'request.' & request.attributeToKeyOn )#">
					<!--- @COMMENT: Provide form for new/responding note --->
					<cfparam name="request.isNewNote" default="1">
					<cfif request.isNewNote>
						<h3 class="devHeaderText">:: Add a New Note :: </h3>	
					<cfelse>
						<h3 class="devHeaderText">:: Add a Follow-up Note :: </h3>	
					</cfif>
					<!--- <textarea name="noteText" cols="40" rows="2"></textarea><br> --->
					<cfscript>
						fckEditor = createObject("component", "#application.globalPath#/fckeditor/#application.fckVersion#/fckeditor");
						fckEditor.basePath		= "#application.globalPath#/fckeditor/#application.fckVersion#/";
						fckEditor.instanceName	= "noteText";
						fckEditor.value			= "";						
						fckEditor.width			= "350";
						fckEditor.height		= "200";
						fckEditor.toolbarSet	= "Basic";
						fckEditor.create(); // create the editor.
					</cfscript>
					<!--- <input name="Notify" type="checkbox" value="1" disabled="disabled" />Notify me of replies ---> <input name="post" type="Submit" id="postButton" value="Post Note">
				</form>
			</div>
		</cfif>
		<span class="clear">&nbsp;</span>
	</div>
</div>
</cfoutput>