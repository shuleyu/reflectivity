#!/bin/bash

#=========================================================
# This script made synthesis seismogrames for altered PREM
# model. (1-D, reflectivity)
# Result: Bunch of SAC files.
#
# Shule Yu
# Jun 23 2014
#=========================================================

# Export variables to all sub scripts.
set -a
CODEDIR=${PWD}
SRCDIR=${CODEDIR}/SRC
RunNumber=$$

#============================================
#            ! Test Files !
#============================================
if ! [ -e ${CODEDIR}/INFILE ]
then
    echo "INFILE not found ..."
    exit 1
fi

#============================================
#            ! Parameters !
#============================================

# DIRs.
WORKDIR=`grep "<WORKDIR>" ${CODEDIR}/INFILE | awk '{print $2}'`
trap "rm -f ${WORKDIR}/tmpfile*_$$; exit 1" SIGINT
mkdir -p ${WORKDIR}/LIST
mkdir -p ${WORKDIR}/INPUT
cp ${CODEDIR}/INFILE ${WORKDIR}/tmpfile_INFILE_$$
cp ${CODEDIR}/INFILE ${WORKDIR}/INPUT/INFILE_`date +%m%d_%H%M`
cp ${CODEDIR}/LIST.sh ${WORKDIR}/tmpfile_LIST_$$
cp ${CODEDIR}/LIST.sh ${WORKDIR}/LIST/LIST_`date +%m%d_%H%M`
chmod -x ${WORKDIR}/LIST/*
cd ${WORKDIR}


# Deal with parameters (single).
grep -n "<" ${WORKDIR}/tmpfile_INFILE_$$     \
| grep ">" | grep -v "BEGIN" | grep -v "END" \
| awk 'BEGIN {FS="<"} {print $2}'            \
| awk 'BEGIN {FS=">"} {print $1,$2}' > tmpfile_$$
awk '{print $1}' tmpfile_$$ > tmpfile1_$$
awk '{$1="";print "\""$0"\""}' tmpfile_$$ > tmpfile2_$$
sed 's/\"[[:blank:]]/\"/' tmpfile2_$$ > tmpfile3_$$
paste -d= tmpfile1_$$ tmpfile3_$$ > tmpfile_$$
source ${WORKDIR}/tmpfile_$$

# Deal with parameters (range).
grep -n "<" ${WORKDIR}/tmpfile_INFILE_$$ \
| grep ">" | grep "_BEGIN"               \
| awk 'BEGIN {FS=":<"} {print $2,$1}'    \
| awk 'BEGIN {FS="[> ]"} {print $1,$NF}' \
| sed 's/_BEGIN//g'                      \
| sort -g -k 2,2 > tmpfile1_$$

grep -n "<" ${WORKDIR}/tmpfile_INFILE_$$ \
| grep ">" | grep "_END"                 \
| awk 'BEGIN {FS=":<"} {print $2,$1}'    \
| awk 'BEGIN {FS="[> ]"} {print $1,$NF}' \
| sed 's/_END//g'                        \
| sort -g -k 2,2 > tmpfile2_$$

paste tmpfile1_$$ tmpfile2_$$ | awk '{print $1,$2,$4}' > tmpfile_parameters_$$

while read Name line1 line2
do
    Name=${Name%_*}
    awk -v N1=${line1} -v N2=${line2} '{ if ( $1!="" && N1<NR && NR<N2 ) print $0}' ${WORKDIR}/tmpfile_INFILE_$$ > ${WORKDIR}/tmpfile_${Name}_$$
done < tmpfile_parameters_$$

# Additional DIRs.
EXECDIR=${WORKDIR}/bin
PLOTDIR=${WORKDIR}/PLOTS

#============================================
#            ! Test Dependencies !
#============================================
CommandList="sac saclst psxy ps2pdf bc"
for Command in ${CommandList}
do
    command -v ${Command} >/dev/null 2>&1 || { echo >&2 "Command ${Command} is not found. Exiting ... "; exit 1; }
done

#============================================
#            ! Compile !
#============================================
mkdir -p ${EXECDIR}
trap "rm -f ${EXECDIR}/*.o ${WORKDIR}/*_$$; exit 1" SIGINT

cd ${CCODEDIR}
make
[ $? -ne 0 ] && rm -f ${WORKDIR}/*_$$ && exit 1

cd ${SRCDIR}
make OUTDIR=${EXECDIR} CDIR=${CCODEDIR} SACDIR=${SACDIR}

echo "Compile finished...running..."

# ==============================================
#           ! Work Begin !
# ==============================================

cat >> ${WORKDIR}/stdout << EOF

======================================
Run Date: `date`
EOF

${WORKDIR}/tmpfile_LIST_$$ >> ${WORKDIR}/stdout 2>&1

cat >> ${WORKDIR}/stdout << EOF

End Date: `date`
======================================
EOF

echo "Finished."

# Clean up.
rm -f ${WORKDIR}/*_$$

exit 0
