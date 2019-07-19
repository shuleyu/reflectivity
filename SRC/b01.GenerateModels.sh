#!/bin/bash

# ==============================================================
# This script plot the models goes into synthesis calculation.
# Called by Run.sh.
#
# Shule Yu
# Jun 22 2014
# ==============================================================

echo ""
echo "--> `basename $0` is running. (`date`)"
mkdir -p ${PLOTDIR}/tmpdir_$$
cd ${PLOTDIR}/tmpdir_$$
trap "rm -rf ${PLOTDIR}/tmpdir_$$; exit 1" SIGINT EXIT

# Plot parameters.
gmtset PAPER_MEDIA = letter
gmtset ANNOT_FONT_SIZE_PRIMARY = 8p
gmtset LABEL_FONT_SIZE = 10p
gmtset LABEL_OFFSET = 0.05c
gmtset GRID_PEN_PRIMARY = 0.25p,200/200/200

# ================================================
#             ! Work Begin !
# ================================================
for count in `seq ${PlotBegin} ${PlotEnd}`
do
    if ! [ -e ${WORKDIR}/${ModelName}_${count}/ModelOutput ]
    then
        echo "    ==> No ModelOutput found for ${ModelName}_${count}..."
        continue
    else
        echo "    ==> Ploting ${ModelName}_${count}..."
    fi

    Num=`wc -l < ${WORKDIR}/${ModelName}_${count}/ModelInput`

    # Create data to plot perturbated PREM.
    rm -f tmpfile_$$
    for count2 in `seq ${Num} -1 1`
    do
        awk -v N=${count2} 'NR==N {print $0}' ${WORKDIR}/${ModelName}_${count}/ModelInput >> tmpfile_$$
    done

    toplayer=2891
    downlayer=2891
    rm -f tmpfile1_$$
    while read H vp1 vp2 vs1 vs2 rho1 rho2
    do
        downlayer=${toplayer}
        toplayer=`echo "${toplayer} - ${H}" | bc -l`
        awk -v T=${toplayer} -v D=${downlayer} -v vp1=${vp1} -v vp2=${vp2} -v vs1=${vs1} -v vs2=${vs2} -v rho1=${rho1} -v rho2=${rho2} '{ if (T<$1 && $1<=D) { dvp=vp2-(vp2-vp1)/(D-T)*($1-T) ; dvs=vs2-(vs2-vs1)/(D-T)*($1-T) ; drho=rho2-(rho2-rho1)/(D-T)*($1-T) ; print $1,$2*dvp,$3*dvs,$4*drho }}' ${BASHCODEDIR}/prem_profile.txt >> tmpfile1_$$
    done < tmpfile_$$

    awk -v T=${toplayer} -v D=2891 '{ if ($1<=T || D<$1) print $1,$2,$3,$4 }' ${BASHCODEDIR}/prem_profile.txt >> tmpfile1_$$

    sort -g -k1,1 tmpfile1_$$ > tmpfile_ulvz

    # calculation model.
    ${EXECDIR}/plotmodel.out 1 2 0 << EOF
`wc -l < ${WORKDIR}/${ModelName}_${count}/ModelOutput`
${WORKDIR}/${ModelName}_${count}/ModelOutput
tmpfile1_ulvz
EOF
    # The related reference model.
    ${EXECDIR}/plotmodel.out 1 2 0 << EOF
`wc -l < ${WORKDIR}/${ModelName}_${count}/ReferenceModel`
${WORKDIR}/${ModelName}_${count}/ReferenceModel
tmpfile1_ref
EOF

	# Output Unmodified PREM.
	${EXECDIR}/PREM.out 0 2 0 << EOF
tmpfile1_ref
tmpfile1_real_prem
EOF


	paste ${BASHCODEDIR}/prem_profile.txt tmpfile_ulvz > tmpfile_$$

    # ================================================
    #             ! PLOT !
    # ================================================

    OUTFILE=tmp.ps
    PROJ="-JX`echo "7 *6 / 7 / 3" | bc -l`i/5i"
#     REG="-R-40/40/`echo "2891-${DepthMax}"| bc -l`/`echo "2891-${DepthMin}"| bc -l`"
    REG="-R0/16/`echo "2891-${DepthMax}"| bc -l`/`echo "2891-${DepthMin}"| bc -l`"

    ## Plot title.
    pstext -R0/6371/-1/1 ${PROJ} -Y8i -N -K > ${OUTFILE} << EOF
0 -1.2 10 0 0 LB  Model: ${ModelName}_${count} ( `cat ${WORKDIR}/${ModelName}_${count}/ModelInput | awk '{printf "%s\t",$0}'` )
EOF

    # P velocity.
    psbasemap ${REG} ${PROJ} -Ba${AnoyInc}g${GridyInc}f${TickyInc}:"Vp (km/s)":/a${AnoDepthInc}g${GridDepthInc}f${TickDepthInc}:"Height above CMB (km)":WSne -Y-7i -O -K >> ${OUTFILE}
