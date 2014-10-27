<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00033" is-a="MutuallyExclusiveAttributeValues"
	xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00033][Error] If ISM_CAPCO_RESOURCE, then tokens [REL], [EYES] 
        and [NF] are mutually exclusive for attribute disseminationControls.
    </sch:p>
	<sch:p id="codeDesc">
		This rule uses an abstract pattern to consolidate logic.
		If the document is an ISM-CAPCO-RESOURCE, for each element which 
		has attribute ism:disseminationControls specified with a value 
		containing the token [REL], [EYES] or [NF], we make sure that attribute
		ism:disseminationControls is specified with a value containing only 
		one of the tokens [REL], [EYES] or [NF].
	</sch:p>
	
	<sch:param name="context" value="*[$ISM_CAPCO_RESOURCE
                                	  and util:containsAnyOfTheTokens(@ism:disseminationControls, ('REL', 'EYES', 'NF'))]"/>
	<sch:param name="attrValue" value="@ism:disseminationControls"/>
	<sch:param name="mutuallyExclusiveTokenList" value="('REL', 'EYES', 'NF')"/>
	<sch:param name="errMsg" value="'
		[ISM-ID-00033][Error] If ISM_CAPCO_RESOURCE, then tokens [REL], [EYES] 
		and [NF] are mutually exclusive for attribute disseminationControls.
		'"/>
</sch:pattern>