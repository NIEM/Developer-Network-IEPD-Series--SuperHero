<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00269" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:p id="ruleText">
		[ISM-ID-00269][Error] All classifiction attributes must be of type NmToken. 
	</sch:p>
	<sch:p id="codeDesc">
		For all elements which contain an classification attribute, we 
		make sure that the classification value matches the pattern
		defined for type NmTokens.  
	</sch:p>
	<sch:rule context="*[@ism:classification]">
		<sch:assert  
			test="util:meetsType(@ism:classification, $NmTokenPattern)"
			flag="error">
			[ISM-ID-00269][Error] All classifiction attributes values must be of type NmToken. 
		</sch:assert>
	</sch:rule>
</sch:pattern>
