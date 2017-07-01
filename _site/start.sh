#!/usr/bin/env bash

if [ -s jekyll.pid ] ; then 
echo 'stop old process:'
sh stop.sh 
fi   

cat /dev/null > jekyll.log

if [ -d "_site" ]; then
echo "rm _site"
rm -rf _site
fi

nohup jekyll server >> jekyll.log 2>&1 &

echo `ps -ef | grep -i 'jekyll server' | grep -v grep | awk '{print $2}'` >> jekyll.pid

echo "running at: $(cat jekyll.pid)"


