<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00161" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00161][Error] If ISM_CAPCO_RESOURCE and:
        1. The attribute notice of ISM_RESOURCE_ELEMENT does contains [DoD-Dist-A]
        and does not have attribute externalNotice with a value of [true].
        AND
        2. attribute nonICmarkings contains any of [XD], [ND], [SBU], [SBU-NF], [LES], OR [LES-NF].
        
        Human Readable: Distribution statement A (Public Release) is incompatible with [XD], [ND], [SBU], [SBU-NF], [LES], OR [LES-NF].
    </sch:p>
    <sch:p id="codeDesc">
    	If the document is an ISM-CAPCO-RESOURCE and the attribute
    	noticeType of ISM_RESOURCE_ELEMENT contains the token [DoD-Dist-A]
    	and does not have attribute externalNotice with a value of [true], for
    	each element which specifies attribute ism:nonICmarkings we make
    	sure that attribute ism:nonICmarkings does not contain any of the
    	following tokens: [XD], [ND], [SBU], [SBU-NF], [LES], [LES-NF].
    </sch:p>
	<sch:rule context="*[$ISM_CAPCO_RESOURCE
						and (util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:noticeType, ('DoD-Dist-A')))
						and not (@ism:externalNotice=true())]">
		<sch:assert 
			test="not(util:containsAnyOfTheTokens(@ism:nonICmarkings, ('XD', 'ND', 'SBU', 'SBU-NF', 'LES', 'LES-NF')))"
			flag="error"> 
            [ISM-ID-00161][Error] Distribution statement A (Public Release) is incompatible with [XD], [ND], [SBU], [SBU-NF], [LES], OR [LES-NF].
        </sch:assert>
    </sch:rule>
</sch:pattern>
