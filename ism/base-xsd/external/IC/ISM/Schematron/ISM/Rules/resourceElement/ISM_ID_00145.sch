<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00145" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00145][Error] If ISM_CAPCO_RESOURCE and any element in the document: 
        1. Meets ISM_CONTRIBUTES
        AND
        2. Has the attribute nonICmarkings containing [LES]
        AND
        3. No element meeting ISM_CONTRIBUTES in the document has nonICmarkings containing any of [LES-NF]
        Then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [LES].
        
        Human Readable: USA documents having LES and not having LES-NF must have LES at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
      If the document is an ISM_CAPCO_RESOURCE, the current element is the 
      ISM_RESOURCE_ELEMENT, some element meeting ISM_CONTIBUTES specifies
      attribute ism:nonICmarkings with a value containing the token [LES], and
      no element meeting ISM_CONTRIBUTES specifies attribute ism:nonICmarkings
      with a value containing the token [LES-NF], then we make sure that
      ISM_RESOURCE_ELEMENT sepcifies attribute ism:nonICmarkings with a value
      containing the token [LES].
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
                        and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)
                        and index-of($partNonICmarkings_tok, 'LES') > 0
                        and not(index-of($partNonICmarkings_tok, 'LES-NF') > 0)]">
        <sch:assert  
            test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES'))"
            flag="error">
            [ISM-ID-00145][Error] USA documents having LES and not having LES-NF must have LES at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>