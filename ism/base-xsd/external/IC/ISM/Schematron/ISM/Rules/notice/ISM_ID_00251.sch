<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00251" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [[ISM-ID-00251][Error] If ISM-ICDOCUMENT-APPLIES, then attribute 
        @ism:noticeType must not be specified with a value of [COMSEC]. 
        
        Human Readable: COMSEC notices are not valid for documents that claim
        compliance with IC rules.
    </sch:p>
    <sch:p id="codeDesc">
    	If ISM_ICDOCUMENT_APPLIES, for each element which has attribute 
    	@ism:noticeType specified, we make sure that attribute
    	@ism:noticeType is not specified with a value containing token
    	[COMSEC].
    </sch:p>
	<sch:rule context="*[$ISM_ICDOCUMENT_APPLIES and @ism:noticeType]">
        <sch:assert  
            test="not(util:containsAnyTokenMatching(@ism:noticeType, 'COMSEC'))"
            flag="error">
        	[ISM-ID-00251][Error] If ISM-ICDOCUMENT-APPLIES, then attribute 
        	@ism:noticeType must not be specified with a value of [COMSEC]. 
        	
        	Human Readable: COMSEC notices are not valid for documents that claim
        	compliance with IC rules.
        </sch:assert>
    </sch:rule>
</sch:pattern>