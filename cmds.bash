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

# Usage: has "$thing to search" 'regex'
# Returns if thing 2 is found in thing 1
function has()
{
    echo "$1" | grep -i $2 > /dev/null
}


botnick=$(head -n 1 ./data/botnick.txt)
regex="\b${botnick}\b"

# Private messages
if [[ $chan == $botnick ]] ; then
    if [[ $nick == $admin ]] ; then # Admin commands
        output=`echo "$nick" "$saying" | ./admin.bash`
        echo "$output"
    fi

    if has "$saying" '\broll\b' ; then
        output=`echo "$nick" "$chan" "$saying" | ./roll.bash`
        echo "$output"
    elif has "$saying" '\bhelp\b' ; then
        privsay "Please visit http://web.cecs.pdx.edu/~nickg/dicebothelp.txt"
    elif has "$saying" '\bstats\b' ; then
        sum=$(head -n 1 ./data/sum.log)
        sumlong=`echo $sum | sed -re ' :restart ; s/([0-9])([0-9]{3})($|[^0-9])/\1,\2\3/ ; t restart '`
        privsay "Total sum of all dice rolled: $(printf "%0.3E\n" $sum) or $sumlong"

        tot=$(head -n 1 ./data/dice.log)
        totlong=`echo $tot | sed -re ' :restart ; s/([0-9])([0-9]{3})($|[^0-9])/\1,\2\3/ ; t restart '`
        privsay "Total number of dice rolled: $(printf "%0.3E\n" $tot) or $totlong"

        if has "$saying" '\busers\b' ; then
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
    if has "$saying" "$regex" ; then
        if has "$saying" '\bhelp\b' ; then
            say-to "$nick" "Please visit http://web.cecs.pdx.edu/~nickg/dicebothelp.txt for help using dicebot"
        elif has "$saying" '\broll\b' ; then
            output=`echo "$nick" "$chan" "$saying" | ./roll.bash`
            echo "$output"
        elif has "$saying" '\bwho\b' ; then
            say-to "$nick" "I am a souless automatan created by gilben. This command pings gilben, so be sure to spam it as much as possible"
        elif has "$saying" '\bcommands\b' ; then
            say-to "$nick" "Dicebot Commands: commands, help, !roll, roll, stats, who"
        elif has "$saying" '\bstats\b' ; then
            sum=$(head -n 1 ./data/sum.log)
            sumlong=`echo $sum | sed -re ' :restart ; s/([0-9])([0-9]{3})($|[^0-9])/\1,\2\3/ ; t restart '`
            say-to "$nick" "Total sum of all dice rolled: $(printf "%0.3E\n" $sum) or $sumlong"

            tot=$(head -n 1 ./data/dice.log)
            totlong=`echo $tot | sed -re ' :restart ; s/([0-9])([0-9]{3})($|[^0-9])/\1,\2\3/ ; t restart '`
            say-to "$nick" "Total number of dice rolled: $(printf "%0.3E\n" $tot) or $totlong"
        elif has "$saying" '\bsource\b' ; then
            say-to "$nick" "Dicebot source code: https://gitlab.com/gilben/dicebot"
        fi
    elif has "$saying" '\!roll\b' ; then
        output=`echo "$nick" "$chan" "$saying" | ./roll.bash`
        echo "$output"
    fi
fi
