<cfsilent>
<!--- 
**i3SiteTools File Chooser Script ** 
Version: 0.1
Authors: Ben Wakeman, George McLin 
Date: July 31, 2002
Purpose: This custom tag works in conjuction with the file upload tool.  
It creates a select box / upload tool button, taking the category you want 
to start in, and the fieldname you want to use in the form for that file.
Revision History***********
3/5/2009 BDW Mods: Added Javascript to allow users to preview images
 --->
</cfsilent>
<cfif thisTag.executionmode EQ "start">
	<cfsilent>
	<cfif NOT isDefined("attributes.categoryid")>
        <b>ERROR! You must specify a CATEGORYID to use this custom tag!</b>
    <cfelseif attributes.categoryid eq "">
        <b>ERROR! You must specify a value for CATEGORYID to use this custom tag!</b>
    </cfif>
    <cfif NOT isDefined("attributes.fieldname")>
        <b>ERROR! You must specify a FIELDNAME to use this custom tag!</b>
    <cfelseif attributes.fieldname eq "">
        <b>ERROR! You must specify a value for FIELDNAME to use this custom tag!</b>
    </cfif>
    <cfparam name="attributes.buttonlabel" default="Get File">
    <cfparam name="attributes.formname" default="adminform">
    <cfparam name="attributes.tabindex" default="">
    <cfset fieldValue=listfirst(evaluate('form.'&attributes.fieldname),'~')>
    <cfset imgTypes = "jpg,gif,png">
    
<!--- Query for files by id --->
    <cfquery datasource="#application.datasource#" name="q_getuploads" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
        SELECT upload.uploadid, upload.uploadtitle, upload.uploaddescription, upload.active, upload.filename, upload.datemodified, upload.filetype, upload.ordinal, uploadcategory.uploadcategoryid, '/uploads/' + uploadcategory.foldername + '/' + upload.filename AS filepath
        FROM upload INNER JOIN uploadcategory ON upload.uploadcategoryid = uploadcategory.uploadcategoryid
        WHERE upload.uploadcategoryid=#attributes.categoryid#
        ORDER BY upload.uploadtitle ASC
    </cfquery>
    
    <cfif isNumeric(fieldValue) AND NOT ListFind(ValueList(q_getuploads.uploadid),fieldValue)>
        <cfset CurrentFile = application.getUpload(fieldValue)>
    </cfif>
 	<!--- Determine whether or not this category of uploads uses images --->
    <cfset hasImages = 0>
    <cfloop query="q_getuploads">
    	<cfif listFindNoCase(imgTypes, q_getuploads.filetype)>
			<cfset hasImages = 1>
            <cfbreak>
		</cfif>
    </cfloop>
    <cfif hasImages>
		<!--- Set up Javascript to manage preview of images --->
        <cfparam name="REQUEST.showImagePreviewExists" default="false">
        <cfsavecontent variable="js">
            <cfoutput>
                <!--- Build javascript array to hold image paths --->
                <script type="text/javascript">
                    #attributes.fieldname#_array = new Array();
                    <cfloop query="q_getuploads">
                        var imageObj = {uid: '#q_getuploads.uploadid#', path:'#q_getuploads.filepath#'};
                        #attributes.fieldname#_array[#evaluate(q_getuploads.currentrow - 1)#] = imageObj;
                    </cfloop>
                    <cfif NOT REQUEST.showImagePreviewExists>
                        function showImagePreview(fieldObj)
                        {
                            var uploadId = fieldObj.options[fieldObj.selectedIndex].id.split('~')[0];
                            var lookupArray = eval(fieldObj.id + '_array');
                            
                            for(var i=0; i < lookupArray.length; i++)
                            {
							   	var field = fieldObj.id + '_preview';
							    //Find this uploadId from the appropriate image folder array and set the preview
                                if(lookupArray[i].uid == uploadId)
                                {
                                    document.getElementById(field).src = lookupArray[i].path;
									document.getElementById(field).style.cursor = "pointer";
                                    document.getElementById(field).width = 85;
                                    document.getElementById(field).style.border = '1px solid ##000000';
                                    document.getElementById(field).style.display = 'inline';
									break;
                                }
								else if(uploadId == 'emptyField')
								{
									document.getElementById(field).style.display = "none";
									break;
								}
                            }
                        }
                        
                        function hidePreview(fieldObj)
                        {
                            var field = fieldObj.id + '_preview';
                        }
                        
                        function enlargePicture(imgObj)
                        {
                            window.open(imgObj.src, "imgPreview", "width=500, height=500");
                        }
                        
                        <cfset REQUEST.showImagePreviewExists = true>
                    </cfif>
                </script>
            </cfoutput>
        </cfsavecontent>
        <cfhtmlhead text="#js#">
    </cfif>
   </cfsilent>
	<!--- Populate select dynamically from above query --->
	<cfoutput>
	<select name="#attributes.fieldname#" id="#attributes.fieldname#" tabindex="#attributes.tabindex#" <cfif hasImages>onchange="showImagePreview(this)" onblur="hidePreview(this)"</cfif>>
		<option value="" id="emptyField"><cfif isDefined("#attributes.fieldname#_display") AND evaluate('#attributes.fieldname#_display') NEQ''>#evaluate(attributes.fieldname&'_display')#<cfelse>Choose File or Upload New >>></cfif></option>
		<cfloop query="q_getuploads">
			<option value="#q_getuploads.uploadid#~#q_getuploads.uploadtitle#" id="#q_getuploads.uploadid#~#q_getuploads.uploadtitle#"<cfif q_getuploads.uploadid eq fieldValue> selected</cfif>>#q_getuploads.uploadtitle#</option>
		</cfloop>
		<cfif isDefined('CurrentFile') AND isNumeric(CurrentFile.uploadid)>
			
			<option value="#CurrentFile.uploadid#~#CurrentFile.uploadtitle#" id="#CurrentFile.uploadid#~#CurrentFile.uploadtitle#" selected>#CurrentFile.uploadtitle#</option>
		</cfif>
	</select><!--- Launch image upload tool!  --->
		<input type=button value="#attributes.buttonlabel#" id="#attributes.buttonlabel#" onclick="javascript:window.open('/admintools/index.cfm?fileform=fileform&thiscategoryid=#attributes.categoryid#&listuploadcategory=#attributes.categoryid#&callingfield=#attributes.fieldname#&formname=#attributes.formname#&newfile=true','uploadwin','toolbar=0,scrollbars=1,location=0,statusbar=0,menubar=1,resizable=1,width=720,height=400');" class="submitbutton" style="width:100;" tabindex="#attributes.tabindex#">
	<input type="Hidden" name="#attributes.fieldname#_display" id="#attributes.fieldname#_display" value="">
    <cfif hasImages>
    <img id="#attributes.fieldname#_preview" src="" onclick="enlargePicture(this);" title="Click to Enlarge." />
    <script type="text/javascript">showImagePreview(document.getElementById('#attributes.fieldname#'));</script>
    </cfif>
	</cfoutput>
</cfif>