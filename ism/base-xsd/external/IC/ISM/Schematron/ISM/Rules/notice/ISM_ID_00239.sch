<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<sch:pattern id="ISM-ID-00239" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:p id="ruleText">
		[ISM-ID-00239][Error] If ISM_CAPCO_RESOURCE and attribute noticeType of
		ISM_RESOURCE_ELEMENT contains the token [DoD-Dist-A], then any element 
		which contributes to rollup should not have an attribute
		disseminationControls that contains any of the following tokens:
		[FOUO], [PR], [DSEN], or [FISA].
		
		Human Readable: Distribution statement A (Public Release) is incompatible 
		with [FOUO], [PR], [DSEN], and [FISA] for contributing portions.
	</sch:p>
	<sch:p id="codeDesc">
		If the document is an ISM-CAPCO-RESOURCE and the attribute
		noticeType of ISM_RESOURCE_ELEMENT contains the token [DoD-Dist-A], for
		each element which specifies attribute ism:disseminationControls 
		we make sure that attribute ism:disseminationControls does not contain any of the
		following tokens: [FOUO], [PR], [DSEN], [FISA].
	</sch:p>
	<sch:rule context="*[$ISM_CAPCO_RESOURCE
		and util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:noticeType, ('DoD-Dist-A'))
		and not (@ism:excludeFromRollup='true')]">
		<sch:assert 
			test="
			not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('FOUO', 'PR', 'DSEN', 'FISA')))"
			flag="error"> 
			[ISM-ID-00239][Error] If ISM_CAPCO_RESOURCE and attribute noticeType of
			ISM_RESOURCE_ELEMENT contains the token [DoD-Dist-A], then any element 
			which contributes to rollup should not have an attribute
			disseminationControls that contains any of the following tokens:
			[FOUO], [PR], [DSEN], or [FISA].
			
			Human Readable: Distribution statement A (Public Release) is incompatible 
			with [FOUO], [PR], [DSEN], and [FISA] for contributing portions.
		</sch:assert>
	</sch:rule>
</sch:pattern>
