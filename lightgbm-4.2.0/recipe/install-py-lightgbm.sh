#!/bin/bash
# *****************************************************************
# (C) Copyright IBM Corp. 2020, 2024. All Rights Reserved.
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

INSTALL_OPTION=""

if [[ $ppc_arch == "p10" ]]
then
    if [[ -z "${GCC_HOME}" ]];
    then
	echo "Please set GCC_HOME to the install path of gcc-toolset-12"
        exit 1
    else
        export PATH=$GCC_HOME/bin:$PATH
        export CC=$GCC_HOME/bin/gcc
        export CXX=$GCC_HOME/bin/g++
    fi
fi

if [[ $build_type == "cuda" ]]
then
    INSTALL_OPTION="--cuda "
fi

if [[ $mpi_type != None ]]
then
    INSTALL_OPTION+="--mpi"
fi

echo $INSTALL_OPTION

${SRC_DIR}/build-python.sh bdist_wheel $INSTALL_OPTION
pip install ${SRC_DIR}/dist/lightgbm-${PKG_VER}*.whl --no-deps

#remove the extra dependencies getting installed by the line - https://github.com/microsoft/LightGBM/blob/v4.2.0/build-python.sh#L189
SYS_PYTHON_MAJOR=$(python -c "import sys;print(sys.version_info.major)")
SYS_PYTHON_MINOR=$(python -c "import sys;print(sys.version_info.minor)")
rm -rf $PREFIX/lib/python${SYS_PYTHON_MAJOR}.${SYS_PYTHON_MINOR}/site-packages/pyproject_hooks*
rm -rf $PREFIX/lib/python${SYS_PYTHON_MAJOR}.${SYS_PYTHON_MINOR}/site-packages/build*
rm -rf $PREFIX/lib/python${SYS_PYTHON_MAJOR}.${SYS_PYTHON_MINOR}/site-packages/packaging*
if [[ "${SYS_PYTHON_MINOR}" -eq '10' ]]; then
  rm -rf $PREFIX/lib/python${SYS_PYTHON_MAJOR}.${SYS_PYTHON_MINOR}/site-packages/tomli*
fi
