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

# Deal with parameters.
grep -n "<" ${WORKDIR}/tmpfile_INFILE_$$ \
| grep ">"                           \
| grep -v "BEGIN"                    \
| grep -v "END"                      \
| awk 'BEGIN {FS="<"} {print $2}'    \
| awk 'BEGIN {FS=">"} {print $1,$2}' \
| awk '{print $1"=\""$2"\""}' > tmpfile_$$

source ${WORKDIR}/tmpfile_$$

grep -n "<" ${WORKDIR}/tmpfile_INFILE_$$ \
| grep ">"                           \
| awk 'BEGIN {FS=":"} {print $2,$1}' \
| awk 'BEGIN {FS="<"} {print $2}'    \
| awk 'BEGIN {FS=">"} {print $1,$2}' \
| awk '{print $1,$2}'                \
| grep "BEGIN"                       \
| sort -g -k 2,2 > tmpfile1_$$

grep -n "<" ${WORKDIR}/tmpfile_INFILE_$$ \
| grep ">"                           \
| awk 'BEGIN {FS=":"} {print $2,$1}' \
| awk 'BEGIN {FS="<"} {print $2}'    \
| awk 'BEGIN {FS=">"} {print $1,$2}' \
| awk '{print $1,$2}'                \
| grep "END"                         \
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
CommandList="sac saclst psxy ps2pdf bc ${CCOMP} ${FCOMP} ${CPPCOMP}"
for Command in ${CommandList}
do
    command -v ${Command} >/dev/null 2>&1 || { echo >&2 "Command ${Command} is not found. Exiting ... "; exit 1; }
done

#============================================
#            ! Compile !
#============================================
mkdir -p ${EXECDIR}
cp ${WORKDIR}/tmpfile_INFILE_$$ ${EXECDIR}
trap "rm -f ${EXECDIR}/*.o ${WORKDIR}/*_$$; exit 1" SIGINT

INCLUDEDIR="-I${SACDIR}/include -I${CCODEDIR}"
LIBRARYDIR="-L. -L${SACDIR}/lib -L${CCODEDIR}"
LIBRARIES="-lASU_tools -lsac -lsacio -lm"

# ASU_tools Functions.
cd ${CCODEDIR}
make
cd ${EXECDIR}

# Executables.
for code in `ls ${SRCDIR}/*.c | grep -v fun.c`
do
    name=`basename ${code}`
    name=${name%.c}

    ${CCOMP} -o ${EXECDIR}/${name}.out ${code} ${INCLUDEDIR} ${LIBRARYDIR} ${LIBRARIES}

    if [ $? -ne 0 ]
    then
        echo "${name} C code is not compiled ..."
        rm -f ${EXECDIR}/*.o ${WORKDIR}/*_$$
        exit 1
    fi
done

for code in `ls ${SRCDIR}/*.cpp | grep -v fun.cpp`
do
    name=`basename ${code}`
    name=${name%.cpp}

    ${CPPCOMP} ${CPPFLAG} -o ${EXECDIR}/${name}.out ${code} ${INCLUDEDIR} ${LIBRARYDIR} ${LIBRARIES}

    if [ $? -ne 0 ]
    then
        echo "${name} C++ code is not compiled ..."
        rm -f ${EXECDIR}/*.o ${WORKDIR}/*_$$
        exit 1
    fi
done

for code in `ls ${SRCDIR}/*.f`
do
    name=`basename ${code}`
    name=${name%.f}

    ${FCOMP} -o ${EXECDIR}/${name}.out ${code} ${INCLUDEDIR} ${LIBRARYDIR} ${LIBRARIES}

    if [ $? -ne 0 ]
    then
        echo "${name} F code is not compiled ..."
        rm -f ${EXECDIR}/*.o ${WORKDIR}/*_$$
        exit 1
    fi
done

# Clean up.
rm -f ${EXECDIR}/*fun.o

# ==============================================
#           ! Work Begin !
# ==============================================

cat >> ${WORKDIR}/stdout << EOF

======================================
Run Date: `date`
EOF

${CODEDIR}/tmpfile_LIST_$$ >> ${WORKDIR}/stdout 2>&1

cat >> ${WORKDIR}/stdout << EOF

End Date: `date`
======================================
EOF

# Clean up.
rm -f ${WORKDIR}/*_$$

exit 0
