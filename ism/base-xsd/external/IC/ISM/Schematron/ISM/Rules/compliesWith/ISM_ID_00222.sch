<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00222" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00222][Error] If ISM_INTELREPORT_APPLIES, then attribute pocType
        must be specified with a value of [ICD-710] on some element in the
        document.
        
        Human Readable: A document claiming compliance with ICD-710 must specify
        a point-of-contact to whom questions about the document can be directed.
    </sch:p>
    <sch:p id="codeDesc">
        If ISM_INTELREPORT_APPLIES, then ensure that some element specifies 
        attribute ism:pocType with a value of [ICD-710].
    </sch:p> 
    <sch:rule context="/*[$ISM_INTELREPORT_APPLIES]">       
        <sch:assert  
            test="index-of($partPocType_tok, 'ICD-710') > 0" 
            flag="error">
        	[ISM-ID-00222][Error] If ISM_INTELREPORT_APPLIES, then attribute pocType
        	must be specified with a value of [ICD-710] on some element in the
        	document.
        	
        	Human Readable: A document claiming compliance with ICD-710 must specify
        	a point-of-contact to whom questions about the document can be directed.
        </sch:assert>
    </sch:rule>
</sch:pattern>