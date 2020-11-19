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
    BUILD_OPTION="-DUSE_CUDA=ON -DCMAKE_CUDA_COMPILER=${CUDA_HOME}/bin/nvcc -DCMAKE_C_COMPILER=${GCC} -DCMAKE_CXX_COMPILER=${GXX} -DCMAKE_CUDA_HOST_COMPILER=${CXX}"

    # Create symlinks of cublas headers into CONDA_PREFIX
    mkdir -p $CONDA_PREFIX/include
    find /usr/include -name cublas*.h -exec ln -s "{}" "$CONDA_PREFIX/include/" ';'
    export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include -I${CUDA_HOME}/include -I${CONDA_PREFIX}/include"

    if [[ "${ARCH}" == 'ppc64le' ]]
    then 
        export CUDA_ARCH_FLAGS="3.7 6.0 7.0 7.5 8.0"
    else
        export CUDA_ARCH_FLAGS="3.7 5.2, 6.0 6.1 7.0 7.5 8.0"
    fi
    
fi

if [[ $mpi_type == 'openmpi' ]]
then
    BUILD_OPTION+=" -DUSE_MPI=ON"
fi

echo $BUILD_OPTION

cmake .. $BUILD_OPTION -DCMAKE_INSTALL_PREFIX=$PREFIX 
make
make install
cd ..
