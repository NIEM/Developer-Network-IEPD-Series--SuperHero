<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00250" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:p id="ruleText">
		[ISM-ID-00250][Error] If ISM-CAPCO-RESOURCE, element Notice must specify
		attribute ism:noticeType or ism:unregisteredNoticeType.
		
		Human Readable: Notices must specify their type.
	</sch:p>
	<sch:p id="codeDesc">
		For element ism:Notice
	</sch:p>
	<sch:rule context="ism:Notice[$ISM_CAPCO_RESOURCE]">
		<sch:assert
			test="@ism:noticeType or @ism:unregisteredNoticeType"
			flag="error">
			[ISM-ID-00250][Error] If ISM-CAPCO-RESOURCE, element Notice must specify
			attribute ism:noticeType or ism:unregisteredNoticeType.
			
			Human Readable: Notices must specify their type.
		</sch:assert>
	</sch:rule>
</sch:pattern>