<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00099" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00099][Error] If ISM_CAPCO_RESOURCE and attribute ownerProducer
        contains the token [FGI], then the token [FGI] must be the only value 
        in attribute ownerProducer.
    </sch:p>
    <sch:p id="codeDesc">
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        specifies attribtue ism:ownerProducer with a value containing the token
        [FGI] we make sure that attribute ism:ownerProducer only contains a 
        single token.
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
                        and util:containsAnyOfTheTokens(@ism:ownerProducer, ('FGI'))]">
        <sch:assert  
            test="
            count(
                tokenize(normalize-space(string(@ism:ownerProducer)), ' ')
            ) = 1"
            flag="error">
            [ISM-ID-00099][Error] If ISM_CAPCO_RESOURCE and attribute ownerProducer
            contains the token [FGI], then the token [FGI] must be the only value 
            in attribute ownerProducer.
        </sch:assert>
    </sch:rule>
</sch:pattern>