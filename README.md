# dirnews / news.sh
news.sh is a  bash script replacement for sysnews, written for FreeBSD but easily changed to fit your *N*X flavor.

## Description: 
  news.sh shows the contents of files specified in $DIRNEWSDIR along with file owner and modified date of file.
  File ending .txt is stripped and underscore is replaced with whitespace to create the title of the news item.
  When a news item has been read the script creates $DIRNEWSHOMEDIR<newsitem_name>.read
  $DIRNEWSDIR should have mode 1777 set to allow any user to create news, but prohibit deletion of other users' news.
  $DIRNEWSDIR and $DIRNEWSHOMEDIR should end with trailing /
  Some commands (e.g. stat(1)) have different syntax in FreeBSD than GNU versions.

## Help: 
news.sh 1.2 [invoked as /bin/news]
Usage: /bin/news [options]

OPTIONS:
  -all: Read all news even if already read
  -clean: Remove (all) files in /home/dir-admins/mahriman/.dirnews/ that mark news as read
  -user <username>: Read all news written by <username>
  -help: This help
