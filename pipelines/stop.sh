#!/bin/bash
# This script stops a persistent subscription previously made by a fedora-update-handler service

# The service is a JMS client which listens to "fedora.apim.update" messages from Fedora.
# When an update event occurs, the fedora-update-handler executes an external program
# and passes the event message (an Atom XML document) to the program's standard input.

java -jar /home/fedora-user/pipelines/fedora-update-handler/fedora-update-handler.jar stop $1
