<!--- list of fields to populate cellproperties style dropdown (formbuilder) --->
<!-- {formitemlabel,formitemlabelreq,formiteminput,formitemcheckbox,subtoolheader} -->

/* png fix */
/*img, div { behavior: url(/css/iepngfix.htc) }*/


/* admintoolsCSS */

body{
	margin:0;
	padding:0;
	background-color:#336699;
	background-image:url(/admintools/media/images/topBlueGradBG.png);
	background-repeat:repeat-x;
	background-position:top;
	font-family:"Trebuchet MS", Arial, Verdana;
	font-size: 11px;
	color: #666666;
}
a {
	color: #11518F;
	text-decoration: none;
}
a:hover {
	color: #45729F;
	text-decoration: underline;
}
h1 {
	font-size : 22px;
}
h2 {
	font-size : 17px;
}
h3 {
	font-size : 14px;
}
/* Template Shell */
#mainShell{
	width: 950px;
	margin: 0 auto;
	background-image:url(/admintools/media/images/mainShellBG.gif);
	background-repeat:repeat-y;
	min-height: 400px;
}
#header{
	background-image:url(/admintools/media/images/headerBG.jpg);
	background-repeat:no-repeat;
	background-position:top;
	height:91px;
	text-align: right;
}
#textNav{
	/*position:absolute;
	top:3px;
	margin:0 auto;
	width:935px;*/
	text-align:right;
	color:#fff;
	border:0px solid #009900;
	margin-right:10px;
}
#textNav a, 
#textNav a:link, 
#textNav a:visited, 
#textNav a:hover, 
#textNav a:active{
	color:#fff;
}
#topNavBar{
	/*height: 41px;*/
	height:67px;
	margin-top: -16px; /* top nav floats over header bg */
	#margin-top: -20px; /* IE fix */
}
#nonNavItems{
	float:left;
	margin-top:-20px;
}
#contentArea{
	margin: 28px 4px 0 4px;
	border-bottom:1px solid #fff; /* safari fix- to prevent gap btwn content & footer */
}
#logo{
	margin-right: 15px;
}
<cfif FindNoCase('Macintosh',application.osDetect()) AND (FindNoCase('Firefox',application.browserDetect()) OR FindNoCase('Safari',application.browserDetect()) OR FindNoCase('Camino',application.browserDetect()))>
	#logo{
		margin-bottom:4px;
	}
</cfif>
#footer{
	width: 950px;
	margin: 0 auto;
	background-image:url(/admintools/media/images/footerBG.png);
	background-repeat:no-repeat;
	height: 33px;
	text-align:center;
	font-size: 10px;
	color: #336699;
	padding: 8px 0;
}
/* Admin Dashboard Page Styles */
#dashboardPageShell{
	margin: 20px 0 0 15px;
	padding-bottom: 20px;
}
#dashboardPageShell h1{
	font-size: 25px;
}
#userInfoBox{
	height: 25px;
	margin: 1px;
	background-color: #F8AD37;
	border-color: #a46603;
	border-style: solid;
	border-width: 1px;
	color: #093160;
}
#adminDateLine{
	float: right;
	margin: 5px;
}
#adminUserData{
	float: left;
	margin: 5px;
}
#dashboardIntroText{
	margin: 0px 30px 15px 30px;
	font-size: 12px;
	font-style: italic;
}
#dashboardPageLeft{
	width: 591px;
	margin-right: 15px;
	float: left;
}

#dashboardPageLeft h3{
	margin-bottom:5px;
	border-bottom:solid 1px #dadada;
}

#dashboardPageRight{
	width: 320px;
	margin: 1px 1px 0 0;
	min-height: 200px;
	float: left;
}
.dashboardSidebarHdr{
	background-color: #ccdff4;
	border: 1px solid #093160;
	height: 25px;
	margin: 1px;
	padding-left: 5px;
	padding-right: 5px;
	color: #093160;
}

