<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00066" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00066][Error] If ISM_CAPCO_RESOURCE and: 
        1. Any element meeting ISM_CONTRIBUTES in the document has the attribute disseminationControls containing [FOUO]
        AND
        2. ISM_RESOURCE_ELEMENT has the attribute classification [U]
        AND
        3. No element meeting ISM_CONTRIBUTES in the document has nonICmarkings containing [SBU], [SBU-NF], [LES], [LES-NF]
        
        Then the ISM_RESOURCE_ELEMENT must have disseminationControls containing [FOUO].
        
        Human Readable: USA Unclassified documents having FOUO data and not having SBU, SBU-NF, LES, or LES-NF must have 
        FOUO at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If the document is an ISM_CAPCO_RESOURCE, the current element is the ISM_RESOURCE_ELEMENT,
        some element meeting ISM_CONTRIBUTES specifies attribute ism:disseminationControls
        with a value containing [FOUO], the ISM_RESOURCE_ELEMENT specifies the attribute
        ism:classification with a value of [U], and no element meeting ISM_CONTRIBUTES
        specifies attribute ism:nonICmarkings with a value containing [SBU], [SBU-NF],
        [LES], or LES-NF], then we make sure that the ISM_RESOURCE_ELEMENT
        specifies attribute ism:disseminationControls with a value containing the
        token [FOUO].
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
                        and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)
                        and index-of($dcTagsFound,'FOUO') > 0
                        and util:containsAnyOfTheTokens(@ism:classification, ('U'))
                        and not($partNonICmarkings_tok = ('SBU', 'SBU-NF', 'LES', 'LES-NF'))]">
        <sch:assert test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('FOUO'))"
            flag="error">
            [ISM-ID-00066][Error] USA Unclassified documents having FOUO data and not having SBU, SBU-NF, LES, or LES-NF must have 
            FOUO at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>