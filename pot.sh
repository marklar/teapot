#!/bin/bash

# entr
# Event Notify Test Runner
# http://eradman.com/entrproject/
# -c : clear screen
# -d : directory watch

# ag
# like ack (or grep)
# https://github.com/ggreer/the_silver_searcher

trap killServer EXIT

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NO_COLOR='\033[0m'
GOOD="${GREEN}\xE2\x9C\x94${NO_COLOR}"
BAD="${RED}\xE2\x9D\x8C${NO_COLOR}"
MAYBE="${YELLOW}?$??{NO_COLOR}"


WEB_SERVER_PID=""

WEB_SERVER_PORT=$1
if [ -z "$WEB_SERVER_PORT" ]; then
    WEB_SERVER_PORT=8421
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function startServer {
    elm=`which elm`
    if [ $? -eq 0 ]; then
        elm reactor --port=$WEB_SERVER_PORT >& /dev/null &
    else
        python -m SimpleHTTPServer $WEB_SERVER_PORT >& /dev/null &
    fi
    WEB_SERVER_PID=$!
    clear
    echo ""
    echo -e "$GOOD Web server started (pid: $WEB_SERVER_PID) on port $WEB_SERVER_PORT."
    echo ""
    # displayConfig
}

function displayConfig {
    echo ""
    echo -e "Make sure you have ${YELLOW}port-forwarding${NO_COLOR} on your Mac, like this:"
    echo ""
    echo "    # ~/.ssh/config"
    echo "    Host <NAME_OF_MY_VM>"
    echo "      HostName <IP.OF.MY.VM>"
    echo "      IdentityFile ~/.ssh/id_rsa"
    echo "      LocalForward $WEB_SERVER_PORT localhost:$WEB_SERVER_PORT"
    echo ""
    echo -e "${YELLOW}Hit <return> to continue.${NO_COLOR}"

    read
}

function killServer {
    kill $WEB_SERVER_PID >& /dev/null &
    clear
    echo ""
    echo -e "$GOOD Web server shut down."
    popd
}

function build {
    exec="./make.sh $WEB_SERVER_PORT"
    ag=`which ag`
    if [ $? -eq 1 ]; then
        # ag: _not_ installed
        clear
        $exec
        while true; do
            sleep 60
        done
    else
        while true; do
            ag -l \
                | egrep '\.elm$|\.css$|\.html$' \
                | egrep -v '~$' \
                | entr -c -d $exec
        done
    fi
}

pushd $SCRIPT_DIR
startServer
build
