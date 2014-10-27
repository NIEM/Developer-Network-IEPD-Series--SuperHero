<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00233" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00233][Error] If ISM_CAPCO_RESOURCE, then any portion with  
        attribute FGIsourceOpen specified and an ownerProducer containing [USA]
        must not have attribute disseminationControls containing [DISPLAYONLY] 
        or [RELIDO].
        
        Human Readable: DISPLAYONLY and RELIDO are not authorized for use on portions 
        containing Foreign Government Information.
    </sch:p>
    <sch:p id="codeDesc">
    	If the document is an ISM-CAPCO-RESOURCE, for each element which is not
    	the ISM_RESOURCE_ELEMENT, has attribute ism:FGIsourceOpen specified, has
    	attribute ism:disseminationControls specified, and has attribute 
    	ism:ownerProducer specified with a value containing the
    	token [USA], we make sure that attribute ism:disseminationControls does
    	not contain the token [DISPLAYONLY] or [RELIDO].
    </sch:p>
	<sch:rule context="*[$ISM_CAPCO_RESOURCE 
          						and not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT))
          						and @ism:FGIsourceOpen
	        		        and util:containsAnyOfTheTokens(@ism:ownerProducer, ('USA'))]">
        <sch:assert  
            test="not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('DISPLAYONLY', 'RELIDO')))"
            flag="error">
        	[ISM-ID-00233][Error] If ISM_CAPCO_RESOURCE, then any portion with  
        	attribute FGIsourceOpen specified and an ownerProducer containing [USA]
        	must not have attribute disseminationControls containing [DISPLAYONLY] 
        	or [RELIDO].
        	
        	Human Readable: DISPLAYONLY and RELIDO are not authorized for use on portions 
        	containing Foreign Government Information.
        </sch:assert>
    </sch:rule>
</sch:pattern>