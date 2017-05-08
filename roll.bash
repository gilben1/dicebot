#!/bin/bash

read nick chan saying
dicecap=25000

# test for the command used
header="PRIVMSG $chan $nick: "
if [[ $chan == dicebot ]] ; then
    amount=1
    header="PRIVMSG ${nick//:} :"
elif `echo "$saying" | grep -i '\!roll\b' > /dev/null` ; then
    amount=2
else
    amount=3
fi




# Cut out the dice from the message
#dice=`echo "$saying" | cut -d ' ' -f $amount | cut -d '#' -f 1`
dice=`echo "$saying" | cut -d ' ' -f $amount`


# Add "+" so the delimiter for parsing works to the end
dice="+$dice+"


delim=1 # current delimiter number
di=0    # Dice/multiples index 
ai=0    # Additives index

parser=`echo "$dice" | cut -d '+' -f $delim`


# To heck with it, let them have bad input.
# Deal with bad input later

additives=( $(echo "$dice" | grep -Po '\+[0-9]+\+' ) )
multiples=( $(echo "$dice" | grep -o '\+[0-9]*d' ) )
sizes=( $(echo "$dice" | grep -o 'd[0-9]*\+' ) )

additives=("${additives[@]//\+}")
multiples=("${multiples[@]//\+}")
multiples=("${multiples[@]//d}")
sizes=("${sizes[@]//d}")





for i in "${multiples[@]}" ; do
    echo "PRIVMSG ${nick//:} :Multiples : $i"
done

for i in "${sizes[@]}" ; do
    echo "PRIVMSG ${nick//:} :Sizes: $i"
done

for i in "${additives[@]}" ; do
    echo "PRIVMSG ${nick//:} :Additives: $i"
done

# -------------------------------------------
# Note: 245 characters is the limit for IRC
# -------------------------------------------

msgnumber=0
numdice=0
sum=0
index=0

pingcount=0

for i in "${sizes[@]}"
do
    let "numdice+=${multiples[$index]}"
    let "index+=1"
done

# Timeout failsafe for the time being 
if [[ $numdice -gt $dicecap ]] ; then
    echo "${header}Ok, seriously. $numdice is too many dice. Terminating to prevent timeout"
    exit
fi

index=0
for i in "${sizes[@]}"
do
    counter=0

    numout=`echo "$i" | sed -re ' :restart ; s/([0-9])([0-9]{3})($|[^0-9])/\1,\2\3/ ; t restart '`

    while [[ $counter -lt ${multiples[$index]} ]] ; do
        number=$RANDOM

        if [[ $i == 0 ]] ; then
            let "result=0"
        else
            let "result=($number%$i)+1"
        fi
        len=${#dicemsg[$msgnumber]}

        if [[ $len -gt 245 ]] ; then
            let "msgnumber+=1"
        fi

        # Make a version that has commas in the correct locations
        resultout=`echo "$result" | sed -re ' :restart ; s/([0-9])([0-9]{3})($|[^0-9])/\1,\2\3/ ; t restart '`

        if [[ ${dicemsg[$msgnumber]} == "" ]] ; then
            dicemsg[$msgnumber]="(d$numout: $resultout)"			
        else
            dicemsg[$msgnumber]="${dicemsg[$msgnumber]} (d$numout: $resultout)"	
        fi

        let "counter+=1"
        let "sum+=$result"
    done
    let "index+=1"
done

if [[ ${#sizes[@]} == 0 ]] ; then
    echo "${header}No good dice rolls detected. Type 'dicebot: help' For correct rolling syntax."
    exit
fi

hide=0

# Comma output
numdiceout=`echo "$numdice" | sed -re ' :restart ; s/([0-9])([0-9]{3})($|[^0-9])/\1,\2\3/ ; t restart '`

if [[ $numdice -gt 100 ]] ; then
    echo "${header}Dice overflow exception ($numdiceout dice). Hiding main output."
    hide=1
fi

# Loop through raw ints to add to sum
for i in "${additives[@]}"
do
    if ! [[ $i == "" ]] ; then
        len=${#dicemsg[$msgnumber]}
        if [[ $len -gt 245 ]] ; then
            let "msgnumber+=1"
        fi

        # Comma output
        addout=`echo "$i" | sed -re ' :restart ; s/([0-9])([0-9]{3})($|[^0-9])/\1,\2\3/ ; t restart '`
        dicemsg[$msgnumber]="${dicemsg[$msgnumber]} (+$addout)"
        let "sum+=$i"
        let "numdice+=1"
    fi
done

# If hide flag hasn't been tripped, output each roll
if [[ $hide == 0 ]] ; then
    for i in "${dicemsg[@]}"
    do
        echo "$header$i"
    done
fi

# Comma output
sumout=`echo "$sum" | sed -re ' :restart ; s/([0-9])([0-9]{3})($|[^0-9])/\1,\2\3/ ; t restart '`

# Echo the sum
# If beyond a certain value, add a scientific notation output in addition to the regular
if [ $sum -gt 100000 ] ; then
    sciencesum=$(printf "%0.3E\n" $sum)
    echo "${header}Sum of all $numdiceout dice: $sumout or $sciencesum"
else
    echo "${header}Sum of all $numdiceout dice: $sumout"
fi


# Update the total sum log
let "sum+=$(head -n 1 ./data/sum.log)"
echo "$sum" > ./data/sum.log

# Update the total number of dice log
let "numdice+=$(head -n 1 ./data/dice.log)"
echo "$numdice" > ./data/dice.log


if ! grep -q "${nick//:}" ./data/users.log ; then
    echo "${nick//:}" >> ./data/users.log
fi
