#!/bin/bash
address=$5
echo $7: $address:
curl -s http://$3/v1/machine:readmem?address=$address\&length=$6 -H "X-Password:$4" | xxd -g 1
echo ""
