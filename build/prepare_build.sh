#!/bin/bash
ASCNED_TYPE=910 #根据芯片类型选择310或910。
ASCNED_INSTALL_PATH=/usr/local/Ascend  #驱动安装路径，根据实际修改。
USE_ASCEND_DOCKER=false  #是否使用昇腾Docker，请修改为false。

CUR_DIR=$(dirname $(readlink -f $0))
TOP_DIR=$(realpath ${CUR_DIR}/..)

LD_LIBRARY_PATH_PARA1=${ASCNED_INSTALL_PATH}/driver/lib64/driver
LD_LIBRARY_PATH_PARA2=${ASCNED_INSTALL_PATH}/driver/lib64
apt-get install -y pkg-config
apt-get install -y dos2unix
TYPE=Ascend910
PKG_PATH=${TOP_DIR}/src/plugin/config/config_910
PKG_PATH_STRING=\$\{TOP_DIR\}/src/plugin/config/config_910
LIBDRIVER="driver/lib64/driver"

if [ ${ASCNED_TYPE} == "310"  ]; then
  TYPE=Ascend310
  LD_LIBRARY_PATH_PARA1=${ASCNED_INSTALL_PATH}/driver/lib64
  PKG_PATH=${TOP_DIR}/src/plugin/config/config_310
  PKG_PATH_STRING=\\$\\{TOP_DIR\\}/src/plugin/config/config_310
  LIBDRIVER="/driver/lib64"
fi
sed -i "s/Ascend[0-9]\\{3\\}/${TYPE}/g" ${TOP_DIR}/ascendplugin.yaml
sed -i "s#ath: /usr/local/Ascend/driver#ath: ${ASCNED_INSTALL_PATH}/driver#g" ${TOP_DIR}/ascendplugin.yaml
sed -i "/^ENV LD_LIBRARY_PATH /c ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH_PARA1}:${LD_LIBRARY_PATH_PARA2}/common" ${TOP_DIR}/Dockerfile
sed -i "/^ENV USE_ASCEND_DOCKER /c ENV USE_ASCEND_DOCKER ${USE_ASCEND_DOCKER}" ${TOP_DIR}/Dockerfile
sed -i "/^libdriver=/c libdriver=$\\{prefix\\}/${LIBDRIVER}" ${PKG_PATH}/ascend_device_plugin.pc
sed -i "/^prefix=/c prefix=${ASCNED_INSTALL_PATH}" ${PKG_PATH}/ascend_device_plugin.pc
sed -i "/^CONFIGDIR=/c CONFIGDIR=${PKG_PATH_STRING}" ${CUR_DIR}/build_in_docker.sh
