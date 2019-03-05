#!/bin/bash

# 
# 1. All noise traces are ended with .sac
# 
# 2. Noise are cut before the P arrival of input records.
# 
# 3. Before the cut, a butterworth high pass filter with corner 0.02 is applied.
# 
# 4. After the cut, the mean and trend is removed, sampling is downsampled to 10 Hz.
# 
# 5. The length of the noise is 400 ~ 500 sec.
# 
# 6. The noises are looping itself before adding to the signals.
# 
# 7. The begin/end of the noises are tapered before added to signal: we need to
# have a continuity when wraping around.

rm -f *sac

count=1
while read file
do
	sac << EOF
r ${file}
lh delta gcarc
evaluate to begin &1,t0-510
evaluate to end &1,t0-60
hp co 0.02 n 2 p 2
w junk.sac
cut %begin %end
r junk.sac
rtr
decimate 4
w noise${count}.sac
q
EOF
	count=$((count+1))
done << EOF
/home/shule/soduser/200601022213/200601022213.TA.Y12C.BHT.sac
/home/shule/soduser/200601022213/200601022213.TA.Y22C.BHT.sac
/home/shule/soduser/200601022213/200601022213.UW.TAKO.BHT.sac
/home/shule/soduser/200601022213/200601022213.TA.M02C.BHT.sac
/home/shule/soduser/200601022213/200601022213.TA.O03C.BHT.sac
/home/shule/soduser/200601022213/200601022213.TA.O04C.BHT.sac
/home/shule/soduser/200601022213/200601022213.TA.O05C.BHT.sac
/home/shule/soduser/200601022213/200601022213.TA.P01C.BHT.sac
/home/shule/soduser/200601022213/200601022213.TA.P05C.BHT.sac
/home/shule/soduser/200601022213/200601022213.TA.Q03C.BHT.sac
/home/shule/soduser/200601022213/200601022213.TA.R04C.BHT.sac
/home/shule/soduser/200601022213/200601022213.TA.R06C.BHT.sac
/home/shule/soduser/200601022213/200601022213.TA.S04C.BHT.sac
/home/shule/soduser/200601022213/200601022213.TA.S06C.BHT.sac
/home/shule/soduser/200601022213/200601022213.TA.T05C.BHT.sac
/home/shule/soduser/200601022213/200601022213.TA.U04C.BHT.sac
/home/shule/soduser/200601022213/200601022213.TA.U05C.BHT.sac
/home/shule/soduser/200601022213/200601022213.TA.V03C.BHT.sac
/home/shule/soduser/200707211327/200707211327.BK.BDM.BHT.sac   
/home/shule/soduser/200707211327/200707211327.BK.BKS.BHT.sac   
/home/shule/soduser/200707211327/200707211327.BK.BRIB.BHT.sac  
/home/shule/soduser/200707211327/200707211327.BK.CMB.BHT.sac   
/home/shule/soduser/200707211327/200707211327.BK.ELFS.BHT.sac  
/home/shule/soduser/200707211327/200707211327.BK.GASB.BHT.sac  
/home/shule/soduser/200707211327/200707211327.BK.HAST.BHT.sac  
/home/shule/soduser/200707211327/200707211327.BK.HATC.BHT.sac  
/home/shule/soduser/200707211327/200707211327.BK.HELL.BHT.sac  
/home/shule/soduser/200707211327/200707211327.BK.HUMO.BHT.sac  
/home/shule/soduser/200707211327/200707211327.BK.JCC.BHT.sac   
/home/shule/soduser/200707211327/200707211327.BK.KCC.BHT.sac   
EOF


rm -r junk.sac

exit 0

