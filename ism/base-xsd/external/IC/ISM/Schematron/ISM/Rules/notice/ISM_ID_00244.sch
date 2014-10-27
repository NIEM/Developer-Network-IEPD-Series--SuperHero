<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00244" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
  <sch:p id="ruleText">
    [ISM-ID-00244][Error] If ISM_CAPCO_RESOURCE and:
    1. Any element meeting ISM_CONTRIBUTES in the document has the attribute atomicEnergyMarkings containing [RD-CNWDI]
    AND
    2. No element meeting ISM_CONTRIBUTES in the document has noticeType containing [CNWDI].
    that does not have attribute externalNotice with a value of [true].
    Human Readable: USA documents containing CNWDI data must also have an CNWDI notice.
  </sch:p>
  <sch:p id="codeDesc">
    If the document is an ISM_CAPCO_RESOURCE, for each element meeting
    ISM_CONTRIBUTES which specifies attribute ism:atomicEnergyMarkings with
    a value containing the token [RD-CNWDI], we make sure that some element
    in the document specifies attribute ism:noticeType with a value containing
    the token [CNWDI] and not an attribute externalNotice with a value of [true].
  </sch:p>
  <sch:rule context="*[$ISM_CAPCO_RESOURCE
                      and util:contributesToRollup(.)
                      and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD-CNWDI'))]">
    <sch:assert test="
      some $elem in $partTags satisfies
        ($elem[@ism:noticeType]
        and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('CNWDI'))
        and not ($elem/@ism:externalNotice=true()))"
      flag="error">
      [ISM-ID-00244][Error] If ISM_CAPCO_RESOURCE and:
      1. Any element meeting ISM_CONTRIBUTES in the document has the attribute atomicEnergyMarkings containing [RD-CNWDI]
      AND
      2. No element meeting ISM_CONTRIBUTES in the document has noticeType containing [CNWDI].
      
      Human Readable: USA documents containing CNWDI data must also have an CNWDI notice.
    </sch:assert>
  </sch:rule>
</sch:pattern>