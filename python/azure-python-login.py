# https://docs.microsoft.com/en-us/python/azure/python-sdk-azure-authenticate?view=azure-python

from azure.common.credentials import get_azure_cli_credentials, ServicePrincipalCredentials
import azure.mgmt.resource
import os, sys

try:
  tenant = os.environ["AZ_AD_TENANT"]
  client_id = os.environ["AZ_AD_ID"]
  secret = os.environ["AZ_AD_PASS"]
except KeyError as ke:
  print("set the following env variables:")
  print("AZ_AD_ID")
  print("AZ_AD_TENANT")
  print("AZ_AD_PASS")
  sys.exit(1)

credentials = ServicePrincipalCredentials(
                    client_id=client_id,
                    secret=secret,
                    tenant=tenant)

subscription = get_azure_cli_credentials()[1]

new_resource_groups = ["wewewe", "ererere", "fgfgfgfg"]
res_client = azure.mgmt.resource.ResourceManagementClient(credentials, subscription)

def print_resource_group_info(res_client):
  for res_group in res_client.resource_groups.list():
    for thing in ["name", "id", "location", "tags"]:
      print("{:.<10}{}{}{}".format(thing,"{0.", thing, "}").format(res_group))
    print("."*20)

print("===============Before")
print_resource_group_info(res_client)

for new_resource_group in new_resource_groups:
  res_client.resource_groups.create_or_update(new_resource_group, {'location':'westus', 'tags':{'hello':'world'}}) 

print("===============After")
print_resource_group_info(res_client)

print("===============Cleanup")
async_deletes = []
for old_resource_group in new_resource_groups:
  async_deletes += [(old_resource_group, res_client.resource_groups.delete(old_resource_group))]

for group_name, async_delete in async_deletes:
  print("deleting: {}".format(group_name))
  async_delete.wait() 
 
print("===============After cleanup")
print_resource_group_info(res_client)

