#!/bin/bash

for SNR in 0.05 0.1 0.15 0.2 0.25 0.3
do

    echo "<NoiseLevel>  ${SNR}"   > tmpfile_$$
	awk 'NR>1 {print $0}' INFILE >> tmpfile_$$
	mv tmpfile_$$ INFILE

	./Run.sh

done

exit 0
