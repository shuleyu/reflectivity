#!/bin/bash

# ===========================================================
# Plot Modeling space. Raw data waveforms.
#
# Shule Yu
# Jul 13 2018
# ===========================================================

# seimogram size (in inch) / Interval white spaces size (in inch).
XSIZE="1.2"
YSIZE="1"
XSpaceSIZE="0.1"
YSpaceSIZE="0.1"

# job begin.

echo ""
echo "--> `basename $0` is running. "
mkdir -p ${PLOTDIR}/tmpdir_$$
cd ${PLOTDIR}/tmpdir_$$
trap "rm -rf ${PLOTDIR}/tmpdir_$$; exit 1" SIGINT EXIT

# Plot parameters.


NX=`echo "${X_MAX} ${X_MIN} ${X_INC}" | awk '{printf "%d",($1-$2+$3/4)/$3+1}'`
NY=`echo "${Y_MAX} ${Y_MIN} ${Y_INC}" | awk '{printf "%d",($1-$2+$3/4)/$3+1}'`

PlotWidth=`echo "${NX}*(${XSIZE}+${XSpaceSIZE})" | bc -l`
PlotHeight=`echo "${NY}*(${YSIZE}+${YSpaceSIZE})" | bc -l`

PaperWidth=`echo "0.75 + ${PlotWidth} + 0.3" | bc -l`
PaperHeight=`echo "0.75 + ${PlotHeight} + 1" | bc -l`

gmt set PS_MEDIA ${PaperHeight}ix${PaperWidth}i
gmt set FONT_ANNOT_PRIMARY 8p
gmt set FONT_LABEL 9p
gmt set MAP_LABEL_OFFSET 5p
gmt set MAP_FRAME_PEN 0.5p,black
gmt set MAP_GRID_PEN_PRIMARY 0.3p,gray,.

# Time and amplitude marks.
rm -f tmpfile_x_marks_$$
for time in `seq -200 5 200`
do
    echo "${time} 0 ${time}" >> tmpfile_x_marks_$$
done

rm -f tmpfile_y_marks_$$
for amp in `seq -1 0.5 1`
do
    echo "0 ${amp}" >> tmpfile_y_marks_$$
done


# Prepare model properties.
keys="<EQ> <${X_FieldName}> <${Y_FieldName}>"
${BASHCODEDIR}/Findfield.sh ${WORKDIR}/index "${keys}" | awk '{printf "%.2lf_%.2lf %s %lf %lf\n",$2,$3,$1,$2,$3}' > tmpfile_all_models

# Select models.
rm -f tmpfile_$$
for X in `seq ${X_MIN} ${X_INC} ${X_MAX}`
do
    for Y in `seq ${Y_MIN} ${Y_INC} ${Y_MAX}`
    do
        echo "${X} ${Y}" | awk '{printf "%.2lf_%.2lf\n",$1,$2}' >> tmpfile_$$
    done
done

${BASHCODEDIR}/Findrow.sh tmpfile_all_models tmpfile_$$ | awk '{$1="";print $0}'> tmpfile_models_eq_x_y
! [ -s tmpfile_models_eq_x_y ] && echo "No selected models" && exit 1

# Prepare gcarc - stnm.
read Model A < tmpfile_models_eq_x_y
saclst gcarc kstnm f `ls ${WORKDIR}/${Model}/*sac` | awk '{printf "%.2lf %s\n",$2,$3}' | sort -gu > tmpfile_gcarc_stnm

# Plot.

