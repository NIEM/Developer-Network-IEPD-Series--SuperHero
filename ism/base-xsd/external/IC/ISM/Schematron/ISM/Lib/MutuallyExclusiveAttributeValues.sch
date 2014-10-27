<?xml version="1.0" encoding="UTF-8"?>

<sch:pattern abstract="true" id="MutuallyExclusiveAttributeValues"
	xmlns:sch="http://purl.oclc.org/dsdl/schematron">	
	<sch:rule context="$context">
		<sch:assert test="
			count(
				for $token in tokenize(normalize-space(string($attrValue)),' ') return
					if($token = $mutuallyExclusiveTokenList)
					then 1
					else null
			) = 1"
			flag="warning">
			<sch:value-of select="$errMsg"/>
		</sch:assert>
	</sch:rule>
</sch:pattern>