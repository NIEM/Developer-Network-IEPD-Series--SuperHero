<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00252" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00252][Error] If ISM_RESOURCE_ELEMENT specifies the attribute
        ism:disseminationControls with a value containing the token [RELIDO], 
        then attribute nonICmarkings must not be specified with a value containing 
        the token [NNPI]. 
        
        Human Readable: NNPI tokens are not valid for documents that have
        RELIDO at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        For resource elements which have attribute ism:disseminationControls specified 
        with a value containing the token [RELIDO], we make sure that attribute 
        ism:nonICmarkings is not specified with a value containing the token [NNPI].
    </sch:p>
    <sch:rule context="*[index-of(tokenize(normalize-space(string($ISM_RESOURCE_ELEMENT/
        @ism:disseminationControls)), ' '),'RELIDO') &gt; 0 and @ism:nonICmarkings]">
        <sch:assert  
        	test="not(util:containsAnyTokenMatching(@ism:nonICmarkings, 'NNPI'))"
            flag="error">
            [ISM-ID-00252][Error] If ISM_RESOURCE_ELEMENT specifies the attribute
            ism:disseminationControls with a value containing the token [RELIDO], 
            then attribute nonICmarkings must not be specified with a value containing 
            the token [NNPI]. 
        	
        	Human Readable: NNPI tokens are not valid for documents that have
        	RELIDO at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>