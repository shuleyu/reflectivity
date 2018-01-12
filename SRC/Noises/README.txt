
1. All noise traces are ended with .sac

2. Noise are cut before the P arrival of according record.

3. Before the cut, a butterworth high pass filter with corner 0.02 is applied.

4. After the cut, the mean and trend is removed, sampling is downsampled to 10 Hz.

5. The length of the noise is 400 ~ 500 sec.

6. The noises are looping itself before adding to the signals.

7. The begin/end of the noises are tapered before added to signal: we need to
have a continuity when wraping around.
