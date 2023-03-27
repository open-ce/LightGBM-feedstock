#!/bin/bash
# *****************************************************************
# (C) Copyright IBM Corp. 2020, 2023. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# *****************************************************************

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

    CUDA_COMPUTE_CAPABILITY=${cuda_levels//,/ }
    # LightGBM doesn't work with cuda capability 3.7. So, removing it.
    export CUDA_COMPUTE_CAPABILITY=${CUDA_COMPUTE_CAPABILITY//3.7 /}
    echo $CUDA_COMPUTE_CABABILITY
   
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
