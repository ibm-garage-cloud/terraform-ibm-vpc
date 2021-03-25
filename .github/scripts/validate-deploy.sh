#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

echo "terraform.tfvars"
cat terraform.tfvars

PREFIX_NAME=$(cat terraform.tfvars | grep prefix_name | sed "s/prefix_name=//g" | sed 's/"//g')
PUBLIC_GATEWAY=$(cat terraform.tfvars | grep public_gateway | sed "s/public_gateway=//g" | sed 's/"//g')
REGION=$(cat terraform.tfvars | grep region | sed "s/region=//g" | sed 's/"//g')
RESOURCE_GROUP_NAME=$(cat terraform.tfvars | grep resource_group_name | sed "s/resource_group_name=//g" | sed 's/"//g')

echo "PREFIX_NAME: ${PREFIX_NAME}"
echo "PUBLIC_GATEWAY: ${PUBLIC_GATEWAY}"
echo "REGION: ${REGION}"
echo "RESOURCE_GROUP_NAME: ${RESOURCE_GROUP_NAME}"
echo "IBMCLOUD_API_KEY: ${IBMCLOUD_API_KEY}"

VPC_NAME="${PREFIX_NAME}-vpc"

ibmcloud login -r "${REGION}" -g "${RESOURCE_GROUP_NAME}" --apikey "${IBMCLOUD_API_KEY}"

echo "Retrieving VPC_ID for name: ${VPC_NAME}"
VPC_ID=$(ibmcloud is vpcs | grep "${VPC_NAME}" | sed -E "s/^([A-Za-z0-9-]+).*/\1/g")

if [[ -z "${VPC_ID}" ]]; then
  echo "VPC id not found: ${VPC_NAME}"
  exit 1
fi

echo "Retrieving VPC info for id: ${VPC_ID}"
if ! ibmcloud is vpc "${VPC_ID}"; then
  echo "Unable to find vpc for id: ${VPC_ID}"
  exit 1
fi

echo "Retrieving VPC subnets for VPC: ${VPC_NAME}"
SUBNETS=$(ibmcloud is subnets | grep "${VPC_NAME}")

if [[ -z "${SUBNETS}" ]]; then
  echo "Subnets not found: ${VPC_NAME}"
  exit 1
fi

echo "Retrieving public gateways for VPC: ${VPC_NAME}"
ibmcloud is pubgws | grep "${VPC_NAME}"
PGS=$(ibmcloud is pubgws | grep "${VPC_NAME}")

if [[ "${PUBLIC_GATEWAY}" == "true" ]] && [[ -z "${PGS}" ]]; then
  echo "Public gateways not found: ${VPC_NAME}"
  exit 1
elif [[ "${PUBLIC_GATEWAY}" == "false" ]] && [[ -n "${PGS}" ]]; then
  echo "Public gateways found: ${VPC_NAME}"
  exit 1
fi

exit 0