.dashboardSidebarHdrLeft{
	float:left;
	font-size: 16px;
}


.dashboardSidebarHdrRight{
	float:right;
	font-size:12pts;
	margin-top:3px;
	
}

.dashboardSidebarHdrRight a{
	text-decoration:none;
}

.dashboardSidebarHdrRight a b{
	float:left;
}

.viewAllArrow{
	margin-top:2px;
	float:left;
}

.viewAllArrow img{
	border:none;
	margin-left:5px;
}


.dashboardSidebarBlock{
	padding: 4px 8px;
}
#socketLauncherContainer{
	margin-left: 50px;
}
.socketLauncherPod{
	width: 450px;
	padding-right: 20px;
}
.socketLauncherPod h3{
	background-image: url(<cfoutput>#application.globalPath#</cfoutput>/media/images/icon_socketBlueBullet.gif);
	background-position: left;
	background-repeat:no-repeat;
	padding-left: 25px;
	color: #0E3C6C;
	margin-bottom: 4px;
}
.socketDescription{
	margin: 0 0 8px 25px;

}
.socketLauncherButtonBar{
	text-align: right;
}
.socketLauncherButtonBar img{
	margin-right: 1px;
}

/* Pop up template definitions */
#popupcontent{
	background-color: #ffffff;
	margin: 10px;
	padding: 10px;
	border: 2px solid #F8AD37;
	
}

/* Login Page*/
#loginBox{
	background-image:url(/admintools/media/images/loginboxBG.png);
	background-repeat:no-repeat;
	width: 559px;
	height: 280px;
	margin: 80px auto;
}
#loginDisclaimerTable{
	float:left;
	margin-top: 85px;
	margin-left: 35px;
	width: 230px;
	text-align:left;
}
#platformList{
	list-style-type:none; 
	margin: 15px 0;
	padding:0 0 0 14px;
}
#loginFormTable{
	float:left;
	margin-top: 85px;
	margin-left: 90px;
	width: 185px;
}
#passwordForm{
	float:left;
	margin-top: 85px;
	margin-left: 90px;
	width: 320px;
}
* html #loginFormTable{
	margin-left:50px;
}
#loginInfoButton{
	position:relative;
	top: -15px;
	#top: -5px; /* IE6 & IE7 */
	left: 520px;
	clear:both;
}
#loginInfoBox{
	position:relative;
	top: 28px;
	left: 200px;	
	width: 500px;
	color: #ffffff;
}
#forgotPasswordLink{
	float:left;
	margin-top:15px;
}

