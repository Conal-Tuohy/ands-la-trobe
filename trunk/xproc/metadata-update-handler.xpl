<p:declare-step name="main" version="1.0" 
	xmlns:p="http://www.w3.org/ns/xproc" 
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	xmlns:atom="http://www.w3.org/2005/Atom" 
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:lib="http://code.google.com/p/ands-la-trobe/wiki/XProcLibrary">
	
	<p:import href="library.xpl"/>
	
	<p:input port="source"/>
<!--	<p:output port="result" sequence="true"/>-->
		
	<!--
	<p:store href="file:///tmp/output.xml"/>
	-->
	
	<p:option name="fedora-username"/>
	<p:option name="fedora-password"/>
	<p:option name="rif-cs-output-folder-uri"/>
	
	
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
	<!-- NB the RIF-CS file name is doubly encoded for URI because it will be decoded once when it's stored, leaving a singly-encoded-for-URI filename -->
	<p:variable name="rif-cs-output-uri" select="concat($rif-cs-output-folder-uri, '/', fn:encode-for-uri($uri-encoded-identifier), '.xml')"/>
	<!--
	methods:
		"purgeObject", "purgeDatastream" (delete)
		"modifyDatastreamByValue", "modifyDatastreamByReference" (update)
		"ingest" (create)
	-->
	
	<!-- if the notification is that one of the metadata streams has been modified ... -->
	<p:choose>
		<p:when test="($datastream='dataset') or ($datastream='person') or ($datastream='group') or ($datastream='project') or ($datastream='vamas-xml') or ($datastream='surfacelab-xml')"> 
			
			<!-- get the full FoxML representation -->
			<lib:http-request method="get" detailed="false" name="foxml">
				<p:with-option name="username" select="$fedora-username"/>
				<p:with-option name="password" select="$fedora-password"/>
				<p:with-option name="uri" select="concat($item-base-uri, '/objectXML')"/>
			</lib:http-request>

			<!-- convert the aggregate metadata into RIF-CS -->
			<lib:crosswalk xslt="../xslt/foxml-to-rif-cs.xsl" name="create-rif-cs"/>
			
			<!-- Store the RIF-CS in the OAI-PMH server jOAI -->
			<p:store name="rif-cs-to-oai-pmh-provider">
				<p:with-option name="href" select="$rif-cs-output-uri"/>
			</p:store>

			<!-- store RIF-CS to Fedora datastream (not really necessary, but may be handy for debugging) -->			
			<lib:fedora-save-datastream name="rif-cs-to-fedora">
				<p:input port="source">
					<p:pipe step="create-rif-cs" port="result"/>
				</p:input>
				<p:with-option name="username" select="$fedora-username"/>
				<p:with-option name="password" select="$fedora-password"/>
				<p:with-option name="uri" select="concat($item-base-uri, '/datastreams/rif-cs')"/>
			</lib:fedora-save-datastream>
			<p:sink name="ignore-fedora-response"/>

			<!-- convert the RIF-CS to OAI_DC for the Fedora simple search -->
			<lib:crosswalk xslt="../xslt/rif-cs-to-oai_dc.xsl" name="dc">
				<p:input port="source">
					<p:pipe step="create-rif-cs" port="result"/>
				</p:input>
			</lib:crosswalk>
			
			<!-- Put the dc stream back into fedora. This stream will always exist so it's safe to just use HTTP put -->
			<lib:http-request method="put">
				<p:with-option name="username" select="$fedora-username"/>
				<p:with-option name="password" select="$fedora-password"/>
				<p:with-option name="uri" select="concat($item-base-uri, '/datastreams/DC')"/>
			</lib:http-request>

			<!-- For changed dataset metadata streams only, convert the foxml to solr and update the Solr index -->
			<p:choose>
				<p:when test="($datastream='dataset') or ($datastream='vamas-xml') or ($datastream='surfacelab-xml')">
					<lib:crosswalk xslt="../xslt/foxml-to-solr.xsl" name="foxml-to-solr">
						<p:input port="source">
							<p:pipe step="foxml" port="result"/>
						</p:input>
					</lib:crosswalk>
					<!-- post the solr stream to the solr server -->
					<lib:http-request method="post" uri="http://localhost:8080/solr-example/update"/>
					<!-- save the solr record in fedora too -->
					<lib:fedora-save-datastream name="solr-to-fedora">
						<p:input port="source">
							<p:pipe step="foxml-to-solr" port="result"/>
						</p:input>
						<p:with-option name="username" select="$fedora-username"/>
						<p:with-option name="password" select="$fedora-password"/>
						<p:with-option name="uri" select="concat($item-base-uri, '/datastreams/solr')"/>
					</lib:fedora-save-datastream>
					<p:sink name="ignore-response-from-solr"/>
				</p:when>
				<p:otherwise>
					<p:sink name="solr-ignore-foxml-of-non-dataset-record"/>
				</p:otherwise>
			</p:choose>
		</p:when>
		<p:otherwise>
			<p:sink name="ignore-non-source-metadata-stream-update"/>
		</p:otherwise>
	</p:choose>


</p:declare-step>
