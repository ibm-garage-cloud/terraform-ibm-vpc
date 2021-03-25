#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

source terraform.tfvars

PREFIX_NAME="${prefix_name}"
PUBLIC_GATEWAY="${public_gateway}"

VPC_NAME="${PREFIX_NAME}-vpc"

ibmcloud login -r "${region}" -g "${resource_group_name}" --apikey "${ibmcloud_api_key}"

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
