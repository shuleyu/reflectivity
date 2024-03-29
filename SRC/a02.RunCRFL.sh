#!/bin/bash

# ==============================================================
# This script run crfl and make SAC files on each models.
#
# Shule Yu
# Jun 22 2014
# ==============================================================

echo ""
echo "--> `basename $0` is running. (`date`)"
cd ${WORKDIR}

# ================================================
#             ! Work Begin !
# ================================================

# echo "<EQ> <Thickness> <Vp_Bot> <Vp_Top> <Vs_Bot> <Vs_Top> <Rho_Bot> <Rho_Top>" > ${WORKDIR}/index
for count in `seq ${RunBegin} ${RunEnd}`
do

    while [ `jobs -r | grep crfl.out | wc -l` -ge ${NThreads} ]
    do
        sleep 30
    done

	dir=`ls -d ${WORKDIR}/${ModelName}_${count}`
    Model=${ModelName}_${count}

	if ! [ -d ${dir} ]
	then
		echo "    ~=> No Calculation file for ${Model} ..."
		continue
	fi

    cd ${dir}
    trap "rm -f ${dir}/crfl.dat ${dir}/crfl.sh ${dir}/crfl.psv ${dir}/crfl.out ; kill `jobs -p`; exit 1" SIGINT
    echo "    ==> Running reflectivity method on ${Model}..  (`date`)"

    if [ ${RunReference} -eq 1 ]
    then
        cp crfl.dat.ref crfl.dat
    else
        cp crfl.dat.${Model} crfl.dat
    fi

    # Run reflectivity method on ${Model}.
    ${EXECDIR}/crfl.out &

done

while [ `jobs -r | grep crfl.out | wc -l` -ge 1 ]
do
    sleep 30
done

for count in `seq ${RunBegin} ${RunEnd}`
do

	dir=`ls -d ${WORKDIR}/${ModelName}_${count}`
    Model=${ModelName}_${count}

    cd ${dir}

    # Rename calculation information.
    if [ ${RunReference} -eq 1 ]
    then
        mv crfl.out crfl.out.ref
        ! [ ${Comp} = "SH" ] && mv crfl.psv crfl.psv.ref
        ! [ ${Comp} = "PSV" ] && mv crfl.sh crfl.sh.ref
    else
        mv crfl.out crfl.out.${Model}
        ! [ ${Comp} = "SH" ] && mv crfl.psv crfl.psv.${Model}
        ! [ ${Comp} = "PSV" ] && mv crfl.sh crfl.sh.${Model}
    fi

	# Set index file.

    [ ${RunReference} -eq 1 ] && EQname=`echo "201600000000 - ${count}" | bc ` || EQname=`echo "201500000000 + ${count}" | bc `

    NR=`wc -l < ModelInput`
    ${BASHCODEDIR}/GenerateColumn.sh "${EQname} ${EVDE}" ${NR} > tmpfile_$$
    paste tmpfile_$$ ModelInput >> ${WORKDIR}/index

    # Clean up.
	rm -f tmpfile_$$
    mkdir -p ${WORKDIR}/Calculation
	rm -rf ${WORKDIR}/Calculation/${Model}
    mv ${dir} ${WORKDIR}/Calculation

done # Done model loop.

cd ${WORKDIR}

exit 0
