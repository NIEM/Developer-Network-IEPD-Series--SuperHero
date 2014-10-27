<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00297" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:p id="ruleText">
		[ISM-ID-00297][Error] All unregisteredNoticeType attributes must be a string with less than 2048 characters. 
	</sch:p>
	<sch:p id="codeDesc">
		For all elements which contain an unregisteredNoticeType attribute, we 
		make sure that the unregisteredNoticeType value is a string with less
		than 2048 characters.   
	</sch:p>
	<sch:rule context="*[@ism:unregisteredNoticeType]">
		<sch:assert  
			test="string-length(@ism:unregisteredNoticeType) &lt;= 2048"
			flag="error">
			[ISM-ID-00297][Error] All unregisteredNoticeType attributes must be a string with less than 2048 characters. 
		</sch:assert>
	</sch:rule>
</sch:pattern>

