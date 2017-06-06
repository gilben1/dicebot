from irc import *
import os
import random
import subprocess

server = "irc.cat.pdx.edu"
port = 6667
nick = "dicebot-py"

bot = IRC()
bot.connect(server, port, nick)
bot.join_chan("#gilbentest")

while 1:
    ircmsg = bot.get_text()
    print "<- " + ircmsg

    if bot.regex('\sPRIVMSG\s', ircmsg):
        name = ircmsg.split('!',1)[0][1:]
        message = ircmsg.split('PRIVMSG',1)[1].split(':',1)[1].rstrip()
        channel = "#" + ircmsg.split('#',1)[1].split(' ',1)[0]
        #bot.send(channel, "Your message is " + message + "end")
        #if bot.regex('^!roll', message):
        #    dicein = ":" + name + " " + channel + " " + message
        #    dice_echo = subprocess.Popen(['echo', dicein], stdout=subprocess.PIPE)
        #    diceout = subprocess.check_output('./roll.bash', stdin=dice_echo.stdout)
        #    bot.send_raw(diceout)
        echo_in = ":" + name + " " + channel + " " + message
        echo_out = subprocess.Popen(['echo', echo_in], stdout=subprocess.PIPE)
        output = subprocess.check_output('./cmds.bash', stdin=echo_out.stdout)
        if output:
            bot.send_raw(output)