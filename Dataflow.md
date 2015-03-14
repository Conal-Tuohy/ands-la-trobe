Data is ingested into Fedora using SWORD, edited using XForms, manipulated and cross-walked using XSLT transformations, parsed by metadata extractors, and exported to an OAI-PMH server and a search engine.

The automated flow of data through the system is driven by a set of events. Fedora emits notifications of these events, and a set of event-handlers receive these notifications and perform processing in response.

## Events ##

<table border='1'>
<thead>
<tr valign='top'>
<th>Event name</th>
<th>Description</th>
<th>Tasks triggered by event</th>
</tr>
</thead>
<tbody>
<tr valign='top'>
<td>Package Ingested</td>
<td>A package containing data and initial metadata from booking system has been ingested.</td>
<td>
<ul>
<li>mint and attach PID</li>
<li>extract technical metadata</li>
<li>convert booking system metadata to editable form</li>
</ul>
</td>
</tr>
<tr valign='top'>
<td>Metadata Updated</td>
<td>Metadata has been updated either by:<ul><li>direct data entry using a form,</li><li>the automated conversion of metadata ingested from the booking system, or</li><li>automated extraction from data files.</li></ul></td>
<td>Update the Solr index and OAI-PMH provider of RIF-CS.</td>
</tr>
<tr valign='top'>
<td>Data Updated</td>
<td>Data files in a Fedora object have been updated</td>
<td>Extract technical metadata and save it to Fedora.</td>
</tr>
</tbody>
</table>

## Event Handlers ##

<table border='1'>
<blockquote><thead>
<blockquote><tr valign='top'>
<blockquote><th>Handler Name</th>
<th>Events Triggering this Handler</th>
<th>Tasks Performed</th>
</blockquote></tr>
</blockquote></thead>
<tbody>
<blockquote><tr valign='top'>
<blockquote><td>Ingest Handler</td>
<td><ul><li>Package Ingested</li></ul></td>
<td><ul><li>mint and attach PID</li><li>convert booking system metadata to our editable format</li><li>recognise data files and tag them with altID "vamas" or "surfacelab-itm"</li></ul></td>
</blockquote></tr>
<tr valign='top'>
<blockquote><td>SurfaceLab Update Handler</td>
<td><ul><li>Data with altID "surfacelab-itm" Updated</li></ul></td>
<td><ul><li>Extract technical metadata</li></ul></td>
</blockquote></tr>
<tr valign='top'>
<blockquote><td>VAMAS Update Handler</td>
<td><ul><li>Data with altID "vamas" Updated</li></ul></td>
<td><ul><li>Extract technical metadata</li></ul></td>
</blockquote></tr>
<tr valign='top'>
<blockquote><td>Metadata Update Handler</td>
<td><ul><li>Metadata Updated</li></ul></td>
<td><ul><li>Convert the metadata to Solr schema and update index</li><li>Convert to RIF-CS and update OAI-PMH provider</li><li>Convert to DC and update Fedora</li></ul></td>
</blockquote></tr>
</blockquote></tbody>
</table>