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

	1|2|3|4 )
		EQ1=200608250044
		;;
	5|6|7|8|9 )
		EQ1=200705251747
		;;
	10|11|12|13|14|15|16 )
		EQ1=200707211327
		;;
	17|18|19|20|21|22 )
		EQ1=200707211534
		;;
	23|24|25|26|27|28 )
		EQ1=200711180540
		;;
    29|30|31|32|33 )
		EQ1=200807080913
		;;
	34|35|36 )
		EQ1=200809031125
		;;
	37|38|39|40|41 )
		EQ1=200810122055
		;;
	42|43|44 )
		EQ1=200907120612
		;;
	45|46|47 )
		EQ1=200911141944
		;;
	48 )
		EQ1=201003042239
		;;
	49|50|51 )
		EQ1=201101010956
		;;
	52|53|54 )
		EQ1=201103061231
		;;
	55|56|57|58|59 )
		EQ1=201106201636
		;;
	60|61|62|63|64 )
		EQ1=201111221848
		;;
	65|66|67|68 )
		EQ1=201205141000
		;;
	69|70|71|72 )
		EQ1=201205280507
		;;
	73|74 )
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
        EQname=`echo "${EQ1} - ${count}" | bc `
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
