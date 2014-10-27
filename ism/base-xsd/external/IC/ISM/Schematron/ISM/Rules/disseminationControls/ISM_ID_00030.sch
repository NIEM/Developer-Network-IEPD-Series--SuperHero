<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00030" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00030][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [FOUO], then attribute
        classification must have a value of [U].
        
        Human Readable: Portions marked for FOUO dissemination in a USA document
        must be classified UNCLASSIFIED.
    </sch:p>
    <sch:p id="codeDesc">
    	If the document is an ISM-CAPCO-RESOURCE, for each element which has 
    	attribute ism:disseminationControls specified with a value containing
    	the token [FOUO] we make sure that attribute ism:classification is 
    	specified with a value of [U].
    </sch:p>
	<sch:rule context="*[$ISM_CAPCO_RESOURCE
                  	  and util:containsAnyOfTheTokens(@ism:disseminationControls, ('FOUO'))]">
        <sch:assert  
            test="@ism:classification='U'"
            flag="error">
        	[ISM-ID-00030][Error] If ISM_CAPCO_RESOURCE and attribute 
        	disseminationControls contains the name token [FOUO], then attribute
        	classification must have a value of [U].
        	
        	Human Readable: Portions marked for FOUO dissemination in a USA document
        	must be classified UNCLASSIFIED.
        </sch:assert>
    </sch:rule>
</sch:pattern>