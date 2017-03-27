#!/bin/bash

function send {
	echo "-> $1"
	echo "$1" >> .botfile
}

if [ $# -lt 2 ] ; then
    echo "Specify the nickname, server and port to connect to: "
    echo "Format: ./dicebot.sh \$server \$port [-optional nickname]"
    exit
fi

count=0

if [ $# -lt 3 ] ; then
    botnick="dicebot"
fi

for i in "$@" ; do
    if [ $count -eq 0 ] ; then
        server=$i
        let "count += 1"
    elif [ $count -eq 1 ] ; then
        port=$i
        let "count += 1"
    elif [ $count -eq 2 ] ; then
        botnick=$i
        let "count += 1"
    fi
done

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
tail -f .botfile | openssl s_client -connect $connection | while true ; do
	if [[ -z $started ]] ; then
		send "USER ${botnick} ${botnick} ${botnick} :${botnick}"
		send "NICK ${botnick}"

        # Read through the channels set to autojoin, and join them
        while read p; do
            send "JOIN $p"
        done <./data/autojoin.txt

		started="yes"
	fi
	read irc
	echo "<- $irc"
	if `echo "$irc" | cut -d ' ' -f 1 | grep PING > /dev/null` ; then
		send "PONG"
	elif `echo $irc | grep PRIVMSG > /dev/null` ; then
		chan=`echo "$irc" | cut -d ' ' -f 3`
		barf=`echo "$irc" | cut -d ' ' -f 1-3`
		saying=`echo "${irc##$barf :}"|tr -d "\r\n"`
		nick="${irc%%!*}"; nick="${nick#;}"
		var=`echo $nick $chan $saying | ./cmds.bash`
		if [[ ! -z $var ]] ; then
			send "$var"
		fi
	fi
done
