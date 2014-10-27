<?xml version="1.0" encoding="UTF-8"?>
<!--
    This abstract pattern checks to see if an attribute of an element exists in a list or matches the pattern defined by the list.

    $context        := the context in which the searchValue exists
    $searchTermList := the set of values which you want to verify is in the list
    $list           := the list in which to search for the searchValue
    $errMsg         := the error message text to display when the assertion fails
    
    Example usage:
    <sch:pattern is-a="ValidateValueExistenceInList" id="IRM_ID_00027" xmlns:sch="http://purl.oclc.org/dsdl/schematron">  
        <sch:param name="context" value="@ism:releasableTo"/>
        <sch:param name="searchTermList" value="."/>
        <sch:param name="list" value="$releasableToList"/>
        <sch:param name="errMsg" value="'
    		[ISM-ID-00265][Error] Any @ism:releasableTo must
    		be a value in CVEnumISMRelTo.xml.
        '"/>
    </sch:pattern>

    Note: $iso4217TrigraphList is defined in the main document, IRM_XML.xml.
-->
<sch:pattern abstract="true" id="ValidateTokenValuesExistenceInList" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">$ruleText</sch:p>
    <sch:p id="codeDesc">$codeDesc</sch:p>

    <sch:rule context="$context"> 
        <sch:assert
            test="every $searchTerm in tokenize(normalize-space(string($searchTermList)), ' ') satisfies 
                    $searchTerm = $list or
                    (some $listTerm in $list satisfies (matches(normalize-space($searchTerm), concat('^',$listTerm,'$')))) 
            "
            flag="error">
            <sch:value-of select="$errMsg"/>
        </sch:assert>
    </sch:rule>
</sch:pattern>