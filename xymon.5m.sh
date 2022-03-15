#!/bin/bash

# <xbar.title>Xymon Checker</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Jake Shaw</xbar.author>
# <xbar.author.github>codejake</xbar.author.github>
# <xbar.desc>Display current Xymon status.</xbar.desc>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>

# This script requires RSS be enabled in Xymon!

# Configure your Xymon instance base URL.
export XYMON="https://example.com/xymon"

# Get the useful info.
export RESULT=`curl -s "${XYMON}/nongreen.rss"`

# Redundant. but I want the condition color.
export COND=`curl -s "${XYMON}/nongreen.html" | grep "<TITLE"`

# Spruce things up.
export GREEN="🙂"
export YELLOW="⚠️"
export RED="❌"

# Poor man's XML parser in bash, so I can avoid external deps.
# https://stackoverflow.com/questions/35927760/how-can-i-loop-over-the-output-of-a-shell-command
read_dom () {
    local IFS=\>
    read -d \< ENTITY CONTENT
}

case "${COND}" in
    *\<TITLE\>green* ) echo "Green ${GREEN}";;
    *\<TITLE\>red* ) echo "Red ${RED}";;
    *\<TITLE\>yellow* ) echo "Yellow ${YELLOW}";;
    * ) echo "Error...";;
esac

echo "---"

# Dump the problems, if any.
echo ${RESULT} | while read_dom; do
    if [[ $ENTITY = "title" ]] || [[ $ENTITY = "description" ]]; then
        echo $CONTENT
    fi
done

# RED SOMETHING WRONG:
# <?xml version="1.0"?>
# <rss version="0.91">
# <channel>
#   <title>Xymon Alerts</title>
#   <link>http://foo.org/xymon/</link>
#   <description>Last updated on Sat Oct 30 10:09:36 2021</description>
#   <item>
#       ...