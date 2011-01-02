<!--------------------------------------------------------------------------------------!>
	EDIT HISTORY ::::::::::::: 
									:: 08.10.2010 Initial Creation EOM (Emile Melbourne)
	FILENAME ::::::::::::::::: ckeditor.cfm
	DEPENDANCIES ::::::::::::: 
	DESCRIPTION :::::::::::::: Custom tag for CKEditor.<br>
											http://ckeditor.com/
<---------------------------------------------------------------------------------------->
<cfparam name="ATTRIBUTES.id" 							type="string" >
<cfparam name="ATTRIBUTES.cols" 							type="integer" 	default="45" >
<cfparam name="ATTRIBUTES.rows" 							type="integer" 	default="10" >
<cfparam name="ATTRIBUTES.useCKeditor" 				type="boolean" 	default="true" >
<cfparam name="ATTRIBUTES.CKEditorToolbar" 			type="regex" 		default="standard" 	pattern="standard|basic|simple|none|custom" >
<cfparam name="ATTRIBUTES.CKEditorToolbarOptions" 	type="string" 		default="" 	 >
<cfparam name="ATTRIBUTES.value"							type="string" 		default="" >

<cfswitch expression=#thisTag.ExecutionMode#>
   <cfcase value= 'start'>
		<cfoutput>
			<div class="formSpryTextArea" id="#ATTRIBUTES.id#TextArea">
				<cfif ATTRIBUTES.value EQ "" AND structKeyExists(FORM, '#ATTRIBUTES.id#')>
					<cfset ATTRIBUTES.value = Evaluate('FORM.' & ATTRIBUTES.id)>
				</cfif>
				
				<textarea name="#ATTRIBUTES.id#" cols="#ATTRIBUTES.cols#" rows="#ATTRIBUTES.rows#" >#ATTRIBUTES.value#</textarea>						
				
				<cfif ATTRIBUTES.useCKeditor>
					<cfset filenames = ArrayNew(1)>
					
					<cfif isDefined('APPLICATION.globalPath') AND Trim(APPLICATION.globalPath) NEQ ''>
						<cfset filenames[1] = APPLICATION.globalPath & "/ckeditor/3_3_2/ckeditor.js" >
					<cfelse>
						<cfset filenames[1] = "/i3Global/CKEditor/3_3_2/ckeditor.js" >
					</cfif>
					
					<cfmodule template="#APPLICATION.customTagPath#/headerLink.cfm" files="#ArrayToList(filenames)#" />
		
					<script type="text/javascript">
						<cfswitch expression="#ATTRIBUTES.CKEditorToolbar#">
							<cfcase value="full">
								CKEDITOR.replace( '#ATTRIBUTES.id#' );
							</cfcase>
							<cfcase value="standard">
								CKEDITOR.replace( '#ATTRIBUTES.id#' , {
									toolbar : [ 
										['Source', '-', 'Bold', 'Italic', 'Underline', '-', 'subscript', 'subscript', '-', 'JustifyLeft','JustifyCenter',
											'JustifyRight','JustifyBlock', '-','RemoveFormat','Strike','Subscript','Superscript', 
											'-', 'NumberedList', 'BulletedList','-','Outdent','Indent',
											'-', 'Link','Unlink','Anchor',
											'-', 'Find','Replace'],['TextColor','BGColor','Styles'],
											'/', ['Undo','Redo','Cut','Copy','Paste','PasteText','PasteFromWord','Table','SpecialChar'],['ImageButton']
									],
									filebrowserBrowseUrl : '/admintools/index.cfm?fileform=fileform&thiscategoryid=100000',
									//filebrowserUploadUrl : '/admintools/index.cfm?fileform=fileform&thiscategoryid=100000',
									filebrowserWindowWidth  : 800,
									filebrowserWindowHeight : 500
								});
							</cfcase>
							<cfcase value="basic">
								CKEDITOR.replace( '#ATTRIBUTES.id#' , {
									toolbar:[
										['Source', '-', 'Bold', 'Italic', 'Underline', '-', 'subscript', 'subscript',
										'-','RemoveFormat','Strike','Subscript','Superscript', 
										'-', 'NumberedList', 'BulletedList','-','Outdent','Indent',
										'-', 'Link','Unlink','Anchor'
										'-', 'Find','Replace'],
										'/', ['Undo','Redo','Cut','Copy','Paste','PasteText','PasteFromWord','Table']
									]
								});
							</cfcase>
							<cfcase value="simple">
								CKEDITOR.replace( '#ATTRIBUTES.id#' , {
									toolbar : [ 
										['Source', '-', 'Bold', 'Italic', 'Underline', '-', 'subscript', 'subscript', '-', 'JustifyLeft','JustifyCenter',
											'JustifyRight','JustifyBlock', '-','RemoveFormat','Strike','Subscript','Superscript', 
											'-', 'NumberedList', 'BulletedList','-','Outdent','Indent',
											'-', 'Link','Unlink','Anchor',
											'-', 'Find','Replace'],['TextColor','BGColor','Styles'],
											'/', ['Undo','Redo','Cut','Copy','Paste','PasteText','PasteFromWord','Table','SpecialChar'],['ImageButton']
									],
									filebrowserBrowseUrl : '/admintools/index.cfm?fileform=fileform&thiscategoryid=100000',
									//filebrowserUploadUrl : '/admintools/index.cfm?fileform=fileform&thiscategoryid=100000',
									filebrowserWindowWidth  : 800,
									filebrowserWindowHeight : 500
								});
							</cfcase>
							<cfcase value="custom">
								CKEDITOR.replace( '#ATTRIBUTES.id#' , {toolbar : [#ATTRIBUTES.CKEditorToolbarOptions#]});
							</cfcase>
							<cfdefaultcase>
								CKEDITOR.replace( '#ATTRIBUTES.id#' , {toolbar : [ ]} );
							</cfdefaultcase>
						</cfswitch>
					</script>
				</cfif>
			</div>
		</cfoutput>
	</cfcase>
   <cfcase value='end'>
   </cfcase>
</cfswitch>