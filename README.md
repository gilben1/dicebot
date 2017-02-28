# dicebot
Roll some dice in an IRC bot

# Running

Use `./dicebot.sh $channel $port` to start the bot, connecting to the server and port of your choice

# Autojoin

In the subdirectory data, add or edit the file autojoin.txt
Line seperated list of channels + passcode (if necessary)

Ex.
```
#foo bar
#test
#channel pass
```

# In Channel Usage

Any user can type `dicebot: roll $DICECOMBO`
Alternatively, users can type `!roll $DICECOMBO`

# Dice Combinations
Dice combinations are `+` separated. They can be of three different formats:
```
#d#
d#
#
```
#d# will roll the # of dice specified of the second # type. For example, `2d6` simulates rolling 2 six-sided die.
d# is the same as #d#, but will always roll one of that type. `d20` will roll one twenty sided die
# is simply adding an integer value to the dice roll. `2d6+10` will do as shown above, and then add 10 to the final value.
