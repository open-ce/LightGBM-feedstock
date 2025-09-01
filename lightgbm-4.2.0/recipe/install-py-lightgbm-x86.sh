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
set -ex

pushd ${SRC_DIR}

export CMAKE_PREFIX_PATH=$PREFIX
export CMAKE_LIBRARY_PATH=$PREFIX/lib:$BUILD_PREFIX/lib:$CMAKE_LIBRARY_PATH

CMAKE_ARGS="-DCMAKE_INSTALL_PREFIX=$PREFIX \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_PREFIX_PATH=$PREFIX"

if [[ $build_type == "cuda" ]]; then
    CMAKE_ARGS="$CMAKE_ARGS -DUSE_CUDA=ON"

    export CUDACXX=$CUDA_HOME/bin/nvcc
    export CMAKE_CUDA_HOST_COMPILER=${GXX}

    # Make sure CUDA headers are available to cmake
    mkdir -p $CONDA_PREFIX/include
    if [ -d "$CUDA_HOME/include" ]; then
        ln -sf $CUDA_HOME/include/cublas*.h $CONDA_PREFIX/include/ || true
    fi

    export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include -I${CUDA_HOME}/include -I${CONDA_PREFIX}/include"
fi

# MPI build
if [[ $mpi_type != None ]]; then
    CMAKE_ARGS="$CMAKE_ARGS -DUSE_MPI=ON"
fi

echo "CMake configuration: $CMAKE_ARGS"

# Build and install C++ core
mkdir -p build
cd build

cmake ${SRC_DIR} $CMAKE_ARGS
cmake --build . --target _lightgbm -- -j${CPU_COUNT}
cmake --build . --target install -- -j${CPU_COUNT}

cd ..

# Now lib_lightgbm.so should exist
LIB_PATH=${PREFIX}/lib/lib_lightgbm.so
if [[ ! -f "$LIB_PATH" ]]; then
    echo "ERROR: lib_lightgbm.so not found in ${PREFIX}/lib/"
    exit 1
fi

# Copy into python package so wheel contains it
mkdir -p ${SRC_DIR}/python-package/lightgbm
cp "$LIB_PATH" ${SRC_DIR}/python-package/lightgbm/
mkdir -p ${SRC_DIR}/python-package/lightgbm/lib
cp "$LIB_PATH" ${SRC_DIR}/python-package/lightgbm/lib/
cp "$LIB_PATH" ${SRC_DIR}/python-package/

echo "Installing Python package with setuptools..."
cd python-package

# Patch pyproject.toml to avoid scikit-build-core
cat > pyproject.toml <<EOF
[build-system]
requires = ["setuptools>=42", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "lightgbm"
version = "4.2.0"
description = "LightGBM Python Package"
authors = [{ name = "Microsoft Corporation" }]
requires-python = ">=3.7"

[tool.setuptools]
include-package-data = true

[tool.setuptools.package-data]
lightgbm = ["lib_lightgbm.so","lib/*"]
EOF

# Install with setuptools
$PYTHON -m pip install . --no-build-isolation --no-deps -v

popd

