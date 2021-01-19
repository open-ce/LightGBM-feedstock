#!/bin/bash
# *****************************************************************
# (C) Copyright IBM Corp. 2020, 2021. All Rights Reserved.
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

pushd ${SRC_DIR}/python-package
export CMAKE_PREFIX_PATH=$PREFIX
export CMAKE_LIBRARY_PATH=$PREFIX/lib:$BUILD_PREFIX/lib:$CMAKE_LIBRARY_PATH

INSTALL_OPTION=""

if [[ $build_type == "cuda" ]]
then
    INSTALL_OPTION="--cuda "
    export CUDACXX=$CUDA_HOME/bin/nvcc
    export CMAKE_CUDA_HOST_COMPILER=${GXX}

    # Create symlinks of cublas headers into CONDA_PREFIX
    mkdir -p $CONDA_PREFIX/include
    find /usr/include -name cublas*.h -exec ln -s "{}" "$CONDA_PREFIX/include/" ';'
    export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include -I${CUDA_HOME}/include -I${CONDA_PREFIX}/include"
fi

if [[ $mpi_type != None ]]
then
    INSTALL_OPTION+="--mpi"
fi

echo $INSTALL_OPTION

${PYTHON} setup.py install $INSTALL_OPTION
popd
