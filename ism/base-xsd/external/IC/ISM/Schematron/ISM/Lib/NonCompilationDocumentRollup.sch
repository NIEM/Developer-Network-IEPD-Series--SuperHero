<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern abstract="true" id="NonCompilationDocumentRollup"
	xmlns:sch="http://purl.oclc.org/dsdl/schematron">
  <sch:p id="codeDesc">
    If ISM_CAPCO_RESOURCE and attribute $attrLocalName of ISM_RESOURCE_ELEMENT 
    has a value of [$value] and attribute ism:compilationReason does not have a 
    value, then we make sure that at least one element meeting ISM_CONTRIBUTES 
    specifies attribute $attrLocalName with a value of [$value].
  </sch:p>
  <sch:rule context="*[$ISM_CAPCO_RESOURCE
                      and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)
                      and util:containsAnyOfTheTokens(@ism:$attrLocalName, ('$value'))
                      and string-length(normalize-space(@ism:compilationReason)) = 0]">
      <sch:assert test="
        some $ele in $partTags satisfies
          util:containsAnyOfTheTokens($ele/@ism:$attrLocalName, ('$value'))"
			flag="error">
			<sch:value-of select="$errorMessage"/>
      </sch:assert>
	</sch:rule>
</sch:pattern>