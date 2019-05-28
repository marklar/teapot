#!/bin/bash

# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NO_COLOR='\033[0m'
GOOD="${GREEN}\xE2\x9C\x94${NO_COLOR}"
WARN="${YELLOW}\xE2\x80\xA2${NO_COLOR}"
FAIL="${RED}\xE2\x9D\x8C${NO_COLOR}"

#-- CMD LINE ARGS --

WEB_SERVER_PORT=$1
if [ -z "$WEB_SERVER_PORT" ]; then
    WEB_SERVER_PORT="8000"
fi


#---- Elm ----

COMPILER_RETURN_CODE=0
function maybeCompile {
    elm=`which elm`
    if [ $? -eq 1 ]; then
        # elm: _not_ installed
        echo ""
        echo -e "${YELLOW}Skipping Elm compilation.${NO_COLOR}"
        echo "    'elm' not installed."
        COMPILER_RETURN_CODE=0
    else
        # elm: _is_ installed
        echo -e "${YELLOW}"
        echo "------------------------------------------------------------------------"
        echo "Compiling Elm..."
        echo "------------------------------------------------------------------------"
        echo -e "${NO_COLOR}"
        elm make src/Main.elm --output=js/main.js
        COMPILER_RETURN_CODE=$?
    fi
}

maybeCompile
if [ $COMPILER_RETURN_CODE -eq 0 ]; then
    # if Elm compilation eiher worked or didn't run at all...
    echo ""
    echo ""
    echo -e "${GREEN}Open browser:${NO_COLOR}"
    echo "    http://localhost:$WEB_SERVER_PORT/index.html"
    echo ""
    echo -e "(To quit: ${YELLOW}<Ctrl-c>${NO_COLOR})"
fi
echo ""
