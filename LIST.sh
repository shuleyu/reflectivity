#!/bin/bash

${SRCDIR}/a01.GenerateModels.sh
${SRCDIR}/a02.RunCRFL.sh
${SRCDIR}/a03.PostProcess.sh
# ${SRCDIR}/a03.PostProcess_AddNoise.sh

# ${SRCDIR}/b01.GenerateModels.sh
#  ================        Supplementary        ==================

exit 0
