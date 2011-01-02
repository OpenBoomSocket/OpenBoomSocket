<!--- <cfsetting showdebugoutput="no">
<cfcontent type="text/css" reset="yes"> --->
/*code container*/
#fmContainer{
	width: 100%;
}
/*Category Listing*/
#categoryholder{
	float: left;
	width: 30%;
}
#categoryholder ul{
	list-style: none;
	margin:0;
	padding-left:1em;
}
#categoryholder li.current a:link, #categoryholder li.current a:visited, #categoryholder li.current a:hover, #categoryholder li.current a:active{
	background-image: url('<cfoutput>#application.globalPath#</cfoutput>/media/images/tree_openCurrent.gif');
	font-weight:bold;
	color:#EFA93B;
}
#categoryholder li.parent a:link, #categoryholder li.parent a:visited, #categoryholder li.parent a:hover, #categoryholder li.parent a:active{
	background-image: url('<cfoutput>#application.globalPath#</cfoutput>/media/images/tree_openMinus.gif');
}
#categoryholder li a:link, #categoryholder li a:visited, #categoryholder li a:hover, #categoryholder li a:active{
	display: block;
	height: 20px;
	padding-left: 30px;
	background-image: url('<cfoutput>#application.globalPath#</cfoutput>/media/images/tree_closedPlus.gif');
	background-repeat: no-repeat;
}
/*File Listing*/
#fileholder{
	float: left;
	width: 70%;
}

#fileholder table{
	clear: both;
	width: 98%;
}
#fileholder table th{
	background-color: #0E3B6B;
}
#fileholder table th a{
	color: #ffffff;;
}
/*header bars*/

#buttonSearchWrapper{
	background-color: #eff2f6;
	height:35px;
}
#buttonbar{
	background-color: #eff2f6;
	height:25px;
	padding:5px;	
	clear:both;
	width:225px;
	float:left;
	margin-top:-3px;
}
<cfif FindNoCase('Macintosh',application.osDetect())>
	#buttonbar{
		margin-top:0;
	}
</cfif>
.disabled{
	opacity:.5;
}
/*search header*/
#searchHeader{
	background-color: #eff2f6;
	height:25px;
	padding:5px;	
	width:450px;
	float:right;
	margin-top:-3px;
}
<cfif FindNoCase('Macintosh',application.osDetect())>
	#searchHeader{
		width:465px;
		margin-top:0;
	}
	<cfif FindNoCase('Firefox',application.browserDetect()) OR FindNoCase('Firefox',application.browserDetect())>
		#searchHeader{
			width:500px;			
		}
	</cfif>
</cfif>
#searchFields{
	margin-left:5px;
}
#searchGoButton{
	margin-left:5px;
	margin-top:-2px;
}
/*list header*/
#filelistHeader{
	width: 100%;
	background-color: #eff2f6;
}
#filelistHeader div img{
	float: left;
	margin-left: 2px;
	z-index:-10;
}
/*restyle tooltables*/
.toolTable th{
	BACKGROUND-COLOR: #ccc;
	COLOR: black;
	FONT-SIZE: 11px;
	PADDING: 5px;
	VERTICAL-ALIGN: top;
	font-weight: bold;
}
.toolTable td{
	BACKGROUND-COLOR: #dadada;
	COLOR: black;
	FONT-SIZE: 11px;
	PADDING: 5px;
	VERTICAL-ALIGN: top;
}
/*window styling*/
.windowTop{
	background-image: url('<cfoutput>#application.globalPath#</cfoutput>/media/images/popup_hdrTile.gif');
	background-repeat: repeat-x;
	height: 24px;
	padding: 5px 5px 0 5px;
	margin: 0;
	margin-top:-1px;
	overflow: auto;
}
* html .windowTop{
	background-image: url('<cfoutput>#application.globalPath#</cfoutput>/media/images/popup_hdrTile.gif');
	background-repeat: repeat-x;
	height: 29px;
	padding-top: 5px;
	margin: 0;
	overflow: auto;
}
.windowTop h2{
	float: left;
	margin: 0;
	padding: 0;
	color: #fff;
	font-size: 14px;
}
.windowCloser{
	float: right;
	display: block;
}
/*dynamic category form*/
#addEditCategoryHolder{
	z-index: 5;
	display: none;
}
#addEditCategoryHolder table{
	margin: 2px 8px;
}

#addEditCategoryHolder label{
	width: 130px;
	float: left;
}
#addEditCategoryHolder input, #addEditCategoryHolder select, #addEditCategoryHolder textarea{
	/*CMC 1/30/06: invalid css
	clear: bottom;*/
	z-index: 3;
}
#addEditCategoryData{
	background-color: #EFF2F6;
}

/*messaging area*/
#messageData{
}
#messageHolder{
	display: none;
	opacity: 1;
	z-index: 10;
}
#linkHolder{
	z-index: 100;
	border: 1px solid #000000;
	margin: 10px;
	padding: 10px;
	background-color: #FFFFFF;
}
/*file submit frame*/
.targetFrame{
	width:1px;
	height:1px;
	border:0;
	background-color:E6E6E6;
}
/* Insert the custom corners and borders for browsers with sufficient JavaScript support */

/* Rules for the top corners and border */
.bt {
	background:url('<cfoutput>#application.globalPath#</cfoutput>/media/images/popupbox.png') no-repeat 100% 0;
	margin:0 0 0 2px;
	height:2px;
	}
.bt div {
	height:2px;
	width:2px;
	position:relative;
	left:-2px;
	background-color: #f00;
	background:url('<cfoutput>#application.globalPath#</cfoutput>/media/images/popupbox.png') no-repeat 0 0;
	font-size: 1px;
	}

/* Rules for the bottom corners and border */
.bb {
	background:url('<cfoutput>#application.globalPath#</cfoutput>/media/images/popupbox.png') no-repeat 100% 100%;
	margin:0 0 0 10px;
	height:11px;
	}
.bb div {
	height:11px;
	width:10px;
	position:relative;
	left:-10px;
	background:url('<cfoutput>#application.globalPath#</cfoutput>/media/images/popupbox.png') no-repeat 0 100%;
	}

/* Insert the left border */
.i1 {
	padding:0 0 0 2px;
	background:url('<cfoutput>#application.globalPath#</cfoutput>/media/images/popupborder.png') repeat-y 0 0;
	}
/* Insert the right border */
.i2 {
	padding:0 10px 0 0;
	background:url('<cfoutput>#application.globalPath#</cfoutput>/media/images/popupborder.png') repeat-y 100% 0;
	}
/* Wrapper for the content. Use it to set the background colour and insert some padding between the borders and the content. */
.i3 {
	background:#fff;
	border:1px solid #fff;
	border-width:1px 0;
	padding:0;
	}
#previous20list a, #next20list a{
	color: #cc0000;
	font-weight: bold;
	display: block;
	padding: 4px;
}
#previous20list a:hover, #next20list a:hover{
	text-decoration: none;
	background-color: #DFEEFF;
}