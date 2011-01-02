<cfif isDefined('form.parentrole') AND form.parentrole GT 0>
	<cftry>
		<cfquery name="q_removeChildren" datasource="#application.datasource#">
			DELETE FROM guestroleparentchild
			WHERE parentid = #form.parentrole#
		</cfquery>
		<cfquery name="q_insert" datasource="#application.datasource#">
			INSERT INTO guestroleparentchild (parentid,childid) VALUES (#form.parentrole#,#form.parentrole#)
		</cfquery>
		<cfif isDefined('form.childrole') AND listLen('form.childrole')>
			<cfloop list="#form.childrole#" index="thisChild">
				<cfif thisChild NEQ form.parentrole>
					<cfquery name="q_insert" datasource="#application.datasource#">
						INSERT INTO guestroleparentchild (parentid,childid) VALUES (#form.parentrole#,#thisChild#)
					</cfquery>
				</cfif>
			</cfloop>
		</cfif>
		<cfcatch type="any">
			<cfrethrow>
		</cfcatch>
	</cftry>
</cfif>