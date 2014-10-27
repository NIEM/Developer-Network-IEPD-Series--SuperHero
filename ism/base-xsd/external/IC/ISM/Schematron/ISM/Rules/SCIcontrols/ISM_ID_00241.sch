<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00241" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00241][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [RSV-XXX],
        then it must also contain the name token [RSV].
        
        Human Readable: A USA document that contains RESEVERE data (RSV) compartment data must also specify that 
        it contains RSV data. 
    </sch:p>
    <sch:p id="codeDesc">
        If the document is an ISM_CAPCO_RESOURCE, for each element which specifies
        attribute ism:SCIcontrols with a value containing a token matching
        the regular expression "RSV-[A-Z0-9]{3}", we make sure that attribute
        ism:SCIcontrols is specified with a value containing the token [RSV].
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
                        and util:containsAnyTokenMatching(@ism:SCIcontrols, ('RSV-[A-Z0-9]{3}'))]">
        <sch:assert  
            test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('RSV'))"
            flag="error">
            [ISM-ID-00241][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [RSV-XXX],
            then it must also contain the name token [RSV].
            
            Human Readable: A USA document that contains RESEVERE data (RSV) compartment data must also specify that 
            it contains RSV data. 
        </sch:assert>
    </sch:rule>
</sch:pattern>