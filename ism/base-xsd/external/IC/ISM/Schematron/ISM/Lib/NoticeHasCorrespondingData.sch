<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern abstract="true" id="NoticeHasCorrespondingData"
	xmlns:sch="http://purl.oclc.org/dsdl/schematron">	
	<sch:rule context="*[$ISM_CAPCO_RESOURCE
						and util:contributesToRollup(.)
	                    and not (@ism:externalNotice=true())
                  		and util:containsAnyOfTheTokens(@ism:noticeType, ($dataType))]">
		<sch:assert test="
			index-of($dataTokenList, $dataType)>0"
			flag="error">
			[<sch:value-of select="$ruleId"/>][Error]
			If ISM_CAPCO_RESOURCE and any element meeting 
			ISM_CONTRIBUTES in the document has the attribute noticeType 
			containing [<sch:value-of select="$dataType"/>], then some element
			meeting ISM_CONTRIBUTES in the document MUST have attribute <sch:value-of select="$attrName"/> containing 
			[<sch:value-of select="$dataType"/>].
			
			Human Readable: USA documents containing an <sch:value-of select="$dataType"/> 
			notice must also have <sch:value-of select="$dataType"/> data.
		</sch:assert>
	</sch:rule>
</sch:pattern>