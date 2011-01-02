<!--- Prepare alphabetized list... --->
	<cfset keys = structKeyArray(attributes.currentStruct)>
	<cfset arraySort(keys,"text")>

	<!--- dump keys one by one --->
	<cfloop index="x" from=1 to="#arrayLen(keys)#">
		<cfset keyName = keys[x]>
		<cfoutput>
		#keyName#<br>
		</cfoutput>

       <cftry> 
			<cfmodule template="#application.customTagPath#/showTree.cfm" currentstruct="#attributes.currentStruct[keyName]#">
 		<cfcatch>
				<cfoutput>[undefined struct element]</cfoutput>
        	</cfcatch>
        </cftry> 
	</cfloop>
