<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00181" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00181][Error] If ISM_CAPCO_RESOURCE and element's 
        classification does not have a value of "U" then attribute atomicEnergyMarkings must not 
        contain the name token [UCNI] or [DCNI].
        
        Human Readable: UCNI and DCNI may only be used on UNCLASSIFIED portions.
    </sch:p>
	<sch:p id="codeDesc">
		If the document is an ISM-CAPCO-RESOURCE, for each element which has 
		attribute ism:atomicEnergyMarkings specified and has attribute 
		ism:classification specified with a value other than [U], we 
		make sure that attribute ism:atomicEnergyMarkings does not contain the 
		token [UCNI] or [DNCI].
	</sch:p>
	<sch:rule context="*[$ISM_CAPCO_RESOURCE
	                    and @ism:atomicEnergyMarkings
	                    and not(@ism:classification='U')]">
		<sch:assert 
		  test="not(util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('UCNI', 'DCNI')))" 
			flag="error">
        [ISM-ID-00181][Error] If ISM_CAPCO_RESOURCE and element's 
        classification does not have a value of "U" then attribute atomicEnergyMarkings must not 
        contain the name token [UCNI] or [DCNI].
        
        Human Readable: UCNI and DCNI may only be used on UNCLASSIFIED portions.
		</sch:assert>
	</sch:rule>
</sch:pattern>