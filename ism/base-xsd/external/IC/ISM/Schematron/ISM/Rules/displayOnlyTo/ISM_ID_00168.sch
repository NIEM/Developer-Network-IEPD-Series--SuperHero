<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00168" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00168][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls is not specified or is specified and does not contain the name token 
        [DISPLAYONLY], then attribute displayOnlyTo must not be specified.
        
        Human Readable: If a portion in a USA document is not marked for DISPLAY ONLY dissemination, 
        it must not list countries to which it may be disclosed. 
    </sch:p>
    <sch:p id="codeDesc">
        If the document is an ISM-CAPCO-RESOURCE and attribute ism:disseminationControls
      	does not contain the token [DISPLAYONLY], we make sure that the attribute 
      	ism:displayOnlyTo is not specified.
    </sch:p>
	<sch:rule context="*[$ISM_CAPCO_RESOURCE
                      and not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('DISPLAYONLY')))]">
        <sch:assert 
            test="not(@ism:displayOnlyTo)"
            flag="error">
            [ISM-ID-00168][Error] If ISM_CAPCO_RESOURCE and attribute 
            disseminationControls is not specified or is specified and does not contain the name token 
            [DISPLAYONLY], then attribute displayOnlyTo must not be specified.
            
            Human Readable: If a portion in a USA document is not marked for DISPLAY ONLY dissemination, 
            it must not list countries to which it may be disclosed.
        </sch:assert>
    </sch:rule>
</sch:pattern>