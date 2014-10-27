<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00248" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:p id="ruleText">
		[ISM-ID-00248][Error] ISM_RESOURCE_ELEMENT cannot have externalNotice set to [true].
		
		Human Readable: ISM resource elements can not be external notices.
	</sch:p>
	<sch:p id="codeDesc">
		If ISM_RESOURCE_ELEMENT, we make sure that the ISM_RESOURCE_ELEMENT does not contain
		externalNotice set to [true].
	</sch:p>
	<sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)][@ism:externalNotice]">
		<sch:assert
			test="not(string(@ism:externalNotice)='true')"
			flag="error">
			[ISM-ID-00248][Error] ISM_RESOURCE_ELEMENT cannot have externalNotice set to [true].
			
			Human Readable: ISM resource elements can not be external notices.
		</sch:assert>
	</sch:rule>
</sch:pattern>