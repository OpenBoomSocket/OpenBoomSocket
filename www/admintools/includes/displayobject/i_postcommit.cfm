<!--- i_postcommit.cfm --->

<!--- Create css file --->
<cffile action="write" file="#application.installpath##application.slash#css#application.slash#displayobject#application.slash##listLast(form.displayobjectpath,'.')#.css" output="/*CSS File for #form.displayobjectpath# generated #dateFormat(now(),'m/d/yyyy')#*/">