<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00119" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00119][Error] If ISM_CAPCO_RESOURCE and 
        1. attribute classification is not [U]
        AND
        2. ISM_ICDOCUMENT_APPLIES
        AND
        3. attribute excludeFromRollup is not true
        AND
        4. Attribute disseminationControls must contain one or more of 
            [DISPLAYONLY], [REL], [RELIDO], [EYES], or [NF]

        Human Readable: All classified NSI that claims compliance with 
        ICD 710 must have an appropriate foreign disclosure or release marking.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document, or ICDocument does not apply to the document,
        or the resource is unclassified, or  excludeFromRollup is true, then the rule does not apply. 
        Otherwise, we make sure that the attribute disseminationControls contains at least
        one of the values [DISPLAYONLY], [RELIDO], [REL], [EYES], or [NF].
    </sch:p>
    <sch:rule context="*[@ism:* except (@ism:pocType | @ism:DESVersion | @ism:unregisteredNoticeType) 
                            and $ISM_CAPCO_RESOURCE 
                            and $ISM_ICDOCUMENT_APPLIES 
                            and util:contributesToRollup(.)
                            and not(@ism:classification='U')]">
        <sch:assert  
        	test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('DISPLAYONLY', 'RELIDO','REL','EYES', 'NF'))"
            flag="error">
        	[ISM-ID-00119][Error] If ISM_CAPCO_RESOURCE and ISM_ICDOCUMENT_APPLIES
        	and attribute classification is specified with a value other than [U],
        	then attribute disseminationControls must contain one or more of the
        	following named tokens: [DISPLAYONLY], [REL], [RELIDO], [EYES], or [NF].
        	
        	Human Readable: All classified NSI that claims compliance with 
        	ICD 710 must have an appropriate foreign disclosure or release marking.
        </sch:assert>
    </sch:rule>
</sch:pattern>