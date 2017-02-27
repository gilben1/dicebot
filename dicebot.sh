#!/bin/bash

function send {
	echo "-> $1"
	echo "$1" >> .botfile
}
rm .botfile
mkfifo .botfile
tail -f .botfile | openssl s_client -connect irc.cat.pdx.edu:6697 | while true ; do
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
