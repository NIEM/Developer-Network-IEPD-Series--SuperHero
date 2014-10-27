<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00028" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
      [ISM-ID-00028][Error] If ISM_CAPCO_RESOURCE and attribute 
      disseminationControls contains the name token [OC] or [EYES],
      then attribute classification must have a value of [TS], [S], or [C].
      
      Human Readable: Portions marked for ORCON or EYES ONLY dissemination 
      in a USA document must be CONFIDENTIAL, SECRET, or TOP SECRET.
    </sch:p>
    <sch:p id="codeDesc">
    	If the document is an ISM-CAPCO-RESOURCE, for each element which has 
    	attribute ism:disseminationControls specified with a value containing
    	the token [OC] or [EYES] we make sure that attribute
    	ism:classification is specified with a value of [C], [S], or [TS].
    </sch:p>
	<sch:rule context="*[$ISM_CAPCO_RESOURCE
	                    and util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC', 'EYES'))]">
        <sch:assert  
            test="@ism:classification=('TS', 'S', 'C')" 
            flag="error">
            [ISM-ID-00028][Error] If ISM_CAPCO_RESOURCE and attribute 
            disseminationControls contains the name token [OC] or [EYES], 
            then attribute classification must have a value of [TS], [S], or [C].
            
            Human Readable: Portions marked for ORCON or EYES ONLY dissemination 
            in a USA document must be CONFIDENTIAL, SECRET, or TOP SECRET.
        </sch:assert>
    </sch:rule>
</sch:pattern>