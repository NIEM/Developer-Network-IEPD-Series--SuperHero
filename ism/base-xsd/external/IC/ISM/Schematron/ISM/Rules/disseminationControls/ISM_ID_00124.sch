<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00124" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
      [ISM-ID-00124][Warning] If ISM_CAPCO_RESOURCE and
      1. Attribute ownerProducer does not contain [USA].
      AND
      2. Attribute disseminationControls contains [RELIDO]
      
      Human Readable: RELIDO is not authorized for non-US portions.
    </sch:p>
    <sch:p id="codeDesc">
    	If the document is an ISM-CAPCO-RESOURCE, for each element which has 
    	attribute ism:disseminationControls specified with a value containing
    	the token [RELIDO] we make sure that attribute ism:ownerProducer is
    	specified with a value containing [USA].
    </sch:p>
	<sch:rule context="*[$ISM_CAPCO_RESOURCE
                  	  and util:containsAnyOfTheTokens(@ism:disseminationControls, ('RELIDO'))]">
        <sch:assert  
            test="util:containsAnyOfTheTokens(@ism:ownerProducer, ('USA'))"
            flag="warning">
          [ISM-ID-00124][Warning] If ISM_CAPCO_RESOURCE and
          1. Attribute ownerProducer does not contain [USA].
          AND
          2. Attribute disseminationControls contains [RELIDO]
          
          Human Readable: RELIDO is not authorized for non-US portions.
        </sch:assert>
    </sch:rule>
</sch:pattern>