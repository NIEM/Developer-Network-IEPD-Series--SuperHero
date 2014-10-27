<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00056" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00056][Error] If ISM_CAPCO_RESOURCE and attribute classification of 
        ISM_RESOURCE_ELEMENT has a value of [U] then no element meeting ISM_CONTRIBUTES_USA in the document may have 
        a classification attribute of [C], [S], [TS], or [R].
        
        Human Readable: USA UNCLASSIFIED documents can't have portion markings with the classification TOP SECRET, SECRET, CONFIDENTIAL, or RESTRICTED data.    
    </sch:p>
    <sch:p id="codeDesc">
      If the document is an ISM-CAPCO-RESOURCE and attribute ism:classification
      on $ISM_RESOURCE_ELEMENT has a value of [U], then we make sure that
      no element meeting ISM_CONRIBUTES_USA has attribute ism:classification with
      value [C], [S], [TS], [R].
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
                        and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)
                        and normalize-space(string(@ism:classification))='U']">
        <sch:assert  
            test="every $ele in $partTags satisfies
                    not(util:containsAnyOfTheTokens($ele/@ism:classification, ('C', 'S', 'TS', 'R')))"
            flag="error">
          [ISM-ID-00056][Error] If ISM_CAPCO_RESOURCE and attribute classification of 
          ISM_RESOURCE_ELEMENT has a value of [U] then no element meeting ISM_CONTRIBUTES_USA in the document may have 
          a classification attribute of [C], [S], [TS], or [R].
          
          Human Readable: USA UNCLASSIFIED documents can't have portion markings with the classification TOP SECRET, SECRET, CONFIDENTIAL, or RESTRICTED data.  
        </sch:assert>
    </sch:rule>
</sch:pattern>