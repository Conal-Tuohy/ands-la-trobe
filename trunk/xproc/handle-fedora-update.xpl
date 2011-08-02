<p:declare-step name="main" version="1.0" xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	
	<p:input port="source"/>
	<p:output port="result"/>
		
	<!--
	<p:store href="file:///tmp/output.xml"/>
	-->
	
	<p:option name="fedora-username"/>
	<p:option name="fedora-password"/>
	<p:option name="pids-identity-file"/>
	
	<p:variable name="auth-method" select=" 'Basic' "/>
	<p:variable name="method" select="/atom:entry/atom:title[@type='text']"/>
	<p:variable name="datastream" select="/atom:entry/atom:category[@scheme='fedora-types:dsID']/@term"/>
	<p:variable name="identifier" select="/atom:entry/atom:summary[@type='text']"/>
	<p:variable name="uri-encoded-identifier" select="fn:encode-for-uri($identifier)"/> 
<!--
	<p:variable name="fedora-base-uri" select="/atom:entry/atom:author/atom:uri"/>
-->
	<p:variable name="fedora-base-uri" select="'http://localhost:8080/fedora/'"/>	
	<!--
	methods:
		"purgeObject", "purgeDatastream" (delete)
		"modifyDatastreamByValue", "modifyDatastreamByReference" (update)
		"ingest" (create)
	-->
	
	<p:choose>
		<!-- if the event is an ingested object, or a modified rif-cs datastream ... -->
		<p:when test=" ($method = 'ingest') or (($method = 'modifyDatastreamByValue') and ($datastream='rif-cs'))">
			
			<!--<p:store href="file:///tmp/atom-message.xml"/>-->
			<p:in-scope-names name="variables"/>
			<p:template>
				<p:input port="template">
					<p:inline exclude-inline-prefixes="atom">
						<c:request method="get" href="{ concat( $fedora-base-uri, 'objects/', $uri-encoded-identifier, '/datastreams/rif-cs/content' ) }"/>
					</p:inline>
				</p:input>
				<p:input port="parameters">
					<p:pipe step="variables" port="result"/>
				</p:input>
				<p:input port="source">
					<p:pipe step="main" port="source"/><!-- actually ignored -->
				</p:input>
			</p:template>
			<!--
			<p:store href="file:///tmp/http-request.xml"/>
			-->
			<p:http-request/>
			<!--
			<p:store href="file:///tmp/rif-cs.xml"/>
			-->
			<!-- transform the rif-cs into dc -->
			<p:xslt>
				<p:input port="parameters">
					<p:empty/>
				</p:input>
				<p:input port="stylesheet">
					<p:document href="../xslt/rif-cs-to-oai_dc.xsl"/>
				</p:input>
			</p:xslt>
			<!--
			<p:store href="file:///tmp/dc.xml"/>
			-->
			<!-- put the dc stream back into fedora -->
			<p:template>
				<p:input port="template">
					<p:inline exclude-inline-prefixes="atom">
						<c:request method="put" detailed="true" username="{$fedora-username}" password="{$fedora-password}" auth-method="{$auth-method}" href="{concat($fedora-base-uri, 'objects/', $uri-encoded-identifier, '/datastreams/DC')}">
							<c:body content-type="text/xml">{/*}</c:body>
						</c:request>
					</p:inline>
				</p:input>
				<p:input port="parameters">
					<p:pipe step="variables" port="result"/>
				</p:input>
			</p:template>
			<!--
			<p:store href="file:///tmp/http-request.xml"/>
			-->
			<p:http-request/>
		</p:when>
		<p:otherwise>
			<p:store name="dump-ignored-message" href="file:///tmp/fedora-update-handler-ignored-message.xml"/>
			<p:identity>
				<p:input port="source">
					<p:pipe port="result" step="dump-ignored-message"/>
				</p:input>
			</p:identity>
		</p:otherwise>
	</p:choose>

</p:declare-step>

