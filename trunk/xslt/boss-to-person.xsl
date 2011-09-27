<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:boss="http://hdl.handle.net/102.100.100/7003"
>
	<xsl:template match="boss:job">
		<xsl:variable name="request-values" select="boss:request/boss:value"/>
		<person xmlns="http://hdl.handle.net/102.100.100/6976">
			<name><xsl:value-of select="$request-values[@name='Users Name']"/></name>
			<department><xsl:value-of select="$request-values[@name='Users Department']" /></department>
			<institution><xsl:value-of select="$request-values[@name='Users Institution']" /></institution>
			<dateOfBirth></dateOfBirth>
			<alternativeName></alternativeName>
			<abbreviatedName></abbreviatedName>
			<url></url>
			<email><xsl:value-of select="$request-values[@name='Users Email']" /></email>
			<phone><xsl:value-of select="$request-values[@name='Users Telephone']" /></phone>
			<fax><xsl:value-of select="$request-values[@name='Users Fax']" /></fax>
			<otherElectronic type=""></otherElectronic>
			<postalAddress>
				<country></country>
				<postcode></postcode>
				<state></state>
				<text><xsl:value-of select="$request-values[@name='Users Address']" /></text>
			</postalAddress>
			<streetAddress>
				<country></country>
				<postcode></postcode>
				<state></state>
				<text><xsl:value-of select="$request-values[@name='Users Address']" /></text>
			</streetAddress>
			<briefDescription></briefDescription>
			<fullDescription></fullDescription>
			<relatedWebsite>
				<location></location>
				<title></title>
				<notes></notes>
			</relatedWebsite>
			<relatedPublication>
				<location></location>
				<title></title>
				<notes></notes>
			</relatedPublication>
		</person>
	</xsl:template>
	

</xsl:stylesheet>
