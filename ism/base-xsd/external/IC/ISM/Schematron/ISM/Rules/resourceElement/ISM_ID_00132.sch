<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00132" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00132][Error] If ISM_CAPCO_RESOURCE and the ISM_RESOURCE_ELEMENT has the 
        attribute disseminationControls containing [RELIDO] then every element meeting 
        ISM_CONTRIBUTES_CLASSIFIED in the document must have the attribute 
        disseminationControls containing [RELIDO].
        
        Human Readable: USA documents having RELIDO at the resource level must have every classified portion having RELIDO and on any U portions that have explicit Release specified must have RELIDO.
    </sch:p>
    <sch:p id="codeDesc">
        If the document is an ISM_CAPCO_RESOURCE, the current element is the
        ISM_RESOURCE_ELEMENT, and the ISM_RESOURCE_ELEMENT specifies the attribute
        ism:disseminationControls with a value containing the token [RELIDO],
        then we make sure that every element meeting ISM_CONTRIBUTES_CLASSIFIED
        speficies attribute ism:disseminationControls with a value containing
        the token [RELIDO].
        
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
                        and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)
                        and util:containsAnyOfTheTokens(@ism:disseminationControls, ('RELIDO'))]">
        <sch:assert  
            test="every $ele in $partTags satisfies
            if  ($ele/@ism:classification[normalize-space()='U'] and not(util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('REL','NF','DISPLAYONLY')))
                       or not($ele/@ism:classification)
                 )
                    then true()
                    else
                      util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('RELIDO'))"
            flag="error">
            [ISM-ID-00132][Error] USA documents having RELIDO at the resource level must have every classified portion having RELIDO and on any U portions that have explicit Release specified must have RELIDO.
        </sch:assert>
    </sch:rule>
</sch:pattern>