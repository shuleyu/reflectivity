#!/bin/bash

# ==============================================================
# This script run crfl and make SAC files on each models.
#
# Shule Yu
# Jun 22 2014
# ==============================================================

echo ""
echo "--> `basename $0` is running."
cd ${WORKDIR}

# ================================================
#             ! Work Begin !
# ================================================

echo "<EQ> <Thickness> <Vp_Bot> <Vp_Top> <Vs_Bot> <Vs_Top> <Rho_Bot> <Rho_Top>" > ${WORKDIR}/index
for dir in `ls -d ${WORKDIR}/${ModelName}_*`
do

    Model=${dir##*/}
    count=${Model##*_}

    cd ${dir}
    trap "rm -f ${dir}/crfl.dat ${dir}/crfl.sh ${dir}/crfl.psv ${dir}/crfl.out; exit 1" SIGINT
    echo "    ==> Running reflectivity method on ${Model}.."

    if [ ${RunReference} -eq 1 ]
    then
        cp crfl.dat.ref crfl.dat
    else
        cp crfl.dat.${Model} crfl.dat
    fi

    # Run reflectivity method on ${Model}.
    ${EXECDIR}/crfl.out

    if [ $? -ne 0 ]
    then
        echo "!=> crfl Abort on ${Model} !"
        touch ERROR
        chmod +x ERROR
        rm -f crfl.dat crfl.out crfl.psv crfl.sh
		continue
	else
		rm -f ERROR crfl.dat
    fi

    # Rename calculation information.
    if [ ${RunReference} -eq 1 ]
    then
        mv crfl.out crfl.out.ref
        mv crfl.psv crfl.psv.ref
        mv crfl.sh crfl.sh.ref
    else
        mv crfl.out crfl.out.${Model}
        mv crfl.psv crfl.psv.${Model}
        mv crfl.sh crfl.sh.${Model}
    fi

	# Set index file.

    if [ ${RunReference} -eq 1 ]
    then
        EQname=`echo "201600000000 - ${count}" | bc `
    else
        EQname=`echo "201500000000 + ${count}" | bc `
    fi

    NR=`wc -l < ModelInput`
    rm -f tmpfile_$$
    for count2 in `seq 1 ${NR}`
    do
        echo ${EQname} >> tmpfile_$$
    done
    paste tmpfile_$$ ModelInput >> ${WORKDIR}/index

    # Clean up.
	rm -f tmpfile_$$
    mkdir -p ${WORKDIR}/Calculation
	rm -rf ${WORKDIR}/Calculation/${Model}
    mv ${dir} ${WORKDIR}/Calculation

done # Done model loop.

cd ${CODEDIR}

exit 0
