<cfset newSupervisorid="">
<cfset newUserid="">
<cfset newFormobject="">

<cfloop list="#form.Supervisorid#" index="thisSupervisorid">
	<cfset newSupervisorid=listAppend(newSupervisorid,listFirst(thisSupervisorid,"~"))>
</cfloop>
<cfset form.Supervisorid=newSupervisorid>

<cfloop list="#form.Userid#" index="thisUserid">
	<cfset newUserid=listAppend(newUserid,listFirst(thisUserid,"~"))>
</cfloop>
<cfset form.Userid=newUserid>

<cfloop list="#form.Formobject#" index="thisFormobject">
	<cfset newFormobject=listAppend(newFormobject,listFirst(thisFormobject,"~"))>
</cfloop>
<cfset form.Formobject=newFormobject>
