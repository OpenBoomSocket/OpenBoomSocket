<cfinclude template="i_validate.cfm">
<cfif NOT request.isError>
<cfoutput>
<script language="JavaScript">
	function complete(){
		window.opener.location.reload();
		self.close();
	}
	complete();
</script>
</cfoutput>
		<cfquery datasource="#application.datasource#" name="q_getTableDef" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT tabledefinition
			FROM formobject
			WHERE formobjectid = #form.formobjectid#
		</cfquery>
		<cftry>
		<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="XML2CFML"
		input="#q_gettabledef.tabledefinition#"
		output="a_tableelements">
		<cfcatch type="Any">
			<h1>Invalid XML Object</h1>The object you are trying to reference is not recognizable XML. Check the database.
			<cfdump var="#a_tableelements#">
			<cfabort>
		</cfcatch>		
		</cftry>
		
<!--- Update XML cell props blob--->
<cfscript>
	"row_#thisrow#"=structNew();
	"row_#thisrow#"=a_tableelements[thisrow];
	"cell_#thiscell#"=structNew();
	"cell_#thiscell#.colspan"=form.colspan;
	"cell_#thiscell#.rowspan"=form.rowspan;
	"cell_#thiscell#.width"=form.width;
	"cell_#thiscell#.valign"=form.valign;
	"cell_#thiscell#.align"=form.align;
	"cell_#thiscell#.class"=form.class;
	if (isDefined("form.nowrap")) {
		"cell_#thiscell#.nowrap"=form.nowrap;
		} else { 
		"cell_#thiscell#.nowrap"=0;
		}
	"row_#thisrow#.cell_#thiscell#"=evaluate("cell_#thiscell#");
	a_tableelements[#thisrow#]=evaluate("row_#thisrow#");
</cfscript> 

<!--- WDDX XML blob --->
		<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="CFML2XML"
		input="#a_tableelements#"
		output="form.tabledefinition">

<!--- INSERT updated blob --->
		<cfmodule template="#application.customTagPath#/dbaction.cfm" 
				action="UPDATE" 
				tablename="formobject"
				datasource="#application.datasource#"
				whereclause="formobjectid=#trim(form.formobjectid)#"
				assignidfield="formobjectid">

<!--- Relocate to parent window and close this one --->
<cfelse>	
	<cfinclude template="i_cellproperties.cfm">
</cfif>
