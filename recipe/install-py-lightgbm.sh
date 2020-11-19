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
