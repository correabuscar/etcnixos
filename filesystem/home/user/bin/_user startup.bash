#!/usr/bin/env bash

echo "Hello from script '$0' on stdout"
#stdbuf -o0 -- echo "'$0' here, turning off stdout buffering"
#stdbuf -e0 -- echo "'$0' here, turning off stderr buffering"
#log="/tmp/user_startup.log"
#echo "$0 says hi on stdout before redirecting to $log"
#echo "$0 says hi on stderr before redirecting to $log" >&2
#exec > "$log" 2>&1
#^ both stdout and stderr to same file, from now on.
#but instead of this you should can just use: $ systemctl --user status user_startup    , however it doesn't work for some reason, ergo... Well, it works now due to 'sleep 2' at the end there.

#echo "$0 says hi on stdout this should be in $log"
#echo "$0 says hi on stderr this should be in $log" >&2

#log env. vars
export

#Start to do actual stuff:
vimdir=~/.vim_swap
test -d "$vimdir" || mkdir --parents --mode=700 -- "$vimdir"


#the end:
#echo "$0 says bye on stdout this should be in $log"
#echo "$0 says bye on stderr this should be in $log" >&2
echo "Bye from script '$0' on stdout"
echo "$0 ended, delaying exit by 2 seconds due to https://bugs.freedesktop.org/show_bug.cgi?id=50184#c2" >&2
sleep 2
