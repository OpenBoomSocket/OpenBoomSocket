<cfoutput>
	<cfif isDefined("application.wysiwyg")>
		<cfswitch expression="#application.wysiwyg#" >
			<cfcase value="fckeditor">
				<cfscript>
					fckEditor = createObject("component", "#application.globalPath#/fckeditor/#application.fckVersion#/fckeditor");								
					fckEditor.basePath		= "#application.globalPath#/fckeditor/#application.fckVersion#/";
					fckEditor.instanceName	= "#a_formelements[a].fieldname#";
					fckEditor.value			= "#evaluate('form.#a_formelements[a].fieldname#')#";
					fckEditor.width			= "#a_formelements[a].width#";
					fckEditor.height		= "#a_formelements[a].height#";
					fckEditor.toolbarSet	= "Basic";
					fckEditor.create(); // create the editor.
				</cfscript>
			</cfcase>
			
			<cfcase value="ckeditor">
				<cf_ckeditor
					id="#a_formelements[a].fieldname#"
					value="#evaluate('form.#a_formelements[a].fieldname#')#" 
					CKEditorToolbar="basic" />
			</cfcase>
		</cfswitch>
	</cfif>
	<cfset request.useActiveEdit=1>
</cfoutput>