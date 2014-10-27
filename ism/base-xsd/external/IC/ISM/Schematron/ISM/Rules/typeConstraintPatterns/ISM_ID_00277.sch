<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00277" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:p id="ruleText">
		[ISM-ID-00277][Error] All declassException attributes must be of type NmToken. 
	</sch:p>
	<sch:p id="codeDesc">
		For all elements which contain an declassException attribute, we 
		make sure that the declassException value matches the pattern
		defined for type NmToken. 
	</sch:p>
	<sch:rule context="*[@ism:declassException]">
		<sch:assert  
			test="util:meetsType(@ism:declassException, $NmTokenPattern)"
			flag="error">
			[ISM-ID-00277][Error] All declassException attributes values must be of type NmToken. 
		</sch:assert>
	</sch:rule>
</sch:pattern>
