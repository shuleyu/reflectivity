#!/bin/bash

# ==============================================================
# This script make models of the input parameters.
#
# Shule Yu
# Jun 22 2014
# ==============================================================

echo ""
echo "--> `basename $0` is running. (`date`)"
mkdir -p ${WORKDIR}
cd ${WORKDIR}
trap "rm -rf ${EXECDIR}/*.out ${ModelName}_* *index; exit 1" SIGINT

# ================================================
#             ! Work Begin !
# ================================================

Layer=0
while read hmin hmax hinc vp1min vp1max vp1inc vpslop vp2min vp2max vp2inc vs1min vs1max vs1inc vsslop vs2min vs2max vs2inc rho1min rho1max rho1inc rhoslop rho2min rho2max rho2inc
do
    Layer=$((Layer+1))

    NModel[${Layer}]=0
    H=${hmin}
    while [ `echo "${H}<=${hmax}" | bc` -eq 1 ]
    do
        VP1=${vp1min}

        while [ `echo "${VP1}<=${vp1max}" | bc` -eq 1 ]
        do
            if [ "${vpslop}" -eq 1 ]
            then

                VP2=`echo "${vp2min} ${VP1}" | awk '{ if ($1>$2) print $1; else print $2}'`

                while [ `echo "${VP2}<=${vp2max}" | bc` -eq 1 ] || [ `echo "${VP2}==${VP1}" | bc` -eq 1 ]
                do
                    VS1=${vs1min}

                    while [ `echo "${VS1}<=${vs1max}" | bc` -eq 1 ]
                    do
                        if [ "${vsslop}" -eq 1 ]
                        then

                            VS2=`echo "${vs2min} ${VS1}" | awk '{ if ($1>$2) print $1; else print $2}'`

                            while [ `echo "${VS2}<=${vs2max}" | bc` -eq 1 ] || [ `echo "${VS2}==${VS1}" | bc` -eq 1 ]
                            do
                                RHO1=${rho1min}

                                while [ `echo "${RHO1}<=${rho1max}" | bc` -eq 1 ]
                                do
                                    if [ "${rhoslop}" -eq 1 ]
                                    then

                                        RHO2=`echo "${rho2min} ${RHO1}" | awk '{ if ($1>$2) print $1; else print $2}'`

                                        while [ `echo "${RHO2}<=${rho2max}" | bc` -eq 1 ] || [ `echo "${RHO2}==${RHO1}" | bc` -eq 1 ]
                                        do

                                            NModel[${Layer}]=$((NModel[${Layer}]+1))
                                            echo "${H} ${VP1} ${VP2} ${VS1} ${VS2} ${RHO1} ${RHO2}" | awk '{printf "%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf\n",$1,$2,$3,$4,$5,$6,$7}' > ${Layer}.${NModel[${Layer}]}.index

                                            RHO2=`echo "${RHO2}+${rho2inc}" | bc -l`

                                        done # done rho2 loop @ vp slop > 0 && vs slop > 0 && rho slop > 0.

                                    else # if vp slop > 0 && vs slop > 0 && rho slop < 0.

                                        RHO2=`echo "${rho2max} ${RHO1}" | awk '{ if ($1<$2) print $1; else print $2}'`

                                        while [ `echo "${RHO2}>=${rho2min}" | bc` -eq 1 ] || [ `echo "${RHO2}==${RHO1}" | bc` -eq 1 ]
                                        do

                                            NModel[${Layer}]=$((NModel[${Layer}]+1))
                                            echo "${H} ${VP1} ${VP2} ${VS1} ${VS2} ${RHO1} ${RHO2}" | awk '{printf "%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf\n",$1,$2,$3,$4,$5,$6,$7}' > ${Layer}.${NModel[${Layer}]}.index

                                            RHO2=`echo "${RHO2}-${rho2inc}" | bc -l`

                                        done # done rho2 loop @ vp slop > 0 && vs slop > 0 && rho slop < 0.

                                    fi

                                    RHO1=`echo "${RHO1}+${rho1inc}" | bc -l`

                                done # done rho1 loop @ vp slop > 0 && vs slop > 0.

                                VS2=`echo "${VS2}+${vs2inc}" | bc -l`

                            done # done vs2 loop @ vp slop>0 && vs slop > 0.

                        else # if vp slop > 0 && vs slop < 0.

                            VS2=`echo "${vs2max} ${VS1}" | awk '{ if ($1<$2) print $1; else print $2}'`

                            while [ `echo "${VS2}>=${vs2min}" | bc` -eq 1 ] || [ `echo "${VS2}==${VS1}" | bc` -eq 1 ]
                            do
                                RHO1=${rho1min}

                                while [ `echo "${RHO1}<=${rho1max}" | bc` -eq 1 ]
                                do
                                    if [ "${rhoslop}" -eq 1 ]
                                    then

                                        RHO2=`echo "${rho2min} ${RHO1}" | awk '{ if ($1>$2) print $1; else print $2}'`

                                        while [ `echo "${RHO2}<=${rho2max}" | bc` -eq 1 ] || [ `echo "${RHO2}==${RHO1}" | bc` -eq 1 ]
                                        do

                                            NModel[${Layer}]=$((NModel[${Layer}]+1))
                                            echo "${H} ${VP1} ${VP2} ${VS1} ${VS2} ${RHO1} ${RHO2}" | awk '{printf "%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf\n",$1,$2,$3,$4,$5,$6,$7}' > ${Layer}.${NModel[${Layer}]}.index

                                            RHO2=`echo "${RHO2}+${rho2inc}" | bc -l`

                                        done # done rho2 loop @ vp slop > 0 && vs slop < 0 && rho slop > 0.

                                    else # if vp slop > 0 && vs slop < 0 && rho slop < 0.

                                        RHO2=`echo "${rho2max} ${RHO1}" | awk '{ if ($1<$2) print $1; else print $2}'`

                                        while [ `echo "${RHO2}>=${rho2min}" | bc` -eq 1 ] || [ `echo "${RHO2}==${RHO1}" | bc` -eq 1 ]
                                        do

                                            NModel[${Layer}]=$((NModel[${Layer}]+1))
                                            echo "${H} ${VP1} ${VP2} ${VS1} ${VS2} ${RHO1} ${RHO2}" | awk '{printf "%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf\n",$1,$2,$3,$4,$5,$6,$7}' > ${Layer}.${NModel[${Layer}]}.index

                                            RHO2=`echo "${RHO2}-${rho2inc}" | bc -l`

                                        done # done rho2 loop @ vp slop > 0 && vs slop < 0 && rho slop < 0.

                                    fi

                                    RHO1=`echo "${RHO1}+${rho1inc}" | bc -l`

                                done # done rho1 loop @ vp slop > 0 && vs slop < 0.

                                VS2=`echo "${VS2}-${vs2inc}" | bc -l`

                            done # done vs2 loop @ vp slop>0 && vs slop < 0.

                        fi

                        VS1=`echo "${VS1}+${vs1inc}" | bc -l`

                    done # done vs1 loop @ vp slop > 0.

                    VP2=`echo "${VP2}+${vp2inc}" | bc -l`

                done # done vp2 loop @ vp slop > 0.

            else # if vp slop < 0.

                VP2=`echo "${vp2max} ${VP1}" | awk '{ if ($1<$2) print $1; else print $2}'`

                while [ `echo "${VP2}>=${vp2min}" | bc` -eq 1 ] || [ `echo "${VP2}==${VP1}" | bc` -eq 1 ]
                do
                    VS1=${vs1min}

                    while [ `echo "${VS1}<=${vs1max}" | bc` -eq 1 ]
                    do
                        if [ "${vsslop}" -eq 1 ]
                        then

                            VS2=`echo "${vs2min} ${VS1}" | awk '{ if ($1>$2) print $1; else print $2}'`

                            while [ `echo "${VS2}<=${vs2max}" | bc` -eq 1 ] || [ `echo "${VS2}==${VS1}" | bc` -eq 1 ]
                            do
                                RHO1=${rho1min}

                                while [ `echo "${RHO1}<=${rho1max}" | bc` -eq 1 ]
                                do
                                    if [ "${rhoslop}" -eq 1 ]
                                    then

                                        RHO2=`echo "${rho2min} ${RHO1}" | awk '{ if ($1>$2) print $1; else print $2}'`

                                        while [ `echo "${RHO2}<=${rho2max}" | bc` -eq 1 ] || [ `echo "${RHO2}==${RHO1}" | bc` -eq 1 ]
                                        do

                                            NModel[${Layer}]=$((NModel[${Layer}]+1))
                                            echo "${H} ${VP1} ${VP2} ${VS1} ${VS2} ${RHO1} ${RHO2}" | awk '{printf "%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf\n",$1,$2,$3,$4,$5,$6,$7}' > ${Layer}.${NModel[${Layer}]}.index

                                            RHO2=`echo "${RHO2}+${rho2inc}" | bc -l`

                                        done # done rho2 loop @ vp slop < 0 && vs slop > 0 && rho slop > 0.

                                    else # if vp slop < 0 && vs slop > 0 && rho slop < 0.

                                        RHO2=`echo "${rho2max} ${RHO1}" | awk '{ if ($1<$2) print $1; else print $2}'`

                                        while [ `echo "${RHO2}>=${rho2min}" | bc` -eq 1 ] || [ `echo "${RHO2}==${RHO1}" | bc` -eq 1 ]
                                        do

                                            NModel[${Layer}]=$((NModel[${Layer}]+1))
                                            echo "${H} ${VP1} ${VP2} ${VS1} ${VS2} ${RHO1} ${RHO2}" | awk '{printf "%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf\n",$1,$2,$3,$4,$5,$6,$7}' > ${Layer}.${NModel[${Layer}]}.index

                                            RHO2=`echo "${RHO2}-${rho2inc}" | bc -l`

                                        done # done rho2 loop @ vp slop < 0 && vs slop > 0 && rho slop < 0.

                                    fi

                                    RHO1=`echo "${RHO1}+${rho1inc}" | bc -l`

                                done # done rho1 loop @ vp slop > 0 && vs slop > 0.

                                VS2=`echo "${VS2}+${vs2inc}" | bc -l`

                            done # done vs2 loop @ vp slop > 0 && vs slop > 0.

                        else # if vp slop < 0 && vs slop < 0.

                            VS2=`echo "${vs2max} ${VS1}" | awk '{ if ($1<$2) print $1; else print $2}'`

                            while [ `echo "${VS2}>=${vs2min}" | bc` -eq 1 ] || [ `echo "${VS2}==${VS1}" | bc` -eq 1 ]
                            do
                                RHO1=${rho1min}

                                while [ `echo "${RHO1}<=${rho1max}" | bc` -eq 1 ]
                                do
                                    if [ "${rhoslop}" -eq 1 ]
                                    then

                                        RHO2=`echo "${rho2min} ${RHO1}" | awk '{ if ($1>$2) print $1; else print $2}'`

                                        while [ `echo "${RHO2}<=${rho2max}" | bc` -eq 1 ] || [ `echo "${RHO2}==${RHO1}" | bc` -eq 1 ]
                                        do

                                            NModel[${Layer}]=$((NModel[${Layer}]+1))
                                            echo "${H} ${VP1} ${VP2} ${VS1} ${VS2} ${RHO1} ${RHO2}" | awk '{printf "%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf\n",$1,$2,$3,$4,$5,$6,$7}' > ${Layer}.${NModel[${Layer}]}.index

                                            RHO2=`echo "${RHO2}+${rho2inc}" | bc -l`

                                        done # done rho2 loop @ vp slop < 0 && vs slop < 0 && rho slop > 0.

                                    else # if vp slop < 0 && vs slop < 0 && rho slop < 0.

                                        RHO2=`echo "${rho2max} ${RHO1}" | awk '{ if ($1<$2) print $1; else print $2}'`

                                        while [ `echo "${RHO2}>=${rho2min}" | bc` -eq 1 ] || [ `echo "${RHO2}==${RHO1}" | bc` -eq 1 ]
                                        do

                                            NModel[${Layer}]=$((NModel[${Layer}]+1))
                                            echo "${H} ${VP1} ${VP2} ${VS1} ${VS2} ${RHO1} ${RHO2}" | awk '{printf "%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf%11.2lf\n",$1,$2,$3,$4,$5,$6,$7}' > ${Layer}.${NModel[${Layer}]}.index

                                            RHO2=`echo "${RHO2}-${rho2inc}" | bc -l`

                                        done # done rho2 loop @ vp slop < 0 && vs slop < 0 && rho slop < 0.

                                    fi

                                    RHO1=`echo "${RHO1}+${rho1inc}" | bc -l`

                                done # done rho1 loop @ vp slop < 0 && vs slop < 0.

                                VS2=`echo "${VS2}-${vs2inc}" | bc -l`

                            done # done vs2 loop @ vp slop > 0 && vs slop < 0.

                        fi

                        VS1=`echo "${VS1}+${vs1inc}" | bc -l`

                    done # done vs1 loop @ vp slop < 0.

                    VP2=`echo "${VP2}-${vp2inc}" | bc -l`

                done # done vp2 loop @ vp slop < 0.

            fi

            VP1=`echo "${VP1}+${vp1inc}" | bc -l`

        done # done vp1 loop.

        H=`echo "${H}+${hinc}" | bc -l`

    done # done height loop.

