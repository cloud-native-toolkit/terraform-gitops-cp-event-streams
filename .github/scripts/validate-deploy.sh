#!/usr/bin/env bash

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

export KUBECONFIG=$(cat .kubeconfig)
NAMESPACE=$(cat .namespace)
COMPONENT_NAME="$(jq -r '.name // "my-module"' gitops-output.json)"
BRANCH=$(jq -r '.branch // "main"' gitops-output.json)
SERVER_NAME=$(jq -r '.server_name // "default"' gitops-output.json)
LAYER=$(jq -r '.layer_dir // "2-services"' gitops-output.json)
TYPE=$(jq -r '.type // "base"' gitops-output.json)

mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

if [[ ! -f "argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml" ]]; then
  echo "ArgoCD config missing - argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"
  exit 1
fi

echo "Printing argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"
cat "argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"

if [[ ! -f "payload/${LAYER}/namespace/${NAMESPACE}/${COMPONENT_NAME}/values.yaml" ]]; then
  echo "Application values not found - payload/${LAYER}/namespace/${NAMESPACE}/${COMPONENT_NAME}/values.yaml"
  exit 1
fi

echo "Printing payload/${LAYER}/namespace/${NAMESPACE}/${COMPONENT_NAME}/values.yaml"
cat "payload/${LAYER}/namespace/${NAMESPACE}/${COMPONENT_NAME}/values.yaml"

count=0
until kubectl get namespace "${NAMESPACE}" 1> /dev/null 2> /dev/null || [[ $count -eq 20 ]]; do
  echo "Waiting for namespace: ${NAMESPACE}"
  count=$((count + 1))
  sleep 15
done

if [[ $count -eq 20 ]]; then
  echo "Timed out waiting for namespace: ${NAMESPACE}"
  exit 1
else
  echo "Found namespace: ${NAMESPACE}. Sleeping for 30 seconds to wait for everything to settle down"
  sleep 30
fi

count=0
CR="eventstreams/${COMPONENT_NAME}"
until kubectl get "${CR}" -n "${NAMESPACE}" || [[ $count -eq 20 ]]; do
  echo "Waiting for ${CR} in ${NAMESPACE}"
  count=$((count + 1))
  sleep 30
done

if [[ $count -eq 20 ]]; then
  echo "Timed out waiting for ${CR} in ${NAMESPACE}"
  kubectl get eventstreams -n "${NAMESPACE}"
  exit 1
fi

EVENT_STREAMS_CRD="eventstreams.eventstreams.ibm.com"
TIMEOUT=60
count=0
DESIRED_STATE="Ready"

until [[ $(kubectl get ${EVENT_STREAMS_CRD}  -n  ${NAMESPACE} -o jsonpath="{range .items[*]}{.status.phase}{end}") == ${DESIRED_STATE} ||  $count -eq ${TIMEOUT} ]]; do
  echo "Waiting for ibm-event-streams ${EVENT_STREAMS_CRD} to come up in ${NAMESPACE}"
  count=$((count + 1))
  sleep 60
done

if [[ $count -eq 20 ]]; then
  echo "Timed out waiting for ${EVENT_STREAMS_CRD} in ${NAMESPACE}"
  kubectl get all -n "${NAMESPACE}"
  exit 1
else
  echo "Found an instances of ibm-event-streams ${EVENT_STREAMS_CRD} in a Running state in ${NAMESPACE}"
fi

cd ..
rm -rf .testrepo
