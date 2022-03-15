#!/bin/sh
# Installs Softhsm for Kernel and Ida
## Usage: ./install.sh [kubeconfig]


if [ $# -ge 1 ] ; then
  export KUBECONFIG=$1
fi

NS=softhsm
STORAGE_CLASS=gp2
CHART_VERSION=1.2.0

echo Create $NS namespaces
kubectl create ns $NS

echo Istio label
kubectl label ns $NS istio-injection=enabled --overwrite
helm repo update

echo Installing Softhsm for Kernel
helm -n $NS install softhsm-kernel mosip/softhsm --set persistence.storageClass=$STORAGE_CLASS -f values.yaml --version $CHART_VERSION
echo Installed Softhsm for Kernel

echo Installing Softhsm for IDA
helm -n $NS install softhsm-ida mosip/softhsm --set persistence.storageClass=$STORAGE_CLASS -f values.yaml --version $CHART_VERSION
echo Installed Softhsm for IDA
