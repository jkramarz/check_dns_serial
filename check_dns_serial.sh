#!/bin/bash

DIG="/usr/bin/dig"
CUT="/usr/bin/cut"
HEAD="/usr/bin/head"
TAIL="/usr/bin/tail"

ZONE=$1

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

RETURN=$STATE_CRITICAL

SERIAL1=$($DIG $ZONE +nssearch | $CUT -d' ' -f4 | $HEAD -1)
SERIAL2=$($DIG $ZONE +nssearch | $CUT -d' ' -f4 | $TAIL -1)

if [ "$SERIAL1"="$SERIAL2" ]; then
	RETURN=$STATE_OK
	OUTPUT="OK: serial $SERIAL1"
else
	RETURN=$STATE_WARNING
	OUTPUT="WARNING: serial $SERIAL1 differs from $SERIAL2"
fi

echo $OUTPUT
exit $RETURN