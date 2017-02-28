#!/bin/bash

function send {
	echo "-> $1"
	echo "$1" >> .botfile
}


if [ $# -lt 2 ] ; then
    echo "Specify the channel and port to connect to: "
    echo "Format: ./dicebot.sh \$channel \$port"
    exit
fi

count=0
for i in "$@" ; do
    if [ $count -eq 0 ] ; then
        channel=$i
        let "count += 1"
    elif [ $count -eq 1 ] ; then
        port=$i
        let "count += 1"
    fi
done

connection="$channel:$port"

#6697
rm .botfile
mkfifo .botfile
tail -f .botfile | openssl s_client -connect $connection | while true ; do
	if [[ -z $started ]] ; then
		send "USER dicebot dicebot dicebot :dicebot"
		send "NICK dicebot"
		#send "JOIN #gilbentest"
		#send "JOIN #tabletop"

        # Read through the channels set to autojoin, and join them
        while read p; do
            send "JOIN $p"
        done <./logs/autojoin.txt

		started="yes"
	fi
	read irc
	echo "<- $irc"
	if `echo $irc | cut -d ' ' -f 1 | grep PING > /dev/null` ; then
		send "PONG"
	elif `echo $irc | grep PRIVMSG > /dev/null` ; then
		chan=`echo $irc | cut -d ' ' -f 3`
		barf=`echo $irc | cut -d ' ' -f 1-3`
		saying=`echo $irc##$barf :}|tr -d "\r\n"`
		nick="${irc%%!*}"; nick="${nick#;}"
		var=`echo $nick $chan $saying | ./cmds.bash`
		if [[ ! -z $var ]] ; then
			send "$var"
		fi
	fi
done
