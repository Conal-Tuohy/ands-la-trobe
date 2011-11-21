<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:boss="http://hdl.handle.net/102.100.100/7003"
>
	<xsl:template match="boss:job">
		<dataset xmlns="http://hdl.handle.net/102.100.100/6976">
			<xsl:attribute name="embargoDate">
				<!-- one year in the future -->
				<xsl:value-of select="concat(
					1 + number(boss:logsheet/boss:value[@name='fYear']), 
					'-', 
					format-number(boss:logsheet/boss:value[@name='fMonth'], '00'), 
					'-', 
					format-number(boss:logsheet/boss:value[@name='fDay'], '00')
				)" />
			</xsl:attribute>
			<hasCollector id="person:{boss:request/boss:value[@name='Users ID']}"><xsl:value-of select="
				concat(
					boss:request/boss:value[@name='Users Name'],
					' ',
					boss:request/boss:value[@name='Users Surname'])"/></hasCollector>
			<abbreviatedName></abbreviatedName>
			<name><xsl:value-of select="boss:request/boss:value[@name='technique']"/>
				<xsl:text>: </xsl:text>
				<xsl:for-each select="boss:logsheet/boss:value[@name='sampletable']/boss:row">
					<xsl:value-of select="boss:column[2]"/>
					<xsl:if test="position() = last() - 1"><!-- there is exactly one more sample -->
						<xsl:text> and </xsl:text>
					</xsl:if>
					<xsl:if test="position() &lt; last() - 1"><!-- there are more than one more sample -->
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:for-each></name>
			<url></url>
			<otherElectronic type=""></otherElectronic>
			<startDate><xsl:value-of select="concat(
				boss:logsheet/boss:value[@name='sYear'], 
				'-', 
				format-number(boss:logsheet/boss:value[@name='sMonth'], '00'), 
				'-', 
				format-number(boss:logsheet/boss:value[@name='sDay'], '00'), 
				'T', 
				boss:logsheet/boss:value[@name='sTime'], 
				':00+10:00'
			)" /></startDate>
			<endDate><xsl:value-of select="concat(
				boss:logsheet/boss:value[@name='fYear'], 
				'-', 
				format-number(boss:logsheet/boss:value[@name='fMonth'], '00'), 
				'-', 
				format-number(boss:logsheet/boss:value[@name='fDay'], '00'), 
				'T', 
				boss:logsheet/boss:value[@name='fTime'], 
				':00+10:00'
			)" /></endDate>  
			<subject type="anzsrc-for">020406</subject>
			<subject type="anzsrc-for">030603</subject>
			<subject type="anzsrc-for">030301</subject>
			<xsl:for-each select="boss:logsheet/boss:table[@name='sampletable']/boss:row">
				<sample>
					<name><xsl:value-of select="boss:column[3]"/></name>
					<id><xsl:value-of select="boss:column[1]"/></id>
					<cas></cas>
					<dimensions></dimensions>
					<supplier></supplier>
					<supplierCode></supplierCode>
					<purity></purity>
					<typicalAnalysis></typicalAnalysis>
					<prep></prep>
					<additionalNotes><xsl:value-of select="boss:column[2]"/></additionalNotes>
				</sample>
			</xsl:for-each>
			<briefDescription><xsl:value-of select="boss:logsheet/boss:value[@name='GeneralDescription']"/></briefDescription>
			<fullDescription><xsl:value-of select="boss:logsheet/boss:value[@name='GeneralDescription']"/><xsl:text>
</xsl:text>
				<xsl:text>Samples: </xsl:text>
				<xsl:for-each select="boss:logsheet/boss:table[@name='sampletable']/boss:row">
					<xsl:value-of select="boss:column[2]"/>
					<xsl:text> (</xsl:text>
					<xsl:value-of select="boss:column[3]"/>
					<xsl:text>)</xsl:text>
					<xsl:if test="position() &lt; last()">, </xsl:if>
				</xsl:for-each></fullDescription>
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
		</dataset>
	</xsl:template>
	

</xsl:stylesheet>
