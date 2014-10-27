<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern abstract="true" id="AttributeContributesToRollup"
	xmlns:sch="http://purl.oclc.org/dsdl/schematron">
  <sch:p id="codeDesc">
    If the document is an ISM_CAPCO_RESOURCE and an element meeting ISM_CONTRIBUTES
    specifies attribute ism:$attrLocalName with a value containing the token
    [$value], then we make sure that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:$attrLocalName with a value containing the token [$value].
  </sch:p>
  <sch:rule context="*[$ISM_CAPCO_RESOURCE
                      and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)
                      and (
                        some $ele in $partTags satisfies
                          util:containsAnyOfTheTokens($ele/@ism:$attrLocalName, ('$value'))
                      )]">
    <sch:assert test="util:containsAnyOfTheTokens(@ism:$attrLocalName, ('$value'))"
			flag="error">
			<sch:value-of select="$errorMessage"/>
    </sch:assert>
	</sch:rule>
</sch:pattern>