# vim:noexpandtab
#
# To run:
# NICK=nick REAL_NAME='Ronald Reagan' CHANNEL=channel_without_hash CHANNEL_PASSWORD=password \
#   socat OPENSSL:irc.hackint.org:9999,verify=0 EXEC:'awk -f awkson.awk'
#

BEGIN {
	if(!ENVIRON["NICK"] || !ENVIRON["REAL_NAME"] || !ENVIRON["CHANNEL"])
		die("$NICK, $REAL_NAME or $CHANNEL not set.")
}

function send(msg) {
	printf "%s\r\n", msg
	dump("< " msg)
	fflush() # Don't forget to flush, or stuff might get stuck...
}

# For now, logging just prints to STDERR.
function dump(msg) { print msg | "cat >&2" }

function error(msg) { print "! " msg | "cat >&2" }

function die(msg) { error(msg); exit -1 }

1 {
	dump("> " $0) # Log all incoming messages.

	# Send the registration stuff as soon was we get the first line from the
	# server.
	if(NR == 1) {
		send("NICK " ENVIRON["NICK"])
		send("USER " ENVIRON["NICK"] " 0 * :" ENVIRON["REAL_NAME"])
	}
}

# Respond to PING messages so we don't time out.
/^PING/ { send("PONG " $2) }

# Wait until we've been registered (mode set) before joining some channel.
$2 == "MODE" {
	send("JOIN #" ENVIRON["CHANNEL"] " " ENVIRON["CHANNEL_PASSWORD"])
}

$2 == "475" { die("Bad channel password!") }

$2 == "PRIVMSG" {
	from = substr($1, 2, index($1, "!") - 2)
	to = $3
	reply_to = from

	if($3 ~ /^#/) reply_to = $3

	msg = $4

	if(msg ~ /^:/) {
		msg = substr(msg, 2)
		for(n = 5; n <= NF; ++n)
			msg = msg " " $n
	}

	process(from, to, reply_to, msg)
}

function process(from, to, reply_to, msg) {
	response = ""

	if(tolower(msg) ~ /(^| )(2|zwei)($|[^0-9a-z])/)
		response = response "Zwe! "

	if(tolower(msg) ~ /(^| )(11|elf)($|[^0-9])/)
		response = response "Ölf! Also: eins-eins!"

	if(tolower(msg) ~ /(^| )laptop($|[^a-z0-9])/)
		response = response "Läppie! "

	if(tolower(msg) ~ /(^| )fitnessstudio($|[^a-z0-9])/)
		response = response "Fitti! "

	if(tolower(msg) ~ /(^| )brennt($|[^a-z0-9])/)
		response = response "Jetzt heißt es: Zähnchen zusammenbeißen! "

	if(tolower(msg) ~ /(^| )minuten?($|[^a-z0-9])/)
		response = response "Minütchen! "

	if(tolower(msg) ~ /freitag/) {
		"date +%u" | getline day
		if(day == "5") {
			response = response "Yaaay! Es ist Freitag! "
		}
		else {
			response = response "Meh. Leider noch nicht Freitag."
		}
	}

	send("PRIVMSG " reply_to " :" response)
}
