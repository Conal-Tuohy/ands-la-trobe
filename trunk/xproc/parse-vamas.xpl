<p:declare-step name="main" version="1.0" 
	xmlns:p="http://www.w3.org/ns/xproc" 
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	xmlns:atom="http://www.w3.org/2005/Atom" 
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:lib="http://code.google.com/p/ands-la-trobe/wiki/XProcLibrary">
	
	<p:import href="library.xpl"/>
	
	<p:input port="source"/>
	<p:output port="result"/>
		
	<!--
	<p:store href="file:///tmp/output.xml"/>
	-->
	
	<p:option name="fedora-username"/>
	<p:option name="fedora-password"/>
	
	<p:variable name="auth-method" select=" 'Basic' "/>
	<p:variable name="method" select="/atom:entry/atom:title[@type='text']"/>
	<p:variable name="datastream" select="/atom:entry/atom:category[@scheme='fedora-types:dsID']/@term"/>
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
		<!-- if the event is an ingested object, or a modified rif-cs datastream ... -->
		<p:when test=" ($method = 'ingest') or (($method = 'modifyDatastreamByValue') and ($datastream='vamas'))">
			
			<!--<p:store href="file:///tmp/atom-message.xml"/>-->
			<lib:http-request method="get">
				<p:with-option name="username" select="$fedora-username"/>
				<p:with-option name="password" select="$fedora-password"/>
				<p:with-option name="uri" select="concat($item-base-uri, '/datastreams/vamas/content')"/>
			</lib:http-request>	

			<!--
			<lib:crosswalk xslt="../xslt/rif-cs-to-oai_dc.xsl"/>
			-->
			
			<!-- put the vamas-xml stream back into fedora -->
			<lib:http-request method="put">
				<p:with-option name="username" select="$fedora-username"/>
				<p:with-option name="password" select="$fedora-password"/>
				<p:with-option name="uri" select="concat($item-base-uri, '/datastreams/vamas-xml')"/>
			</lib:http-request>

		</p:when>
		<p:otherwise>
			<!-- it's not an ingest or the update of a rif-cs stream -->
			<p:identity name="ignoring-message"/>
		</p:otherwise>
	</p:choose>

</p:declare-step>

