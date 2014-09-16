#!/bin/sh

rm -f *.log

export LD_PRELOAD=libjemalloc.so

./waiter -l 192.168.100.154 -p 4800 -s 1001 -d
