// attach events
womAdd('attachBehaviors()');
womOn();
// attach behaviors to drive apps, modern browsers only invited
var isMoved = false;
function attachBehaviors(){
	if(!isMoved){
		// set add/update dialog initial position with wz_dragdrop.js script
		var catHolder = dd.elements.addEditCategoryHolder; 
		if(catHolder){
			catHolder.moveTo(100, 100);
		}
		isMoved = true;
	}
	if(document.getElementById){
		attachActivateCategory();
		attachSearch();
		attachFileSort();
		attachAddCategory();
		attachEditCategory();
		attachDeleteCategory();
		attachSelectFile();
		attachAddFile();
		attachEditFile();
		attachDeleteFile();
		attachViewLink();
		attachDetailPreviewShowHide();
		attachSearchShowHide();
		attachChangeViewType();
		attachOrdinalCategory();
		x_updateSessionHasJavascript('1', do_updateSessionHasJavascript_cb);
	}
}
// update the view for this category
function updateView(categoryId){
	x_buildCategoryList(categoryId, 0, 'start', do_getbuildCategoryList_cb);
	//x_buildCategoryList(0, do_getbuildCategoryList_cb);
	x_buildFileList(categoryId, do_getbuildFileList_cb);
	x_buildHeader(categoryId, do_getbuildHeader_cb);
	x_buildSearch(categoryId, do_getbuildSearch_cb);
}
function attachChangeViewType(){
	if(document.getElementById('catThumbViewButton')!=null){
		document.getElementById('catThumbViewButton').onclick=function(){
			x_updateSessionListStyle('thumbnails', do_updateSessionListStyle_cb);
			return false;
		};
	}else if(document.getElementById('catDetailViewButton')!=null){
		document.getElementById('catDetailViewButton').onclick=function(){
			x_updateSessionListStyle('details', do_updateSessionListStyle_cb);
			return false;
		};
	}
}
function do_updateSessionListStyle_cb(z){
	updateView(z);
}
// show a message, throbs and stays until dismissed when fade = false, fades out if fade = true
function showMessage(msg, fade){
	document.getElementById('messageData').innerHTML='<object type="application/x-shockwave-flash" data="#application.globalPath#/fileManager/swf/throbber.swf" height="79" width="109" style="vertical-align: middle; margin: 0;"><param name="wmode" value="transparent"><param name="movie" value="#application.globalPath#/fileManager/swf/throbber.swf"><param name="quality" value="high"></object>'+msg;
	document.getElementById('messageHolder').style.display='block';
	document.getElementById('messageHolder').style.top='150px';
	document.getElementById('messageHolder').style.left='200px';
	if(fade){
		opacity('messageHolder', 100, 0, 1000);
	}else{
		var object = document.getElementById('messageHolder').style;
		object.opacity=1;
		object.MozOpacity=1;
		object.KhtmlOpacity=1;
		object.filter="alpha(opacity=100)";
	}
}
//opacity scripts from http://www.brainerror.net/scripts_js_blendtrans.php
function opacity(id, opacStart, opacEnd, millisec) {
    //speed for each frame
    var speed = Math.round(millisec / 100);
    var timer = 0;

    //determine the direction for the blending, if start and end are the same nothing happens
    if(opacStart > opacEnd) {
        for(i = opacStart; i >= opacEnd; i--) {
            fadeloop=setTimeout("changeOpac(" + i + ",'" + id + "')",(timer * speed));
            timer++;
        }
    } else if(opacStart < opacEnd) {
        for(i = opacStart; i <= opacEnd; i++)
            {
            setTimeout("changeOpac(" + i + ",'" + id + "')",(timer * speed));
            timer++;
        }
    }
	else{
		document.getElementById(id).style.top='-1000px';
	}
}

