<!--- Begin Error Trapping --->
<cfif NOT isDefined("attributes.action") OR attributes.action EQ "">
	<h1>Error Calling XMLconvert Custom Tag</h1>
	<p>You must provide an <strong>action</strong> attribute to use this tag.
		Valid actions are 
		<ul>
			<li>XML2CFML</li>
			<li>CFML2XML</li>
			<li>WDDX2XML</li>
		</ul>
	</p>
	<cfexit method="EXITTAG">
</cfif>
<cfif NOT isDefined("attributes.input")>
	<h1>Error Calling XMLconvert Custom Tag</h1>
	<p>You must provide an <strong>input</strong> attribute to use this tag.</p>
	<cfexit method="EXITTAG">
</cfif>
<cfif isDefined("attributes.input") AND NOT IsArray(attributes.input)>
	<cfif Len(Trim(attributes.input)) EQ 0>
		<h1>Error Calling XMLconvert Custom Tag</h1>
		<p>The inpute String provide currently has a length of <cfoutput>#Len(Trim(attributes.input))#</cfoutput>. You must provide an input attribute with actual data.</p>
		<cfexit method="EXITTAG">
	</cfif>
</cfif>
<cfif NOT isDefined("attributes.output")>
	<h1>Error Calling XMLconvert Custom Tag</h1>
	<p>You must provide an <strong>output</strong> attribute to use this tag.</p>
	<cfexit method="EXITTAG">
</cfif>
<!--- End Error Trapping --->
<cfif isWDDX(attributes.input)>
	<cfset RequestedAction=attributes.action>
	<cfset attributes.action="WDDX2XML">
