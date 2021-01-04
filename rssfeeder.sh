#!/bin/bash

dirdate() {
    echo $(date +%Y-%m-%d)
}

rsslogname() {   
   local -r urlname=$1 
   local -r tname=${urlname////-}
   echo $PODCASTDIR/${tname/:-/}
}

logglobal() {
    local -r mess="$1"
    echo "$mess"
    echo "`date` : $mess" >>$PODCASTDAILYHIST
    echo "`date` : $mess" >>$PODCASTHIST
}

log() {
    logglobal "$1"
    [ -n "$PODCASTRSSHIST" ] && echo "$DIRDAILY : $1" >>$PODCASTRSSHIST
}

logpodcastdaily() {
    local -r mess="$1"
    echo "$mess" >>$PODCASTDAILYSUMMARY  
}

logfile() {
    local -r file=$1
    cat $file >>$PODCASTDAILYHIST
    cat $file >>$PODCASTHIST
    cat $file >>$PODCASTRSSHIST
}

logfatal() {
    log "$1"
    echo "FATAL - cannot continue"
    exit 4
}

setvariables() {
    PODCASTDIR=$1
    DIRDAILY=`dirdate`

    PODCASTDIRDAILY=$PODCASTDIR/$DIRDAILY
    PODCASTLOG=$PODCASTDIR/podcast.log
    PODCASTFAILEDLOG=$PODCASTDIR/podcastfailed.log
    PODCASTHIST=$PODCASTDIR/histlog.log

    PODCASTDAILYLOG=$PODCASTDIRDAILY/podcast.log
    PODCASTDAILYFAILEDLOG=$PODCASTDIRDAILY/podcastfailed.log
    PODCASTDAILYHIST=$PODCASTDIRDAILY/histlog.log
    PODCASTDAILYSUMMARY=$PODCASTDIRDAILY/summary.log

#    PODCASTRSSHIST=$PODCASTDIR/


    mkdir -p $PODCASTDIRDAILY
    touch $PODCASTLOG
    touch $PODCASTFAILEDLOG
}

browseitems() {
    local -r rssfile=$1
    local -r name="$2"
    local -r temp=`mktemp`
    local -r etemp=`mktemp`

    echo "Analize $name : $rssfile"
    xmllint $rssfile --xpath '/rss/channel/item/enclosure/@url' >$temp 2>$etemp

    RES=$?

    if [ $RES -eq 10 ]; then                
       log "Not items in rss"
       logfile $etemp
       rm -f $temp $etemp
       return
    fi

    [ $RES -ne 0 ] && logfatal "Error while analyzing rss"

    local DOWNLOADED=0
    local IGNORED=0
    local FAILED=0
    local IGNOREDFAILED=0

    while IFS= read -r url 
    do
        local line=`echo $url | xargs`
        [ -z "$line" ] && continue
        grep $line $PODCASTLOG
        RES=$?
        if [ $RES -eq 0 ]; then log "$line - already downloaded"; let "IGNORED+=1"; continue
        elif [ $RES -ne 1 ]; then logfatal "Error while grep $PODCASTLOG"
        fi

        grep $line $PODCASTFAILEDLOG
        RES=$?
        if [ $RES -eq 0 ]; then log "$line - already failed"; let "IGNOREDFAILED+=1"; continue
        elif [ $RES -ne 1 ]; then logfatal "Error while grep $PODCASTFAILEDLOG"
        fi
        
        log "Download $line"

        wget -P $PODCASTDIRDAILY $line >$etemp 2>&1                  
        RES=$?
#        RES=0

        if [ $RES -ne 0 ]; then
          let "FAILED+=1"
          local errmess=""
          case $RES in
            1) mess="Generic error code";;
            2) mess="Parse error---for instance, when parsing command-line options, the .wgetrc or .netrc..";;
            3) mess="File I/O error";;
            4) mess="Network failure";;
            5) mess="SSL verification failure";;
            6) mess="Username/password authentication failure.";;
            7) mess="Protocol errors";;
            8) mess="Server issued an error response";;
            *) mess="Other errors";;
          esac

          echo $line >>$PODCASTFAILEDLOG
          cp $PODCASTFAILEDLOG $PODCASTDAILYFAILEDLOG
          logfile $etemp
          log "Failed $RES $mess"
        else

          log "OK"
          let "DOWNLOADED+=1"
          echo $line >>$PODCASTLOG
          cp $PODCASTLOG $PODCASTDAILYLOG
        fi

    done < <(sed 's/url="//g' <$temp| sed 's/"/\n/g' )

    local -r summarymess="Summary: downloaded: $DOWNLOADED , ignored: $IGNORED , failed: $FAILED , ignored failed: $IGNOREDFAILED"
    log "$summarymess"
    logpodcastdaily "$summarymess"
    logpodcastdaily ""

    rm -f $temp $etemp
}

downloadrss() {
    local -r rssurl=$1
    local -r name="$2"
    local -r tmprss=`mktemp`
    local -r etmp=`mktemp`

    PODCASTRSSHIST=`rsslogname $rssurl`
    log "$name"
    log $rssurl
    logpodcastdaily "`date`  $name : $rssurl"
    wget $rssurl -O $tmprss >$etmp 2>&1
    local RES=$?
    if [ $RES -ne 0 ]; then
       logfile $etemp
       rm -f $tmprss $etmp
       logfatal "Cannot open RSS"
    fi
    browseitems $tmprss "$name"
    rm -f $tmprss $etmp
}

loadpodcasts() {
    local -r bpfile=$1
    log $bpfile
    logpodcastdaily "========================================"
    while IFS=@ read -r name rssurl 
    do
        local line=`echo $rssurl | xargs`
        [ -z "$line" ] && continue
        downloadrss $line "$name"
    done <$bpfile
}

test() {
#    browseitems rss.xml    
#   browseitems podcast.xml
#  browseitems podcast.xml.1
#  downloadrss https://www.theguardian.com/news/series/todayinfocus/podcast.xml  
   setvariables /tmp/podcast
   loadpodcasts template/bptest.conf
}

printhelp() {
    echo "rssfeeder 1.0 24 DEC 2020"
    echo
    echo "Launch:"
    echo "rssfeeder.sh /podcastdir/ /bpfile/"
    echo " where:"
    echo "    podcastdir - home directory for podcast files"
    echo "    bpfile - list of rss urls"
    echo 
    echo "Example: ./rssfeeder.sh /tmp/podcast bp.conf"
    exit 4
}

# test

run() {
  [ $# -ne 2 ] && printhelp
  local -r podcastdir=$1
  local -r inputfile=$2
  setvariables $podcastdir
  case "$podcastdir" in 
    -?|--help) printhelp;;
    "") printhelp;;
    *) loadpodcasts $inputfile;;
  esac    
}

run $@
#test
