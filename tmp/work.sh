#!/bin/bash

for file in `ls INFILE*`
do
	echo $file

	ed -s $file << EOF
3d
2a
<WORKDIR>                            /home/shule/PROJ/t039.ULVZ1_1110_Amp
.
94d
93a
15 15 5    1 1 0.05   1   1 1 0.05    0.85 0.85 0.02  1  0.85 0.85 0.2    1.00 1.00 0.05   1  1.0 1.0 0.05
.
wq
EOF


done



exit 0
