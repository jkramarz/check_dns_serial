#!/bin/bash

LEVEL="warn"

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

RETURN=$STATE_UNKNOWN
OUTPUT="UNKNOWN: cannot test"

function usage() {
	cat << EOF
Usage: $0 <OPTIONS>
Checks DNS zone serial numbers 
Options:
-z DNS zone
-l Notification level (warn or crit, defaults to warn)
-h Prints this help message
Example: $0 -z example.com -l crit 
EOF
}

function quit {
	echo $OUTPUT
	exit $RETURN
}

while getopts "hz:l:" OPTION; do
	case $OPTION in
	h)
		usage
		exit 1
		;;
	z)
		ZONE="$OPTARG"
		;;
	l)
		LEVEL="$OPTARG"
		;;
	*)
		echo "Invalid option"
		usage
		exit 1;
		;;
	?)
		usage
		exit 0
		;;
	esac
done

[ -n "$ZONE" ] || { echo "No zone specified." ; exit $STATE_UNKNOWN; }
[ -n "$LEVEL" ] || { echo "No notification level specified." ; exit $STATE_UNKNOWN; }

declare -a SERIALS
i=0
for x in $(dig $ZONE +nssearch | cut -d' ' -f4)
do
   i=$[$i + 1];
   SERIALS[$i]="$x"
done

if [ -z "$i" ]; then
	RETURN=$STATE_UNKNOWN
	OUTPUT="UNKNOWN: no serials"
	quit
fi

SERIAL_COUNT=$i
CMP=${SERIALS[1]}

i=1
for x in SERIALS
do
	if [ "$CMP" = "${SERIALS[$i]}" ]; then
		i=$[$i + 1];
	fi
done

if [ "$i" = "$SERIAL_COUNT" ]; then
	RETURN=$STATE_OK
	OUTPUT="OK: serial ${SERIALS[1]}"
else
	if [ "$LEVEL" = "crit" ]; then
		RETURN=$STATE_CRITICAL
		OUTPUT="CRITICAL: serials different"
	else
		RETURN=$STATE_WARNING
		OUTPUT="WARNING: serials different"
	fi
fi

quit