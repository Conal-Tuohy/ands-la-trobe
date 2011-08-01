<p:declare-step 
	xmlns:p="http://www.w3.org/ns/xproc" 
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	xmlns:fn="http://www.w3.org/2005/xpath-functions" 
	xmlns:atom="http://www.w3.org/2005/Atom" 
	name="mint-handle" version="1.0">
<!-- 
	Mint a handle for a dataset 
-->

	<p:input port="source"/>
	<p:output port="result"/>
		
	<p:option name="fedora-username"/>
	<p:option name="fedora-password"/>
	<p:option name="pids-identity-file"/>
	<p:option name="pids-uri" required="true"/>

	<p:variable name="auth-method" select=" 'Basic' "/>
	<p:variable name="method" select="/atom:entry/atom:title[@type='text']"/>
	<p:variable name="datastream" select="/atom:entry/atom:category[@scheme='fedora-types:dsID']/@term"/>
	<p:variable name="identifier" select="/atom:entry/atom:summary[@type='text']"/>
	<p:variable name="uri-encoded-identifier" select="fn:encode-for-uri($identifier)"/> 
	<p:variable name="fedora-base-uri" select="/atom:entry/atom:author/atom:uri"/>
	<p:variable name="handle-datastream-uri" select="concat($fedora-base-uri, '/objects/', $uri-encoded-identifier, '/datastreams/handle')"/>
	<p:variable name="public-item-uri" select="concat('http://andsdb-dc19-dev.latrobe.edu.au/fedora/objects/', $uri-encoded-identifier, '/datastreams')"/>

	<p:in-scope-names name="variables"/>
	
	<!--
	methods:
		"purgeObject", "purgeDatastream" (delete)
		"modifyDatastreamByValue", "modifyDatastreamByReference" (update)
		"ingest" (create)
	-->
	
	<!-- check if the updated object already has a handle datastream -->
	<!-- if the datastream is missing, we will create it -->
	<p:template>
		<p:input port="template">
			<p:inline exclude-inline-prefixes="c">
				<c:request detailed="true" method="HEAD" 
							username="{$fedora-username}"
							password="{$fedora-password}"
							auth-method="{$auth-method}"
							href="{$handle-datastream-uri}">
					<c:header name="Accept" value="text/xml"/>
				</c:request>
			</p:inline>
		</p:input>
		<p:input port="source">
			<p:pipe step="mint-handle" port="source"/>
		</p:input>
		<p:input port="parameters">
			<p:pipe step="variables" port="result"/>
		</p:input>
	</p:template>
	<p:http-request/>
	
	<!-- if the Fedora item has no handle metadata then we will have received:
	<c:response xmlns:c="http://www.w3.org/ns/xproc-step" status="404">
	-->
	<p:for-each name="item-missing-handle">
		<p:iteration-source select="/c:response[@status='404']"/>
		<!-- mint a handle -->
		<p:template>
			<p:input port="template">
				<p:inline exclude-inline-prefixes="c">
					<c:request detailed="true" method="POST" href="{$pids-uri}/mint?type=URL&amp;value={fn:encode-for-uri($public-item-uri)}">
						<c:header name="Accept" value="text/xml"/>
						<c:body content-type="text/xml">{/*}</c:body>
					</c:request>
				</p:inline>
			</p:input>
			<p:input port="source">
				<p:pipe step="mint-handle" port="source"/>
			</p:input>
			<p:input port="parameters">
				<p:pipe step="variables" port="result"/>
			</p:input>
		</p:template>
<!--
		<p:http-request/>
-->
	</p:for-each>

</p:declare-step>

