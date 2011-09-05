<p:library version="1.0" 
	xmlns:p="http://www.w3.org/ns/xproc" 
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	xmlns:lib="http://code.google.com/p/ands-la-trobe/wiki/XProcLibrary"
	xmlns:fn="http://www.w3.org/2005/xpath-functions" >

	
	<p:declare-step type="lib:fedora-tag-datastreams">
		<p:option name="username" required="true"/>
		<p:option name="password" required="true"/>
		<p:option name="extension" required="true"/>
		<p:option name="uri"/>
		<p:option name="format-uri"/>
		<p:option name="content-type"/>
	
		<p:for-each name="matching-files">
			<!-- for each file with a matching extension ... -->
			<p:iteration-source select="/f:digitalObject/f:datastream[ends-with(lower-case(f:datastreamVersion[last()]/@LABEL), $extension)]"/>
			<!--	 tag the file -->
			<lib:fedora-set-datastream-format>
				<p:with-option name="format-uri" select="$format-uri"/>
				<p:with-option name="content-type" select="$content-type"/>
				<p:with-option name="username" select="$fedora-username"/>
				<p:with-option name="password" select="$fedora-password"/>
				<p:with-option name="uri" select="concat($item-base-uri, '/datastreams/', fn:encode-for-uri(/f:datastream/@ID))"/>
			</lib:fedora-set-datastream-format>
		</p:for-each>    
	</p:declare-step>
	
	<!-- tag a datastream with a format URI -->
	<p:declare-step type="lib:fedora-set-datastream-format" name="fedora-set-datastream-format">
		<p:option name="username" required="true"/>
		<p:option name="password" required="true"/>
		<p:option name="uri"/>
		<p:option name="format-uri"/>
		<p:option name="content-type"/>
		<lib:http-request method="put" name="update-properties" detailed="true">
			<p:input port="source"><p:inline><ignore/></p:inline></p:input>
			<p:with-option name="username" select="$username"/>
			<p:with-option name="password" select="$password"/>
			<p:with-option name="uri" select="concat($uri, '?ignoreContent=true&amp;formatURI=', fn:encode-for-uri($format-uri), '&amp;mimeType=', fn:encode-for-uri($content-type))"/>			
		</lib:http-request>
		<p:sink name="ignore-response-from-fedora"/>
	</p:declare-step>
	
	<!-- create or update a datastream in Fedora -->
	<p:declare-step type="lib:fedora-save-datastream" name="fedora-save-datastream">
		<p:input port="source"/>
		<p:output port="result"/>
		<p:option name="username" required="true"/>
		<p:option name="password" required="true"/>
		<p:option name="uri"/>
		<!-- 
			Fedora doesn't allow a datastream to be created with a PUT, or updated with a POST
			so it's necessary to check if the datastream exists first, and use a different method
			and different URI for the different cases.
		-->
		<lib:http-request method="head" name="check-if-datastream-exists-already">
			<p:with-option name="username" select="$username"/>
			<p:with-option name="password" select="$password"/>
			<p:with-option name="uri" select="$uri"/>
		</lib:http-request>	
		<p:choose name="whether-datastream-already-exists">
			<p:when test="/c:response[@status='404']">
				<!-- The datastream does not exist, so it must be created by a POST to a URI like "/objects/{pid}/datastreams/{dsID}" -->
				<lib:http-request method="post" name="create-datastream">
					<p:input port="source">
						<p:pipe step="fedora-save-datastream" port="source"/>
					</p:input>
					<p:with-option name="username" select="$username"/>
					<p:with-option name="password" select="$password"/>
					<p:with-option name="uri" select="$uri"/>
				</lib:http-request>
			</p:when>
			<p:otherwise>
				<!-- The datastream exists, so it can be updated with PUT to a URI like "/objects/{pid}/datastreams/{dsID}" --> 
				<lib:http-request method="put" name="update-datastream">
					<p:input port="source">
						<p:pipe step="fedora-save-datastream" port="source"/>
					</p:input>
					<p:with-option name="username" select="$username"/>
					<p:with-option name="password" select="$password"/>
					<p:with-option name="uri" select="$uri"/>
				</lib:http-request>
			</p:otherwise>
		</p:choose>
	</p:declare-step>

	<!-- shorthand for executing an XSLT crosswalk -->
	<p:declare-step type="lib:crosswalk" name="crosswalk">
	
		<p:input port="source"/>
		<p:output port="result"/>
		
		<p:option name="xslt" required="true"/>
		
		<p:load name="load-stylesheet">
			<p:with-option name="href" select="$xslt"/>
		</p:load>

		<p:xslt name="execute-xslt">
			<p:input port="source">
				<p:pipe step="crosswalk" port="source"/>
			</p:input>
			<p:input port="parameters">
				<p:empty/>
			</p:input>
			<p:input port="stylesheet">
          	<p:pipe step="load-stylesheet" port="result"/>
          </p:input>
		</p:xslt>
		
	</p:declare-step>

		<!-- 
			Execute an HTTP request.
			
			Constructs an XProc http request document
			by taking "method", "uri", "username" and "password"
			parameters and substituting them into a
			template, then executes the request
		-->
	<p:declare-step type="lib:http-request" name="http-request">
		
		<p:input port="source"/>
		<p:output port="result"/>
		
		<p:option name="method" select="'get'"/>
		<p:option name="username"/>
		<p:option name="password"/>
		<p:option name="uri" required="true"/>
		<p:option name="detailed" select="'true'"/>
		<p:option name="accept" select="'text/xml'"/>
		
		<p:in-scope-names name="variables"/>
		
		<p:choose name="choose-method">
			<p:when test="($method = 'get' or $method='head')">
				<p:template name="construct-request-without-body">
					<p:input port="template">
						<p:inline exclude-inline-prefixes="c">
							<c:request detailed="{$detailed}" send-authorization="true"  method="{$method}" href="{$uri}" auth-method="Basic" username="{$username}" password="{$password}">
								<c:header name="Accept" value="{$accept}"/>
							</c:request>
						</p:inline>
					</p:input>
					<p:input port="source">
						<p:pipe step="http-request" port="source"/>
					</p:input>
					<p:input port="parameters">
						<p:pipe step="variables" port="result"/>
					</p:input>
				</p:template>
			</p:when>
			<p:otherwise><!-- put or post allow a message body -->
				<p:template name="construct-request-with-body">
					<p:input port="template">
						<p:inline exclude-inline-prefixes="c">
							<c:request detailed="{$detailed}" send-authorization="true" method="{$method}" href="{$uri}" auth-method="Basic" username="{$username}" password="{$password}">
								<c:header name="Accept" value="{$accept}"/>
								<c:body content-type="text/xml">{/*}</c:body>
							</c:request>
						</p:inline>
					</p:input>
					<p:input port="source">
						<p:pipe step="http-request" port="source"/>
					</p:input>
					<p:input port="parameters">
						<p:pipe step="variables" port="result"/>
					</p:input>
				</p:template>
			</p:otherwise>
		</p:choose>
		<!-- execute the request -->
		<p:http-request name="execute-request"/>
	</p:declare-step>
	
	<p:declare-step type="lib:mint-handle">
		<p:input port="source"/>
		<p:output port="result"/>

		<p:option name="pids-identity-file" required="true"/>
		<p:option name="pids-uri" required="true"/>
		<p:option name="uri" required="true"/>
		<p:in-scope-names name="variables"/>

		<p:load name="load-pids-identity-file">
			<p:with-option name="href" select="$pids-identity-file"/>
		</p:load>
		<lib:http-request method="post">
			<p:with-option name="uri" select="concat($pids-uri, '/mint?type=URL&amp;value=', fn:encode-for-uri($uri))"/>
			<p:input port="source">
				<p:pipe step="load-pids-identity-file" port="result"/>
			</p:input>
		</lib:http-request>
	</p:declare-step>
	
	<!-- checks if an object has a handle datastream, and if not, it creates one -->
	<p:declare-step type="lib:ensure-fedora-object-has-handle">
	<!--
		<p:input port="source"/>
		<p:output port="result"/>
	-->
		<p:option name="fedora-username"/>
		<p:option name="fedora-password"/>
		<p:option name="pids-uri"/>
		<p:option name="pids-identity-file"/>
		<p:option name="handle-datastream-uri"/>
		<p:option name="public-item-uri"/>
		
		<lib:http-request name="check-if-handle-exists" method="head">
			<p:input port="source"><p:empty/></p:input>
			<p:with-option name="username" select="$fedora-username"/>
			<p:with-option name="password" select="$fedora-password"/>
			<p:with-option name="uri" select="$handle-datastream-uri"/>
		</lib:http-request>	
		
		<!-- if the Fedora item has no handle metadata then we will have received:
		<c:response xmlns:c="http://www.w3.org/ns/xproc-step" status="404">
		-->
		
		<p:for-each name="item-missing-handle">
			<p:iteration-source select="/c:response[@status='404']"/>
			<p:identity/>
			<!-- mint a handle for the datastream -->
			<lib:mint-handle>
				<p:with-option name="pids-identity-file" select="$pids-identity-file"/>
				<p:with-option name="pids-uri" select="$pids-uri"/>
				<p:with-option name="uri" select="$public-item-uri"/>
			</lib:mint-handle>
			<!-- post the handle stream back into fedora -->
			<lib:http-request name="save-handle" method="post">
				<p:with-option name="username" select="$fedora-username"/>
				<p:with-option name="password" select="$fedora-password"/>
				<p:with-option name="uri" select="$handle-datastream-uri"/>
			</lib:http-request>	

		</p:for-each>
		<p:sink name="return-nothing"/>
	</p:declare-step>
	
</p:library>
