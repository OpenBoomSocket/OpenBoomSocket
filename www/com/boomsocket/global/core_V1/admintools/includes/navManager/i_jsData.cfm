<cfsavecontent variable="jstext">
	<cfoutput>
		<script type="text/javascript">
			function updateDetails(){
				navManager.submit();
			}
			function clearForm(){
				document.getElementById('label').value = '';
				document.getElementById('href').value = '';
				document.navManager.pageid.selectedIndex = 0;
				document.navManager.imageOn.selectedIndex = 0;
				document.navManager.imageAt.selectedIndex = 0;
				document.navManager.imageOff.selectedIndex = 0;
				document.getElementById('menuAction').value = 'Add Item';
			}
			function confirmDelete(){
			var doit=confirm("Are you sure you wish to delete this item?");
			if (doit)
				return true ;
			else
				return false ;
			}
			function Field_up(lst){
				var i = lst.selectedIndex;
				if (i>0){
					Field_swap(lst,i,i-1);
				}
			}
			function Field_down(lst){
				var i = lst.selectedIndex;
				if (i<lst.length-1){
					Field_swap(lst,i+1,i);
				}
			}
			function Field_swap(lst,i,j){
				var t = '';
				t = lst.options[i].text; lst.options[i].text = lst.options[j].text; lst.options[j].text = t;
				t = lst.options[i].value; lst.options[i].value = lst.options[j].value; lst.options[j].value = t;
				t = lst.options[i].selected; lst.options[i].selected = lst.options[j].selected; lst.options[j].selected = t;
				t = lst.options[i].defaultSelected; lst.options[i].defaultSelected = lst.options[j].defaultSelected; lst.options[j].defaultSelected = t;
				//SetFields(document.quicklink.quicklinkordinal,document.quicklink.FieldsSave);
			}
			function SetFields(lst,lstSave){
				var t;
				lstSave.value=""
				for (t=0;t<=lst.length-1;t++)
					lstSave.value+=String(lst.options[t].value)+",";
				if (lstSave.value.length>0)
					lstSave.value=lstSave.value.slice(0,-1);
				
				document.navManager.formAction.value = document.navManager.menuAction.value;
				document.navManager.submit();	
			}
		</script>
	</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#jstext#">