#loginErrorText{
	position:relative;
	top: 75px;
	left: 94px;
	color: #cc0000;
}
/* Form Styles */
#socketformheader{
	background-color: #F8AD37;
	width: 100%;
	height: 30px;
}
#socketformheader h2{
	display: inline;
	float: left;
	margin: 5px 5px 5px 15px;
	color: #ffffff;
}
#socketformheader h3{
	display: inline;
	float: left;
	margin: 8px 5px 5px 5px;
	color: #ffffff;
}
div.columnheaderrow, .columnheaderrow td{
	background-color: #0E3C6C;
	height: 22px;
	padding-left: 4px;
}
div.columnheaderrow, .columnheaderrow td, .columnheaderrow td .formiteminput, .columnheaderrow td a{
	color:#FFFFFF;
}
div.columnheaderrow a, .columnheaderrow td a{
	text-decoration: none;
}
.categoryrowheader{
	background-color: #F8AD37;
	color: #0E3C6C;
}
.oddrow{
	background-color:#EFF6FF;
}
.evenrow{
	background-color:#DFEEFF;
}
.oddrow:hover,.evenrow:hover{
	background-color:#BFDEFF;
}
.deleteRow{
	text-align:center;
	width:40px;
	background-color: #0E3C6C;
}
#socketindextable{
	width: 98%;
	margin: 0px 15px;
}
#socketindextable td{
	padding: 4px;

}
.toolConfirmLabel{
	font-weight: bold;
	font-size: 11px;
	border-bottom: 1px solid #dadada;
}
.toolConfirmData{
	font-size: 11px;
	border-bottom: 1px solid #dadada;
}
#returnToIndex {
	display: inline;
	float: right;
	height: 29px;
}
#returnToIndex a {
	text-decoration:none;
	color: #00274F;
	padding: 6px 15px;
	display:block;
	font-size: 12px;
	font-weight: bold;	
}
#returnToIndex a:hover {
	background-color: #FFCD7F;
}
#socketformtable{
	margin-left: 15px;
	width: 98%;
}
.toolheader{
	background-color: #F8AD37;
	font-size: 18px;
	font-weight: bold;
	color: #ffffff;
	padding-left: 10px;
}
#buttonbar{
	background-color:#EFF2F6;
	padding: 4px;
	text-align: right;	
}
#leftBtns img{
	margin:0 -1px;
}
.subtoolheader{
	background-color:#EFF2F6;
	padding: 4px;
	font-size: 13px;
	border-style:solid;
	border-color:#B5C7DF;
	border-width: 0 0 1px 1px;
	color: #0E3C6C;
}
.formiteminput {
	padding: 4px 8px;
}
.formitemlabel, .formitemlabelreq {
	padding: 4px;
	color: #777777;
	border-color: #dadada;
	border-width: 0 1px 0 0;
	border-style: solid;
	text-align:right;
	vertical-align: top;
}
.formitemlabelreq {
	color: #000000;
}
.formitemcheckbox {
	padding-bottom : 5px;
	padding-left : 5px;
	padding-right : 5px;
	padding-top : 5px;
	font-family : Arial, Helvetica, sans-serif;
	font-size : 10px;
	COLOR: #000000;
	vertical-align : top;
	background-color : #dadada;
}
.submitbutton{
	background-color: #07447F;
	color: white;
	font-family:"Trebuchet MS",Helvetica,Verdana;
	font-size: 10px;
	border: 1px solid #000033;
	padding: 1px 4px;
	margin-left: 5px;
	cursor:pointer;
}

.largeSubmitbutton{
	background-color: #336699;
	color: white;
	font-family:"Trebuchet MS",Helvetica,Verdana;
	font-size: 10px;
	border: 1px solid #000033;
	padding: 2px 8px;
	cursor:pointer;
	font-weight:bold;
}

#addRowButton{
	background-color: #336699;
	color: white;
	font-family:"Trebuchet MS",Helvetica,Verdana;
	font-size: 10px;
	border: 1px solid #000033;
	padding: 1px 9px;
	margin-left: 5px;
	cursor:pointer;
	margin-left:25px;
}

#addRowButton:hover{
	background-color: #07447F;
	color: white;
	text-decoration:none;
}

#deleteRowButton{
	background-color: #336699;
	color: white;
	font-family:"Trebuchet MS",Helvetica,Verdana;
	font-size: 10px;
	border: 1px solid #000033;
	padding: 1px 4px;
	margin-left: 5px;
	cursor:pointer;
	margin-left:10px;
}

#deleteRowButton:hover{
	background-color: #cc0000;
	color: white;
	text-decoration:none;
}

#rowButtons{
	margin-top:20px;
}

