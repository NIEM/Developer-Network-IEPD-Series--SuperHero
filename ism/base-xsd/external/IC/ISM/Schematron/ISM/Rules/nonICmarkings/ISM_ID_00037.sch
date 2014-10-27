<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00037" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00037][Error] If ISM_CAPCO_RESOURCE and attribute nonICmarkings
        contains the name token [SBU], [SBU-NF] then attribute
        classification must have a value of [U].
        
        Human Readable: SBU, SBU-NF data must be marked UNCLASSIFIED
        in USA documents.
    </sch:p>
    <sch:p id="codeDesc">
    	If the document is an ISM-CAPCO-RESOURCE, for each element which 
    	has attribute ism:nonICmarkings specified with a value containing
    	the token [SBU], [SBU-NF] we make sure that attribute
    	ism:classification is specified with a value of [U].
    </sch:p>
	<sch:rule context="*[$ISM_CAPCO_RESOURCE
						          and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('SBU', 'SBU-NF'))]">
        <sch:assert
            test="@ism:classification='U'"
            flag="error">
          [ISM-ID-00037][Error] If ISM_CAPCO_RESOURCE and attribute nonICmarkings
          contains the name token [SBU], [SBU-NF] then attribute
          classification must have a value of [U].
          
          Human Readable: SBU, SBU-NF data must be marked UNCLASSIFIED
          in USA documents.
        </sch:assert>
    </sch:rule>
</sch:pattern>