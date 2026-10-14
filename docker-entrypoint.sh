#!/bin/sh
# Config comes from the deployment under /etc/nut. Drivers and upsd always run;
# upsmon runs when upsmon.conf is present. Any of them exiting ends the container.
set -eu

stop() {
    trap - TERM INT
    kill $pids 2>/dev/null || true
    wait
}
trap 'stop; exit 0' TERM INT

upsdrvctl -F start & pids=$!
upsd -F & pids="$pids $!"
if [ -f /etc/nut/upsmon.conf ]; then
    upsmon -F & pids="$pids $!"
fi

set +e
wait -n
status=$?
stop
exit "$status"
