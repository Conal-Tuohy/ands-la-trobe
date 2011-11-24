<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:f="info:fedora/fedora-system:def/foxml#"
	xmlns:vamas="http://hdl.handle.net/102.100.100/6919"
	xmlns:latrobe="http://hdl.handle.net/102.100.100/6976"
	exclude-result-prefixes="f vamas latrobe"
>

	<xsl:variable name="handle-datastream" select="/f:digitalObject/f:datastream[@ID='handle']/f:datastreamVersion[last()]/f:xmlContent/*"/>
	<xsl:variable name="handle" select="$handle-datastream//response/identifier/@handle"/>
	<xsl:variable name="solr-uri" select="$handle-datastream//response/identifier/property[@type='URL']/@value"/>
	<xsl:variable name="host-base-uri" select="substring-before($solr-uri, 'solr')"/>
	<xsl:variable name="uri-encoded-pid" select="concat(substring-before(/f:digitalObject/@PID, ':'), '%3A', substring-after(/f:digitalObject/@PID, ':'))"/>
	<xsl:variable name="vamas-datastream" select="/f:digitalObject/f:datastream[@ID='vamas-xml']/f:datastreamVersion[last()]/f:xmlContent/*"/>
	<xsl:variable name="surfacelab-datastream" select="/f:digitalObject/f:datastream[@ID='vamas-xml']/f:datastreamVersion[last()]/f:xmlContent/*"/>
	<xsl:variable name="dataset-datastream" select="/f:digitalObject/f:datastream[@ID='dataset']/f:datastreamVersion[last()]/f:xmlContent/*"/>
	<xsl:variable name="person-datastream" select="/f:digitalObject/f:datastream[@ID='person']/f:datastreamVersion[last()]/f:xmlContent/*"/>
	<xsl:variable name="group-datastream" select="/f:digitalObject/f:datastream[@ID='group']/f:datastreamVersion[last()]/f:xmlContent/*"/>
	<xsl:variable name="project-datastream" select="/f:digitalObject/f:datastream[@ID='project']/f:datastreamVersion[last()]/f:xmlContent/*"/>
	<!-- the "descriptive datastream" is whichever of the "dataset", "person", "group", or "project" datastreams is actually present-->
	<xsl:variable name="descriptive-datastream" select="$dataset-datastream | $person-datastream | $group-datastream | $project-datastream"/>
	
	<xsl:template match="/">
		<!-- Create notification messages about a change to the object whose foxml stream is the input to this stylesheet. -->
		<!-- We may need to send emails to several people associated with the object. -->
		<messages>
			<xsl:apply-templates select="$descriptive-datastream"/>
		</messages>
	</xsl:template>
	
	<!-- latrobe:group elements have latrobe:hasMember children -->
	
	<!-- notifications about a dataset: send a message to each of the dataset's collectors -->
	<xsl:template match="latrobe:dataset">
		<!-- the URL of the page where the metadata stream can be edited -->
		<xsl:variable name="edit-uri" select="concat($host-base-uri, 'fedora-objects/', $uri-encoded-pid, '/datastreams/dataset.xhtml')"/>
		<!-- the dataset's name -->
		<xsl:variable name="dataset-name" select="latrobe:name"/>
		<!-- create a message for each of the dataset's collectors -->
		<xsl:for-each select="latrobe:hasCollector">
			<!-- the person's name is the content of the hasCollector element -->
			<xsl:variable name="person-name" select="."/>
			<!-- the @id attribute holds the person's pid -->
			<xsl:variable name="uri-encoded-pid-of-person" select="concat(substring-before(@id, ':'), '%3A', substring-after(@id, ':'))"/>
			<xsl:variable name="person-datastream-uri" select="
				concat(
					'http://localhost:8080/fedora/objects/',
					$uri-encoded-pid-of-person,
					'/datastreams/person/content'
				)
			"/>
			<xsl:variable name="email" select="document($person-datastream-uri)/latrobe:person/latrobe:email"/>
			<!--<message
				to="{normalize-space($email)}"
				subject="Update notification for dataset &quot;{$dataset-name}&quot;">Dear <xsl:value-of select="$person-name"/>,
Your dataset record entitled "<xsl:value-of select="$dataset-name"/>" has been updated.
To review and edit the updated record, visit this page: 
<xsl:value-of select="$edit-uri"/>
			</message>-->
			<message
				to="R.Jones@latrobe.edu.au"
				subject="Update notification for dataset &quot;{$dataset-name}&quot;">The dataset record entitled "<xsl:value-of select="$dataset-name"/>" has been updated.
To review and edit the updated record, visit this page: 
<xsl:value-of select="$edit-uri"/>
			</message>
			<message
				to="conal.tuohy@gmail.com"
				subject="Update notification for dataset &quot;{$dataset-name}&quot;">The dataset record entitled "<xsl:value-of select="$dataset-name"/>" has been updated.
To review and edit the updated record, visit this page: 
<xsl:value-of select="$edit-uri"/>
			</message>
		</xsl:for-each>
	</xsl:template>
	
	
	
</xsl:stylesheet>
