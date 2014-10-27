<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00157" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00157][Error] If ISM_CAPCO_RESOURCE and:
        1. The attribute notice contains one of the [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], or [DoD-Dist-E]
        AND
        2. The attribute noticeReason is not specified.
        
        Human Readable: DoD distribution statements B, C, D , or E  all require a reason.
    </sch:p>
    <sch:p id="codeDesc">
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        specifies attribute ism:noticeType with a value containing the token
        [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], or [DoD-Dist-E], we make
        sure that attribute ism:noticeReason is specified.
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE  
				    	          and util:containsAnyOfTheTokens(@ism:noticeType,
				    		              ('DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E'))]">        
        <sch:assert 
            test="@ism:noticeReason"
            flag="error"> 
        	[ISM-ID-00157][Error] If ISM_CAPCO_RESOURCE and:
        	1. The attribute notice contains one of the [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], or [DoD-Dist-E]
        	AND
        	2. The attribute noticeReason is not specified.
        	
        	Human Readable: DoD distribution statements B, C, D , or E  all require a reason.
        </sch:assert>
    </sch:rule>
</sch:pattern>
