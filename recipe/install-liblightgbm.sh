# *****************************************************************
#
# Licensed Materials - Property of IBM
#
# (C) Copyright IBM Corp. 2020. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
# *****************************************************************
#!/bin/bash

export CMAKE_PREFIX_PATH=$PREFIX

mkdir -p ${SRC_DIR}/build
cd ${SRC_DIR}/build

BUILD_OPTION=""
# Determine Architecture
ARCH="$(arch)"

if [[ $build_type == "cuda" ]]
then
    BUILD_OPTION="-DUSE_CUDA=ON -DCMAKE_CUDA_COMPILER=${CUDA_HOME}/bin/nvcc -DCMAKE_CUDA_HOST_COMPILER=${CXX}"

    # Create symlinks of cublas headers into CONDA_PREFIX
    mkdir -p $CONDA_PREFIX/include
    find /usr/include -name cublas*.h -exec ln -s "{}" "$CONDA_PREFIX/include/" ';'
    export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include -I${CUDA_HOME}/include -I${CONDA_PREFIX}/include"

    if [[ "${ARCH}" == 'ppc64le' ]]
    then 
        CUDA_COMPUTE_CABABILITY="6.0 7.0 7.5"
    else
        CUDA_COMPUTE_CABABILITY="6.0 6.1 7.0 7.5"
    fi

    CUDA_VERSION="${cudatoolkit%.*}"
    if [[ $CUDA_VERSION == '11' ]]; then
        CUDA_COMPUTE_CABABILITY+=' 8.0'
    fi
    export CUDA_COMPUTE_CABABILITY
fi

if [[ $mpi_type != None ]]
then
    BUILD_OPTION+=" -DUSE_MPI=ON"
fi

echo $BUILD_OPTION

cmake .. $BUILD_OPTION -DCMAKE_INSTALL_PREFIX=$PREFIX 
make -j${CPU_COUNT}
make install
cd ..