.deletebutton{
	background-color: #cc0000;
	color: white;
	font-family:"Trebuchet MS",Helvetica,Verdana;
	font-size: 10px;
	border: 1px solid #330000;
	padding: 1px 4px;
	margin-left: 5px;
	cursor:pointer;
}
.ordinalSelect{
	border: 1px solid #dadada;
}
.ordinalSelect option{
	margin-right: 5px;
}
#errorBlock{
	margin-left: 15px;
	margin-bottom: 10px;
}
#errorBlock h2{
	color: #cc0000;
	margin: 2px;
	background-image:url(/media/images/icon_error.gif);
	background-repeat:no-repeat;
	padding-left: 30px;
}
#errorBlock ul{
	list-style:square;
	margin: 3px 0px;
	padding-left: 30px;
}
#errorBlock ul li{
	color: #cc0000;
	border-left: 1px solid #cc0000;
	margin-left: 3px;
	padding-left: 8px;
}
#pagingControls{
	font-size: 12px;
	margin: 5px 0;
	padding: 5px 0;
}
#pagingControls a{
	font-weight: bold;
	color: #cc0000;
}
#pagingControls select option{
	font-size: 12px;
}
/*  Page Layout Wizard */
.chooseDDDButton, .chooseBCButton, .deletePageComponent{
	width: 80px;
	height: 24px; 
	background-image: url(<cfoutput>#application.globalPath#</cfoutput>/media/images/icon_DDD.gif);
	font-size: 11px;
	font-weight: solid;
	background-repeat:no-repeat;
	background-position:left;
	background-color: #EFF2F6; 
	border: 1px solid #0E3C6C;
	cursor: pointer;
	padding-left: 20px;
}
.chooseBCButton{
	background-image: url(<cfoutput>#application.globalPath#</cfoutput>/media/images/icon_BC.gif);
}
.deletePageComponent{
	background-image: url(<cfoutput>#application.globalPath#</cfoutput>/media/images/icon_deleteFile.gif);
}
.chooseBCButtonOver{
	width: 80px;
	height: 24px; 
	background-image: url(<cfoutput>#application.globalPath#</cfoutput>/media/images/icon_BC.gif);
	font-size: 11px;
	font-weight: solid;
	background-repeat:no-repeat;
	background-position:left;
	background-color: #CFE4FF;
	border: 1px solid #0E3C6C;
	cursor: pointer;
	padding-left: 20px;
}
.chooseDDDButtonOver{
	width: 80px;
	height: 24px; 
	background-image: url(<cfoutput>#application.globalPath#</cfoutput>/media/images/icon_DDD.gif);
	font-size: 11px;
	font-weight: solid;
	background-repeat:no-repeat;
	background-position:left;
	background-color: #CFE4FF;
	border: 1px solid #0E3C6C;
	cursor: pointer;
	padding-left: 20px; 
}
.deletePageComponentHover{
	width: 80px;
	height: 24px; 
	background-image: url(<cfoutput>#application.globalPath#</cfoutput>/media/images/icon_deleteFile.gif);
	font-size: 11px;
	font-weight: solid;
	background-repeat:no-repeat;
	background-position:left;
	background-color: #CFE4FF;
	border: 1px solid #0E3C6C;
	cursor: pointer;
	padding-left: 20px;
}
.pageContainerOff{
	border: 1px dotted #0E3C6C; 
	padding: 3px 10px 10px 10px;
}
.pageContainerHover{
	border: 1px dotted #0E3C6C;
	padding: 3px 10px 10px 10px;
	background-color: #FFF3DF;
}
#pageWireFrame{
	margin: 10px 0 0 10px;
}
#pageWireFrame table, #pageWireFrame table td {
	border: 1px solid #dadada;
}

/* Formbuilder Styles */
#sockebuildertable {
}
#sockebuildertable td{
	background-color:#FFF3DF;
	border-width: 0 1px 1px 0;
	border-style: solid;
	border-color:#CFCFCF;
	padding: 4px;
	color:#333333;
}
#sockebuildertable td.socketbuildertablehdr{
	background-color:#0E3C6C;
	color:#ffffff;
	padding-left: 5px;
}
#rightButtons{
}
#socketformpreviewhdr{
	background-color:#F8AD37;	
	width: 100%;
	height: 30px;
	border-width: 1px 0;
	border-style: solid;
	border-color: #333333;
}
#socketformpreviewhdr h2{
	display: inline;
	float: left;
	margin: 5px 5px 5px 15px;
	color: #ffffff;
}
#socketformpreviewtable td{
	border-width: 0px 1px 1px 0px;
	border-style: solid;
	border-color: #999999;
}
.socketformpreviewrownum{
	background-color: #0E3C6C;
	color:#ffffff;
	font-weight:bold;
	padding: 0px 4px 0px 3px;
	text-align: right;
}
#socketeditfieldtable{
	margin: 0 5px;
}
#socketeditfieldtable td{
	border-width: 0px 1px 1px 1px;
	border-style: solid;
	border-color: #999999;
}
/* Review Queue & Versioning Styles */
.versionColorCell{
	color: #ffffff;
}
a.nottalink, a.nottalink:visited, a.nottalink:active {
	COLOR: #000000;
	FONT-SIZE: 10px;
	TEXT-DECORATION: none;
}

