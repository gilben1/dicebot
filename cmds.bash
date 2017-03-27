#!/bin/bash


read nick chan saying

admin=":gilben"

botnick=$(head -n 1 ./data/botnick.txt)
regex="\b${botnick}\b"

# Private messages
if [[ $chan == $botnick ]] ; then
    if [[ $nick == $admin ]] ; then	# Admin commands
        output=`echo $nick $chan $saying | ./admin.bash`
        echo "$output"
    fi

    if `echo $saying | grep -i '\broll\b' > /dev/null` ; then
        output=`echo $nick $chan $saying | ./roll.bash`
        echo "$output"
    elif `echo $saying | grep -i '\bhelp\b' > /dev/null` ; then # Help docs
        echo "NOTIFY ${nick//:} :Please visit http://web.cecs.pdx.edu/~nickg/dicebothelp.txt for help using dicebot"
    elif `echo $saying | grep -i '\bstats\b' > /dev/null` ; then # display stats
        sum=$(head -n 1 ./data/sum.log)
        sumlong=`echo $sum | sed -re ' :restart ; s/([0-9])([0-9]{3})($|[^0-9])/\1,\2\3/ ; t restart '`
        echo "PRIVMSG ${nick//:} :Total sum of all dice rolled: $(printf "%0.3E\n" $sum) or $sumlong"

        tot=$(head -n 1 ./data/dice.log)
        totlong=`echo $tot | sed -re ' :restart ; s/([0-9])([0-9]{3})($|[^0-9])/\1,\2\3/ ; t restart '`
        echo "PRIVMSG ${nick//:} :Total number of dice rolled: $(printf "%0.3E\n" $tot) or $totlong"

        if `echo $saying | grep -i '\busers\b' > /dev/null` ; then # Get users
            out="Users of dicebot:"
            num=0
            while read p; do
                out="$out $p"	
                let "num+=1"
            done <./data/users.log
            echo "PRIVMSG ${nick//:} :$num $out"
        fi
    fi
# Regular channel commands
elif ! grep -Fxqi "${nick//:}" ./data/blacklist.txt ; then
    if `echo "$saying" | grep -i $regex > /dev/null` ; then
        if `echo $saying | grep -i '\bhelp\b' > /dev/null` ; then # HELP
            echo "PRIVMSG $chan $nick: Please visit http://web.cecs.pdx.edu/~nickg/dicebothelp.txt for help using dicebot"
        elif `echo $saying | grep -i '\broll\b' > /dev/null` ; then # ROLL
            output=`echo $nick $chan $saying | ./roll.bash`
            echo "$output" 		
        elif `echo $saying | grep -i '\bwho\b' > /dev/null` ; then # WHO
            echo "PRIVMSG $chan $nick: I am a souless automatan created by gilben. This command pings gilben, so be sure to spam it as much as possible"
        elif `echo $saying | grep -i '\bcommands\b' > /dev/null` ; then # COMMANDS
            echo "PRIVMSG $chan $nick: Dicebot Commands: commands, help, !roll, roll, stats, who"
        elif `echo $saying | grep -i '\bstats\b' > /dev/null` ; then # STATS
            
            sum=$(head -n 1 ./data/sum.log)
            sumlong=`echo $sum | sed -re ' :restart ; s/([0-9])([0-9]{3})($|[^0-9])/\1,\2\3/ ; t restart '`
            echo "PRIVMSG $chan $nick: Total sum of all dice rolled: $(printf "%0.3E\n" $sum) or $sumlong"

            tot=$(head -n 1 ./data/dice.log)
            totlong=`echo $tot | sed -re ' :restart ; s/([0-9])([0-9]{3})($|[^0-9])/\1,\2\3/ ; t restart '`
            echo "PRIVMSG $chan $nick: Total number of dice rolled: $(printf "%0.3E\n" $tot) or $totlong"
        elif `echo $saying | grep -i '\bsource\b' > /dev/null` ; then # SOURCE code on GITHUB
            echo "PRIVMSG $chan $nick: Dicebot source code: https://github.com/gilben1/dicebot"
        fi
    elif `echo $saying | grep -i '\!roll\b' > /dev/null` ; then # ROLL AGAIN
        output=`echo $nick $chan $saying | ./roll.bash`
        echo "$output"
    fi
fi
