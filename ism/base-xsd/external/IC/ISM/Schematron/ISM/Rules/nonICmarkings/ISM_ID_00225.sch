<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00225" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00225][Error] If ISM-ICDOCUMENT-APPLIES, then attribute 
        nonICmarkings must not be specified with a value containing any name 
        token starting with [ACCM] or [NNPI]. 
        
        Human Readable: ACCM and NNPI tokens are not valid for documents that claim
        compliance with IC rules.
    </sch:p>
    <sch:p id="codeDesc">
    	If ISM_ICDOCUMENT_APPLIES, for each element which has attribute 
    	ism:nonICmarkings specified, we make sure that attribute
    	ism:nonICmarkings is not specified with a value containing a token
    	which starts with [ACCM] or [NNPI].
    </sch:p>
	<sch:rule context="*[$ISM_ICDOCUMENT_APPLIES and @ism:nonICmarkings]">
        <sch:assert  
        	test="not(util:containsAnyTokenMatching(@ism:nonICmarkings, ('ACCM', 'NNPI')))"
            flag="error">
        	[ISM-ID-00225][Error] If ISM-ICDOCUMENT-APPLIES, then attribute 
        	nonICmarkings must not be specified with a value containing any name 
        	token starting with [ACCM] or [NNPI]. 
        	
        	Human Readable: ACCM and NNPI tokens are not valid for documents that claim
        	compliance with IC rules.
        </sch:assert>
    </sch:rule>
</sch:pattern>