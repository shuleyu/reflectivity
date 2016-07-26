#!/bin/bash

for file in `ls tmp/INFILE*`
do
	cp $file INFILE

	Running=`jobs|grep Running | wc -l`
	while [ ${Running} -eq 7 ]
	do
		sleep 60
		Running=`jobs|grep Running | wc -l`
	done

	./Run.sh &
	sleep 65

done

Running=`jobs|grep Running | wc -l`
while [ ${Running} -ne 0 ]
do
	sleep 65
	Running=`jobs|grep Running | wc -l`
done

exit 0
