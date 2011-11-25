<p:declare-step name="main" version="1.0" 
	xmlns:p="http://www.w3.org/ns/xproc" 
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	xmlns:atom="http://www.w3.org/2005/Atom" 
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:lib="http://code.google.com/p/ands-la-trobe/wiki/XProcLibrary"
	xmlns:foxml="info:fedora/fedora-system:def/foxml#">
	
	<p:import href="library.xpl"/>
	
	<p:input port="source"/>
	<p:output port="result"/>
	
	<p:option name="fedora-username"/>
	<p:option name="fedora-password"/>
	
	<p:variable name="auth-method" select=" 'Basic' "/>
	<p:variable name="method" select="/atom:entry/atom:title[@type='text']"/>
	<p:variable name="datastream" select="/atom:entry/atom:category[@scheme='fedora-types:dsID']/@term"/>
	<p:variable name="format-uri" select="/atom:entry/atom:category[@scheme='fedora-types:formatURI']/@term"/>
	<p:variable name="label" select="/atom:entry/atom:category[@scheme='fedora-types:dsLabel']/@term"/>
	<p:variable name="identifier" select="/atom:entry/atom:summary[@type='text']"/>
	<p:variable name="uri-encoded-identifier" select="fn:encode-for-uri($identifier)"/> 
<!--
	<p:variable name="fedora-base-uri" select="/atom:entry/atom:author/atom:uri"/>
-->
	<p:variable name="fedora-base-uri" select="'http://localhost:8080/fedora/'"/>	
	<p:variable name="item-base-uri" select="concat($fedora-base-uri, 'objects/', $uri-encoded-identifier)"/>
	<!--
	methods:
		"purgeObject", "purgeDatastream" (delete)
		"modifyDatastreamByValue", "modifyDatastreamByReference" (update)
		"ingest" (create)
	-->
	
	<p:choose>
		<!-- if the event is a modified vamas datastream ... -->
		<p:when test="starts-with($method, 'modifyDatastream') and $format-uri='http://www.iso.org/iso/iso_catalogue/catalogue_tc/catalogue_detail.htm?csnumber=24269'">
			
			<p:variable name="uri-encoded-dsid" select="fn:encode-for-uri($datastream)"/>
			<p:variable name="vamas-datastream-uri" select="concat($item-base-uri, '/datastreams/', $uri-encoded-dsid, '/content')"/>
			<p:variable name="vamas-xml-datastream-uri" select="
				concat(
					$item-base-uri, 
					'/datastreams/', 
					$uri-encoded-dsid,	'-xml',
					'?&amp;formatURI=', fn:encode-for-uri('http://hdl.handle.net/102.100.100/6919'), 
					'&amp;mimeType=', fn:encode-for-uri('application/vamas+xml'),
					'&amp;dsLabel=', fn:encode-for-uri($label), '.xml'
				)
			"/>
			
			<!-- execute a bash script to download the VAMAS file from Fedora and run the (Java) XML converter over it -->
			<p:exec name="download-vamas-and-convert-to-xml" command="bash" result-is-xml="false">
				<p:with-option name="args" select="concat('xproc/get-vamas-xml.sh ', $fedora-username, ' ', $fedora-password, ' ', $vamas-datastream-uri)"/>
			</p:exec>
			<!-- load the vamas xml file created by the previous step -->
			<p:load href="/tmp/vamas-xml.xml" name="vamas-xml"/>

			<!-- put the vamas-xml stream back into fedora -->
			<lib:fedora-save-datastream name="save-vamas-xml">
				<p:with-option name="username" select="$fedora-username"/>
				<p:with-option name="password" select="$fedora-password"/>
				<p:with-option name="uri" select="$vamas-xml-datastream-uri"/>
			</lib:fedora-save-datastream>

		</p:when>
		<p:otherwise>
			<!-- it's not an ingest or the update of a vamas datastream -->
			<p:identity name="ignoring-message"/>
		</p:otherwise>
	</p:choose>

</p:declare-step>

