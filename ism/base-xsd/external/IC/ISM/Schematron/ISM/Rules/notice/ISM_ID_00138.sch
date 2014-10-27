<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00138" is-a="NoticeHasCorrespondingData"
	xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00138][Error] If ISM_CAPCO_RESOURCE and:
        1. No element without ism:excludeFromRollup=true() in the document has the attribute nonICmarkings containing [DS]
        AND
        2. Any element without ism:excludeFromRollup=true() in the document has the attribute noticeType containing [DS]
        and does not specifiy attribute ism:externalNotice with a 
        value of [true].
        Human Readable: USA documents containing a non-external DS notice must also have DS data. 
    </sch:p>
	<sch:p id="codeDesc">
		This rule uses an abstract pattern to consolidate logic.
		If the document is an ISM-CAPCO-RESOURCE and any element meets
		ISM_CONTRIBUTES and specifies attribute ism:noticeType
		with a value containing the token [DS] and does not specifiy attribute ism:externalNotice with a 
		value of [true], we make sure that an element
		meeting ISM_CONTRIBUTES specifies attribute ism:nonICmarkings
		with a value containing the token [DS].
	</sch:p>
	<sch:param name="ruleId" value="'ISM-ID-00138'"/>
	<sch:param name="attrName" value="'nonICmarkings'"/>
	<sch:param name="dataType" value="'DS'"/>
	<sch:param name="dataTokenList" value="$partNonICmarkings_tok"/>
</sch:pattern>