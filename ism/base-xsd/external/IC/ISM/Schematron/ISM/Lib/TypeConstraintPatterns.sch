<?xml version="1.0" encoding="UTF-8"?>
<!--
    This abstract pattern checks to see if an attribute of an element exists in a list.

    $context     := the context in which the searchValue exists
    $searchTerm  := the value which you want to verify is in the list
    $list        := the list in which to search for the searchValue
    $errMsg      := the error message text to display when the assertion fails
    
    Example usage:
    <sch:pattern is-a="ValidateValueExistenceInList" id="IRM_ID_00027" xmlns:sch="http://purl.oclc.org/dsdl/schematron">  
        <sch:param name="context" value="//irm:CountryCode[@irm:vocabulary='FIPS']"/>
        <sch:param name="searchTerm" value="."/>
        <sch:param name="list" value="$coverageFipsDigraphList"/>
        <sch:param name="errMsg" value="'
            [IRM-ID-00027][Error]
            If element CountryCode has attribute vocabulary specified as FIPS
            the element value must be in CVEnumIRMCoverageFIPSDigraph.xml.
        '"/>
    </sch:pattern>
    
    Note: $iso4217TrigraphList is defined in the main document, IRM_XML.xml.
-->
<sch:pattern id="typeConstraintPatterns"  xmlns:sch="http://purl.oclc.org/dsdl/schematron">

    <sch:let name="NameStartCharPattern" value="':|[A-Z]|_|[a-z]'"/>
    <sch:let name="NameCharPattern" value="concat($NameStartCharPattern, '|-|\.|[0-9]')"/>
    <sch:let name="NmTokenPattern" value="concat('(', $NameCharPattern, ')+')"/>
    <sch:let name="NmTokensPattern" value="concat($NmTokenPattern, '( ', $NmTokenPattern, ')*')"/>
    
    <!-- strings --> 
    <sch:let name="BooleanPattern" value="'(false|true|0|1)'"/>
    <sch:let name="DatePattern" value="'-?([1-9][0-9]{3,}|0[0-9]{3})-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])(Z|(\+|-)((0[0-9]|1[0-3]):[0-5][0-9]|14:00))?'"/>
    
</sch:pattern>