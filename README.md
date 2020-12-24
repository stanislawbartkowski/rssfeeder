# rssfeeder

It is a simple podcast feeder downloading RSS podcasts in an incremental way. The solution consists of several simple bash scripts easy to customiz and adjust to someone particular needs.

# Solution description

The solution is designed to be run as a crontab job on daily or even hourly basis. It keeps the history of podcasts already downloaded and select only new programms published after the last download.<br>

The general flow<br>

* The *rssfeeder* script read a list of RSS pages (for instance: https://www.theguardian.com/news/series/todayinfocus/podcast.xml). 
* Extracts the list of programs, usually *mp3* files, using XPath  **/rss/channel/item/enclosure/@url**. 
* Compares the list with the list of podcasts already downloaded and downloads only new ones.
* Stores the results in the *podcast* directory. The directory structure is defined below.

# Podcast directory

* **2020-12-19**  : Daily directories
* **2020-12-20**
* **2020-12-21**
* **2020-12-22**
* **2020-12-23**

* **histlog.log**  : Log file
* **http-downloads.bbc.co.uk-podcasts-radio3-r3arts-rss.xml** : Log file regarding a single podcast RSS
* **http-downloads.bbc.co.uk-podcasts-radio4-aitm-rss.xml**
* **podcastfailed.log** : List of failed podcast, for instance, the podcast is listed in RSS but URL points to non-existing file
* **podcast.log** : List of all podcasts already downloded. *rssfeeder* uses this file to ignore podcasts

# Usage description

The solution consists of one bash script file and number of template files to utilize.

*./rssfeeder.sh /podcast directory/ /list of rss urls/*

Example: *./rssfeeder.sh /mnt/usb/podcast bp.conf*

Parameter description

| Parameter | Description | Example |
| -------- | ------------ | -------- |
| podcast directory | Directory where podcasts are stored in daily basis | /mnt/usb/podcast
| list of rss urls | File containing list of rss url. Every line contains a single RSS site | bp.conf

# Template

https://github.com/stanislawbartkowski/rssfeeder/tree/main/template

| File | Description |
| --- | --- |
| bp.conf | Example file with list of RSS sites
| cronjob.sh | Example of cron job launching rssfeeder
| crontab | Example of crontab
| testdown.sh | Test bash script file executing rssfeeder.sh


