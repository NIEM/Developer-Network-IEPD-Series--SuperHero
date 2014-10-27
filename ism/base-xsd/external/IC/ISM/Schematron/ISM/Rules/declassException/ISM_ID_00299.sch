<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00299" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00299][Error] If an element contains the attribute declassException with a value of [AEA], 
        it must also contain the attribute atomicEnergyMarkings.
    </sch:p>
	<sch:p id="codeDesc">
		If an element contains an ism:declassException attribute with a value containing
		AEA, we must check to make sure that element also has an ism:atomicEnergyMarkings
		attribute.
	</sch:p>
	<sch:rule context="*[util:containsAnyTokenMatching(@ism:declassException, ('AEA'))]">
		<sch:assert 
			test="@ism:atomicEnergyMarkings" 
			flag="error">
			[ISM-ID-00299][Error] If an element contains the attribute declassException with a value of [AEA], 
			it must also contain the attribute atomicEnergyMarkings.
		</sch:assert>
	</sch:rule>
</sch:pattern>