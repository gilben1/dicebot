from irc import *
import os
import random

server = "irc.cat.pdx.edu"
port = 6667
nick = "dicebot-py"

bot = IRC()
bot.connect(server, port, nick)
bot.join_chan("#gilbentest")

while 1:
    text = bot.get_text()
    print "<- " + text

    if "PRIVMSG" in text and "#gilbentest" in text and "hello" in text:
        irc.send("#gilbentest", "hi there")
