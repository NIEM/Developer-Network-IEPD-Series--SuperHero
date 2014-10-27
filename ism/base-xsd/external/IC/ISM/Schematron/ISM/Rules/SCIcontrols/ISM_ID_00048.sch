<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00048" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00048][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols
        contains the name token [HCS], then attribute classification must have
        a value of [TS], [S], or [C].
        
        Human Readable: A USA document containing HCS data must be classified
        CONFIDENTIAL, SECRET, or TOP SECRET.
    </sch:p>
    <sch:p id="codeDesc">
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing the token
        [HCS] we make sure that attribute ism:classification is 
        specified with a value containing the token [TS], [S], or [C].
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
                        and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS'))]">
        <sch:assert  
          test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S', 'C'))"
            flag="error">
            [ISM-ID-00048][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols
            contains the name token [HCS], then attribute classification must have
            a value of [TS], [S], or [C].
            
            Human Readable: A USA document containing HCS data must be classified
            CONFIDENTIAL, SECRET, or TOP SECRET.
        </sch:assert>
    </sch:rule>
</sch:pattern>