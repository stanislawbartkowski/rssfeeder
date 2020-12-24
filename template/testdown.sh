#!/bin/bash

#PODCASTDIR=/mnt/usb1/podcast.test

PODCASTDIR=$1

PODCASTDIR=/mnt/usb/podcast
cd /home/podcast/rssfeeder
./rssfeeder.sh $PODCASTDIR bp.conf
