<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00255" is-a="ValidateTokenValuesExistenceInList"
	xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00255][Error] All @ism:compliesWith values must
        be defined in CVEnumISMCompliesWith.xml.
    </sch:p>

	<sch:p id="codeDesc">
		This rule uses an abstract pattern to consolidate logic. It checks that the
		value in parameter $searchTerm is contained in the parameter $list. The parameter
		$searchTerm is relative in scope to the parameter $context. The value for the parameter 
		$list is a variable defined in the main document (ISM_XML.sch), which reads 
		values from a specific CVE file.
	</sch:p>
	
	<sch:param name="context" value="*[@ism:compliesWith]"/>
	<sch:param name="searchTermList" value="@ism:compliesWith"/>
	<sch:param name="list" value="$compliesWithList"/>
	<sch:param name="errMsg" value="'
		[ISM-ID-00255][Error] All @ism:compliesWith values must
		be defined in CVEnumISMCompliesWith.xml.
		'"/>
</sch:pattern>