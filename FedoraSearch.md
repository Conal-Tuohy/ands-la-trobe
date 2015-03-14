We are using fedora's native search (over Dublin Core metadata) to output an XML list of Fedora objects with 4 possible Type values: dataset, person, group and project.

The following url returns an xml Dataset list from a fedora test server:

http://host/fedora/search?pid=true&label=true&state=true&ownerId=true&cDate=true&mDate=true&dcmDate=true&title=true&creator=true&subject=true&description=true&publisher=true&contributor=true&date=true&format=true&identifier=true&source=true&language=true&relation=true&coverage=true&rights=true&terms=&query=type~dataset&maxResults=100&xml=true

We create an Apache httpd reverse proxy which calls the Fedora search and exposes a simpler URL. NB since Fedora listens on port 8080 and our website is on port 80, a proxy is needed anyway, but we also take the opportunity to simply the URL.

### conf.d ###

Using the following rewrite rules, the http://site/search/$1 url can be made to return an xml list if $1 is equal to one of the 4 values listed above.

```
RewriteRule ^/search/(dataset|person|group|project)/$ /fedora/search?pid=true&label=true&state=true&ownerId=true&cDate=true&mDate=true&dcmDate=true&title=true&creator=true&subject=true&description=true&publisher=true&contributor=true&date=true&format=true&identifier=true&source=true&language=true&relation=true&coverage=true&rights=true&terms=&query=type\~$1&maxResults=100&xml=true [P]
RewriteRule ^/search/(dataset|person|group|project)/(.*) /fedora/search?pid=true&label=true&state=true&ownerId=true&cDate=true&mDate=true&dcmDate=true&title=true&creator=true&subject=true&description=true&publisher=true&contributor=true&date=true&format=true&identifier=true&source=true&language=true&relation=true&coverage=true&rights=true&terms=&query=title\~$2+type\~$1&maxResults=100&xml=true [P]
```

This search service is used by the [XForms](XForms.md) user interface to populate drop-down lists of related entities.