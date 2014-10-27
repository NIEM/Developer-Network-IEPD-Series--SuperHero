<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00130" is-a="DataHasCorrespondingNotice"
	xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00130][Error] If ISM_CAPCO_RESOURCE and:
        1. Any element meeting ISM_CONTRIBUTES in the document has the attribute disseminationControls containing [FISA]
        AND
        2. No element meeting ISM_CONTRIBUTES in the document has the attribute noticeType containing [FISA]
        and does not have attribute externalNotice with a value of [true]
        Human Readable: USA documents containing FISA data must also have a non-external FISA notice.
    </sch:p>
	<sch:p id="codeDesc">
		This rule uses an abstract pattern to consolidate logic.
		If the document is an ISM-CAPCO-RESOURCE, for each element which
		meets ISM_CONTRIBUTES and specifies attribute ism:disseminationControls
		with a value containing the token [FISA], we make sure that an element
		meeting ISM_CONTRIBUTES specifies attribute ism:noticeType with a value
		containing the token [FISA] and does not specifiy attribute ism:externalNotice with a 
		value of [true].
	</sch:p>
	<sch:param name="ruleId" value="'ISM-ID-00130'"/>
	<sch:param name="attrName" value="'disseminationControls'"/>
	<sch:param name="attrValue" value="@ism:disseminationControls"/>
	<sch:param name="noticeType" value="'FISA'"/>
</sch:pattern>