#!/bin/sh
# $1=fedora-username
# $2=fedora-password
# $3=vamas URI
rm /tmp/vamas-xml.xml
rm /tmp/vamas.vms
curl -u $1:$2 $3 -o /tmp/vamas.vms
java -jar vamas-parser.jar /tmp/vamas.vms > /tmp/vamas-xml.xml

