<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00311" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00311][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [EL-NK],
        then it must also contain the name token [EL].
        
        Human Readable: A USA document that contains ENDSEAL (EL) -NONBOOK compartment data must also specify that 
        it contains EL data. 
    </sch:p>
    <sch:p id="codeDesc">
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing the token
        [EL-NK] we make sure that attribute ism:SCIcontrols is 
        specified with a value containing the token [EL].
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
        and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('EL-NK'))]">
        <sch:assert test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('EL'))"
            flag="error">
            [ISM-ID-00311][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [EL-NK],
            then it must also contain the name token [EL].
            
            Human Readable: A USA document that contains ENDSEAL (EL) -NONBOOK compartment data must also specify that 
            it contains EL data. 
        </sch:assert>
    </sch:rule>
</sch:pattern>