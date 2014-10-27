<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern abstract="true" id="DataHasCorrespondingNotice"
	xmlns:sch="http://purl.oclc.org/dsdl/schematron">	
	<sch:rule context="*[$ISM_CAPCO_RESOURCE
                  	  and util:contributesToRollup(.)
					and util:containsAnyOfTheTokens($attrValue, ($noticeType))]">
		<sch:assert test="
			some $elem in $partTags satisfies
				($elem[@ism:noticeType]
				and util:containsAnyOfTheTokens($elem/@ism:noticeType, ($noticeType))
				and not ($elem/@ism:externalNotice=true()))"
			flag="error">
			[<sch:value-of select="$ruleId"/>][Error]
			If ISM_CAPCO_RESOURCE, any element meeting ISM_CONTRIBUTES in 
			the document has the attribute <sch:value-of select="$attrName"/> containing 
			[<sch:value-of select="$noticeType"/>], then some element
			meeting ISM_CONTRIBUTES in the document MUST have attribute
			noticeType containing [<sch:value-of select="$noticeType"/>].
			
			Human Readable:
			USA documents containing <sch:value-of select="$noticeType"/> 
			data must also have an <sch:value-of select="$noticeType"/> notice.
		</sch:assert>
		</sch:rule>
</sch:pattern>