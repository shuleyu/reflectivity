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

for count in `seq ${PostBegin} ${PostEnd}`
do

	Model=${ModelName}_${count}
	dir=${WORKDIR}/Calculation/${Model}

	if ! [ -d ${dir} ]
	then
		echo "    ~=> No crfl calculation result found for ${Model}.."
		continue
	else
		echo "    ==> Running post-process on ${Model}.."
	fi

	# Get source depth.
	read A B C EVDE < ${dir}/Source

    # Note down calculation information.
    if [ ${RunReference} -eq 1 ]
    then
        file_psv=crfl.psv.ref
        file_sh=crfl.sh.ref
        EQname=`echo "201600000000 - ${count}" | bc `
    else
        file_psv=crfl.psv.${Model}
        file_sh=crfl.sh.${Model}
        EQname=`echo "201500000000 + ${count}" | bc `
#         EQname="${EQ1}"
    fi

	rm -rf ${WORKDIR}/${EQname}
	mkdir -p ${WORKDIR}/${EQname}
    trap "rm -rf ${WORKDIR}/${EQname} ${dir}/*sac ${dir}/tmpfile*$$; exit 1" SIGINT

    cd ${dir}
	find . -iname "*sac" -exec rm '{}' \;

    # Run crfl2sac on R and Z component. Make SAC files.
    if ! [ ${Comp} = "SH" ]
    then
        ${EXECDIR}/crfl2sac.out > /dev/null << EOF
${file_psv}
n
EOF
        if [ $? -ne 0 ]
        then
            echo "!=> crfl2sac psv Abort on ${Model} !"
            exit 1;
        fi

        for file in `ls *.h`
        do
            mv ${file} ${EQname}.${Model}.${file%h}THR.sac
        done

        for file in `ls *.v`
        do
            mv ${file} ${EQname}.${Model}.${file%v}THZ.sac
        done
    fi

    # Run crfl2sac on T component. Make SAC files.
    if ! [ ${Comp} = "PSV" ]
    then
        ${EXECDIR}/crfl2sac.out > /dev/null << EOF
${file_sh}
n
EOF
        if [ $? -ne 0 ]
        then
            echo "!=> crfl2sac sh Abort on ${Model} !"
            rm -rf ${WORKDIR}/${EQname}
            continue
        fi

        for file in `ls *.sh`
        do
            mv ${file} ${EQname}.${Model}.${file%sh}THT.sac
        done

    fi

    # Set Omarker and Depth and other headers.
    [ ${RunReference} -eq 1 ] && Model=PREM

	rm -f sac.macro
    for file in `ls *.sac`
    do
        COMP=${file%%.sac}
        COMP=${COMP##*.}
        cat >> sac.macro << EOF
r ${file}
ch O ${OMARKER} evdp `echo "${EVDE} * 1000" | bc -l` LCALDA false KNETWK ${Model} EVLA 0 EVLO 0 KCMPNM ${COMP}
w over
EOF
    done

    # Set gcarc and AZ. Read from StationGcarcAZ file. ( Potential bug for multiple AZ,
    # because I don't know how the output of crfl2sac is arranged for gcarc / az order.)
    count2=1
    [ ${Comp} = "SH" ] && Suffix="T.sac" || Suffix="Z.sac"
    for file in `ls *${Suffix} | sort -n`
    do
        Prefix=${file%.TH?.sac}
        Tcomp=${Prefix}.THT.sac
        Rcomp=${Prefix}.THR.sac
        Zcomp=${Prefix}.THZ.sac
        STNM=${Prefix##*.}

        if [ -e StationGcarcAZ ]
        then
            Gcarc=`sed -n ${count2}p StationGcarcAZ | awk '{print $1}'`
            AZ=`sed -n ${count2}p StationGcarcAZ | awk '{print $2}'`
        else
            Gcarc=`echo "${DISTMIN} + ${DISTINC} * ( ${count2} - 1 )" | bc -l`
            AZ=0.0
        fi

        ! [ ${Comp} = "PSV" ] && cat >> sac.macro << EOF
r ${Tcomp}
ch gcarc ${Gcarc} az ${AZ} KSTNM ${STNM}
w over
EOF
        ! [ ${Comp} = "SH" ] && cat >> sac.macro << EOF
r ${Rcomp} ${Zcomp}
ch gcarc ${Gcarc} az ${AZ} KSTNM ${STNM}
w over
EOF

        count2=$((count2+1))
    done # done set gcarc/az loop.

    # Execute SAC macro.
    cat >> sac.macro << EOF
q
EOF
    sac >/dev/null << EOF
m sac.macro
EOF

    # Set time header.
    if [ "${VRED}" -eq 0 ]
    then
        for file in `ls *.sac`
        do
            taup_setsac -mod prem -ph P-0,Pdiff-0,pP-1,S-2,Sdiff-2,sS-3,PP-4,SS-5,PcP-6,ScP-7,SP-8,ScS-9 ${file}
        done
    fi

    # Move SAC files to OUTPUT dir.
    mv ${EQname}*.sac ${WORKDIR}/${EQname}
    cp ModelInput ${WORKDIR}/${EQname}/Index_${count}


    # Creat false components.
    if [ ${Comp} = "PSV" ] || [ ${Comp} = "SH" ]
    then
        rm -f sac.macro
        if [ ${Comp} = "SH" ]
        then
            for file in `find ${WORKDIR}/${EQname} -iname "*T.sac"`
            do
                cat >> sac.macro << EOF
cut b 0 1
r ${file}
ch KCMPNM THR
w ${file%T.sac}R.sac
ch KCMPNM THZ
w ${file%T.sac}Z.sac
EOF
            done
        else
            for file in `find ${WORKDIR}/${EQname} -iname "*Z.sac"`
            do
                cat >> sac.macro << EOF
cut b 0 1
r ${file}
ch KCMPNM THT
w ${file%Z.sac}T.sac
EOF
            done
        fi
    fi

    cat >> sac.macro << EOF
q
EOF
    sac >/dev/null << EOF
m sac.macro
EOF

    # Clean up.
    rm -f sac.macro sac.output

done # Done model loop.

cd ${WORKDIR}

exit 0
