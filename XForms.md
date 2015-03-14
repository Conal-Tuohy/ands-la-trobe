# XForms #

## plan ##

  * install Mozilla xforms client - done, found wanting.
  * create (edit e.g. name only) basic rif-cs editor with a fixed resource in the fedora back-end - done
    * http://andsdb-dc19-dev.latrobe.edu.au/xforms/rif-cs.xhtml
  * develop editor into full rif-cs handler
    * all registryObject types
    * authority file lookups with autocomplete
  * deploy a transform to wrap the Fedora rif-cs resource in an xform
    * integrate XSLTForms - done, with small caveats (don't make xforms with multiple embedded repeats).
  * completed forms hosted **[here](http://code.google.com/p/ands-la-trobe/source/browse/#svn%2Ftrunk%2Fxforms)**

## CSS ##

  * [Discussion of CSS in XSLTForms](http://en.wikibooks.org/wiki/XSLTForms/CSS)
  * ["Styling XForms" chapter from O'Reilly "XForms Essentials" book](http://xformsinstitute.com/essentials/browse/ch09.php)

## reference ##

  * http://en.wikibooks.org/wiki/XForms
  * [O'Reilly 'XForms Essentials'](http://xformsinstitute.com/essentials/)
  * http://www.scholarslab.org/digital-libraries/on-xforms/
  * [XForms for Libraries](http://journal.code4lib.org/articles/3916)
  * [XForms MODS editor](http://library.brown.edu/its/software/metadata/)
  * [EAD editor](http://code.google.com/p/eaditor/)

## implementations ##
  * http://www.agencexml.com/xsltforms.htm
  * http://www.mozilla.org/projects/xforms/
  * http://wiki.orbeon.com/forms/doc
    * [Orbeon quirk of not passing the HTTP authentication challenge from a server back to the client](http://orbeon-forms-ops-users.24843.n4.nabble.com/Newbie-Question-Authentication-td38649.html)
  * http://www.w3.org/MarkUp/Forms/#implementations

## ExtXSLTForms ##
  * http://extxsltforms.sourceforge.net/sitKubera/index/index.xml
  * [ExtXSLTForms Rich Text Editor](http://extxsltforms.sourceforge.net/sitKubera/examples/rich-text-editors/TinyMCE-rich-text-editor.xml)

## autocomplete/suggest ##

  * http://en.wikibooks.org/wiki/XForms/Suggesting_Items
  * http://wiki.orbeon.com/forms/doc/developer-guide/xbl-components/autocomplete
  * http://internet-apps.blogspot.com/2005/04/xforms-patterns-incremental-and-google.html

## creating hyperlinks to external resources ##
  * http://www.ibm.com/developerworks/forums/thread.jspa?messageID=13967161

## Notes ##

  * Firefox 4 does not play well with XSLTForms < build 499 due to xPath problems.
  * Internet Explorer does not implement the application/xhtml+xml mime type.