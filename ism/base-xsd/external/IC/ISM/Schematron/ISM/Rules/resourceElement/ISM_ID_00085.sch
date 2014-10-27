<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00085" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00085][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the document 
        has the attribute nonICmarkings containing [XD] and does not have any element meeting ISM_CONTRIBUTES in the document having the 
        attribute nonICmarkings containing [ND] then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [XD].
        
        Human Readable: USA documents having XD Data and not having ND must have XD at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
      If the document is an ISM_CAPCO_RESOURCE, the current element is the ISM_CAPCO_RESOURCE,
      any element meeting ISM_CONTRIBUTES specifies attribute ism:nonICmarkings with a value
      containing the token [XD], and no element meeting ISM_CONTRIBUTES specifies the
      attribute ism:nonICmarkings with a value containing the token [ND], then we make sure
      that the ISM_RESOURCE_ELEMENT specifies attribute ism:nonICmarkings with a value
      containing the token [XD].
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
                        and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)
                        and index-of($partNonICmarkings_tok, 'XD') > 0
                        and not(index-of($partNonICmarkings_tok, 'ND')>0)]">
        <sch:assert  
            test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('XD'))"
            flag="error">
            [ISM-ID-00085][Error] USA documents having XD Data and not having ND must have XD at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>