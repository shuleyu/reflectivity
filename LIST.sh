#!/bin/bash

# ${SRCDIR}/a01.GenerateModels.sh
${SRCDIR}/a02.RunCRFL.sh
${SRCDIR}/a03_1.PostProcess.sh
# ${SRCDIR}/a03_2.PostProcess_AddNoise.sh
# ${SRCDIR}/a03_3.AddDataNoise.sh

# ${SRCDIR}/b01.GenerateModels.sh
# ${SRCDIR}/b03.PlotModelSpace.sh
#  ================        Supplementary        ==================

exit 0
