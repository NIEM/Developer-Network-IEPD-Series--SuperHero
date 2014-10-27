<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00288" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:p id="ruleText">
		[ISM-ID-00288][Error] All noticeReason attributes must be a string with less than 2048 characters. 
	</sch:p>
	<sch:p id="codeDesc">
		For all elements which contain an noticeReason attribute, we 
		make sure that the noticeReason value is a string with less
		than 2048 characters.   
	</sch:p>
	<sch:rule context="*[@ism:noticeReason]">
		<sch:assert  
			test="string-length(@ism:noticeReason) &lt;= 2048"
			flag="error">
			[ISM-ID-00288][Error] All noticeReason attributes must be a string with less than 2048 characters. 
		</sch:assert>
	</sch:rule>
</sch:pattern>
