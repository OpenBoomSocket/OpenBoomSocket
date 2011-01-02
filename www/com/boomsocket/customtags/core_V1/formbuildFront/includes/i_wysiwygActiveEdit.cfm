<cfoutput>
<cfif isDefined("application.wysiwyg") AND application.wysiwyg EQ "fckeditor">
	<cfscript>
		fckEditor = createObject("component", "#application.globalPath#/fckeditor/#application.fckVersion#/fckeditor");								
		fckEditor.basePath		= "#application.globalPath#/fckeditor/#application.fckVersion#/";
		fckEditor.instanceName	= "#a_formelements[a].fieldname#";
		fckEditor.value			= "#evaluate('form.#a_formelements[a].fieldname#')#";
		fckEditor.width			= "#a_formelements[a].width#";
		fckEditor.height		= "#a_formelements[a].height#";
		fckEditor.toolbarSet	= "Default";
		fckEditor.create(); // create the editor.
	</cfscript>
</cfif>
<cfset request.useActiveEdit=1>
</cfoutput>