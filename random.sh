#!bin/bash

function rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(($RANDOM+1000000000)) #增加一个10位的数再求余
    echo $(($num%$max+$min))
}
for i in $(seq 100000);
do
    time=$(date +%s)
    lessonId=$(rand 1 999)
    uid=$(rand 10000 99999) 
    random=$(rand 1000 9999)
    id=$time$uid$random
    value=\($id,$lessonId,$uid,$time,2,1,$time,\'\',88.00\),
    echo $value >> value.txt
done
