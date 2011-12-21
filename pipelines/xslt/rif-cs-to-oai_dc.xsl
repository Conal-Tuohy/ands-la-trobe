<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:rif-cs="http://ands.org.au/standards/rif-cs/registryObjects">

<xsl:template match="/">
	<oai_dc:dc 
		xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" 
		xmlns:dc="http://purl.org/dc/elements/1.1/" 
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
		xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
		<dc:title><xsl:apply-templates select="//rif-cs:name[@type='primary']"/></dc:title>
		<xsl:for-each select="//rif-cs:name">
			<dc:description><xsl:apply-templates select="."/></dc:description>
		</xsl:for-each>
		<dc:type><xsl:value-of select="/rif-cs:registryObjects/rif-cs:registryObject/rif-cs:*/@type"/></dc:type>
   </oai_dc:dc>
</xsl:template>

<!-- ensure that we output spaces between adjacent nameParts -->
<xsl:template match="rif-cs:namePart">
	<xsl:value-of select="normalize-space(.)"/>
	<xsl:if test="following-sibling::rif-cs:namePart">
		<xsl:text> </xsl:text>
	</xsl:if>
</xsl:template>

</xsl:stylesheet>
