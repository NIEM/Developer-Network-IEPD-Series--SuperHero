<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00107" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00107][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [IMC] then attribute 
        classification must have a value of [TS] or [S].
        
        Human Readable:  IMCON data is SECRET (S), but may appear with 
        S or TOP SECRET data.
    </sch:p>
    <sch:p id="codeDesc">
    	If the document is an ISM-CAPCO-RESOURCE, for each element which has 
    	attribute ism:disseminationControls specified with a value containing
    	the token [IMC] we make sure that attribute ism:classification is not
    	specified with a value of [TS] or [S].
    </sch:p>
	<sch:rule context="*[$ISM_CAPCO_RESOURCE
                  	  and util:containsAnyOfTheTokens(@ism:disseminationControls, ('IMC'))]">
        <sch:assert  
            test="@ism:classification=('TS', 'S')"
            flag="error">
        	[ISM-ID-00107][Error] If ISM_CAPCO_RESOURCE and attribute 
        	disseminationControls contains the name token [IMC] then attribute 
        	classification must have a value of [TS] or [S].
        	
        	Human Readable:  IMCON data is SECRET (S), but may appear with 
        	S or TOP SECRET data.
        </sch:assert>
    </sch:rule>
</sch:pattern>