//change the opacity for different browsers
function changeOpac(opacity, id) {
    var object = document.getElementById(id).style;
    object.opacity = (opacity / 100);
    object.MozOpacity = (opacity / 100);
    object.KhtmlOpacity = (opacity / 100);
    object.filter = "alpha(opacity=" + opacity + ")";
	if(opacity<=.1){
		clearTimeout(fadeloop);
		document.getElementById(id).style.top='-1000px';
	}
}
// attach search go functionality
function attachSearch(){
	if(document.getElementById('searchGoButton')!=null){
		document.getElementById('searchGoButton').onclick=searchFiles;
	}
}
// search files
function searchFiles(){
	if(document.getElementById('searchScopeCurrent').checked){
		var categoryId = document.getElementById('searchScopeCurrent').value;
	}else{
		var categoryId = document.getElementById('searchScopeAll').value;
	}
	var searchstring = document.getElementById('searchField').value;
	x_buildFileList(categoryId, searchstring, do_getbuildFileList_cb);
	return false;
}
// active category management
function attachActivateCategory(){
	if(document.getElementById('categoryholder')){
		var cats = document.getElementById('categoryholder').getElementsByTagName('ul')[0].getElementsByTagName('a');
		for(i in cats){
			if(cats[i].href != undefined && cats[i].href.indexOf('listuploadcategory=')!=-1){
				cats[i].onclick=activateCategory;
			}
		}
	}
}
function activateCategory(){
	var hrefSplit = new Array();
	var urlString = this.href.split('?')[1];
	if(urlString.indexOf('&') != -1){
		hrefSplit = urlString.split('&');
	}else{
		hrefSplit[0] = urlString;
	}
	
	var categoryId = 0;
	for(i=0 ; i<hrefSplit.length ;i++){
		if( (hrefSplit[i].split('=')[0].toLowerCase() == 'uploadcategoryid') || (hrefSplit[i].split('=')[0].toLowerCase() == 'listuploadcategory') ){
			categoryId = hrefSplit[i].split('=')[1];
		}
	}
	updateView(categoryId);
	return false;
}
// file sort management
function attachFileSort(){
	if(document.getElementById('fileholder')){
		var headers = document.getElementById('fileholder').getElementsByTagName('th');
		for(i in headers){
			if(headers[i] != undefined && headers[i].childNodes != undefined && headers[i].childNodes[0].href != undefined){
				headers[i].childNodes[0].onclick=fileSort;
			}
		}
	}
}
function fileSort(){
	var sortType = this.href.split('=')[3];
	var categoryId = this.href.split('?')[1].split('&')[0].split('=')[1];
	var searchstring = this.href.split('?')[1].split('&')[1].split('=')[1];
	//null searchstrings cause breakage - this will get filtered out
	if(searchstring==''){
		searchstring=',DESC';
	}
	x_buildFileList(categoryId, searchstring, sortType, do_getbuildFileList_cb);
	return false;
}
// handle response from updating cf hasjavascript var
function do_updateSessionHasJavascript_cb (z){
	return true;
}
// recieve buildCatgoryList callback
function do_getbuildCategoryList_cb(z) {
	document.getElementById('categoryholder').innerHTML=z;
	attachBehaviors();
}
// recieve buildFileList callback
function do_getbuildFileList_cb(z) {
	document.getElementById('fileholder').innerHTML=z;
	attachBehaviors();
}
// recieve buildFilePreview callback
function do_buildFilePreview_cb(z) {
	document.getElementById('addEditCategoryData').innerHTML=z;
	document.getElementById('addEditCategoryHolder').style.display='block';
}
// recieve buildHeader callback
function do_getbuildHeader_cb(z) {
	document.getElementById('filelistHeader').innerHTML=z;
	attachBehaviors();
}
// recieve buildSearch callback
function do_getbuildSearch_cb(z) {
	document.getElementById('searchHeader').innerHTML=z;
	attachBehaviors();
}
//add category
function attachAddCategory(){
	if(document.getElementById('addFolderButton')!=null){
	document.getElementById('addFolderButton').onclick=function (e){
		//document.getElementById('addEditCategoryHolder').innerHTML='loading...'; // older implementation
		x_addEditCategory(0, do_addeditCategory_cb);
		return false;
	}
	}
}
//ordinal category
function attachOrdinalCategory(){
	if(document.getElementById('catOrdinalButton')!=null && document.getElementById('catOrdinalButton').className.indexOf('disabled')==-1){
	document.getElementById('catOrdinalButton').onclick=function (e){
		var thisCategoryid = this.parentNode.href.split('=')[1];
		showMessage('Retrieving ordinal information...', false);
		x_buildOrdinalList(thisCategoryid, do_buildOrdinalList_cb);
		return false;
	}
	}
}
//edit category
function attachEditCategory(){
	if(document.getElementById('catEditButton')!=null && document.getElementById('catEditButton').className.indexOf('disabled')==-1){
	document.getElementById('catEditButton').onclick=function (e){
		var thisCategoryid = this.parentNode.href.split('=')[1];
		//document.getElementById('addEditCategoryHolder').innerHTML='loading...'; // older implementation
		showMessage('Retrieving category information...', false);
		x_addEditCategory(thisCategoryid, do_addeditCategory_cb);
		return false;
	}
	}
}
//delete category
function attachDeleteCategory(){
	if(document.getElementById('catDeleteButton')!=null && document.getElementById('catDeleteButton').className.indexOf('disabled')==-1){
		
		document.getElementById('catDeleteButton').onclick=function (e){
			//alert('att del');
			var thisCategoryid = this.parentNode.href.split('=')[1];
			var label = this.parentNode.parentNode.getElementsByTagName('h1')[0].innerHTML;
			if(confirm("Are you sure you want to delete "+label+"?")){
				x_deleteCategory(thisCategoryid, do_deleteCategory_cb);
			}
			return false;
		}
	}
}
// delete category callback
function do_deleteCategory_cb(z) {
	updateView(100000);
}
// recieve add/edit category callback
function do_addeditCategory_cb(z) {
	document.getElementById('addEditCategoryData').innerHTML=z;
	document.getElementById('addEditCategoryHolder').style.display='block';
	document.getElementById('catForm_uploadcategorytitle').focus();
	if (document.getElementById('catForm_uploadcategoryid').value != 0){ showMessage('Category load complete.', true);}
}
//submit new category
function submitAddCategory(){
	//Trap for required fields and/or improperly formatted data
	var isError = false;
	var errorMsg = "Please Correct the following errors:";
	//Title is required
	if(document.getElementById('catForm_uploadcategorytitle').value.length == 0){
		errorMsg = errorMsg + "\n- You must provide a name for this folder.";
		isError = true;
	}
	//Parent folder is required
	if(document.getElementById('catForm_parentid').value.length == 0){
		errorMsg = errorMsg + "\n- You must specify a parent folder.";
		isError = true;
	}
	//Folder name is required and must not contain spaces or special chars
	if(document.getElementById('catForm_foldername').value.length == 0 || document.getElementById('catForm_foldername').value.indexOf(" ") != -1 || document.getElementById('catForm_foldername').value.indexOf("/") != -1 || document.getElementById('catForm_foldername').value.indexOf("\\") != -1){
		errorMsg = errorMsg + "\n- You must specify a valid folder name free of spaces and special characters.";
		isError = true;
	}
	if(isError){
		alert(errorMsg);
	}else{
		showMessage('Adding category...', false);
		x_addCategory(document.getElementById('catForm_uploadcategorytitle').value, document.getElementById('catForm_uploadcategorydescription').value, document.getElementById('catForm_parentid').value, document.getElementById('catForm_foldername').value, do_addCategory_cb);
	}
	return false;
}
//submit updated category
function submitUpdateCategory(){
	showMessage('Updating category...', false);
	x_updateCategory(document.getElementById('catForm_uploadcategorytitle').value, document.getElementById('catForm_uploadcategorydescription').value, document.getElementById('catForm_parentid').value, document.getElementById('catForm_foldername').value, document.getElementById('catForm_uploadcategoryid').value, do_updateCategory_cb);
	return false;
}
function do_addCategory_cb(z){
	showMessage('Folder added.', true);
	updateView(z.split('_')[0]);
	document.getElementById('addEditCategoryHolder').style.display='none';

}
function do_updateCategory_cb(z){
	var categoryId=document.getElementById('catForm_uploadcategoryid').value;
	showMessage('Category updated.', true);
	updateView(categoryId);
	document.getElementById('addEditCategoryHolder').style.display='none';

}

