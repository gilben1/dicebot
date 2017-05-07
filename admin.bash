#!/bin/bash

read nick saying

#TODO change greps for conditions in "has" function


# Send message to indicated channel
# $1 = channel to send to
# $2 = message to send
function say()
{
    echo "PRIVMSG $1 :$2"
}

# Send private message to current user
# $1 = message to send
function privsay()
{
    echo "PRIVMSG ${nick//:} :$1"
}

# Send a '/me' ACT signal to indicated channel
# $1 = channel to send to
# $2 = action to do
function act()
{
    echo "PRIVMSG $1 :ACTION $2"
}


if `echo "$saying" | grep -i '^!join\b' > /dev/null` ; then # JOIN CHANNEL
    channel=`echo "$saying" | cut -d '#' -f 2 | cut -d ' ' -f 1`
    pass=`echo "$saying" | cut -d '#' -f 2 | cut -d ' ' -f 2`
    if [[ $pass == $channel ]] ; then
        pass=""
    fi
    echo "JOIN #$channel $pass"
    privsay "attempting to join #$channel"

elif `echo "$saying" | grep -i '^!part\b' > /dev/null` ; then # LEAVE CHANNEL
    channel=`echo "$saying" | cut -d '#' -f 2 | cut -d ' ' -f 1`
    echo "PART #$channel"
    privsay "attempting to leave #$channel"

elif `echo "$saying" | grep -i '^!reset\b' > /dev/null` ; then # RESET LOGS
    echo 0 > ./data/sum.log
    echo 0 > ./data/dice.log    
    rm ./data/users.log

elif `echo "$saying" | grep -i '^!autojoin\b' > /dev/null` ; then # Set Autojoin
    channel=`echo "$saying" | cut -d '#' -f 2 | cut -d ' ' -f 1`
    pass=`echo "$saying" | cut -d '#' -f 2 | cut -d ' ' -f 2`
    if [[ $pass == $channel ]] ; then
        pass=""
    fi

    if ! grep -q "#$channel" ./data/autojoin.txt ; then
        echo "#$channel $pass" >> ./data/autojoin.txt
        privsay "Adding #$channel to autojoin file"
    else
        privsay "#$channel is already in the autojoin file"
    fi

elif `echo "$saying" | grep -i '^!autoremove\b' > /dev/null` ; then # Remove from autojoin
    channel=`echo "$saying" | cut -d '#' -f 2 | cut -d ' ' -f 1`
    line=$(grep -n "#$channel" ./data/autojoin.txt | cut -d : -f 1)
    if [ -z $line ] ; then
        privsay "#$channel was not found in the autojoin file"
    else
        sed -i "$line d" ./data/autojoin.txt
        privsay "#$channel has been removed from the autojoin file"
    fi

elif `echo "$saying" | grep -i '^!autolist\b' > /dev/null` ; then # List autojoin channels
    output="Channels in autojoin.txt: "
    while read p; do
        output="$output \"$p\""
    done <./data/autojoin.txt
    privsay "$output"
elif `echo "$saying" | grep -i '^!puppet\b' > /dev/null` ; then # PUPPET
    index=0
    delim=2
    parser=`echo "$saying" | cut -d ' ' -f $delim`
    while [[ ${parser:0:1} == "#" ]] ; do
        channels[$index]=$parser
        let "index+=1"
        let "delim+=1"
        parser=`echo "$saying" | cut -d ' ' -f $delim`
    done

    act=0
    let "newdim=$delim-1"
    if `echo "$saying" | grep -i '\/me' > /dev/null` ; then
        message=`echo "$saying" | cut -d '#' -f $newdim | cut -d ' ' -f 3-5000`
        act=1
    else
        message=`echo "$saying" | cut -d '#' -f $newdim | cut -d ' ' -f 2-5000`
    fi

    for i in "${channels[@]}"
    do
        if [[ $act == 0 ]] ; then
            say "$i" "$message"
            privsay "Sent message to $i"
        else
            act "$i" "$message"
            privsay "Sent message to $i"
        fi
    done
fi
