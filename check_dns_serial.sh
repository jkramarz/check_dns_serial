#!/bin/bash

ZONE=$1
NS1=$2
NS2=$3

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

RETURN=$STATE_UNKNOWN
OUTPUT="UNKNOWN: cannot test"

function quit {
	echo $OUTPUT
	exit $RETURN
}

if [ "$(echo "$NS1" | grep '\.$')" = "" ]; then
	NS1=$(echo "$NS1.$ZONE.")
fi

if [ "$(echo "$NS2" | grep '\.$')" = "" ]; then
	NS2=$(echo "$NS2.$ZONE.")
fi

SERIAL1=$(dig @$NS1 $ZONE soa +short | cut -d' ' -f3)
SERIAL2=$(dig @$NS2 $ZONE soa +short | cut -d' ' -f3)

if [ "$SERIAL1" = "" ]; then
	RETURN=STATE_UNKNOWN
	OUTPUT="UNKNOWN: ns1 not responding"
	quit
fi

if [ "$SERIAL2" = "" ]; then
	RETURN=STATE_UNKNOWN
	OUTPUT="UNKNOWN: ns2 not responding"
	quit
fi

if [ "$SERIAL1" = "$SERIAL2" ]; then
	RETURN=$STATE_OK
	OUTPUT="OK: serial $SERIAL1"
else
	RETURN=$STATE_WARNING
	OUTPUT="WARNING: serial $SERIAL1 differs from $SERIAL2"
fi

quit