done < ${WORKDIR}/tmpfile_Model_${RunNumber}

# ========= Mix the Layers. Layer(N+1) is below Layer(N). =========

TotalModelNum=1
for count in `seq 1 ${Layer}`
do
    TotalModelNum=`echo "${TotalModelNum} * ${NModel[${count}]}" | bc `
    A[${count}]=1
done

echo "    ==> Total model numbers: ${TotalModelNum}"

ModelNum=1
while [ ${ModelNum} -le ${TotalModelNum} ]
do
    # output indexes.
    rm -f ${ModelName}_${ModelNum}.model
    for count in `seq 1 ${Layer}`
    do
        cat ${count}.${A[${count}]}.index >> ${ModelName}_${ModelNum}.model
    done

    ModelNum=$((ModelNum+1))

    # loop through to make new A.
    position=1
    A[1]=`echo "${A[1]} + 1" | bc`
    while [ ${position} -lt ${Layer} ] && [ ${A[${position}]} -gt ${NModel[${position}]} ]
    do
        A[${position}]=1
        position=$((position+1))
        A[${position}]=`echo "${A[${position}]} + 1" | bc`
    done

done

if ! [ -z "${CertainStaionListFile}" ]
then
	DISTMIN=`minmax -C ${CertainStaionListFile} | awk '{print $1}'`
	DISTMAX=`minmax -C ${CertainStaionListFile} | awk '{print $2}'`
