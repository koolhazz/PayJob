#!/bin/sh

rm -f *.log

export LD_PRELOAD=libjemalloc.so

./notify -l 192.168.100.154 -p 4801 -s 1002 -d
