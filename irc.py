import socket, ssl
import sys
import re
import time

class IRC:
    s = socket.socket()
    irc = socket.socket()

    def __init__(self):
        self.s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        timeout = 5 * 60
        self.s.settimeout(timeout)

    def send(self, chan, msg):
        self.irc.send("PRIVMSG " + chan + " :" + msg + "\n")
        print "-> PRIVMSG " + chan + " :" + msg

    def send_raw(self, msg):
        self.irc.send(msg)
        print "-> " + msg

    def connect(self, server, port, botnick):
        print "connecting to: " + server
        self.s.connect((server, port))
        self.irc = ssl.wrap_socket(self.s)
        self.irc.send("USER " + botnick + " " + botnick + " " + botnick + ": " + botnick + "\n")
        self.irc.send("NICK " + botnick + "\n")


    def join_chan(self, chan):
        print "joining " + chan
        self.irc.send("JOIN " + chan + "\n")

    def get_text(self):
        text = self.irc.recv(4096)
        return text

    def ping(self):
        self.irc.send('PONG\n')
        print "-> PONG"

    def regex(self, pattern, text):
        output = re.search(pattern, text)
        return output
