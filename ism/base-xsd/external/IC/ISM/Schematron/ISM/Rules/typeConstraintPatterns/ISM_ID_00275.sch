<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00275" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:p id="ruleText">
		[ISM-ID-00275][Error] All declassDate attributes must be of type Date. 
	</sch:p>
	<sch:p id="codeDesc">
		For all elements which contain an declassDate attribute, we 
		make sure that the declassDate value matches the pattern
		defined for type Date. 
	</sch:p>
	<sch:rule context="*[@ism:declassDate]">
		<sch:assert  
			test="util:meetsType(@ism:declassDate, $DatePattern)"
			flag="error">
			[ISM-ID-00275][Error] All declassDate attributes values must be of type Date. 
		</sch:assert>
	</sch:rule>
</sch:pattern>
