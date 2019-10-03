#!/bin/bash

Cnt=0
while read eventDepth eventLon eventLat
do

    Cnt=$((Cnt+1))

    cat > x << EOF
<BeginIndex>                         ${Cnt}
<EVDE>                               ${eventDepth}
<Model_BEGIN>

30 30 1    1.0 1.0 0.05   -1   1.0 1.0 0.05   1.00 1.00 0.01  -1  1.0 1.0 0.1    1.0 1.0 0.025   -1  1.0 1.0 0.1

<Model_END>
EOF

    cat INFILE_Partial0 >> x
    mv x INFILE

    ./Run.sh

done < EQInfo.txt

exit 0
