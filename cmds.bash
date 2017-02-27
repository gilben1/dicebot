#!/bin/bash


read nick chan saying

admin=":gilben"

# Admin private message commands
if [[ $chan == dicebot ]] ; then
    if [[ $nick == $admin ]] ; then	
        output=`echo $nick $chan $saying | ./admin.bash`
        echo "$output"
    fi

    if `echo $saying | grep -i '\broll\b' > /dev/null` ; then
        #output=`echo $nick $channel $saying | ./roll_priv.bash`
        #output=`echo $nick $chan $saying | ./roll_priv.bash`
        output=`echo $nick $chan $saying | ./roll.bash`
        echo "$output"
    elif `echo $saying | grep -i '\bhelp\b' > /dev/null` ; then
        echo "PRIVMSG ${nick//:} :Please visit http://web.cecs.pdx.edu/~nickg/dicebothelp.txt for help using dicebot"
    elif `echo $saying | grep -i '\bstats\b' > /dev/null` ; then
        sum=$(head -n 1 ./logs/sum.log)
        sumlong=`echo $sum | sed -re ' :restart ; s/([0-9])([0-9]{3})($|[^0-9])/\1,\2\3/ ; t restart '`
        echo "PRIVMSG ${nick//:} :Total sum of all dice rolled: $(printf "%0.3E\n" $sum) or $sumlong"

        tot=$(head -n 1 ./logs/dice.log)
        totlong=`echo $tot | sed -re ' :restart ; s/([0-9])([0-9]{3})($|[^0-9])/\1,\2\3/ ; t restart '`
        echo "PRIVMSG ${nick//:} :Total number of dice rolled: $(printf "%0.3E\n" $tot) or $totlong"


        if `echo $saying | grep -i '\busers\b' > /dev/null` ; then
            out="Users of dicebot:"
            num=0
            while read p; do
                out="$out $p"	
                let "num+=1"
            done <./logs/users.log
            echo "PRIVMSG ${nick//:} :$num $out"
        fi
    fi
# Regular channel commands
else
    if `echo $saying | grep -i '\bdicebot\b' > /dev/null` ; then
        if `echo $saying | grep -i '\bhelp\b' > /dev/null` ; then
            #echo "PRIVMSG $chan $nick: This is a bot that simulates rolling dice!"
            #echo "PRIVMSG $chan $nick: Rolling format: 'dicebot: roll #d#+#d#+...+#d#' or '!roll #d#+#d#+...#d#'"
            #echo "PRIVMSG $chan $nick: Each dice can be prefixed by number of dice. Can add individual numbers as well"
            #echo "PRIVMSG $chan $nick: Valid rolls: '2d6' '2d6+10' '1d6+2d10+10+5d10' 'd20'"
            #echo "PRIVMSG $chan $nick: use dicebot: commands to see all possible commands"
            echo "PRIVMSG $chan $nick: Please visit http://web.cecs.pdx.edu/~nickg/dicebothelp.txt for help using dicebot"
        elif `echo $saying | grep -i '\broll\b' > /dev/null` ; then
            output=`echo $nick $chan $saying | ./roll.bash`
            echo "$output" 		
        elif `echo $saying | grep -i '\bwho\b' > /dev/null` ; then
            echo "PRIVMSG $chan $nick: I am a souless automatan created by gilben. This command pings gilben, so be sure to spam it as much as possible"
        elif `echo $saying | grep -i '\bcommands\b' > /dev/null` ; then
            echo "PRIVMSG $chan $nick: Dicebot Commands: commands, help, !roll, roll, stats, who"
        elif `echo $saying | grep -i '\bstats\b' > /dev/null` ; then
            
            sum=$(head -n 1 ./logs/sum.log)
            sumlong=`echo $sum | sed -re ' :restart ; s/([0-9])([0-9]{3})($|[^0-9])/\1,\2\3/ ; t restart '`
            echo "PRIVMSG $chan $nick: Total sum of all dice rolled: $(printf "%0.3E\n" $sum) or $sumlong"

            tot=$(head -n 1 ./logs/dice.log)
            totlong=`echo $tot | sed -re ' :restart ; s/([0-9])([0-9]{3})($|[^0-9])/\1,\2\3/ ; t restart '`
            echo "PRIVMSG $chan $nick: Total number of dice rolled: $(printf "%0.3E\n" $tot) or $totlong"


        fi
    elif `echo $saying | grep -i '\!roll\b' > /dev/null` ; then
        output=`echo $nick $chan $saying | ./roll.bash`
        echo "$output"
    fi
fi
