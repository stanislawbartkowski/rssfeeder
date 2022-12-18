#!/bin/bash

PODCASTDIR=$1

cd /home/podcast/rssfeeder
./rssfeeder.sh $PODCASTDIR bp.conf
