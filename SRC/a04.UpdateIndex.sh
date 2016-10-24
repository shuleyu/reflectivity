#!/bin/bash

# ==============================================================
# This script update model parameter file "index"
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

[ -e ${WORKDIR}/index ] && cp ${WORKDIR}/index ${WORKDIR}/index_BU

echo "<EQ> <Thickness> <Vp_Bot> <Vp_Top> <Vs_Bot> <Vs_Top> <Rho_Bot> <Rho_Top>" > ${WORKDIR}/index

for file in `find *000* -iname "index*" | sort -n`
do
	EQ=${file%/*}
	NR=`wc -l < ${file}`
	${BASHCODEDIR}/GenerateColumn.sh ${EQ} ${NR} > tmpfile_$$
	paste tmpfile_$$ ${file} >> ${WORKDIR}/index
done

rm -f tmpfile_$$

cd ${WORKDIR}

exit 0
