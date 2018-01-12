#!/bin/bash

count=13
for V1 in `seq 5.6 0.1 5.9`
do
	for More in 0.1
	do
		V2=`echo "${V1} ${More}" | awk '{print $1+$2}'`

		cat > tmpfile_$$ << EOF
<BeginIndex>  ${count}
<V1>          ${V1}
<V2>          ${V2}
EOF
		awk 'NR>3 {print $0}' INFILE >> tmpfile_$$
		mv tmpfile_$$ INFILE
		./Run.sh

		count=$((count+1))
	done
done


exit 0
