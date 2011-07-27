
<p:pipeline xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:fn="http://www.w3.org/2005/xpath-functions" name="mint-handle" version="1.0">
<!-- 

	Mint a handle for a dataset 

	inputs:
		URI property for the handle
		description property for the handle
		identity details for authentication
	
	outputs:
		response from server
-->

	<!-- identify the URI to mint a handle for -->
	<p:option name="pids-uri" required="true"/>
	<p:option name="uri" required="true"/>

	<p:in-scope-names name="variables"/>

	<p:template>
		<p:input port="template">
			<p:inline exclude-inline-prefixes="c">
				<c:request detailed="true" method="POST" href="{$pids-uri}/mint?type=URL&amp;value={fn:encode-for-uri($uri)}">
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
	<p:http-request/>
	

</p:pipeline>

