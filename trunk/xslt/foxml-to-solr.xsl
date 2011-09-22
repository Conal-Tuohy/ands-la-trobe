<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:f="info:fedora/fedora-system:def/foxml#"
	xmlns:vamas="http://hdl.handle.net/102.100.100/6919"
	xmlns:dataset="http://hdl.handle.net/102.100.100/6976"
	exclude-result-prefixes="f vamas"
>

	<documentation xmlns="purely-internal">
		e.g.
		
		<add>
			<doc>
				<field name="id">1</field>
				<field name="title">Sample XPS</field>
				<field name="technique">XPS</field>
				<field name="instrument_model">Kratos XSAM 800</field>
				<field name="date">1993-01-04T21:05:00Z</field>
			</doc>
		</add>
		
	</documentation>
	
	<xsl:template match="/">
		<xsl:variable name="pid" select="/f:digitalObject/@PID"/>
		<xsl:variable name="uri-encoded-pid" select="concat(substring-before($pid, ':'), '%3A', substring-after($pid, ':'))"/>
		<xsl:variable name="handle-datastream" select="/f:digitalObject/f:datastream[@ID='handle']/f:datastreamVersion[last()]/f:xmlContent"/>
		<!-- vamas xml datastream is the content of the stream whose current version has the content type 'application/vamas+xml' -->
		<xsl:variable name="vamas-xml-datastreams" select="/f:digitalObject/f:datastream/f:datastreamVersion
			[last()][@MIMETYPE='application/vamas+xml']
				/f:xmlContent
		"/>
		<!-- vamas datastream is the stream whose current version has the content type 'chemical/x-vamas-iso14976' -->
		<xsl:variable name="vamas-datastream-ids" select="
			/f:digitalObject/f:datastream[
				f:datastreamVersion[last()]/@MIMETYPE='chemical/x-vamas-iso14976'
			]/@ID
		"/>
		<xsl:variable name="itm-xml-datastream" select="/f:digitalObject/f:datastream[@ID='vamas-xml']/f:datastreamVersion[last()]/f:xmlContent"/>
		<xsl:variable name="dataset-datastream" select="/f:digitalObject/f:datastream[@ID='dataset']/f:datastreamVersion[last()]/f:xmlContent"/>
		<xsl:variable name="person-datastream" select="/f:digitalObject/f:datastream[@ID='person']/f:datastreamVersion[last()]/f:xmlContent"/>
		<xsl:variable name="group-datastream" select="/f:digitalObject/f:datastream[@ID='group']/f:datastreamVersion[last()]/f:xmlContent"/>
		<xsl:variable name="project-datastream" select="/f:digitalObject/f:datastream[@ID='project']/f:datastreamVersion[last()]/f:xmlContent"/>
		<xsl:variable name="metadata-datastream-id" select="($dataset-datastream | $person-datastream | $group-datastream | $project-datastream)/ancestor::f:datastream/@ID"/>
		<add commitWithin="1000">
			<doc>
				<!-- searchable metadata fields -->
				<field name="type"><xsl:value-of select="$metadata-datastream-id"/></field>
				<field name="edit-uri">/fedora-objects/<xsl:value-of select="$uri-encoded-pid"/>/datastreams/<xsl:value-of select="$metadata-datastream-id"/>.xhtml</field>
				<field name="id"><xsl:value-of select="$pid"/></field>
				<xsl:if test="$handle-datastream">
					<field name="handle"><xsl:value-of select="concat('http://hdl.handle.net/', $handle-datastream//response/identifier/@handle)"/></field>
				</xsl:if>
				<xsl:if test="$dataset-datastream">
					<field name="title"><xsl:value-of select="$dataset-datastream/dataset:dataset/dataset:name"/></field>
				</xsl:if>
				<xsl:for-each select="$vamas-datastream-ids">
					<field name="vamas">/fedora/objects/<xsl:value-of select="$uri-encoded-pid"/>/datastreams/<xsl:value-of select="."/>/content</field>
				</xsl:for-each>
				<xsl:if test="$vamas-xml-datastreams">
					<!-- QAZ there may be multiple techniques, but here we assume just one -->
					<field name="technique"><xsl:value-of select="$vamas-xml-datastreams/vamas:dataset/vamas:block[1]/vamas:technique"/></field>
					<field name="instrument_model"><xsl:value-of select="$vamas-xml-datastreams/vamas:dataset/vamas:instrumentModel"/></field>

					<!-- NB the 'Z' time zone suffix is required by Solr -->
					<field name="date"><xsl:value-of select="$vamas-xml-datastreams/vamas:dataset/vamas:block[1]/vamas:date"/>Z</field>
					
					<!-- also store link to VAMAS XML datastreams for rendering a graph -->
					<xsl:for-each select="$vamas-xml-datastreams">
						<xsl:variable name="uri-encoded-vamas-xml-dsid" select="translate(./ancestor::f:datastream/@ID, ' ', '+')"/>
						<field name="vamas-xml">/fedora/objects/<xsl:value-of select="$uri-encoded-pid"/>/datastreams/<xsl:value-of select="$uri-encoded-vamas-xml-dsid"/>/content</field>
					</xsl:for-each>
				</xsl:if>
				
				<!-- reference to the metadata stream -->
				<field name="metadata-stream-uri">/fedora/objects/<xsl:value-of select="$uri-encoded-pid"/>/datastreams/<xsl:value-of select="$metadata-datastream-id"/>/content</field>
				
				<!-- references to the downloadable datastreams (for generating direct download hyperlinks) -->
				<!-- 
					Encode each datastream's metadata as a (quoted) HTML hyperlink:
					<a href="/fedora/objects/dc19%3A1/datastreams/EXAMPLE/content" type="application/x-iontof-surfacelab-measurement">conal/test.itm</a>
				-->
				<xsl:for-each select="/f:digitalObject/f:datastream[
						not(
							@ID='DC' or @ID='AUDIT' or @ID='RELS-EXT' or 
							@ID='rif-cs' or @ID='solr' or @ID='handle' or
							@ID='boss' or 
							@ID='person' or @ID='group' or @ID='project' or @ID='dataset' or
							f:datastreamVersion[last()]/@MIMETYPE='application/vamas+xml'
						)
				]">
				<!--
					<xsl:variable name="uri-encoded-dsid" select="translate(@ID, ' ', '+')"/>
				-->
					<xsl:variable name="uri-encoded-dsid" select="@ID"/>
					<xsl:variable name="latest-version" select="f:datastreamVersion[last()]"/>
					<field name="datastream">&lt;a href="/fedora/objects/<xsl:value-of select="$uri-encoded-pid"/>/datastreams/<xsl:value-of select="$uri-encoded-dsid"/>/content" type="<xsl:value-of select="$latest-version/@MIMETYPE"/>"&gt;<xsl:value-of select="$latest-version/@LABEL"/>&lt;/a&gt;</field>
				</xsl:for-each>
			</doc>
		</add>
	</xsl:template>

</xsl:stylesheet>
