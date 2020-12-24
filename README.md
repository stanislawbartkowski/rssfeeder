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
