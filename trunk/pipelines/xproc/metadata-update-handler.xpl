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
	<p:variable name="format-uri" select="/atom:entry/atom:category[@scheme='fedora-types:formatURI']/@term"/>
	<p:variable name="identifier" select="/atom:entry/atom:summary[@type='text']"/>
	<p:variable name="uri-encoded-identifier" select="fn:encode-for-uri($identifier)"/> 
	<p:variable name="vamas-xml-format-uri" select="'http://hdl.handle.net/102.100.100/6919'"/>
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
		<p:when test="($datastream='dataset') or ($datastream='person') or ($datastream='group') or ($datastream='project') or ($format-uri=$vamas-xml-format-uri) or ($datastream='surfacelab-xml')"> 
			
			<!-- get the full FoxML representation -->
			<lib:http-request method="get" detailed="false" name="foxml">
				<p:with-option name="username" select="$fedora-username"/>
				<p:with-option name="password" select="$fedora-password"/>
				<p:with-option name="uri" select="concat($item-base-uri, '/objectXML')"/>
			</lib:http-request>

			<!-- convert the aggregate metadata into RIF-CS -->
			<lib:crosswalk xslt="../xslt/foxml-to-rif-cs.xsl" name="create-rif-cs"/>

                        <!-- store RIF-CS to Fedora datastream (not really necessary, but may be handy for debugging) -->
                        <lib:fedora-save-datastream name="rif-cs-to-fedora">
                                <p:input port="source">
                                        <p:pipe step="create-rif-cs" port="result"/>
                                </p:input>
                                <p:with-option name="username" select="$fedora-username"/>
                                <p:with-option name="password" select="$fedora-password"/>
                                <p:with-option name="uri" select="concat($item-base-uri, '/datastreams/rif-cs')"/>
                        </lib:fedora-save-datastream>
			
			<!-- validate the result, and if valid, send it to the OAI-PMH harvester -->
			<!-- otherwise, remove any corresponding stale record from the OAI-PMH provider -->
			<p:try name="to-publish-valid-rif-cs">
				<p:group name="validate-and-publish-rif-cs">
					<p:validate-with-xml-schema>
						<p:input port="source">
							<p:pipe step="create-rif-cs" port="result"/>
						</p:input>
						<p:input port="schema">
							<p:document href="../schemas/rif-cs/registryObjects.xsd"/>
						</p:input>
					</p:validate-with-xml-schema>
					<!-- Store the RIF-CS in the OAI-PMH server jOAI -->
					<p:store name="rif-cs-to-oai-pmh-provider">
						<p:with-option name="href" select="$rif-cs-output-uri"/>
					</p:store>
				</p:group>
				<p:catch name="invalid-rif-cs">
					<lib:http-request method="delete" name="delete-stale-rif-cs">
						<p:with-option name="uri" select="$rif-cs-output-uri"/>
					</lib:http-request>
					<p:sink name="ignore-results-of-deleting-stale-rif-cs"/>
				</p:catch>
			</p:try>
			
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

			<!-- update the owner(s) of the object -->
			<lib:crosswalk xslt="../xslt/foxml-to-owners-list.xsl" name="extract-object-owners-from-foxml">
				<p:input port="source">
					<p:pipe step="foxml" port="result"/>
				</p:input>
			</lib:crosswalk>
			<!--
			<p:store name="owners-list" href="file:///tmp/owners-list.xml"/>
			-->
			
			<lib:http-request name="set-object-owners">
				<p:with-option name="username" select="$fedora-username"/>
				<p:with-option name="password" select="$fedora-password"/>
				<p:with-option name="method" select="'put'"/>
				<p:with-option name="uri" select="concat($item-base-uri, '?ownerId=', normalize-space(.))"/>
				<p:with-option name="accept" select="'*/*'"/>
			</lib:http-request>

			<!-- Convert the foxml to solr and update the Solr index -->
			<lib:crosswalk xslt="../xslt/foxml-to-solr.xsl" name="foxml-to-solr">
				<p:input port="source">
					<p:pipe step="foxml" port="result"/>
				</p:input>
			</lib:crosswalk>
			<!-- post the solr stream to the solr server -->
			<lib:http-request method="post" uri="http://localhost:8080/solr/update"/><!-- this path is defined by solr's setup and is different from install to install -->
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
			
			<!-- test of sending email -->
			<lib:crosswalk name="create-email-message" xslt="../xslt/foxml-to-email-notification.xsl">
				<p:input port="source">
					<p:pipe step="foxml" port="result"/>
				</p:input>
			</lib:crosswalk>
			
			<p:viewport name="for-each-notification-message" match="/messages/message">
			
				<lib:send-mail name="send-email">
					<!--
					<p:input port="message">
						<p:inline><message>Dear Conal Tuohy,
			Your dataset was updated.
			Please visit http://andsdb-dc19-dev.latrobe.edu.au/ to see it.</message></p:inline>
					</p:input>-->
					<!--
					<p:with-option name="from" select="/*/@from"/>
					<p:with-option name="to" select="/*/@to"/>
					<p:with-option name="subject" select="/*/@subject"/>
					-->
				</lib:send-mail>
			</p:viewport>
			<!--

-->
			<p:sink name="ignore-mail-result"/>
		</p:when>
		<p:otherwise>
			<p:sink name="ignore-non-source-metadata-stream-update"/>
		</p:otherwise>
	</p:choose>
	
</p:declare-step>

