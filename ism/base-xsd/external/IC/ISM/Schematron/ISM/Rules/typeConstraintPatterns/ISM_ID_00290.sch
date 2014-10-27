<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00290" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:p id="ruleText">
		[ISM-ID-00290][Error] All externalNotice attributes must be of type Boolean. 
	</sch:p>
	<sch:p id="codeDesc">
		For all elements which contain an externalNotice attribute, we 
		make sure that the externalNotice value matches the pattern
		defined for type Boolean. 
	</sch:p>
	<sch:rule context="*[@ism:externalNotice]">
		<sch:assert  
			test="util:meetsType(@ism:externalNotice, $BooleanPattern)"
			flag="error">
			[ISM-ID-00290][Error] All externalNotice attributes values must be of type Boolean. 
		</sch:assert>
	</sch:rule>
</sch:pattern>
