<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00173" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00173][Error] If ISM_CAPCO_RESOURCE and attribute 
        atomicEnergyMarkings contains a name token starting with 
        [RD-SG] or [FRD-SG], then attribute classification must 
        have a value of [TS], [S], or [C].
        
        Human Readable: Portions in a USA document that contain RD or FRD SIGMA 
        data must be marked CONFIDENTIAL, SECRET, or TOP SECRET.
    </sch:p>
	<sch:p id="codeDesc">
		If the document is an ISM-CAPCO-RESOURCE, for each element which has 
		attribute ism:atomicEnergyMarkings specified with a value containing 
		a token starting with [RD-SG] or [FRD-SG], we make sure that the attribute 
		ism:classification has a value of [TS], [S], or [C].
	</sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE 
                        and util:containsAnyTokenMatching(@ism:atomicEnergyMarkings, ('^RD-SG', '^FRD-SG'))]">
		<sch:assert 
			test="@ism:classification = ('TS','S','C')" 
			flag="error">
		   [ISM-ID-00173][Error] If ISM_CAPCO_RESOURCE and attribute 
        atomicEnergyMarkings contains a name token starting with 
        [RD-SG] or [FRD-SG], then attribute classification must 
        have a value of [TS], [S], or [C].
        
        Human Readable: Portions in a USA document that contain RD or FRD SIGMA 
        data must be marked CONFIDENTIAL, SECRET, or TOP SECRET.
		</sch:assert>
	</sch:rule>
</sch:pattern>