#!/usr/bin/env bash

# summarize results and gets stats

for i in *atleast-2_headers.tab; do
        ID=$(echo $i| cut -d "_" -f 1,2,3);
        TIME=$(cat $ID.time);
	clusters=$(cat $i |grep -v ^ID | wc -l);
        mean=$(cat $i | grep -v ^ID| cut -f 3 | awk '{sum+=$0} END {print sum/NR}');
        std=$(cat $i| grep -v ^ID| cut -f 3 |awk '{delta = $1 - avg; avg += delta / NR; mean2 += delta * ($1 - avg); } END { print  sqrt(mean2 / NR); }');
        paste <(echo "$ID") <(echo "$clusters") <(echo "$TIME") <(echo "$mean") <(echo "$std");
done > results_summary.txt

