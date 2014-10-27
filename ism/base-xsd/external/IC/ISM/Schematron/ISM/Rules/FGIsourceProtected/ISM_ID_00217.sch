<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00217" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00217][Error] If ISM_CAPCO_RESOURCE attribute FGIsourceProtected
        contains [FGI], it must be the only value.
    </sch:p>
    <sch:p id="codeDesc">
    	If the document is an ISM-CAPCO-RESOURCE, for each element which specifies
    	the attribute ism:FGIsourceProtected, we make sure that attribute
    	ism:FGIsourceProtected contains only the token [FGI].
    </sch:p>
	<sch:rule context="*[$ISM_CAPCO_RESOURCE and @ism:FGIsourceProtected]">
		<sch:assert
			test="normalize-space(string(@ism:FGIsourceProtected))='FGI'"
            flag="error">
        	[ISM-ID-00217][Error] If ISM_CAPCO_RESOURCE attribute FGIsourceProtected
        	contains [FGI], it must be the only value.
        </sch:assert>
    </sch:rule>
</sch:pattern>