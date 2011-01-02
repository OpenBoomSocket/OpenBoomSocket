<cfparam name="attributes.ignore" default="">

<!--- Check that fieldnames exists --->
<CFIF isDefined("FORM.fieldnames")>

 <!--- Create empty list of processed variables --->
 <CFSET #fieldnames_processed# = "">
 
 <!--- Loop through fieldnames --->
 <cfloop collection="#form#" item="form_element">
  <!--- Try to find current element in list --->
  <CFIF #ListFind(#fieldnames_processed#, #form_element#)# IS 0>
  
   <!--- Make fully qualified copy of it (to prevent acessing the wrong field type) --->
   <CFSET #form_element_qualified# = "FORM." & #form_element#>
   
   <!--- Output it as a hidden field --->
   <cfif NOT listfindnocase(attributes.ignore,"#form_element#",",")>
	   <CFOUTPUT>
	   <INPUT TYPE="hidden" NAME="#form_element#" VALUE="#HTMLEditFormat(Evaluate(form_element_qualified))#">
	   </CFOUTPUT>
	
	   <!--- And add it to the processed list --->
	   <CFSET #fieldnames_processed# = #ListAppend(#fieldnames_processed#, #form_element#)#>
   </cfif>
  </CFIF>
  
 </CFLOOP>
 
</CFIF>