// file management
//submit file form
function submitFile(){
	showMessage('Uploading file...', false);
	document.getElementById('addEditCategoryHolder').style.display='none';
	return true;
}
//add file
function attachAddFile(){
	if(document.getElementById('addFileButton')!=null){
		document.getElementById('addFileButton').onclick=function (e){
			x_addEditFile(0, do_addeditFile_cb);
			return false;
		}
	}
	if(document.getElementById('addImgButton')!=null){
		document.getElementById('addImgButton').onclick=function (e){
			x_addEditFile(0, do_addeditFile_cb);
			return false;
		}
	}
}

//edit file
function attachEditFile(){
	if(document.getElementById('fileholder')){
		var rows = document.getElementById('fileholder').getElementsByTagName('img');
		for(i in rows){
			if(rows[i] != undefined && rows[i].src != undefined && rows[i].src.indexOf('icon_editFile.gif')!=-1){
				rows[i].onclick=function(e){
					var uploadid=this.parentNode.parentNode.parentNode.id.split('_')[1];
					showMessage('Retrieving file information...', true);
					x_addEditFile(uploadid, do_addeditFile_cb);
					return false;
				};
			}
		}
	}
}
// recieve add/edit file callback
function do_addeditFile_cb(returnedHTML) {
	document.getElementById('addEditCategoryData').innerHTML=returnedHTML;
	document.getElementById('addEditCategoryHolder').style.display='block';
	document.getElementById('uploadtitle').focus();
}
//delete file
function attachDeleteFile(){
	if(document.getElementById('fileholder')){
		var imgs = document.getElementById('fileholder').getElementsByTagName('img');
		for(i in imgs){
			if(imgs[i] != undefined && imgs[i].src != undefined && imgs[i].src.indexOf('icon_deleteFile.gif')!=-1){
				imgs[i].onclick=function(e){
					var uploadid=this.parentNode.parentNode.parentNode.id.split('_')[1];
					var uploadlabel=getThisFileLabel(uploadid);
					deleteFile(uploadid,uploadlabel);
					return false;
				};
			}
		}
	}
}
function attachViewLink(){
	if(document.getElementById('fileholder')){
		var imgs = document.getElementById('fileholder').getElementsByTagName('img');
		var thisFileArray;
		var thisDirectoryName;
		var thisFileName;
		var thisFileExt;
		var thisFileSaveName;
		for(i in imgs){
			if(imgs[i] != undefined && imgs[i].src != undefined && imgs[i].src.indexOf('icon_link.gif')!=-1){
				imgs[i].onclick=function(e){
					document.getElementById('linkURL').value=this.name;
					document.getElementById('linkURLWeb').value="http://"+document.domain+this.name;
					
					//CMC Mod 7/27/06- friendlyDownload URL
					if(document.getElementById('friendlyURL')){
						thisFileArray = this.name.split("/");
						thisDirectoryName = thisFileArray[thisFileArray.length-2];
						thisFileName = thisFileArray[thisFileArray.length-1];
						thisFileExt = thisFileName.split(".")[1];
						thisFileSaveName = this.title.split("::")[1];
						//remove unfriendly characters
						thisFileSaveName = thisFileSaveName.replace(/ /g,"%20");
						thisFileSaveName = thisFileSaveName.replace(/&/g,"And");
						thisFileSaveName = thisFileSaveName.replace(/[.]/g,"");
						thisFileSaveName = thisFileSaveName.replace(/[?]/g,"");
						document.getElementById('friendlyURL').value = "/home/friendlyDownload.cfm?directory=" + thisDirectoryName + "&actualFile=" + thisFileName + "&saveName=" + thisFileSaveName + "." + thisFileExt;
					}
					
					document.getElementById('linkHolder').style.display='block';
					document.getElementById('linkHolder').style.top='150px';
					document.getElementById('linkHolder').style.left='200px';
					self.scrollTo(0,0);
					return false;
				};
			}
		}
	}
}
function getThisFileLabel(uploadid){
	var uploadlabel='This File';
	for(i=0;i<document.getElementById('fileupload_'+uploadid).childNodes.length;i++){
		if(document.getElementById('fileupload_'+uploadid).childNodes[i].className != undefined && document.getElementById('fileupload_'+uploadid).childNodes[i].className.indexOf('uploadtitle')!=-1){
			uploadlabel=document.getElementById('fileupload_'+uploadid).childNodes[i].innerHTML;
			var x=uploadlabel.lastIndexOf(">");
			if( x != -1) {
				uploadlabel=uploadlabel.substr(x);
			}
		}
	}
	return uploadlabel.replace(/^\s+/g, '').replace(/\s+$/g, '');
}
// calls SAJAX exported cfscript deleteFile() which calls CFC function deleteFileQuery
function deleteFile(uploadid,label){
	if(confirm("Are you sure you want to delete "+label+"?")){
		x_deleteFile(uploadid, do_deleteFile_cb);
	}
	return false;
}
// recieve buildFileList callback
function do_deleteFile_cb(z) {
	showMessage('File deleted.', true);
	updateView(z);
}
function attachSelectFile(){
	if(document.getElementById('parentWindow_callingfield')!=null){
		var rows = document.getElementById('fileholder').getElementsByTagName('img');
		for(i in rows){
			if(rows[i] != undefined && rows[i].src != undefined && rows[i].src.indexOf('icon_selectTarget.gif')!=-1){
				rows[i].style.display='inline';
				rows[i].onclick=function(){
					var uploadid=this.parentNode.parentNode.parentNode.id.split('_')[1];
					var uploadlabel=getThisFileLabel(uploadid);
					if(document.getElementById('parentWindow_callingfield').value=='FCKImageManager'){
						var linkList = this.parentNode.parentNode.parentNode.getElementsByTagName('a');
						var filename = "";
						for(j=0 ; j<linkList.length ; j++){
							if(linkList[j].href.indexOf('viewLink') > -1){
								filename = linkList[j].href;
							}
						}
						// Below will remove the http://mydomain.com from the image name so everything is absolute pathed.
						var splitHREF = filename.split("&");
						var splitName = "";
						for(i=0 ; i<splitHREF.length; i++){
							if(splitHREF[i].indexOf('viewLink') > -1){
								splitName = splitHREF[i].split("/");
							}
						}
						filename = "/" + splitName[1];
						
						for(i=2; i < splitName.length; i++){
							filename += "/" + splitName[i];
						}
						window.opener.document.getElementsByTagName('input')[1].value=filename;
						window.close();
					}else if(document.getElementById('parentWindow_caller').value=='CKEditor'){
						var linkList = this.parentNode.parentNode.parentNode.getElementsByTagName('a');
						var filename = "";
						var callerFunc = document.getElementById('parentWindow_callingFuncNum').value;
						for(j=0 ; j<linkList.length ; j++){
							if(linkList[j].href.indexOf('viewLink') > -1){
								filename = linkList[j].href;
							}
						}
						// Below will remove the http://mydomain.com from the image name so everything is absolute pathed.
						var splitHREF = filename.split("&");
						var splitName = "";
						for(i=0 ; i<splitHREF.length; i++){
							if(splitHREF[i].indexOf('viewLink') > -1){
								splitName = splitHREF[i].split("/");
							}
						}
						filename = "/" + splitName[1];
						
						for(i=2; i < splitName.length; i++){
							filename += "/" + splitName[i];
						}
						//alert('callerFunc:' + callerFunc + 'filename:' + filename);
						
						window.opener.CKEDITOR.tools.callFunction(callerFunc,filename);
						//window.opener.document.getElementsByTagName('input')[1].value=filename;
						window.close();
					}else{
						var targetSelect = eval('window.opener.document.'+document.getElementById("parentWindow_formname").value+'.'+document.getElementById("parentWindow_callingfield").value+'.options[0]');
						var targetDisplay = eval('window.opener.document.'+document.getElementById("parentWindow_formname").value+'.'+document.getElementById("parentWindow_callingfield").value+'_display');
						targetSelect.text=uploadlabel;
						targetSelect.value=uploadid+'~$'+uploadlabel;
						targetDisplay.value=uploadlabel;
						targetSelect.selected=true;
						window.close();
					}
					return false;
				}
			}
		}
	}
}

