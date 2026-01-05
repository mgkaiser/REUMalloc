#!/bin/bash
echo $5:
curl -s http://$3/v1/machine:readmem?address=`awk -v myvar="$5" '$3 == myvar {print $2}' $1/$2.sym`\&length=$6 -H "X-Password:$4" | xxd -g 1
echo ""