fi

# ========= Generate crfl.dat on each model. =========

# for count in `seq 1 ${TotalModelNum}`
for count in `seq ${BeginIndex} $((BeginIndex-1+TotalModelNum))`
do
    echo "    ==> Calculating input file for ${ModelName}_${count} .."
    rm -f ${WORKDIR}/${ModelName}_${count}/*
    mkdir -p ${WORKDIR}/${ModelName}_${count}
    cd ${WORKDIR}/${ModelName}_${count}
    mv ${WORKDIR}/${ModelName}_$((count-BeginIndex+1)).model ${WORKDIR}/${ModelName}_${count}/ModelInput
	echo "${strike} ${dip} ${rake} ${EVDE}" > ${WORKDIR}/${ModelName}_${count}/Source
#     mv ${WORKDIR}/${ModelName}_${count}.model ${WORKDIR}/${ModelName}_${count}/ModelInput

    # Generate modified reference model.
	if [ -z "${CertainStaionListFile}" ]
	then # If we use DISTMIN,DISTMAX,AZMIN,AZMAX

		${EXECDIR}/GenModel.out 10 7 28 << EOF
${RaypN}
${NPTS}
${M1}
${M2}
${Layer}
${RemoveCrust}
${Remove220}
${Remove400}
${Remove670}
${PREM_X}
ModelInput
ReferenceModel
ModelOutput
tmpfile_suffix
tmpfile1_$$
tmpfile2_$$
tmpfile_reflzone
${strike}
${dip}
${rake}
${EVDE}
${AZMIN}
${AZMAX}
${AZINC}
${DISTMIN}
${DISTMAX}
${DISTINC}
${REDE}
${Begin}
${V1}
${V2}
${V3}
${V4}
${F1}
${F2}
${F3}
${F4}
${ATTEN}
${DELTA}
${M3}
${M4}
${OMARKER}
${VRED}
${LayerInc}
${ReflDepth}
EOF
		if [ $? -ne 0 ]
		then
			echo "!=> C code Abort on ${ModelName}_${count}!"
			continue
		fi
	else

		${EXECDIR}/GenModel_CertainStations.out 10 6 28 << EOF
${RaypN}
${NPTS}
${M1}
${M2}
${Layer}
${RemoveCrust}
${Remove220}
${Remove400}
${Remove670}
${PREM_X}
ModelInput
ReferenceModel
ModelOutput
tmpfile_suffix
${CertainStaionListFile}
tmpfile_reflzone
${strike}
${dip}
${rake}
${EVDE}
${AZMIN}
${AZMAX}
${AZINC}
${DISTMIN}
${DISTMAX}
${DISTINC}
${REDE}
${Begin}
${V1}
${V2}
${V3}
${V4}
${F1}
${F2}
${F3}
${F4}
${ATTEN}
${DELTA}
${M3}
${M4}
${OMARKER}
${VRED}
${LayerInc}
${ReflDepth}
EOF

		if [ $? -ne 0 ]
		then
			echo "!=> C code Abort on ${ModelName}_${count}!"
			continue
		fi

		awk '{print $1}' ${CertainStaionListFile} > tmpfile1_$$
		awk '{print $2}' ${CertainStaionListFile} > tmpfile2_$$

	fi

    # Make crfl.dat.
    REFLINDEX=`cat tmpfile_reflzone`

    ## Model name and prefix. (don't mess up with the spaces.)
    echo ${ModelName}_${count} > crfl.dat.${ModelName}_${count}
    echo ${ModelName}_${count}_reference > crfl.dat.ref

    if [ ${Comp} = "PSV" ]
    then
        Info=" 0 0 1 0 1   0 1 1 1 1   2 1 0 0 1   0 1 2 1 1   0"
    elif [ ${Comp} = "SH" ]
    then
        Info=" 2 1 0 3 0   0 1 1 1 1   2 1 0 0 1   1 1 2 1 1   0"
    else
        Info=" 0 0 0 0 0   0 1 1 1 1   2 1 0 0 1   0 1 2 1 1   0"
    fi

    cat >> crfl.dat.${ModelName}_${count} << EOF
${Info}
    0    0`printf "%5.2d" ${REFLINDEX}`    1    1
EOF

    ## Structure and Suffix.
    cat ModelOutput >> crfl.dat.${ModelName}_${count}
    cat ReferenceModel >> crfl.dat.ref

    echo "" >> crfl.dat.${ModelName}_${count}
    echo "" >> crfl.dat.ref

    cat tmpfile_suffix >> crfl.dat.${ModelName}_${count}
    cat tmpfile_suffix >> crfl.dat.ref

    # Clean up.
    paste tmpfile1_$$ tmpfile2_$$ > StationGcarcAZ
    rm -f tmpfile*

    cd ${WORKDIR}

done # done generating crfl.dat for each models.

# Clean up.
rm -f *index

cd ${WORKDIR}

exit 0
