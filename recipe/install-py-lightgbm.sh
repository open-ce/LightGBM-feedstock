#!/bin/bash

. activate "${PREFIX}"

pushd ${SRC_DIR}/python-package

INSTALL_OPTION=""
if [[ $build_type == "cuda" ]]
then
    INSTALL_OPTION="--gpu "
fi

if [[ $mpi_type == 'openmpi' ]]
then
    INSTALL_OPTION+="--mpi"
fi

${PYTHON} setup.py install $INSTALL_OPTION
popd
