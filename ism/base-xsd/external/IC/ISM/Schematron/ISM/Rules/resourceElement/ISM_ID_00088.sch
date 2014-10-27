<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00088" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00088][Error] If ISM_CAPCO_RESOURCE and releasableTo is specified on 
        the resource element then all classified portions must specify releasableTo.
        
        Human Readable: USA documents having any classified portion that is not 
        Releasable or having unclassified portions with [NF], [DISPLAYONLY], or [RELIDO]
        cannot be REL at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules apply to the document, we verify that all portions either have 
        the attribute classification specified with a value of [U] or classified portions 
        of the document have the attribute releasableTo. 
        
        Attribute releasableTo is only valid on an element if attribute 
        disseminationControls is specified with a value containing [REL] or [EYES], 
        as [REL] supersedes [EYES] in the banner.
                
        If any elements do not meet either of the two requirements stated above, 
        then the assertion fails since attribute releasableTo appears on 
        the banner but is not present on all classified portions.
    </sch:p>

    <sch:rule context="*[$ISM_CAPCO_RESOURCE 
                        and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) 
                        and @ism:releasableTo]">
        <sch:assert
            test="every $portion in $partTags satisfies
            (
                ($portion/@ism:classification='U' and
                    not(util:containsAnyOfTheTokens($portion/@ism:disseminationControls, ('NF')) or
                    (util:containsAnyOfTheTokens($portion/@ism:disseminationControls, ('DISPLAYONLY', 'RELIDO')) 
                    and not(util:containsAnyOfTheTokens($portion/@ism:dissemintationControls, ('REL')))))
                )
                or $portion/@ism:releasableTo[normalize-space()]
                or not($portion/@ism:classification) 
            )"
            flag="error">
            [ISM-ID-00088][Error] USA documents having any classified portion that is not 
            Releasable or having unclassified portions with [NF], [DISPLAYONLY], or [RELIDO]
            cannot be REL at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>