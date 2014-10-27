<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00090" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00090][Error] If ISM_CAPCO_RESOURCE and any element: 
        1. Meets ISM_CONTRIBUTES
        AND
        2. Has the attribute disseminationControls containing [REL]
        Then the ISM_RESOURCE_ELEMENT must not have attribute disseminationControls containing [EYES]. 
        
        Human Readable: USA documents with any portion that is REL must not be EYES at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If the document is an ISM_CAPO_RESOURCE, the current element is the 
        ISM_RESOURCE_ELEMENT, and some element meeting ISM_CONTRIBUTES specifies
        attribute ism:disseminationControls with a value containing [REL], then
        we make sure that ISM_RESOURCE_ELEMENT does not specify attribute
        ism:disseminationControls or specifies the attribute with a value
        that does not contain the token [EYES].
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
                        and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)
                        and index-of($partDisseminationControls_tok, 'REL') > 0]">
        <sch:assert test="not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('EYES')))"
            flag="error">
            [ISM-ID-00090][Error] USA documents with any portion that is REL must not be EYES at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>