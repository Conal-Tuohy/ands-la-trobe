<p:declare-step 
	name="ingest-handler" version="1.0"
	xmlns:p="http://www.w3.org/ns/xproc" 
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:f="info:fedora/fedora-system:def/foxml#"
	xmlns:atom="http://www.w3.org/2005/Atom" 
	xmlns:ands="http://www.example.org/" 
	xmlns:lib="http://code.google.com/p/ands-la-trobe/wiki/XProcLibrary"
	xmlns:ft="http://www.fedora.info/definitions/1/0/types/">
<!-- 
	Handle the ingestion of a new Fedora .

	Mint a handle for the record and attach it. 
	
	Convert booking system metadata to "dataset" datastream.
	
	Recognise the different types of data files and tag them with alternative identifiers:
		SurfaceLab6 dataset files have the extension .itm
		Vision dataset files have the extension .dset 
		VAMAS files have the extension .vms
-->
	<p:import href="library.xpl"/>

	<p:input port="source"/>

	<!-- options passed to this pipeline from the command-line -->
	<p:option name="fedora-username"/>
	<p:option name="fedora-password"/>
	<p:option name="pids-identity-file" required="true"/>
	<p:option name="pids-uri" required="true"/>
	
	<!-- variables parsed out of the message from Fedora -->
	<p:variable name="method" select="/atom:entry/atom:title[@type='text']"/>
	<p:variable name="datastream" select="/atom:entry/atom:category[@scheme='fedora-types:dsID']/@term"/>
	<p:variable name="identifier" select="/atom:entry/atom:summary[@type='text']"/>
	<p:variable name="uri-encoded-identifier" select="fn:encode-for-uri($identifier)"/> 
	<p:variable name="fedora-base-uri" select="'http://localhost:8080/fedora'"/>
	<p:variable name="item-base-uri" select="concat($fedora-base-uri, '/objects/', $uri-encoded-identifier)"/>
	<p:variable name="handle-datastream-uri" select="concat($item-base-uri, '/datastreams/handle')"/>
	<p:variable name="dataset-datastream-uri" select="concat($item-base-uri, '/datastreams/dataset')"/>
	<p:variable name="public-item-uri" select="concat('http://andsdb-dc19-dev.latrobe.edu.au/fedora/objects/', $uri-encoded-identifier, '/datastreams')"/>
   	
	<p:choose>
		<p:when test="$method='ingest'">
		
			<!-- recognise the types of ingested files (by extension) and explicitly set their format uri and internet media type -->
			<lib:fedora-tag-datastreams>
				<p:input port="type-map">
					<p:inline>
						<map>
							<type 
								extension="vms" 
								format-uri="http://www.iso.org/iso/iso_catalogue/catalogue_tc/catalogue_detail.htm?csnumber=24269" 
								content-type="chemical/x-vamas-iso14976"/>
							<type 
								extension="dset" 
								format-uri="http://hdl.handle.net/102.100.100/6972" 
								content-type="application/x-kratos-vision-dataset"/>
							<type 
								extension="itm" 
								format-uri="http://hdl.handle.net/102.100.100/6972" 
								content-type="application/x-iontof-surfacelab-measurement"/>
						</map>
					</p:inline>
				</p:input>
				<p:with-option name="username" select="$fedora-username"/>
				<p:with-option name="password" select="$fedora-password"/>
				<p:with-option name="item-base-uri" select="$item-base-uri"/>
			</lib:fedora-tag-datastreams>
			
			<!-- Create a handle for the object -->
			<lib:ensure-fedora-object-has-handle>
				<p:with-option name="fedora-username" select="$fedora-username"/>
				<p:with-option name="fedora-password" select="$fedora-password"/>
				<p:with-option name="handle-datastream-uri" select="$handle-datastream-uri"/>
				<p:with-option name="public-item-uri" select="$public-item-uri"/>
				<p:with-option name="pids-identity-file" select="$pids-identity-file"/>
				<p:with-option name="pids-uri" select="$pids-uri"/>
			</lib:ensure-fedora-object-has-handle>

			<!-- convert BOSS (booking system) metadata -->
			<lib:http-request method="get" name="get-boss-metadata-stream" detailed="true">
				<p:input port="source"><p:empty/></p:input>
				<p:with-option name="username" select="$fedora-username"/>
				<p:with-option name="password" select="$fedora-password"/>
				<p:with-option name="uri" select="concat($item-base-uri, '/datastreams/boss/content')"/>
			</lib:http-request>
			<p:choose name="whether-object-has-a-boss-datastream">
				<p:when test="/c:response[@status='200']">
					<p:variable name="user-id" select="/c:response/c:body/values/proposalRequest/UsersUID"/>
					<p:variable name="uri-encoded-user-pid" select="fn:encode-for-uri(concat('person:', $user-id))"/>
					<p:variable name="user-person-datastream-uri" select="concat($fedora-base-uri, '/objects/', $uri-encoded-user-pid, '/datastreams/person')"/>
					<!-- The new object contains a boss metadata stream which should be converted to a dataset stream, -->
					<!-- and which may also require the creation of a person object to represent the researcher -->
					<p:viewport name="boss-datastream-within-http-response" match="/c:response/c:body/*">
						<p:identity name="boss"/>

						<!-- convert boss to dataset metadata and store in fedora -->
						<lib:crosswalk xslt="../xslt/boss-to-dataset.xsl" name="dataset"/>
						<lib:fedora-save-datastream name="dataset-to-fedora">
							<p:with-option name="username" select="$fedora-username"/>
							<p:with-option name="password" select="$fedora-password"/>
							<p:with-option name="uri" select="$dataset-datastream-uri"/>
						</lib:fedora-save-datastream>
						<p:sink name="ignore-response-to-saving-dataset"/>

						<!-- check if there's an existing user corresponding to the boss user -->
						<lib:http-request method="head" name="check-for-existing-user" detailed="true">
							<p:input port="source"><p:empty/></p:input>
							<p:with-option name="username" select="$fedora-username"/>
							<p:with-option name="password" select="$fedora-password"/>
							<p:with-option name="uri" select="$user-person-datastream-uri"/>
						</lib:http-request>
						<p:choose name="whether-user-already-exists">
							<p:when test="/c:response/@status='200'">
								<!-- user found -->
								<p:identity name="ignore-existing-user"/>
							</p:when>
							<p:otherwise>
								<!-- user not found - must create them -->
								<lib:crosswalk xslt="../xslt/boss-to-person.xsl" name="person">
									<p:input port="source"><p:pipe step="boss" port="result"/></p:input>
								</lib:crosswalk>
								<p:store href="file:///tmp/new-person-datastream.xml"/>
								<p:in-scope-names name="new-user-pid"/>
								<!-- construct an Atom document for ingest by Fedora -->
								<p:template name="construct-fedora-object-description">
									<p:input port="template">
										<p:inline exclude-inline-prefixes="c">
											<feed xmlns="http://www.w3.org/2005/Atom">
												<id>info:fedora/person:{$user-id}</id>
											</feed>
										</p:inline>
									</p:input>
									<p:input port="source">
										<p:empty/>
									</p:input>
									<p:input port="parameters">
										<p:pipe step="new-user-pid" port="result"/>
									</p:input>
								</p:template>
								<!-- post the Atom document to Fedora to create the user record -->
								<lib:http-request method="post" name="create-person-object">
									<p:with-option name="username" select="$fedora-username"/>
									<p:with-option name="password" select="$fedora-password"/>
									<p:with-option name="uri" select="concat($fedora-base-uri, '/objects/new?format=', fn:encode-for-uri('info:fedora/fedora-system:ATOM-1.1'))"/>
									<p:with-option name="accept" select="'text/plain'"/>
								</lib:http-request>
								<!-- add the "person" xml datastream to the new user object -->
								<lib:fedora-save-datastream name="save-new-user-person-datastream">
									<p:input port="source"><p:pipe step="person" port="result"/></p:input>
									<p:with-option name="username" select="$fedora-username"/>
									<p:with-option name="password" select="$fedora-password"/>
									<p:with-option name="uri" select="$user-person-datastream-uri"/>
								</lib:fedora-save-datastream>
								<p:store href="file:///tmp/save-new-user-person-datastream.xml"/>
								<p:identity name="ignore-response-to-saving-user">
									<p:input port="source"><p:pipe step="save-new-user-person-datastream" port="result"/></p:input>
								</p:identity>
							</p:otherwise>
						</p:choose>
					</p:viewport>
					<p:sink name="ignore-result-of-handling-boss-datastream"/>
				</p:when>
				<p:otherwise>
					<p:sink name="ignore-missing-boss-datastream"/>
				</p:otherwise>
			</p:choose>
			
		</p:when>
		<p:otherwise>
			<!-- the notification message is not about the ingestion of a new object -->
			<p:sink name="ignoring-non-ingest-notification-message"/>
		</p:otherwise>
	</p:choose>

</p:declare-step>

