<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00175" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00175][Error] If ISM_CAPCO_RESOURCE and attribute 
        atomicEnergyMarkings contains the name token [RD-CNWDI], then attribute 
        classification must have a value of [TS] or [S].
    </sch:p>
	<sch:p id="codeDesc">
		If the document is an ISM-CAPCO-RESORUCE, for each element which has 
		attribute ism:atomicEnergyMarkings specified with a value containing 
		the token [RD-CNWDI], we make sure that the attribute ism:classification
		has a value of [TS] or [S].
	</sch:p>
  <sch:rule context="*[$ISM_CAPCO_RESOURCE 
                      and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD-CNWDI'))]">
		<sch:assert 
			test="@ism:classification = ('TS','S')" 
			flag="error">
			[ISM-ID-00175][Error] If ISM-CAPCO-RESOURCE and attribute 
			atomicEnergyMarkings contains the name token [RD-CNWDI], then attribute 
			classification must have a value of [TS] or [S].
		</sch:assert>
	</sch:rule>
</sch:pattern>