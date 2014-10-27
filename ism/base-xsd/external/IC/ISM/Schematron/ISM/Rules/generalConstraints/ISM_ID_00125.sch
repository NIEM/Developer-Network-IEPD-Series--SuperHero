<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00125" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
  
  <sch:p id="ruleText">
    [ISM-ID-00125][Error] If any attributes in namespace 
    urn:us:gov:ic:ism exist, the local name must exist in CVEnumISMAttributes.xml. 
    
    Human Readable: Ensure that attributes in the ISM namespace are defined by ISM.XML.
  </sch:p>
  <sch:p id="codeDesc">
    This rule uses an abstract pattern to consolidate logic. It checks that the
    value in parameter $searchTerm is contained in the parameter $list. The parameter
    $searchTerm is relative in scope to the parameter $context. The value for the parameter 
    $list is a variable defined in the main document (ISM_XML.sch), which reads 
    values from a specific CVE file.
  </sch:p>
  <sch:rule context="*[@ism:*]"> 
    <sch:assert
      test="every $attr in @ism:* satisfies
              $attr[local-name() = $validAttributeList]"
      flag="error">
      <sch:value-of select="'
        [ISM-ID-00125][Error] If any attributes in namespace 
        urn:us:gov:ic:ism exist, the local name must exist in CVEnumISMAttributes.xml. 
        
        Human Readable: Ensure that attributes in the ISM namespace are defined by ISM.XML.
        '"/>
    </sch:assert>
  </sch:rule>
</sch:pattern>