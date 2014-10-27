<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00105" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
  <sch:p id="ruleText">
    [ISM-ID-00105][Error] If ISM_CAPCO_RESOURCE and any element in the document: 
    1. Meets ISM_CONTRIBUTES
    AND
    2. Has the attribute nonICmarkings containing [SBU]
    AND
    3. No element meeting ISM_CONTRIBUTES in the document has nonICmarkings containing any of [SBU-NF]
    Then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [SBU].
    
    Human Readable: USA documents having SBU and not having SBU-NF must have SBU at the resource level.
  </sch:p>
  <sch:p id="codeDesc">
    If the document is an ISM_CAPCO_RESOURCE, the current element is the 
    ISM_RESOURCE_ELEMENT, some element meeting ISM_CONTIBUTES specifies
    attribute ism:nonICmarkings with a value containing the token [SBU], and
    no element meeting ISM_CONTRIBUTES specifies attribute ism:nonICmarkings
    with a value containing the token [SBU-NF], then we make sure that
    ISM_RESOURCE_ELEMENT sepcifies attribute ism:nonICmarkings with a value
    containing the token [SBU].
  </sch:p>
  <sch:rule context="*[$ISM_CAPCO_RESOURCE
    and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)
    and $bannerClassification='U'
    and index-of($partNonICmarkings_tok, 'SBU') > 0
    and not(index-of($partNonICmarkings_tok, 'SBU-NF') > 0)]">
    <sch:assert  
      test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('SBU'))"
      flag="error">
      [ISM-ID-00105][Error] USA Unclassified documents having SBU and not having SBU-NF must have SBU at the resource level.
    </sch:assert>
  </sch:rule>
</sch:pattern>