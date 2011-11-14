<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:f="info:fedora/fedora-system:def/foxml#"
	xmlns:latrobe="http://hdl.handle.net/102.100.100/6976"
	exclude-result-prefixes="f latrobe"
>

	<xsl:variable name="dataset-datastream" select="/f:digitalObject/f:datastream[@ID='dataset']/f:datastreamVersion[last()]/f:xmlContent/*"/>
	<xsl:variable name="person-datastream" select="/f:digitalObject/f:datastream[@ID='person']/f:datastreamVersion[last()]/f:xmlContent/*"/>
	<xsl:variable name="group-datastream" select="/f:digitalObject/f:datastream[@ID='group']/f:datastreamVersion[last()]/f:xmlContent/*"/>
	<xsl:variable name="project-datastream" select="/f:digitalObject/f:datastream[@ID='project']/f:datastreamVersion[last()]/f:xmlContent/*"/>
	<!-- the "descriptive datastream" is whichever of the "dataset", "person", "group", or "project" datastreams is actually present-->
	<xsl:variable name="descriptive-datastream" select="$dataset-datastream | $person-datastream | $group-datastream | $project-datastream"/>
	
	<xsl:template match="/">
		<owners-list>
			<xsl:apply-templates select="$descriptive-datastream"/>
		</owners-list>
	</xsl:template>
	
	<xsl:template match="latrobe:person">
		<!-- the owner of a person record is the person themself -->
		<xsl:value-of select="/f:digitalObject/@PID"/>
	</xsl:template>

	<!-- the owners of a group or project are the members of the group or project -->
	<xsl:template match="latrobe:group | latrobe:project">
		<xsl:for-each select="latrobe:hasMember/@id">
			<xsl:value-of select="normalize-space(substring-after(., ':'))"/>
			<xsl:if test="position() &lt; last()">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- the owners of a dataset are the collectors of that dataset -->
	<xsl:template match="latrobe:dataset">
		<xsl:for-each select="latrobe:hasCollector/@id">
			<xsl:value-of select="normalize-space(substring-after(., ':'))"/>
			<xsl:if test="position() &lt; last()">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
</xsl:stylesheet>
