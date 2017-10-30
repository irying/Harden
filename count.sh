cat count.txt | awk '{sum+=$1} END {print "Average = ", sum/NR}'
