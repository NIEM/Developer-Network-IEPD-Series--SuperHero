<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<sch:pattern id="ISM-ID-00240" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00240][Error] If ISM_CAPCO_RESOURCE and attribute noticeType of
        ISM_RESOURCE_ELEMENT contains the token [DoD-Dist-A], then any element
        which contributes to rolluop should not have an attribute
        atomicEnergyMarkings that contains any of the following tokens:
        [DCNI], [UCNI].
        
        Human Readable: Distribution statement A (Public Release) is incompatible 
        with [DCNI] and [UCNI].
    </sch:p>
    <sch:p id="codeDesc">
    	If the document is an ISM-CAPCO-RESOURCE and the attribute
    	noticeType of ISM_RESOURCE_ELEMENT contains the token [DoD-Dist-A], for
    	each element which specifies attribute ism:atomicEnergyMarkings we make
    	sure that attribute ism:atomicEnergyMarkings does not contain any of the
    	following tokens: [DCNI], [UCNI].
    </sch:p>
	<sch:rule context="*[$ISM_CAPCO_RESOURCE
						          and util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:noticeType, ('DoD-Dist-A'))
						          and not (@ism:excludeFromRollup='true')]">
        <sch:assert 
        	test="not(util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('DCNI', 'UCNI')))"
            flag="error"> 
            [ISM-ID-00240][Error] If ISM_CAPCO_RESOURCE and attribute noticeType of
            ISM_RESOURCE_ELEMENT contains the token [DoD-Dist-A], then any element
            which contributes to rolluop should not have an attribute
            atomicEnergyMarkings that contains any of the following tokens:
            [DCNI], [UCNI].
            
            Human Readable: Distribution statement A (Public Release) is incompatible 
            with [DCNI] and [UCNI].
        </sch:assert>
    </sch:rule>
</sch:pattern>
