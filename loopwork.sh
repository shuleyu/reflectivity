#!/bin/bash

count=0
while read EQ strike dip rake evde
do

	echo "${EQ} ..."
	count=$((count+1))

	mysql -N -u shule ScS > tmpfile_GcarcAZ_${EQ} << EOF
select Gcarc,Az from Master_a20 where eq=${EQ} and wantit=1;
EOF
	CertainStaionListFile=`pwd`/tmpfile_GcarcAZ_${EQ}

	Running=`jobs|grep Running | wc -l`
	while [ ${Running} -eq 4 ]
	do
		sleep 60
		Running=`jobs|grep Running | wc -l`
	done

	ed -s INFILE << EOF
3d
2a
<WORKDIR>                            /home/shule/PROJ/t039.ULVZ0_1110_Amp
.
16d
15a
<BeginIndex>                         ${count}
.
25,28d
24a
<strike>                             ${strike}
<dip>                                ${dip}
<rake>                               ${rake}
<EVDE>                               ${evde}
.
43d
42a
<CertainStaionListFile>              ${CertainStaionListFile}
.
92d
91a
<ModelName>                          ULVZ0
.
97d
96a
0 0 5    1 1 0.05   1   1 1 0.05    1 1 0.02  1  1 1 0.2    1.00 1.00 0.05   1  1.0 1.0 0.05
.
105,106d
104a
<RunBegin>                           ${count}
<RunEnd>                             ${count}
.
109,110d
108a
<PostBegin>                          ${count}
<PostEnd>                            ${count}
.
wq
EOF

	./Run.sh &
	sleep 65

done << EOF
200608250044 194 36 -48  184.9
200705251747 211 22 -33  181.7
200707211327 14 21 -61   633.7
200707211534 240 3 -24   290.6
200711180540 179 15 -80  216.4
200807080913 177 44 -23  122.6
200809031125 26 21 -36   570.6
200810122055 257 18 -2   357.8
200907120612 101 26 -112 198.7
200911141944 180 11 -79  214.3
201003042239 155 26 -115 108.4
201101010956 360 20 -64  584.3
201103061231 210 26 -37  114.5
201106201636 261 11 -9   126.2
201111221848 163 11 102  560.3
201205141000 203 25 -25  105.9
201205280507 28 23 -44   586.9
201308230834 224 28 -44  111
EOF

Running=`jobs|grep Running | wc -l`
while [ ${Running} -ne 0 ]
do
	sleep 65
	Running=`jobs|grep Running | wc -l`
done

exit 0