</cfif>
<!--- Begin Action Switch --->
<cfswitch expression="#ATTRIBUTES.action#">
	<cfcase value="XML2CFML">
		<cfif attributes.output EQ "a_formelements">
        
        	<cftry>
            	<cfset userInput = XmlParse(ATTRIBUTES.input)>
                <cfcatch type="any">
                	<cfdump var="#attributes#">
                	<cfabort>
                </cfcatch>
            </cftry>
			
		<!--- Create array/struct object from datadefinition XML object--->	
			<cfset a_formelements=arrayNew(1)>
			<cfloop from="1" to="#arrayLen(userInput.XMLRoot.XmlChildren)#" index="q">
			<cfset thisStruct=structNew()>
				<cfloop from="1" to="#arrayLen(userInput.XMLRoot.XmlChildren[q].XmlChildren)#" index="r">
					<cfset "thisStruct.#userInput.XMLRoot.XmlChildren[q].XmlChildren[r].XmlName#"=userInput.XMLRoot.XmlChildren[q].XmlChildren[r].XmlText>
				</cfloop>
				<cfset a_formelements[q]=thisStruct>
			</cfloop>
			<cfset returnThis = a_formelements>
		<cfelseif attributes.output EQ "a_tableelements">
			<cfset userInput = XmlParse(ATTRIBUTES.input)>
			<!--- Create array/struct object from tabledefinition XML object--->	
			<cfset a_tableelements=arrayNew(1)>
			<cfloop from="1" to="#arrayLen(userInput.XMLRoot.XmlChildren)#" index="h">
			<cfset thisStruct=structNew()>
				<cfloop from="1" to="#arrayLen(userInput.XMLRoot.XmlChildren[h].XmlChildren)#" index="i">
					<cfset thisOtherStruct=structNew()>
					<cfloop collection="#userInput.XMLRoot.XmlChildren[h].XmlChildren[i].xmlAttributes#" item="j">
						<cfset "thisOtherStruct.#j#"
							=userInput.XMLRoot.XmlChildren[h].XmlChildren[i].xmlAttributes[j]>
					</cfloop>
					<cfset appendMe = userInput.XMLRoot.XmlChildren[h].XmlChildren[i].xmlName>
					<cfset 'thisStruct.#appendMe#' = thisOtherStruct>
				</cfloop>
				<cfset a_tableelements[h]=thisStruct>
			</cfloop>
			<cfset returnThis = a_tableelements>
		<cfelse>
			<cfmail to="#application.adminemail#" 
					from="#application.adminemail#"
					subject="XML CONVERT ERROR!!!"
					type="HTML">
			<h2>#application.sitename#</h2> <p> has failed to use XML convert during an input at #GCI.SCRIPT_NAME#?#CGI.QUERY_STRING#.</p>
			<cfdump var="#evaluate(attributes.input)#">
			</cfmail>
		</cfif>
	</cfcase>
	<cfcase value="CFML2XML">
		<cfif findNoCase("datadefinition",attributes.output,1)>
		<cfset userInput = Attributes.input>
		<!--- Create datadefinition XML object from array/struct object --->			
			<cfxml casesensitive="no" variable="thisdatadefinition">
				<cfoutput>
					<datadefinition>
						<cfloop from="1" to="#arrayLen(userInput)#" index="j">
							<item id="#j#">
								<cfloop collection="#userInput[j]#" item="k">
									<#k#><![CDATA[#trim(evaluate("userInput[j]."&k))#]]></#k#>
								</cfloop>
							</item>
						</cfloop>
					</datadefinition>
				</cfoutput>
			</cfxml>
            <!--- CleanUp WhiteSpace --->
            <cfset thisdatadefinition = ReReplaceNoCase(thisdatadefinition,'  ',' ','all')>
            <cfset thisdatadefinition = ReReplaceNoCase(thisdatadefinition,'#chr(9)#','','all')>
            <cfset thisdatadefinition = ReReplaceNoCase(thisdatadefinition,'#chr(10)##chr(13)#','','all')>
            <cfset thisdatadefinition = ReReplaceNoCase(thisdatadefinition,'#chr(10)#','','all')>
            <cfset thisdatadefinition = ReReplaceNoCase(thisdatadefinition,'#chr(13)#','','all')>
			<cfset returnThis = toString(trim(thisdatadefinition))>
		<cfelseif findNoCase("tabledefinition",attributes.output,1)>
		<cfset userInput = Attributes.input>
		<!--- Create tabledefinition XML object from array/struct object  --->
			<cfxml casesensitive="no" variable="thistabledefinition">
				<cfoutput>
					<tabledefinition>
					<cfloop from="1" to="#arrayLen(userInput)#" index="j">
						<item id="#j#">
							<cfloop collection="#userInput[j]#" item="i">
								<cfif IsStruct(evaluate('userInput[j].'&i))>
									<#i# 
									<cfloop collection="#evaluate('userInput[j].'&i)#" item="k">
									#k#="#evaluate('userInput[j].'&i&'.'&k)#"
									</cfloop>
									>
									</#i#>
								</cfif>
							</cfloop>
						</item>
					</cfloop>
					</tabledefinition>
				</cfoutput>
			</cfxml>
            <!--- CleanUp WhiteSpace --->
            <cfset thistabledefinition = ReReplaceNoCase(thistabledefinition,'  ',' ','all')>
            <cfset thisdatadefinition = ReReplaceNoCase(thistabledefinition,'#chr(9)#','','all')>
            <cfset thistabledefinition = ReReplaceNoCase(thistabledefinition,'#chr(10)##chr(13)#','','all')>
            <cfset thistabledefinition = ReReplaceNoCase(thistabledefinition,'#chr(10)#','','all')>
            <cfset thistabledefinition = ReReplaceNoCase(thistabledefinition,'#chr(13)#','','all')>
			<cfset returnThis = toString(trim(thistabledefinition))>
		<cfelse>
			<cfmail to="#application.adminemail#" 
					from="#application.adminemail#"
					subject="XML CONVERT ERROR!!!"
					type="HTML">
			<h2>#application.sitename#</h2> <p> has failed to use XML convert during an output.#CGI.SCRIPT_NAME#?#CGI.QUERY_STRING#</p>
			<cfdump var="#evaluate(attributes.output)#">
			</cfmail>
		</cfif>
	</cfcase>
	<cfcase value="WDDX2XML">
		<!--- Deserialize legacy WDDX --->
		<cfwddx action="wddx2cfml"
			input="#attributes.input#"
			output="#attributes.output#">
		<cfmail to="#application.adminemail#" 
				from="#application.adminemail#"
				subject="WDDX Still Used HERE!!!"
				type="HTML">
		<h2>#application.sitename#</h2> <p>is still using WDDX in the formobject table</p>
		<p>Server Name: #CGI.SERVER_NAME#<br>Path Info: #CGI.SCRIPT_NAME#<br>CGI Query String: #CGI.QUERY_STRING#</p>
		<cfdump var="#attributes.output#"><cfdump var="#attributes.input#">
		</cfmail>
	</cfcase>
</cfswitch>
<cfif IsDefined('returnThis')>
	<cfset "caller.#attributes.output#" = returnThis>
</cfif>