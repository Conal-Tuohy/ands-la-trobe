# Introduction #

A list of procedures for setting up the CMSS Repository and Metadata Capture system.

# General Notes #

  1. All internal applications listen on tcp port 8080 and use an apache rewrite rule reverse proxy.

The directory structure must mirror the following and be fully writable to the owner and to the tomcat user.

```
|css
|  +solr.css
|  +CMSS.css
|data
| -rif-cs
|fedora ($FEDORA_HOME)
| -</snip>
|pipelines  (checkout from svn)
| -calabash
| -fedora-update-handler
| -log
| -schemas
| -update-handler-configs
| -xproc
| -xslt
|solr ($SOLR_HOME, checkout conf from svn)
| -</snip>
|xforms (checkout from svn)
| -css
| -images
| -xsltforms
```

# Details #

The following guides will assist in setting up the CMSS system. Note that the path /home/fedora-user/ is assumed to be the base path.

  1. follow the [FedoraInstall guide](FedoraInstall.md).
  1. follow the [SWORD install guide](SWORD.md).
  1. follow the [SolrInstall guide](SolrInstall.md).
  1. follow the [Calabash guide](Calabash.md).
  1. follow the [jOAI guide](jOAI.md).
  1. follow the [XForms install guide](DC19XFormsInstall.md).

On the data capture machine:

  1. follow the [SWORD Client Install guide](SWORDClientInstall.md)