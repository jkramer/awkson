awkson
======

Simple proof-of-concept IRC bot written with (g)awk.

It's really just a PoC, it doesn't do anything useful. If you really want to
use it, adjust the `process` function to your needs.

IRC options are read from the environment variables `$NICK`, `$REAL_NAME`,
`$CHANNEL` and (optional) `$CHANNEL_PASSWORD`.

It requires `socat` (or a similar tool) as wrapper for the actual connection to
the server. Run like this:

	socat OPENSSL:irc.hackint.org:9999,verify=0 EXEC:'gawk -f awkson.awk'
