#!/bin/bash


read nick chan saying

. ./.config

# Sends message to current channel
# $1 = message to send
function say()
{
    echo "PRIVMSG $chan :$1"
}

# Sends private message to user
# $1 = Message to send
function privsay()
{
    echo "PRIVMSG ${nick//:} :$1"
}

# Sends pinging message to channel
# $1 = user to ping
# $2 = message to send
function say-to()
{
    echo "PRIVMSG $chan $1: $2"
}

botnick=$(head -n 1 ./data/botnick.txt)
regex="\b${botnick}\b"

# Private messages
if [[ $chan == $botnick ]] ; then
    if [[ $nick == $admin ]] ; then # Admin commands
        output=`echo "$nick" "$saying" | ./admin.bash`
        echo "$output"
    fi

    if `echo $saying | grep -i '\broll\b' > /dev/null` ; then
        output=`echo "$nick" "$chan" "$saying" | ./roll.bash`
        echo "$output"
    elif `echo $saying | grep -i '\bhelp\b' > /dev/null` ; then # Help docs
        privsay "Please visit http://web.cecs.pdx.edu/~nickg/dicebothelp.txt"
    elif `echo $saying | grep -i '\bstats\b' > /dev/null` ; then # display stats
        sum=$(head -n 1 ./data/sum.log)
        sumlong=`echo $sum | sed -re ' :restart ; s/([0-9])([0-9]{3})($|[^0-9])/\1,\2\3/ ; t restart '`
        privsay "Total sum of all dice rolled: $(printf "%0.3E\n" $sum) or $sumlong"

        tot=$(head -n 1 ./data/dice.log)
        totlong=`echo $tot | sed -re ' :restart ; s/([0-9])([0-9]{3})($|[^0-9])/\1,\2\3/ ; t restart '`
        privsay "Total number of dice rolled: $(printf "%0.3E\n" $tot) or $totlong"

        if `echo $saying | grep -i '\busers\b' > /dev/null` ; then # Get users
            out="Users of dicebot:"
            num=0
            while read p; do
                out="$out $p"
                let "num+=1"
            done <./data/users.log
            privsay "$num $out"
        fi
    fi
# Regular channel commands
elif ! grep -Fxqi "${nick//:}" ./data/blacklist.txt ; then
    if echo "$saying" | grep -i "$regex" > /dev/null ; then
        if echo "$saying" | grep -i '\bhelp\b' > /dev/null ; then # HELP
            say-to "$nick" "Please visit http://web.cecs.pdx.edu/~nickg/dicebothelp.txt for help using dicebot"
        elif echo "$saying" | grep -i '\broll\b' > /dev/null ; then # ROLL
            output=`echo "$nick" "$chan" "$saying" | ./roll.bash`
            echo "$output"
        elif echo "$saying" | grep -i '\bwho\b' > /dev/null ; then # WHO
            say-to "$nick" "I am a souless automatan created by gilben. This command pings gilben, so be sure to spam it as much as possible"
        elif echo "$saying" | grep -i '\bcommands\b' > /dev/null ; then # COMMANDS
            say-to "$nick" "Dicebot Commands: commands, help, !roll, roll, stats, who"
        elif echo "$saying" | grep -i '\bstats\b' > /dev/null ; then # STATS
            sum=$(head -n 1 ./data/sum.log)
            sumlong=`echo $sum | sed -re ' :restart ; s/([0-9])([0-9]{3})($|[^0-9])/\1,\2\3/ ; t restart '`
            say-to "$nick" "Total sum of all dice rolled: $(printf "%0.3E\n" $sum) or $sumlong"

            tot=$(head -n 1 ./data/dice.log)
            totlong=`echo $tot | sed -re ' :restart ; s/([0-9])([0-9]{3})($|[^0-9])/\1,\2\3/ ; t restart '`
            say-to "$nick" "Total number of dice rolled: $(printf "%0.3E\n" $tot) or $totlong"
        elif echo "$saying" | grep -i '\bsource\b' > /dev/null ; then # SOURCE code on GITLAB
            say-to "$nick" "Dicebot source code: https://gitlab.com/gilben/dicebot"
        fi
    elif echo "$saying" | grep -i '\!roll\b' > /dev/null ; then # ROLL AGAIN
        output=`echo "$nick" "$chan" "$saying" | ./roll.bash`
        echo "$output"
    fi
fi
