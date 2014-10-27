<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00315" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00315][Error] If element meets ISM_CONTRIBUTES and attribute
        ownerProducer contains the token [NATO], then attribute declassException
        must be specified with a value of [NATO] or [NATO-AEA] on the resourceElement.
        
        Human Readable: Any non-resource element that contributes to the 
        document's banner roll-up and has NATO Information)
        must also specify a NATO declass exemption on the banner.
    </sch:p>
    <sch:p id="codeDesc">
        In a document that meets ISM_CAPCO_RESOURCE, for each element which is 
        not the $ISM_RESOURCE_ELEMENT and meets ISM_CONTRIBUTES and specifies 
        attribute ism:ownerProducer with a value containing the token [NATO], 
        we make sure that attribute ism:declassExemption on the resource element 
        is specified with a value containing the token [NATO] or [NATO-AEA].
    </sch:p>
    <sch:rule context="*[not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT))
                        and util:contributesToRollup(.)
                        and $ISM_CAPCO_RESOURCE
                        and not(@ism:classification='U')
                        and util:containsAnyOfTheTokens(@ism:ownerProducer, ('NATO'))]">
        <sch:assert  
            test="util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:declassException, ('NATO', 'NATO-AEA'))" 
            flag="error">
            [ISM-ID-00315][Error] If element meets ISM_CONTRIBUTES and attribute
            ownerProducer contains the token [NATO], then attribute declassException
            must be specified with a value of [NATO] or [NATO-AEA] on the resourceElement.
            
            Human Readable: Any non-resource element that contributes to the 
            document's banner roll-up and has NATO Information)
            must also specify a NATO declass exemption on the banner.
        </sch:assert>
    </sch:rule>
</sch:pattern>