from irc import *
import os
import random
import subprocess
import yaml


if not os.path.isfile("./config.yaml"):
    config = dict(
            botnick = 'dicebot-py',
            connection = dict(
                server = 'irc.cat.pdx.edu',
                port = 6697,
                ),
            channels = dict(
                )
            )

    with open('config.yaml', 'w') as outfile:
        yaml.dump(config, outfile, default_flow_style=False)
else:
    with open('config.yaml', 'r') as infile:
        config = yaml.load(infile)


print config['botnick'] + " is my name"
print config['connection']['server'] + " is my server"

server = config['connection']['server']
port = config['connection']['port']
nick = config['botnick']

bot = IRC()
bot.connect(server, port, nick)

if not config['channels']:
    print "No channels to join, edit the config.yaml file to add some"
    exit()

for chan, passwd in config['channels'].items():
    send = "#" + chan + " " + passwd
    bot.join_chan(send)

while 1:
    ircmsg = bot.get_text()
    print "<- " + ircmsg

    if ircmsg[0:4] == 'PING':
        bot.ping()

    if bot.regex('\sPRIVMSG\s', ircmsg):
        name = ircmsg.split('!',1)[0][1:]
        message = ircmsg.split('PRIVMSG',1)[1].split(':',1)[1].rstrip()
        try:
            channel = "#" + ircmsg.split('#',1)[1].split(' ',1)[0]
        except IndexError:
            channel = nick

        echo_in = ":" + name + " " + channel + " " + message
        echo_out = subprocess.Popen(['echo', echo_in], stdout=subprocess.PIPE)
        output = subprocess.check_output('./cmds.bash', stdin=echo_out.stdout)
        if output:
            bot.send_raw(output)
