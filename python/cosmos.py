import pydocumentdb
import pydocumentdb.documents
import pydocumentdb.document_client

connection_policy = pydocumentdb.documents.ConnectionPolicy()
connection_policy.EnableEndpointDiscovery
connection_policy.PreferredLocations = ["Central US", 
                                       "East US 2", 
                                       "Southeast Asia", 
                                       "Western Europe",
                                       "Canada Central"]
master_key = 'SPSVkSfA7f6vMgMvnYdzc1MaWb65v4VQNcI2Tp1WfSP2vtgmAwGXEPcxoYra5QBHHyjDGYuHKSkguHIz1vvmWQ==' 
host = 'https://doctorwho.documents.azure.com:443/'
client = pydocumentdb.document_client.DocumentClient(host, {'masterKey': master_key}, connection_policy)
database_id = "airports"
collection_id = "codes"
db_link = "dbs/{}".format(database_id)
coll_link = "{}/colls/{}".format(db_link, collection_id)
query_string = "SELECT c.City FROM c WHERE c.State='WA'"
query = client.QueryDocuments(coll_link, query_string, options=None, partition_key=None)
for item in query:
  print(item)


