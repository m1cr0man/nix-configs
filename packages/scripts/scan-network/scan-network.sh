#!/usr/bin/env bash

if [ -z "$1" -o -z "$2" ]; then
  echo Usage: $(basename "$0") subnet port
  echo Exclude subnet trailing dot (e.g. 192.168.14)
  exit 1
fi
subnet=$1
port=$2
for ip in {1..254}; do
  ( nc -w 1 -z $subnet.$ip $port > /dev/null 2>&1 && echo Found $port open on $subnet.$ip & ) 2>/dev/null
done
wait
