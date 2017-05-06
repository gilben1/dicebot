#!/bin/bash

function send {
    echo "-> $1"
    echo "$1" >> .botfile
}

. ./.config

echo $botnick > ./data/botnick.txt

connection="$server:$port"

if [ ! -f ./data/autojoin.txt ] ; then
    touch ./data/autojoin.txt
fi

if [ ! -f ./data/blacklist.txt ] ; then
    touch ./data/blacklist.txt
fi

rm .botfile
mkfifo .botfile

echo "" | mail -s "$botnick connecting to $connection" $mail

tail -f .botfile | openssl s_client -connect $connection | while read irc ; do
    if [[ -z $started ]] ; then
        send "USER ${botnick} ${botnick} ${botnick} :${botnick}"
        send "NICK ${botnick}"

        # Read through the channels set to autojoin, and join them
        while read p; do
            send "JOIN $p"
        done <./data/autojoin.txt
        started="yes"
    fi
    echo "<- $irc"
    if `echo "$irc" | cut -d ' ' -f 1 | grep PING > /dev/null` ; then
        send "PONG"
    elif `echo $irc | grep PRIVMSG > /dev/null` ; then
        chan=`echo "$irc" | cut -d ' ' -f 3` 
        barf=`echo "$irc" | cut -d ' ' -f 1-3`

        saying=`echo "${irc##$barf :}"|tr -d "\r\n"`
        nick="${irc%%!*}"; nick="${nick#;}"
        var=`echo "$nick" "$chan" "$saying" | ./cmds.bash`
        if [[ ! -z $var ]] ; then
            send "$var"
        fi
    fi
done
tmux send -t dicebot exit ENTER

