# Filestore interface #

The storage interface (this is what we'd have to implement using Fedora):

http://dev.tdar.org/fisheye/browse/tDAR/trunk/src/main/java/org/tdar/filestore/Filestore.java?hb=true

How does it relate to the FilestoreService (which is supposed to provide access to a "Person" Filestore)?

http://dev.tdar.org/fisheye/browse/~br=trunk/tDAR/trunk/src/main/java/org/tdar/core/service/FilestoreService.java?r=2484

How does one save metadata in filestore?

NB org.tdar.core.service.ResourceService.saveRecordToFilestore appears to write a "record.xml" to the file store, but there's no code calling that method, and there are no such files in the file store. How does it all work?

# Metadata schema #

The metadata schema used in tDAR is shown in this test case:

http://dev.tdar.org/fisheye/browse/tDAR/trunk/src/test/resources/xml/documentImport.xml?hb=true

http://dev.tdar.org/fisheye/browse/tDAR/trunk/src/test/java/org/tdar/struts/action/APIControllerITCase.java?hb=true

# Skin #

The main layout page of the tDAR app (which will need to be customised to brand AHAD): http://dev.tdar.org/fisheye/browse/tDAR/trunk/src/main/webapp/layout.dec?hb=true

This service shows a federated search over the ADS and tDAR repositories (at a granularity of projects, only, though). This apparently is built on a tDAR web service.

http://archaeologydataservice.ac.uk/TAG/