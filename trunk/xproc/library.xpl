<p:library version="1.0" xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:lib="http://code.google.com/p/ands-la-trobe/wiki/XProcLibrary">


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
				<!-- The datastream exists, so it can be updated with PUT to a URI like "/objects/{pid}/datastreams/{dsID}/content" --> 
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
		
		<p:in-scope-names name="variables"/>
		
		<p:choose name="choose-method">
			<p:when test="$method = 'get' or $method='head'">
				<p:template name="construct-request-document-for-get-or-head">
					<p:input port="template">
						<p:inline exclude-inline-prefixes="c">
							<c:request detailed="{$detailed}" send-authorization="true"  method="{$method}" href="{$uri}" auth-method="Basic" username="{$username}" password="{$password}">
								<c:header name="Accept" value="text/xml"/>
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
				<p:template name="construct-request-document-for-put-or-post">
					<p:input port="template">
						<p:inline exclude-inline-prefixes="c">
							<c:request detailed="{$detailed}" send-authorization="true" method="{$method}" href="{$uri}" auth-method="Basic" username="{$username}" password="{$password}">
								<c:header name="Accept" value="text/xml"/>
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

</p:library>
