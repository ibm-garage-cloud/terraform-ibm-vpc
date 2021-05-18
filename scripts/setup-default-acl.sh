#!/usr/bin/env bash

## Currently the IBM terraform provider does not have a resource to add or remove rules from an ACL.
## This script uses the IBM Cloud cli to remove the existing rules from the existing ACL and adds a locked down
## set of rules

ACL_ID="$1"
REGION="$2"
RESOURCE_GROUP="$3"

ibmcloud login --apikey "${IBMCLOUD_API_KEY}" -r "${REGION}" -g "${RESOURCE_GROUP}" --quiet

# Install jq if not available

echo "Deleting existing rules"
ibmcloud is network-acl "${ACL_ID}" --output JSON | \
  jq -c '.rules[]'

ibmcloud is network-acl "${ACL_ID}" --output JSON | \
  jq -r '.rules[].id' | \
  while read rule_id;
do
  echo y | ibmcloud is network-acl-rule-delete "${ACL_ID}" "${rule_id}"
done

ibmcloud is network-acl-rule-add "${ACL_ID}" allow inbound all 10.0.0.0/8 10.0.0.0/8 --name allow-internal-ingress
ibmcloud is network-acl-rule-add "${ACL_ID}" allow outbound all 10.0.0.0/8 10.0.0.0/8 --name allow-internal-egress

ibmcloud is network-acl-rule-add "${ACL_ID}" deny inbound tcp 0.0.0.0/0 0.0.0.0/0 --name deny-external-ssh --source-port-min 22 --source-port-max 22 --destination-port-min 22 --destination-port-max 22
ibmcloud is network-acl-rule-add "${ACL_ID}" deny inbound tcp 0.0.0.0/0 0.0.0.0/0 --name deny-external-rdp --source-port-min 3389 --source-port-max 3389 --destination-port-min 3389 --destination-port-max 3389
ibmcloud is network-acl-rule-add "${ACL_ID}" deny inbound all 0.0.0.0/0 0.0.0.0/0 --name deny-external-ingress
