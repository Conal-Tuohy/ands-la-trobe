# jOAI installation/configuration log #

oai.war file appeared to be corrupt - Tomcat could not unpack it: "Error: Invalid or unreadable WAR file : error in opening zip file"
So I unpacked the oai.war manually:

```
cd /var/lib/tomcat6/webapps
mkdir oai
cd oai
unzip /home/ctuohy/oai.war
chown -R tomcat:tomcat .
```

configured apache httpd to proxy to the joai servlet running on tomcat, by adding /etc/httpd/conf.d/proxy.conf like so:

```
# Settings for accessing jOAI

# Don't access HTTP proxy requests
# (this is a reverse proxy, not a forward proxy)
ProxyRequests off

# Any user may connect
<Proxy *>
Order deny,allow
Allow from all
</Proxy>

# Access control for proxying to the admin interface
<Location /oai/admin>
AuthType Basic
AuthName "OAI Provider Administration"
AuthBasicProvider
AuthUserFile /etc/httpd/.htpasswd
Require user admin
ProxyPass        http://localhost:8080/oai/admin
ProxyPassReverse http://localhost:8080/oai/admin
</Location>

# Other parts of the OAI server are open to all
<Location /oai>
ProxyPass        http://localhost:8080/oai
ProxyPassReverse http://localhost:8080/oai
</Location>
```

Using the htpasswd utility, added a password file at /etc/httpd/.htpasswd to contain admin credentials.

Configured Tomcat to know that it's being accessed through a proxy, by adding proxyName and proxyPort attributes to the Connector element whose port attribute = "8080" in /etc/tomcat6/server.xml

```
    <Connector port="8080" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443"
               proxyName="andsdb-dc19-dev.latrobe.edu.au"
               proxyPort="80"
        />
```
See [Tomcat proxy howto](http://tomcat.apache.org/tomcat-6.0-doc/proxy-howto.html)

created /ands/rif-cs to hold RIF-CS data files for ANDS harvester

Configured repository through the admin UI:

| Repository name (required): | Centre for Materials and Surface Science (development) |
|:----------------------------|:-------------------------------------------------------|
| Repository administrator's e-mail (required): | conal.tuohy@versi.edu.au |
| Repository description (optional): | The La Trobe University Centre for Materials and Surface Science Data Repository |
| Repository namespace identifier (optional): | cmss.latrobe.edu.au |
| Repository base URL (non-editable): | http://cmss.latrobe.edu.au/oai/provider |

Added and configured metadata directory:

| Nickname for these files: | La Trobe RIF-CS records |
|:--------------------------|:------------------------|
| Format of files: | rif |
| Path to the directory: | /home/fedora-user/data/rif-cs |
| Metadata namespace: | http://ands.org.au/standards/rif-cs/registryObjects |
| Metadata schema: | http://services.ands.org.au/sandbox/orca/schemata/registryObjects.xsd |