#!/usr/local/bin/bash

SCRIPTNAME="news.sh"
SCRIPTVERSION="1.3"
# Author: mahriman <mahriman@direktoratet.se>
# Revisions:
#   1.3 Changed news date to correspond to birth of inode rather than last modified. // 2017-04-16
#   1.2 Added an option to view specific user's news and better argument control. // 2017-04-10
#   1.1 Translated to English, better error checking and other improvements. // 2017-04-10
#   1.0 Base version // 2017-04-09
# Description: 
#   news.sh shows the contents of files specified in $DIRNEWSDIR along with file owner and modified date of file.
#   File ending .txt is stripped and underscore is replaced with whitespace to create the title of the news item.
#   When a news item has been read the script creates $DIRNEWSHOMEDIR<newsitem_name>.read
#   $DIRNEWSDIR should have mode 1777 set to allow any user to create news, but prohibit deletion of other users' news.
#   $DIRNEWSDIR and $DIRNEWSHOMEDIR should end with trailing /
#   Some commands (e.g. stat(1)) have different syntax in FreeBSD than GNU versions.

# Configurable variables
DIRNEWSDIR=/var/spool/dirnews/
DIRNEWSHOMEDIR=$HOME/.dirnews/
CLEARCOLOR="[0m"          # Clear colors
ERRORCOLOR="[0;31m"       # Default error color is dark red [0;31m
NOTICECOLOR="[1;34m"      # Default notice color is light blue [1;34m
TITLECOLOR="[0;35m"       # Default title color is pink [0;35m
NEWSCOLOR="[0m"           # Default news text color is <clear colors> [0m
SUBMITCOLOR="[1;34m"      # Default submitter name color is light blue [1;34m
DATECOLOR="[1;34m"        # Default date color is light blue [1;34m

shopt -s nocasematch
NEWSCOUNT=0

showhelp() {
    echo "$SCRIPTNAME $SCRIPTVERSION [invoked as $0]"
    echo "Usage: $0 [options]"
    echo
    echo "OPTIONS:"
    echo "  -all: Read all news even if already read"
    echo "  -clean: Remove (all) files in $DIRNEWSHOMEDIR that mark news as read"
    echo "  -user <username>: Read all news written by <username>"
    echo "  -help: This help"
    echo
}

if [[ ! -x "$DIRNEWSDIR" || ! -r "$DIRNEWSDIR" ]]; then
    echo "$ERRORCOLOR[!] $DIRNEWSDIR is not readable. Exiting (1).$CLEARCOLOR"
    exit 1
fi

if [[ ! -d "$DIRNEWSHOMEDIR" ]]; then
    echo "$NOTICECOLOR[*] $DIRNEWSHOMEDIR did not exist, I'll just go ahead and create that for you.$CLEARCOLOR"
    mkdir $DIRNEWSHOMEDIR
fi

for arg in "$@"
do
    if [[ $arg = "-help" || $arg = "--help" || $arg = "-h" || $arg = "?" ]]; then
        shift
        showhelp
        echo -n "Continue reading news? y/n: "
        read CHOICECONTINUE
        if [[ "$CHOICECONTINUE" != "y" && "$CHOICECONTINUE" != "yes" ]]; then
            exit 0
        else
            :
        fi 
    elif [[ $arg = "-user" || $arg = "--user" || $arg = "-u" ]]; then
        shift
        if [[ -z "$1" ]]; then
            echo "$ERRORCOLOR[!] $arg option need username. Exiting (2).$CLEARCOLOR"
            exit 2
        fi
        TARGETUSER="$1"
        echo "$NOTICECOLOR[*] Fetching news written by $TARGETUSER$CLEARCOLOR"
    elif [[ $arg = "-all" || $arg = "--all" || $arg = "-a" ]]; then
        shift
        SHOWALL=true
    elif [[ $arg = "-clean" || $arg = "--clean" || $arg = "-c" ]]; then
        shift
        echo "$NOTICECOLOR[*] Cleaning up $DIRNEWSHOMEDIR from read news...$CLEARCOLOR"
        rm "$DIRNEWSHOMEDIR"*.read
    fi
done

for newsitem in $(ls -tr $DIRNEWSDIR);
do
    if [[ ! -e "$DIRNEWSHOMEDIR$newsitem.read" || $SHOWALL = "true" ]]; then
        NEWSSUBMITTER=$(stat -f '%Su' $DIRNEWSDIR$newsitem)
        # Check to see if a certain user's news is requested
        if [[ -n "$TARGETUSER" && "$TARGETUSER" != "$NEWSSUBMITTER" ]]; then
            continue
        fi
        NEWSITEMNAME=$(echo $newsitem|sed 's/\.txt$//g'|sed 's/_/ /g')
        NEWSDATE=$(stat -f %SB -t %F $DIRNEWSDIR$newsitem) 
        if [[ $NEWSCOUNT != "0" ]]; then
            echo "- - -"
        fi
        echo
        echo "$TITLECOLOR[*] $NEWSITEMNAME$CLEARCOLOR ($SUBMITCOLOR$NEWSSUBMITTER$CLEARCOLOR // $DATECOLOR$NEWSDATE$CLEARCOLOR)"
        echo
        if [[ ! -r "$DIRNEWSDIR$newsitem" ]]; then
            echo "$ERRORCOLOR   [!] No permission to read news file's contents.$CLEARCOLOR"
        else
            echo "$NEWSCOLOR"
            cat $DIRNEWSDIR$newsitem
            echo "$CLEARCOLOR"
        fi
        echo
        touch "$DIRNEWSHOMEDIR$newsitem.read" 
        NEWSCOUNT=$(let $NEWSCOUNT+1)
    else
        :
    fi  
done

if [[ $NEWSCOUNT = "0" ]]; then
    echo "$NOTICECOLOR[*] No news."
    echo "    You can use \"$0 -all\" to show all (even read) news.$CLEARCOLOR"
fi
