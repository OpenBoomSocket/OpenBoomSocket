<cfparam name="request.mycatcount" default="-1">
<!---
FILE:			SiteMap.cfm
NAME:           CF_SiteMap
CREATED:		5/31/2001
LAST MODIFIED:	5/31/2001
AUTHOR:         Mike Brennan: mjb14@acsu.buffalo.edu

DESCRIPTION:    CF_SiteMap is a custom CFML tag for generating a sitemap from 
				a table tracking item and item_parent.  It will create the 
				sitemap with infite deep levels using recursion.  Perfect tag 
				for any content management system.  

ATTRIBUTES:		ID : The base value for the parent ids.  Default is 0.  (OPTIONAL)
				ITEM_ID_COL : Name of column containg the item ids (REQUIRED)
				DISPLAY_NAME_COL : Name of column containg the display values.  (REQUIRED)
				ITEM_PARENT_ID_COL : Name of column containg parent ids. (REQUIRED)
				THE_TABLE : Name of table containing the item ids, parent_ids, and item names (REQUIRED)
				DB : Name of the datasource (REQUIRED)
				ORDER_BY: Name of column containg the sort order.  Default is the display_name_col (OPTIONAL)
				PICK_SELECTED_ID: "parent" or "current" chooses which category to pre-select (OPTIONAL)
				
SAMPLE INFORMATION:	http://www.acsu.buffalo.edu/~mjb14/sitemap/index.html


RETURN:			I'll put out a newer version with various return options other than a list later on.

--->
<cfset request.mycatcount=request.mycatcount+1>

<!--- default value of 0, representing the base value for parent ids --->
<cfparam name="variables.ID" default="0">

<cfparam name="variables.pick_selected_id" default="current">
<cfparam name="pickID" default="100000">


<!--- For tracking attributes that were not implemented. --->
<cfparam name="variables.error" default="">

<!--- Check to see if an attribute is missing --->
<cfif ISDEFINED("attributes.pick_selected_id")>
	<cfset variables.pick_selected_id = #attributes.pick_selected_id#>
</cfif>

<cfif ISDEFINED("attributes.ID")>
<cfset variables.ID = #attributes.ID#>
</cfif>

<cfif ISDEFINED("attributes.DB")>
	<cfset variables.DB = #attributes.DB#>
<cfelse>
	<cfset variables.error = variables.error & "Attribute DB is required.<br>">
</cfif>

<cfif ISDEFINED("attributes.item_id_col")>
	<cfset variables.item_id_col =  #attributes.item_id_col#>
<cfelse>
	<cfset variables.error = variables.error & "Attribute item_id_col is required.<br>">
</cfif>

<cfif ISDEFINED("attributes.item_parent_id_col")>
	<cfset variables.item_parent_id_col = #attributes.item_parent_id_col#>
<cfelse>
	<cfset variables.error = variables.error & "Attribute item_parent_id_col is required.<br>">
</cfif>

<cfif ISDEFINED("attributes.display_name_col")>
	<cfset variables.display_name_col = #attributes.display_name_col#>
<cfelse>
	<cfset variables.error = variables.error & "Attribute display_name_col is required.<br>">
</cfif>

<cfif ISDEFINED("attributes.the_table")>
	<cfset variables.the_table = #attributes.the_table#>
<cfelse>
	<cfset variables.error = variables.error & "Attribute the_table is required.<br>">
</cfif>
<!--- End checking of missing attributes --->


<!--- Test for missing attribute --->
<cfif variables.error NEQ "">
	<cfoutput>#variables.error#</cfoutput>
	<cfabort>
</cfif>

<!--- the field to order by --->
<cfparam name="variables.order_by" default="#variables.display_name_col#">
<cfif ISDEFINED("attributes.order_by")>
	<cfset variables.order_by = #attributes.order_by#>
</cfif>



<!--- Capture children who have a specified/default parent id --->
<cfquery name="getChildren" datasource="#variables.DB#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
SELECT	#variables.item_id_col#,
		#variables.display_name_col#,
		#variables.item_parent_id_col#
FROM	#variables.the_table#
WHERE	#variables.item_parent_id_col# = #variables.ID#
ORDER BY #variables.order_by#
</cfquery>
<cfif variables.pick_selected_id EQ "parent">
	<cfquery name="q_getParent" datasource="#variables.DB#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT parentid
	FROM #variables.the_table#
	WHERE uploadcategoryid = #listFirst(form.uploadcategoryid,"|")#
	</cfquery>
	<cfset pickID=q_getParent.parentid>
<cfelseif variables.pick_selected_id EQ "current">
		<cfset pickID=listFirst(form.uploadcategoryid,"|")>
</cfif>

<cfset children = "">
<cfif getChildren.recordcount GT 0>
	<cfoutput query="getChildren">

		<option value="#uploadcategoryid#|#uploadcategorytitle#"<cfif getChildren.uploadcategoryid eq pickID> selected</cfif>><cfloop from="1" to="#request.mycatcount#" index="iii">&nbsp;&nbsp;</cfloop><cfloop from="1" to="#request.mycatcount#" index="iii">-&nbsp;</cfloop>#uploadcategorytitle##variables.pick_selected_id#</option>
	

	<cfset newID = "getChildren." & #variables.item_id_col#>

	<!--- recursive call to traverse through table --->
	<cfmodule template="#Application.customtagpath#/categoryindent.cfm"
		id = "#Evaluate(newID)#"
		item_id_col = "#variables.item_id_col#"
		display_name_col = "#variables.display_name_col#"
		item_parent_id_col = "#variables.item_parent_id_col#"
		the_table = "#variables.the_table#"
		db = "#variables.DB#"
		order_by = "#variables.order_by#"
		pick_selected_id = "#variables.pick_selected_id#"
		>

	</cfoutput>
</cfif>
<cfset request.mycatcount=request.mycatcount-1>