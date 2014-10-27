<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00213" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00213][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [DISPLAYONLY], then 
        attribute displayOnlyTo must be specified.
        
        Human Readable: A USA document with DISPLAY ONLY dissemination must 
        indicate the countries to which it may be disclosed.
    </sch:p>
    <sch:p id="codeDesc">
    	If the document is an ISM-CAPCO-RESOURCE, for each element which has 
    	attribute ism:disseminationControls specified with a value containing
    	the token [DISPLAYONLY] we make sure that attribute ism:displayOnlyTo
    	is specified.
    </sch:p>
  <sch:rule context="*[$ISM_CAPCO_RESOURCE
                      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('DISPLAYONLY'))]">
        <sch:assert  
            test="@ism:displayOnlyTo"
            flag="error">
        	[ISM-ID-00213][Error] If ISM_CAPCO_RESOURCE and attribute 
        	disseminationControls contains the name token [DISPLAYONLY], then 
        	attribute displayOnlyTo must be specified.
        	
        	Human Readable: A USA document with DISPLAY ONLY dissemination must 
        	indicate the countries to which it may be disclosed.
        </sch:assert>
    </sch:rule>
</sch:pattern>