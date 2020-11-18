#!/bin/bash

LIBDIR=${PREFIX}/lib
INCDIR=${PREFIX}/include
BINDIR=${PREFIX}/bin
SODIR=${LIBDIR}

mkdir -p ${SRC_DIR}/build
cd ${SRC_DIR}/build

#CMAKE_CUDA_FLAGS: -Xcompiler=-fopenmp -Xcompiler=-fPIC -Xcompiler=-Wall -gencode arch=compute_60,code=sm_60 -gencode arch=compute_61,code=sm_61 -gencode arch=compute_62,code=sm_62 -gencode arch=compute_70,code=sm_70 -gencode arch=compute_75,code=sm_75 -gencode arch=compute_75,code=compute_75 -O3 -lineinfo

BUILD_OPTION=""
if [[ $build_type == "cuda" ]]
then
    BUILD_OPTION="-DUSE_CUDA=ON "
    if [[ "${ARCH}" == 'ppc64le' ]]
    then 
        export CUDA_ARCH_FLAGS="3.7 6.0 7.0 7.5 8.0"
    else
        export CUDA_ARCH_FLAGS="3.7 5.2, 6.0 6.1 7.0 7.5 8.0"
    fi
fi

#if [[ $mpi_type == 'openmpi' ]]
#then
#    BUILD_OPTION+="-DUSE_MPI=ON"
#fi

cmake .. $BUILD_OPTION
make
make install
cd ..
