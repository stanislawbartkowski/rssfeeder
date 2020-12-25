#!/bin/bash

#PODCASTDIR=/mnt/usb1/podcast.test
#PODCASTDIR=/mnt/usb/podcast
PODCASTDIR=/tmp/podcast
cd /home/podcast/rssfeeder
./rssfeeder.sh $PODCASTDIR template/bptest.conf
