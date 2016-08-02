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
for count in `seq ${RunBegin} ${RunEnd}`
do

	dir=`ls -d ${WORKDIR}/${ModelName}_${count}`
    Model=${ModelName}_${count}

	if ! [ -d ${dir} ]
	then
		echo "    ~=> No Calculation file for ${Model} ..."
		continue
	fi

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


case "${count}" in

	1 )
		EQ1=200608250044
		;;
	2 )
		EQ1=200705251747
		;;
	3 )
		EQ1=200707211327
		;;
	4 )
		EQ1=200707211534
		;;
	5 )
		EQ1=200711180540
		;;
    6 )
		EQ1=200807080913
		;;
	7 )
		EQ1=200809031125
		;;
	8 )
		EQ1=200810122055
		;;
	9 )
		EQ1=200907120612
		;;
	10 )
		EQ1=200911141944
		;;
	11 )
		EQ1=201003042239
		;;
	12 )
		EQ1=201101010956
		;;
	13 )
		EQ1=201103061231
		;;
	14 )
		EQ1=201106201636
		;;
	15 )
		EQ1=201111221848
		;;
	16 )
		EQ1=201205141000
		;;
	17 )
		EQ1=201205280507
		;;
	18 )
		EQ1=201308230834
		;;
	* )
		echo "EQ1 Error ..."
		exit 1
		;;
esac





    if [ ${RunReference} -eq 1 ]
    then
        EQname=`echo "201600000000 - ${count}" | bc `
    else
#         EQname=`echo "201500000000 + ${count}" | bc `
        EQname="${EQ1}"
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

cd ${WORKDIR}

exit 0
