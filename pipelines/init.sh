#!/bin/sh


screen -dmS ingest 
screen -dmS metadata 
screen -dmS vamas 

sleep 2s;

screen -S ingest -p 0 -X stuff $'/home/fedora-user/pipelines/start.sh /home/fedora-user/pipelines/update-handler-configs/ingest-handler.xml\n'

screen -S metadata -p 0 -X stuff $'/home/fedora-user/pipelines/start.sh /home/fedora-user/pipelines/update-handler-configs/metadata-update-handler.xml\n'

screen -S vamas -p 0 -X stuff $'/home/fedora-user/pipelines/start.sh /home/fedora-user/pipelines/update-handler-configs/vamas-update-handler.xml\n'
