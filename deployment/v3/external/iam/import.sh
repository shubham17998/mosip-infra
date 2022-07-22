#!/bin/sh
## Point config to your cluster on which you are installing IAM with import enabled.
## "Usage: ./import.sh [kube_config_file]"

if [ $# -ge 1 ]; then
  export KUBECONFIG=$1
fi

NS=keycloak
SERVICE_NAME=keycloak

echo Creating $NS namespace
kubectl create ns $NS

echo Istio label
## TODO: enable istio injection after testing well.
kubectl label ns $NS istio-injection=disabled --overwrite
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

echo Installing
helm -n $NS install $SERVICE_NAME bitnami/keycloak --version "7.1.18" --set image.repository=mosipdev/mosip-keycloak --set image.tag=16.1.1-debian-10-r85 -f import-values.yaml --wait

EXTERNAL_HOST=$(kubectl get cm global -o jsonpath={.data.mosip-iam-external-host})
echo Install Istio gateway, virtual service
helm -n $NS install istio-addons chart/istio-addons --set keycloakExternalHost=$EXTERNAL_HOST --set keycloakInternalHost="$SERVICE_NAME.$NS" --set service=$SERVICE_NAME
