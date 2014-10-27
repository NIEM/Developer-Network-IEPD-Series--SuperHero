<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00274" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:p id="ruleText">
		[ISM-ID-00274][Error] All createDate attributes must be of type Date. 
	</sch:p>
	<sch:p id="codeDesc">
		For all elements which contain an createDate attribute, we 
		make sure that the createDate value matches the pattern
		defined for type Date. 
		
		Note: this rule is not able to be failed. If the createDate does
		not confirm to type Date, schematron fails when defining global
		variables before any rules are fired. 
	</sch:p>
	<sch:rule context="*[@ism:createDate]">
		<sch:assert  
			test="util:meetsType(@ism:createDate, $DatePattern)"
			flag="error">
			[ISM-ID-00274][Error] All createDate attributes values must be of type Date. 
		</sch:assert>
	</sch:rule>
</sch:pattern>
