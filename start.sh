#!/bin/bash
# wget https://raw.githubusercontent.com/zapret-info/z-i/master/dump.csv
iconv -f cp1251 -t utf-8 dump.csv | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' | sort -t. -n -k1,1 -k2,2 -k3,3 -k4,4 | uniq | awk -f script.awk > subnets.rsc