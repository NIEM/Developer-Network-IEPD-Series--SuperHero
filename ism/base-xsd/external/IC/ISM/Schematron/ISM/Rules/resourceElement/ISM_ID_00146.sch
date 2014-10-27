<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00146" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00146][Error] If ISM_CAPCO_RESOURCE and there exist at least 2 elements in the document:
        1. Each element: Meets ISM_CONTRIBUTES
        AND
        2. One of the elements: Has the attribute nonICmarkings containing [LES-NF]
        AND
        3. One of the elements: meets ISM_CONTRIBUTES_CLASSIFIED
        Then the ISM_RESOURCE_ELEMENT must have disseminationControls containing [NF].
        
        Human Readable: Classified USA documents having LES-NF Data must have NF at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute nonICmarkings specified 
        with a value containing [LES-NF] and the resourceElement has attribute classification specified 
        with a value other than [U], then we make sure that the resourceElement has attribute 
        disseminationControls specified with a value containing [NF].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert  
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
                if(index-of($partNonICmarkings_tok, 'LES-NF') > 0 and not($bannerClassification='U')) 
                then (index-of($bannerDisseminationControls_tok, 'NF') > 0)
                else true()
            " 
            flag="error">
            [ISM-ID-00146][Error] Classified USA documents having LES-NF Data must have NF at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>