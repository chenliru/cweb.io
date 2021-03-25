
HISTFILE=~/.sh_history
export HISTFILE
 
PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:$HOME/bin:/usr/bin/X11:/sbin:.
export PATH

PS1="[\$USER@`hostname` \$PWD] $ "
export PS1

if [ -s "$MAIL" ]           # This is at Shell startup.  In normal
then echo "$MAILMSG"        # operation, the Shell checks
fi                          # periodically.

stty columns 132
set -o vi