// detail preview
function attachDetailPreviewShowHide(){
	if(document.getElementById('fileholder')){
		var rows = document.getElementById('fileholder').getElementsByTagName('a');
		for(i in rows){
			if(rows[i] != undefined && rows[i].className != undefined && rows[i].className.indexOf('previewLink')!=-1){
				rows[i].onclick=function(){
					previewWindow=window.open(this.href,'previewWindow','width=400,height=400,resizable=yes');
					previewWindow.focus();
					return false;
				};
			}
		}
	}
}
// search show/hide
function attachSearchShowHide(){
	if(document.getElementById('searchGoButton')){
		// can not override this onclick as it is needed to do search
		/*document.getElementById('searchGoButton').onclick=function(){
			if(document.getElementById('searchHeader').style.display=='' || document.getElementById('searchHeader').style.display=='none'){
				document.getElementById('searchHeader').style.display='block';
			}else{
				document.getElementById('searchHeader').style.display='none';
			}
			return false;
		};*/
	}
}
// check file type and enable/disable thumbnail creation
function checkFileType(o) {
	fileType=o.value.substr(o.value.lastIndexOf(".")+1);
}
function myRefresh(evt){
//	evt = (evt) ? evt : ((window.event) ? window.event : null);
	//document.getElementById('uploadtitle').refresh();
//	var obj=document.getElementById('uploadtitle').createTextRange();
//alert(evt.keyCode);
//	switch(evt.keyCode){
//		case (39);
//			obj.move(char,1);
//			break;
//		case (37);
//			obj.move(char,-1);
//			break;
//	}
}
function doOrdinal(cat){
	x_buildOrdinalList(categoryId, do_buildOrdinalList_cb);
}
function do_buildOrdinalList_cb(z){
	showMessage('Retrieved', true);
	document.getElementById('fileholder').innerHTML = z;
}
function doOrdinalPost(list, cat){
	x_postOrdinal(list, cat, do_doOrdinalPost_cb);
}
function do_doOrdinalPost_cb(z){
	showMessage('Updated Ordinal', true);
	updateView(z);
}
//used for odinal functionality
function Field_up(lst)
{
	var i = lst.selectedIndex;
	if (i>0) Field_swap(lst,i,i-1);
}
function Field_down(lst)
{
	var i = lst.selectedIndex;
	if (i<lst.length-1) Field_swap(lst,i+1,i);
}
function Field_swap(lst,i,j)
{
	var t = '';
	t = lst.options[i].text; lst.options[i].text = lst.options[j].text; lst.options[j].text = t;
	t = lst.options[i].value; lst.options[i].value = lst.options[j].value; lst.options[j].value = t;
	t = lst.options[i].selected; lst.options[i].selected = lst.options[j].selected; lst.options[j].selected = t;
	t = lst.options[i].defaultSelected; lst.options[i].defaultSelected = lst.options[j].defaultSelected; lst.options[j].defaultSelected = t;
}
function SetFields(lst,cat)
{
	var t;
	lstSave='';
	for (t=0;t<=lst.length-1;t++)
		lstSave+=String(lst.options[t].value)+',';
	if (lstSave.length>0)
		lstSave=lstSave.slice(0,-1);
	showMessage('Updating Ordinal information...', false);
	doOrdinalPost(lstSave, cat)
}