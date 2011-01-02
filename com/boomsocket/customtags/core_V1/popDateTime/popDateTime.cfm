<cfsilent><!---=========|=====================================================

TagName:        <cf_popDateTime> v3.0

Author:		      Josh Trefethen / josh@exciteworks.com
Created:	      Friday, January 11, 2002
Last updated:	  Sunday, September 07, 2003
Notes:					This custom tag generates a formfield and popup window
                allowing users to pick a date and/or time by clicking
                on and easy to navigate calendar.  This tag supports
                european and american date formats.

Version Notes:  For version 3, I added some new functionality.
                I created a new date validation which only works for
                US dates when the time is disabled.  I also added the
                ability to specify the 1st day of the week for the
                calendar. It defaults to Sunday now, but can be changed
                to any day of the week.


Variables:      - Required Fields -

                formName   - the name of the form the field belongs to

                - All variables below are optional -

                fieldName  - the name of the form field to assign
                             to the date field generated
                             default is set to "date"
                fieldValue - initial value of the field generated
                             default is set to null
                time       - display time?
                             default is "no"
                euro       - display in euro format?
                             default is "no"
                scriptPath - path to folder containing required
                             javascript files (this path is called
                             by <cfinclude> so it can either be a
                             server mapping, or a relative path)
                             default is set to "popDateTime/"
                imagePath  - path to images used for calendar buttons
                             default is set to same as what
                             scriptPath is set to
                firstDay   - first day of week for the calendar
                             0=Sunday; 1=Monday; and so on
                             default is set to 0

USAGE:          there is only one required field, but you may need to
                specify more depending on your usage. Simply unzip the
                the files and use the tag as shown in the example below:

                <cf_popDateTime formName="myForm"
                                fieldName="myDate"
                                time="no"
                                euro="yes"
                                scriptPath="../../popDateTime/">

                Make sure that the popDateTime directory is unzipped
                onto your webvolume (usually C:\Inetpub\wwwroot in IIS)
                so that the tag can access the images and scripts as
                needed.

==============|=================================================--->

<cfscript>

 /******************************************************
  * SET VARIABLES
  *
  */

  // formName
  variables.formName = attributes.formName;

  // fieldName
  if (isDefined('attributes.fieldName')) {
    variables.fieldName = attributes.fieldName;
  } else {
    variables.fieldName = 'date';
  }

  // fieldValue
  if (isDefined('attributes.fieldValue')) {
    variables.fieldValue = attributes.fieldValue;
  } else {
    variables.fieldValue = '';
  }

  // time
  if (isDefined('attributes.time')) {
    variables.time = attributes.time;
  } else {
    variables.time = 'no';
  }

  // euro
  if (isDefined('attributes.euro')) {
    variables.euro = attributes.euro;
  } else {
    variables.euro = 'no';
  }

  // scriptPath
  if (isDefined('attributes.scriptPath')) {
    variables.scriptPath = attributes.scriptPath;
  } else {
    variables.scriptPath = 'popDateTime/';
  }

  // imagePath
  if (isDefined('attributes.imagePath')) {
    variables.imagePath = attributes.imagePath;
  } else {
    variables.imagePath = variables.scriptPath;
  }

    // fieldSize
  if (isDefined('attributes.fieldSize')) {
    variables.fieldSize = attributes.fieldSize;
  } else {
    variables.fieldSize = '20';
  }

  // firstDay
  if (isDefined('attributes.firstDay'))
    variables.firstDay = attributes.firstDay;
  else
    variables.firstDay = 0;

 /**********************************************************
  * CHOOSE PROPER SCRIPT TO RUN
  *
  * LEGEND of methods:
  *
  * 1 = date, time, euro format
  * 2 = date, euro format
  * 3 = date, time, american format
  * 4 = date, american format
  *
  * The logic below will determine the script to use according to the
  * parameters passsed to this custom tag.
  *
  */

  if (variables.time NEQ 'no' AND variables.euro NEQ 'no') {
    variables.scriptNo = 1;
  } else if (variables.time EQ 'no' AND variables.euro NEQ 'no') {
    variables.scriptNo = 2;
  } else if (variables.time NEQ 'no' AND variables.euro EQ 'no') {
    variables.scriptNo = 3;
  } else if (variables.time NEQ 'no' AND variables.euro EQ 'no') {
    variables.scriptNo = 4;
  } else { // just in case
    variables.scriptNo = 4;
  }

  // file to the include for datetimepopup
  variables.scriptFile = variables.scriptPath & 'popDateTime' & variables.scriptNo & '.js';
  variables.validFile = variables.scriptPath & 'dateValidation.js';

  // calendar image file
  variables.imgFile = variables.imagePath & 'cal.gif';

  // here we concatenate variables and strings to construct javascript call
  variables.javaScriptCall = "javascript:show_calendar" & variables.scriptNo & "('document." & variables.formName & "." & variables.fieldName & "', document." & variables.formName & "." & variables.fieldName & ".value, '" & variables.imagePath & "');";

</cfscript></cfsilent>
<cfoutput>

  <!--- load US date validation --->
  <cfif variables.scriptNo EQ 4>
    <script language="JavaScript">
      <cfinclude template="#variables.validFile#">
    </script>
  </cfif>

  <!--- this is the form field and the calendar image --->
  <input type="Text" name="#trim(variables.fieldName)#"
         value="#trim(variables.fieldValue)#" size="#trim(variables.fieldSize)#"
        <cfif variables.scriptNo EQ 4>
          onBlur="return ValidateForm()"
        </cfif>
        >
    <a href="#variables.javaScriptCall#"><img src="#variables.imgFile#"
                                              width="16"
                                              height="16"
                                              border="0"
                                              alt="Click Here to Pick the date"></a>
</cfoutput>


