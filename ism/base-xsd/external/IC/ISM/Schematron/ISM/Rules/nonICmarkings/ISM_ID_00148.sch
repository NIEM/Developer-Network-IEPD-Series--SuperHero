<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00148" is-a="MutuallyExclusiveAttributeValues"
	xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00148][Error] If ISM_CAPCO_RESOURCE, then Name tokens [LES] and [LES-NF] are mutually
        exclusive for attribute nonICmarkings.
        
        Human Readable: USA documents must not specify both LES and LES-NF on a single element.
    </sch:p>
	<sch:p id="codeDesc">
		This rule uses an abstract pattern to consolidate logic.
		If the document is an ISM-CAPCO-RESOURCE, for each element which 
		has attribute ism:nonICmarkings specified with a value containing
		the token [LES] or [LES-NF], we make sure that attribute
		ism:nonICmarkings is not specified with a value containing both tokens
		[LES] and [LES-NF].
	</sch:p>
	
	<sch:param name="context" value="*[$ISM_CAPCO_RESOURCE
									and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES', 'LES-NF'))]"/>
	<sch:param name="attrValue" value="@ism:nonICmarkings"/>
	<sch:param name="mutuallyExclusiveTokenList" value="('LES', 'LES-NF')"/>
	<sch:param name="errMsg" value="'
		[ISM-ID-00148][Error] If ISM_CAPCO_RESOURCE, then Name tokens 
		[LES] and [LES-NF] are mutually exclusive for attribute nonICmarkings.
		
		Human Readable: USA documents must not specify both LES and LES-NF 
		on a single element.
		'"/>
</sch:pattern>