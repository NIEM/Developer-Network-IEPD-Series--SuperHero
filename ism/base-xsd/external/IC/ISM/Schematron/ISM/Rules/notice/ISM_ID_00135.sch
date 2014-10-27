<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00135" is-a="NoticeHasCorrespondingData"
	xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00135][Error] If ISM_CAPCO_RESOURCE and:
        1. No element meeting ISM_CONTRIBUTES in the document has the attribute atomicEnergyMarkings containing [RD]
        AND
        2. Any element meeting ISM_CONTRIBUTES in the document has the attribute noticeType containing [RD]
        and does not specifiy attribute ism:externalNotice with a 
        value of [true].
        Human Readable: USA documents containing an non-external RD notice must also have RD data.
    </sch:p>
	<sch:p id="codeDesc">
		This rule uses an abstract pattern to consolidate logic.
		If the document is an ISM-CAPCO-RESOURCE and any element meets
		ISM_CONTRIBUTES and specifies attribute ism:noticeType
		with a value containing the token [RD] and does not specifiy attribute ism:externalNotice with a 
		value of [true], we make sure that an element
		meeting ISM_CONTRIBUTES specifies attribute ism:atomicEnergyMarkings
		with a value containing the token [RD].
	</sch:p>
	<sch:param name="ruleId" value="'ISM-ID-00135'"/>
	<sch:param name="attrName" value="'atomicEnergyMarkings'"/>
	<sch:param name="dataType" value="'RD'"/>
	<sch:param name="dataTokenList" value="$partAtomicEnergyMarkings_tok"/>
</sch:pattern>