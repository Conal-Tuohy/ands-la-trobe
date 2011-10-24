<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:boss="http://hdl.handle.net/102.100.100/7003"
>
	<xsl:template match="boss:job">
		<xsl:variable name="request-values" select="boss:request/boss:value"/>
		<xsl:variable name="address" select="$request-values[@name='Users Address']"/>
		<xsl:variable name="street">
			<xsl:call-template name="get-address-field">
				<xsl:with-param name="address" select="$address"/>
				<xsl:with-param name="field-name">Street</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="city">
			<xsl:call-template name="get-address-field">
				<xsl:with-param name="address" select="$address"/>
				<xsl:with-param name="field-name">City</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="postcode">
			<xsl:call-template name="get-address-field">
				<xsl:with-param name="address" select="$address"/>
				<xsl:with-param name="field-name">Postcode</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="state">
			<xsl:call-template name="get-address-field">
				<xsl:with-param name="address" select="$address"/>
				<xsl:with-param name="field-name">State</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<person xmlns="http://hdl.handle.net/102.100.100/6976">
			<name><xsl:value-of select="concat($request-values[@name='Users Name'], ' ', $request-values[@name='Users Surname'])"/></name>
			<department><xsl:value-of select="$request-values[@name='Users Department']" /></department>
			<institution><xsl:value-of select="$request-values[@name='Users Institution']" /></institution>
			<dateOfBirth></dateOfBirth>
			<alternativeName></alternativeName>
			<abbreviatedName></abbreviatedName>
			<url></url>
			<email><xsl:value-of select="$request-values[@name='Users Email']" /></email>
			<phone public="false"><xsl:value-of select="$request-values[@name='Users Telephone']" /></phone>
			<fax><xsl:value-of select="$request-values[@name='Users Fax']" /></fax>
			<otherElectronic type=""></otherElectronic>
			<postalAddress>
				<text><xsl:value-of select="concat($street, '&#xA;', $city)" /></text>
				<state><xsl:value-of select="$state"/></state>
				<postcode><xsl:value-of select="$postcode"/></postcode>
				<country></country>
			</postalAddress>
			<streetAddress>
				<text><xsl:value-of select="concat($street, '&#xA;', $city)" /></text>
				<state><xsl:value-of select="$state"/></state>
				<postcode><xsl:value-of select="$postcode"/></postcode>
				<country></country>
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
	
<!-- extract a field by name from an address such as:
"Street. Department of Physics
City. La Trobe University
State. Victoria
Postcode. 3086"	
	-->
	<xsl:template name="get-address-field">
		<xsl:param name="address"/>
		<xsl:param name="field-name"/>
		<xsl:if test="$address">
			<xsl:variable name="line" select="substring-before(concat($address, '&#xA;'), '&#xA;')"/>
			<xsl:choose>
				<xsl:when test="starts-with($line, $field-name)">
					<!-- the first line of the address contains the field we're after ... -->
					<xsl:value-of select="normalize-space(substring-after($line, concat($field-name, '.')))"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- not in the first line ... search the remainder of the address -->
					<xsl:call-template name="get-address-field">
						<xsl:with-param name="address" select="substring-after($address, '&#xA;')"/>
						<xsl:with-param name="field-name" select="$field-name"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