#     awk '{print 0,2891-$1}' tmpfile_$$ | psxy -R -J -Wblack -O -K >> ${OUTFILE}
#     awk '{print 0,2891-$1}' tmpfile1_$$ | psxy -R -J -Wblack -O -K >> ${OUTFILE}
#     awk '{print ($2/$10-1)*100,2891-$1}' tmpfile1_$$ | psxy -R -J -Sc0.03i -Wblue -O -K >> ${OUTFILE}
#     awk '{print ($6/$2-1)*100,2891-$1}' tmpfile_$$ | psxy -R -J -Wred -O -K >> ${OUTFILE}
#     awk '{print ($6/$10-1)*100,2891-$1}' tmpfile1_$$ | psxy -R -J -Sx0.03i -Wred -O -K >> ${OUTFILE}

    awk '{print $2,2891-$1}' tmpfile1_real_prem | psxy -R -J -Wblack -O -K >> ${OUTFILE}
    awk '{print $2,2891-$1}' tmpfile1_ref | psxy -R -J -Sc0.03i -Wblue -O -K >> ${OUTFILE}
    awk '{print $2,2891-$1}' tmpfile1_ulvz | psxy -R -J -Sx0.03i -Wred -O -K >> ${OUTFILE}

    # S velocity.
    psbasemap ${REG} ${PROJ} -Ba${AnoyInc}g${GridyInc}f${TickyInc}:"Vs (km/s)":/a${AnoDepthInc}g${GridDepthInc}f${TickDepthInc}:"Height above CMB (km)":WSne -X`echo "10/3" | bc -l`i -O -K >> ${OUTFILE}
#     awk '{if ($3!=0) print 0,2891-$1; else print -100,2891-$1}' tmpfile_$$ | psxy -R -J -Wblack -O -K >> ${OUTFILE}
#     awk '{print 0,2891-$1}' tmpfile1_$$ | psxy -R -J -Wblack -O -K >> ${OUTFILE}
#     awk '{if ($11!=0) print ($3/$11-1)*100,2891-$1; else print -100,2891-$1}' tmpfile1_$$ | psxy -R -J -Sc0.03i -Wblue -O -K >> ${OUTFILE}
#     awk '{if ($3!=0) print ($7/$3-1)*100,2891-$1; else print -100,2891-$1}' tmpfile_$$ | psxy -R -J -Wred -O -K >> ${OUTFILE}
#     awk '{if ($11!=0) print ($7/$11-1)*100,2891-$1; else print -100,2891-$1}' tmpfile1_$$ | psxy -R -J -Sx0.03i -Wred -O -K >> ${OUTFILE}

    awk '{print $3,2891-$1}' tmpfile1_real_prem | psxy -R -J -Wblack -O -K >> ${OUTFILE}
    awk '{print $3,2891-$1}' tmpfile1_ref | psxy -R -J -Sc0.03i -Wblue -O -K >> ${OUTFILE}
    awk '{print $3,2891-$1}' tmpfile1_ulvz | psxy -R -J -Sx0.03i -Wred -O -K >> ${OUTFILE}

    # Density.
    psbasemap ${REG} ${PROJ} -Ba${AnoyInc}g${GridyInc}f${TickyInc}:"Rho (g/cm3)":/a${AnoDepthInc}g${GridDepthInc}f${TickDepthInc}:"Height above CMB (km)":WSne -X`echo "10/3" | bc -l`i -O -K >> ${OUTFILE}
#     awk '{print 0,2891-$1}' tmpfile_$$ | psxy -R -J -Wblack -O -K >> ${OUTFILE}
#     awk '{print 0,2891-$1}' tmpfile1_$$ | psxy -R -J -Wblack -O -K >> ${OUTFILE}
#     awk '{print ($4/$12-1)*100,2891-$1}' tmpfile1_$$ | psxy -R -J -Sc0.03i -Wblue -O -K >> ${OUTFILE}
#     awk '{print ($8/$4-1)*100,2891-$1}' tmpfile_$$ | psxy -R -J -Wred -O -K >> ${OUTFILE}
#     awk '{print ($8/$12-1)*100,2891-$1}' tmpfile1_$$ | psxy -R -J -Sx0.03i -Wred -O -K >> ${OUTFILE}

    awk '{print $4,2891-$1}' tmpfile1_real_prem | psxy -R -J -Wblack -O -K >> ${OUTFILE}
    awk '{print $4,2891-$1}' tmpfile1_ref | psxy -R -J -Sc0.03i -Wblue -O -K >> ${OUTFILE}
    awk '{print $4,2891-$1}' tmpfile1_ulvz | psxy -R -J -Sx0.03i -Wred -O -K >> ${OUTFILE}

    # Make PDF.
    psxy -R -J -O >> ${OUTFILE} << EOF
EOF
    ps2pdf tmp.ps ${PLOTDIR}/${ModelName}_${count}.pdf

    # Clean up.
    rm -f ${PLOTDIR}/tmpdir_$$/*

done # done Model loop.

cd ${PLOTDIR}
if [ `ls -rt *_*pdf | wc -l` -eq 1 ]
then
    cp `ls -rt *_*pdf` All.pdf
else
#     pdunite `ls -rt *_*pdf` All.pdf
    pdftk `ls -rt *_*pdf` cat output All.pdf
fi

cd ${WORKDIR}

exit 0