.faqQuestion{
	margin-bottom:6px;
}

.faqQuestion{
	color:#196CCF;
}

.faqAnswer{
	margin-bottom:6px;
	margin-left:12px;
}

.tipTitle{
	margin-top:5px;
	color:#196CCF;
	margin-bottom:3px;
}

.tipBody{
	margin-bottom:6px;
	margin-left:12px;
}

.faqQuestionBlock{
	margin-left:12px;
}

.glossaryTitle{
	margin-top:5px;
	color:#196CCF;
}

.glossaryDescription{
	margin-bottom:6px;
	margin-left:12px;
}

/**************************/
/* Calendar Pop Up Styles */
/**************************/

.BSCalcpYearNavigation,
.BSCalcpMonthNavigation
		{
		background-color:#6677DD;
		text-align:center;
		vertical-align:center;
		text-decoration:none;
		color:#FFFFFF;
		font-weight:bold;
		}
.BSCalcpDayColumnHeader,
.BSCalcpYearNavigation,
.BSCalcpMonthNavigation,
.BSCalcpCurrentMonthDate,
.BSCalcpCurrentMonthDateDisabled,
.BSCalcpOtherMonthDate,
.BSCalcpOtherMonthDateDisabled,
.BSCalcpCurrentDate,
.BSCalcpCurrentDateDisabled,
.BSCalcpTodayText,
.BSCalcpTodayTextDisabled,
.BSCalcpText
		{
		font-family:arial;
		font-size:8pt;
		}
TD.BSCalcpDayColumnHeader
		{
		text-align:right;
		border:solid thin #6677DD;
		border-width:0px 0px 1px 0px;
		}
.BSCalcpCurrentMonthDate,
.BSCalcpOtherMonthDate,
.BSCalcpCurrentDate
		{
		text-align:right;
		text-decoration:none;
		}
.BSCalcpCurrentMonthDateDisabled,
.BSCalcpOtherMonthDateDisabled,
.BSCalcpCurrentDateDisabled
		{
		color:#D0D0D0;
		text-align:right;
		text-decoration:line-through;
		}
.BSCalcpCurrentMonthDate
		{
		color:#6677DD;
		font-weight:bold;
		}
.BSCalcpCurrentDate
		{
		color: #FFFFFF;
		font-weight:bold;
		}
.BSCalcpOtherMonthDate
		{
		color:#808080;
		}
TD.BSCalcpCurrentDate
		{
		color:#FFFFFF;
		background-color: #6677DD;
		border-width:1px;
		border:solid thin #000000;
		}
TD.BSCalcpCurrentDateDisabled
		{
		border-width:1px;
		border:solid thin #FFAAAA;
		}
TD.BSCalcpTodayText,
TD.BSCalcpTodayTextDisabled
		{
		border:solid thin #6677DD;
		border-width:1px 0px 0px 0px;
		}
A.BSCalcpTodayText,
SPAN.BSCalcpTodayTextDisabled
		{
		height:20px;
		}
A.BSCalcpTodayText
		{
		color:#6677DD;
		font-weight:bold;
		}
SPAN.BSCalcpTodayTextDisabled
		{
		color:#D0D0D0;
		}
.BSCalcpBorder
		{
		border:solid thin #6677DD;
		}