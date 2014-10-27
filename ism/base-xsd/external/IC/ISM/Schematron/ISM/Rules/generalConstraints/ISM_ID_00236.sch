<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00236" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText"> [ISM-ID-00236][Error] Duplicate tokens are not permitted in ISM
        attributes.</sch:p>

    <sch:p id="codeDesc"> To determine the valid values, this rule first retrieves the CVE values
        for the attribute, which in this case is classification. Then, each attribute token is
        converted into a numerical value based on its characters. Next, each attribute token is
        given an order number, which compares its position to that of its value in the CVE file. If
        the token is not found, its order number will be -1. If the document is a CAPCO resource and
        the ownerProducer of this element is 'USA', then the rule will fail if tokens are found with
        order numbers of -1. The rule will also fail if duplicate values are found for the element,
        or when its count is greater than 1. </sch:p>

    <sch:rule context="*[@ism:*]">
        <!-- Define variables -->
        <sch:let name="errMsg_ValueNotFound"
            value="'
            [ISM-ID-00236][Error] If ISM_CAPCO_RESOURCE and attribute 
            ownerProducer contains [USA] then attribute classification must have a value in 
            CVEnumISMClassificationUS.xml.'
            "/>

        <!-- Determine if the list has duplicate values. If and only if it does, figure out which ones are duplicates -->
        <sch:let name="dupAttrs"
            value="for $attr in ./@ism:* return if(count(distinct-values(tokenize(string($attr),' '))) != count(tokenize(string($attr),' '))) then $attr else null"/>
        <sch:let name="hasDups" value="count($dupAttrs)>0"/>
        <sch:let name="dupValues"
            value="
    if ($hasDups) then
    distinct-values(
    for $attrib in $dupAttrs return
    for $each in tokenize(string($attrib),' ') return
    if(count(index-of(tokenize(string($attrib),' '), $each))>1)
    then concat(string($each),' in attribute ',$attrib/name(),'; ')
    else null)
    else null
    "/>

        <sch:assert test="not($hasDups)" flag="error"> [ISM-ID-00236][Error] Duplicate tokens
            are not permitted in ISM attributes. Duplicate values found: [<sch:value-of
                select="$dupValues"/>]</sch:assert>
    </sch:rule>
</sch:pattern>
