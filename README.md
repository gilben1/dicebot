# dicebot
Roll some dice in an IRC bot

# Running

Use `./dicebot`. Connection settings and botnick are found in `.config`

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

# Private Message Usage
The same commands can be used when private messaging dicebot. The `!` is optional here

# Dice Combinations
Dice combinations are `+` separated. They can be of three different formats:
```
#d#
d#
#
```
\#d# will roll the # of dice specified of the second # type. For example, `2d6` simulates rolling 2 six-sided die.

d# will roll 1 die of the specified second # type. For example, `d20` simulates rolling 1 twenty-sided die

\# is simply adding an integer value to the dice roll. `2d6+10` will do as shown above, and then add 10 to the final value.
