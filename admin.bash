#!/bin/bash

read nick chan saying

if `echo $saying | grep -i '\bjoin\b' > /dev/null` ; then # JOIN CHANNEL
    comm=`echo $saying | cut -d '#' -f 2`
    channel=`echo $comm | cut -d ' ' -f 1`
    pass=`echo $comm | cut -d ' ' -f 2`
    if [[ $pass == $channel ]] ; then
        pass=""
    fi
    echo "JOIN #$channel $pass"
    echo "PRIVMSG ${nick//:} :attempting to join #$channel"

elif `echo $saying | grep -i '\bpart\b' > /dev/null` ; then # LEAVE CHANNEL
    comm=`echo $saying | cut -d '#' -f 2`
    channel=`echo $comm | cut -d ' ' -f 1`
    echo "PART #$channel"
    echo "PRIVMSG ${nick//:} :attempting to leave #$channel"

elif `echo $saying | grep -i '\breset\b' > /dev/null` ; then # RESET LOGS
    echo 0 > ./logs/sum.log
    echo 0 > ./logs/dice.log 	
    rm ./logs/users.log
elif `echo $saying | grep -i '\bautojoin\b' > /dev/null` ; then # Set Autojoin
    comm=`echo $saying | cut -d '#' -f 2`
    channel=`echo $comm | cut -d ' ' -f 1`
    pass=`echo $comm | cut -d ' ' -f 2`
    if [[ $pass == $channel ]] ; then
        pass=""
    fi

    if ! grep -q "#$channel" ./logs/autojoin.txt ; then
        echo "#$channel $pass" >> ./logs/autojoin.txt
        echo "PRIVMSG ${nick//:} :Adding #$channel to autojoin file"
    else
        echo "PRIVMSG ${nick//:} :#$channel is already in the autojoin file"
    fi

elif `echo $saying | grep -i '\bautoremove\b' > /dev/null` ; then # Remove from autojoin
    comm=`echo $saying | cut -d '#' -f 2`
    channel=`echo $comm | cut -d ' ' -f 1`
    if ! grep -q "#$channel" ./logs/autojoin.txt ; then
        echo "PRIVMSG ${nick//:} :#$channel is not in the autojoin file"
    else
        i=0
        while read p; do
            if ! [[ $p == "#$channel" ]] ; then
                temp[$i]=$p
                let "i+=1"
            fi
        done <./logs/autojoin.txt
        rm ./logs/autojoin.txt
        for i in "${temp[@]}"
        do
            echo "$i" >> ./logs/autojoin.txt
        done
        echo "PRIVMSG ${nick//:} :#$channel has been removed from the autojoin file"
    fi

elif `echo $saying | grep -i '\bautolist\b' > /dev/null` ; then # List autojoin channels
    output="Channels in autojoin.txt: "
    while read p; do
        output="$output \"$p\""
    done <./logs/autojoin.txt
    echo "PRIVMSG ${nick//:} :$output"

elif `echo $saying | grep -i '\bpuppet\b' > /dev/null` ; then # PUPPET
    index=0
    delim=5
    parser=`echo $saying | cut -d ' ' -f $delim`
    #while `echo $parser | grep '#' > /dev/null` ; do
    while [[ ${parser:0:1} == "#" ]] ; do
        channels[$index]=$parser
        let "index+=1"
        let "delim+=1"
        parser=`echo $saying | cut -d ' ' -f $delim`
    done
     
    act=0
    roll=0
    let "newdim=$delim-4"
    if `echo $saying | grep -i '\/me' > /dev/null` ; then
        message=`echo $saying | cut -d '#' -f $newdim | cut -d ' ' -f 3-5000`
        act=1
    elif `echo $saying | grep -i '\broll\b' > /dev/null` ; then
        message=`echo $saying | cut -d '#' -f $newdim | cut -d ' ' -f 3`
        roll=1
    else
        message=`echo $saying | cut -d '#' -f $newdim | cut -d ' ' -f 2-5000`
    fi

    for i in "${channels[@]}"
    do
        if [[ $act == 0 ]] && [[ $roll == 0 ]] ; then
            echo "PRIVMSG $i :$message"
        elif [[ $roll == 0 ]] ; then
            echo "PRIVMSG $i :ACTION $message"
        else
            echo "PRIVMSG $i :roll $message"
            
            output=`echo ":dicebot" $i $message | ./roll.bash`
            echo "$output"
        fi
    done
fi

