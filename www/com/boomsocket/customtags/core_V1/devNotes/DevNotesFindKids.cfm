<!-- DevNotesFindKids.cfm by hal helms and jeff@grokfusebox.com -->

<!---
<fusedoc fuse="gfbDevNotesFindKids.cfm" language="ColdFusion" specification="2.0">
  <responsibilities>
    I recursively build a list of the children of a specified DevNote.
  </responsibilities>
  <history author email="jeff@grokfusebox.com" date="28 Jan 02" comments="Version 0.10">
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

<cfoutput>

<cfquery datasource="#request.DevNotesDSN#" name="search" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT noteID 
    FROM Notes 
   WHERE parentID = #Trim( attributes.noteID )#
</cfquery>

<!--- For each child, append their ID to the list.  Then recurse to --->
<!--- find their children.                                          --->

<cfloop query="search">
	<cfset request.kidList = ListPrepend( request.kidList, noteID )>
	<cfmodule template="#application.customTagPath#/DevNotesFindKids.cfm" noteid="#noteID#">
</cfloop>

</cfoutput>

