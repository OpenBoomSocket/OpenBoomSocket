==============|=====================================================    

TagName:        <cf_popDateTime> v3

Author:		Josh Trefethen / josh@exciteworks.com 

Created:	Friday, January 11, 2002

Last updated:	Sunday, September 7, 2003 

Notes:		This custom tag generates a formfield and popup window
                allowing users to pick a date and/or time by clicking 
                on and easy to navigate calendar.  This tag supports
                european and american date formats.

                The tag works on windows or linux and is cross-browser 
                compatible.

                Date validation is also included for US date formats
                when time is disabled.

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
                                scriptPath="popDateTime/"> 
                                
                Make sure that the popDateTime directory is unzipped 
                onto your webvolume (usually C:\Inetpub\wwwroot in IIS)
                so that the tag can access the images and scripts as
                needed. 
                                                
==============|=====================================================