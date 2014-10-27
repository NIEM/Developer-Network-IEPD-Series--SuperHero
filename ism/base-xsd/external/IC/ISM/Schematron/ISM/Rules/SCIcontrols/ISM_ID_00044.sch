<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00044" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00044][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols
        contains a name token starting with [SI-G], then attribute
        classification must have a value of [TS].
        
        Human Readable: A USA document containing Special Intelligence (SI)
        GAMMA compartment data must be classified TOP SECRET.
    </sch:p>
    <sch:p id="codeDesc">
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing a token
        starting with [SI-G] we make sure that attribute ism:classification
        is specified with a value containing the token [TS].
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
                        and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^SI-G'))]">
        <sch:assert  
          test="util:containsAnyOfTheTokens(@ism:classification, ('TS'))"
            flag="error">
            [ISM-ID-00044][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols
            contains a name token starting with [SI-G], then attribute
            classification must have a value of [TS].
            
            Human Readable: A USA document containing Special Intelligence (SI)
            GAMMA compartment data must be classified TOP SECRET.
        </sch:assert>
    </sch:rule>
</sch:pattern>