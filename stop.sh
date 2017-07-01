#!/usr/bin/env bash

if [ ! -s jekyll.pid ] ; then
echo 'not running. exit'
exit
fi

pid=$(cat jekyll.pid)

cat /dev/null > jekyll.pid

echo "kill process: $pid"

kill -9 $pid

