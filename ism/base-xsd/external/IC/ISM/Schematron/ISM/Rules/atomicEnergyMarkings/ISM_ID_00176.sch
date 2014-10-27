<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00176" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00176][Error] If ISM_CAPCO_RESOURCE and attribute 
        atomicEnergyMarkings has a name token containing [RD] or [FRD], 
        then attributes declassDate and declassEvent cannot be specified
        on the resourceElement.
        
        Human Readable: Automatic declassification of documents containing 
        RD or FRD information is prohibited. Attributes declassDate and 
        declassEvent cannot be used in the classification authority block when 
        RD or FRD is present.
    </sch:p>
    <sch:p id="codeDesc">
    	If the document is an ISM-CAPCO-RESOURCE, for each element which 
    	has attribute ism:atomicEnergyMarkings specified with a value containing
    	the token [RD] or [FRD], we make sure that the resourceElement does not
    	have attributes ism:declassDate or ism:declassEvent specified.
    </sch:p>
	
  <sch:rule context="*[$ISM_CAPCO_RESOURCE 
                      and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD', 'FRD'))]">
        <sch:assert  
            test="not($ISM_RESOURCE_ELEMENT/@ism:declassDate or $ISM_RESOURCE_ELEMENT/@ism:declassEvent)" 
            flag="error">
        	[ISM-ID-00176][Error] Automatic declassification of documents containing 
        	RD or FRD information is prohibited. Attributes declassDate and 
        	declassEvent cannot be used in the classification authority block when 
        	RD or FRD is present.
        </sch:assert>
    </sch:rule>
</sch:pattern>