Page=1
for GCARC in `seq ${GCARC_MIN} ${GCARC_INC} ${GCARC_MAX}`
do

    GCARC=`echo ${GCARC} | awk '{printf "%.2lf",$1}'`

	# Find the stnm for this distance.
    STNM=`grep -w ${GCARC} tmpfile_gcarc_stnm | awk '{print $2}'`
    [ -z ${STNM} ] && continue

    rm -f tmpfile_Cin_$$
    # Dump waveforms.
    while read Model A
    do
        ls ${WORKDIR}/${Model}/*.${STNM}.${COMP}.sac >> tmpfile_Cin_$$
    done < tmpfile_models_eq_x_y

    # Dump x,y waveform to files: "${Model}_${SACfilenames}.txt"
    ${EXECDIR}/DumpWaveforms.out 0 2 4 << EOF
${CenterPhase}
tmpfile_Cin_$$
${GCARC_MIN}
${GCARC_MAX}
${Time_MIN}
${Time_MAX}
EOF

    echo "    ==> Plotting ${Title} Model space (raw waveforms), Gcarc: ${GCARC}..."
    OUTFILE=${Page}.ps

	## plot titles and legends
	cat > tmpfile_$$ << EOF
0 0 ${Title} ModelSpace, Phase = ${CenterPhase}, Gcarc = ${GCARC}.
EOF
	gmt pstext tmpfile_$$ -JX1i/1i -R0/1/0/1 -F+jCM+f15p,1,black -Xf`echo ${PaperWidth}/2 |bc -l`i -Yf`echo "${PaperHeight} - 0.5" | bc -l`i -N -K > ${OUTFILE}

	## plot property basemap.
    XValInchRatio=`echo "${X_INC} / (${XSIZE}+${XSpaceSIZE})" | bc -l`
    YValInchRatio=`echo "${Y_INC} / (${YSIZE}+${YSpaceSIZE})" | bc -l`

    RXMIN=`echo "${X_MIN} - ( ${XSIZE} / 2 + ${XSpaceSIZE} ) * ${XValInchRatio}" | bc -l`
    RXMAX=`echo "${X_MAX} + ( ${XSIZE} / 2 ) * ${XValInchRatio}" | bc -l`
    RYMIN=`echo "${Y_MIN} - ( ${YSIZE} / 2 + ${YSpaceSIZE} ) * ${YValInchRatio}" | bc -l`
    RYMAX=`echo "${Y_MAX} + ( ${YSIZE} / 2 ) * ${YValInchRatio}" | bc -l`

	gmt psbasemap -JX${PlotWidth}i/${PlotHeight}i \
    -R${RXMIN}/${RXMAX}/${RYMIN}/${RYMAX} \
    -Bxa${X_INC}f${X_INC}+l"${X_Label}" -Bya${Y_INC}f${Y_INC}+l"${Y_Label}" -BWS -Xf0.75i -Yf0.75i -O -K >> ${OUTFILE}


    Count=0
    while read Model X Y
	do
        file=`ls ${Model}*.${STNM}.${COMP}.sac.txt`

        ## go to the right position to plot seismograms
		[ -z ${file} ] && continue
        ! [ -e ${file} ] && continue
        Count=$((Count+1))

		# ===================================
		#        ! Plot !
		# ===================================
		MVX=`echo "0.75 + ${XSpaceSIZE} + (${X} - ${X_MIN}) / ${X_INC} * ( ${XSIZE} + ${XSpaceSIZE} )" | bc -l`
		MVY=`echo "0.75 + ${YSpaceSIZE} + (${Y} - ${Y_MIN}) / ${Y_INC} * ( ${YSIZE} + ${YSpaceSIZE} )" | bc -l`

		### go to the correct positoin.
		gmt psxy -JX${XSIZE}i/${YSIZE}i -R${Time_MIN}/${Time_MAX}/-1/1 -Xf${MVX}i -Yf${MVY}i -O -K >> ${OUTFILE} << EOF
EOF
        ### plot customize time axis.
        gmt psxy -J -R -W0.3p,gray,. -O -K >> ${OUTFILE} << EOF
${Time_MIN} 0
${Time_MAX} 0
EOF

        awk '{print $1,$2}' tmpfile_x_marks_$$ | gmt psxy -J -R -Sy`echo 0.025*${YSIZE} | bc -l`i -Wgray -O -K >> ${OUTFILE}
        awk -v Y=${YSIZE} '{print $1,$2-0.05/Y,$3}' tmpfile_x_marks_$$ | gmt pstext -J -R -F+jCT+f`echo "4.8 * ${YSIZE}" | bc`p,1,gray -O -K >> ${OUTFILE}


        ### plot customize amplitude axis.
        gmt psxy -J -R -W0.3p,gray,. -O -K >> ${OUTFILE} << EOF
0 -1
0 1
EOF

        gmt psxy tmpfile_y_marks_$$ -J -R -S-`echo 0.025*${XSIZE} | bc -l`i -Wgray -O -K >> ${OUTFILE}


		### plot waveforms.
		gmt psxy ${file} -J -R -W0.5p,black -O -K >> ${OUTFILE}

	done < tmpfile_models_eq_x_y

	# Seal this gcarc page.
	gmt psxy -J -R -O >> ${OUTFILE} << EOF
EOF

    # If no stations on such distance, remove this page.
	if [ ${Count} -eq 0 ]
    then
        rm -f ${OUTFILE}
    else
        ps2pdf ${OUTFILE}
        Page=$((Page+1))
    fi

    rm -f *txt

done # End of gcarc loop.

# Make PDF.
Title=`basename $0`
pdfunite `ls -rt *.pdf` ${PLOTDIR}/${Title%.sh}.pdf
tomini ${PLOTDIR}/${Title%.sh}.pdf

# Clean up.
cd ${WORKDIR}

exit 0
