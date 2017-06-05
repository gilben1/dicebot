import socket
import sys

class IRC:
    irc = socket.socket()

    def __init__(self):
        self.irc = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    def send(self, chan, msg):
        self.irc.send("PRIVMSG" + chan + " " + msg + "n")

    def connect(self, server, port, botnick):
        print "connecting to: " + server
        self.irc.connect((server, port))
        self.irc.send("USER " + botnick + " " + botnick + " " + botnick + ": " + botnick + "n")
        self.irc.send("NICK " + botnick + "n")


    def join_chan(self, chan):
        print "joining " + chan
        self.irc.send("JOIN " + chan + "n")

    def get_text(self):
        text = self.irc.recv(4096)

        if text.find('PING') != -1:
            self.irc.send('PONG')
        return text

