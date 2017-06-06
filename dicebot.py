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
    ircmsg = bot.get_text()
    print "<- " + ircmsg

    #if "PRIVMSG" in ircmsg:
    if ircmsg.find("PRIVMSG") != -1:
        name = ircmsg.split('!',1)[0][1:]
        say = "Your name is " + name
        bot.send("#gilbentest", say)
