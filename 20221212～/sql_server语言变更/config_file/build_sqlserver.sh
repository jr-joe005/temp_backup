#cd sqlserver2019

LOCATION="eastasia" 
PACKER_RESOURCE_GROUP_NAME="tmp_bbx_jr"
CLIENT_ID="bdd73b92-9479-43e0-8b53-c9788826a268"
CLIENT_SECRET="Tyg8Q~krNHnJXS_hAgHfvvy6Uz5ZtK__sGyFfbZp"
SUBSCRIPTION_ID="175a7e6a-b55c-444d-8c29-292664b18361"
TENANT_ID="ac52665e-dc68-41b8-a597-4f1f1c70ad7a"
DATE_STRING=$(date +%Y-%m-%d-%H%M)

packer build \
-var resource_group_name=$PACKER_RESOURCE_GROUP_NAME \
-var client_id=$CLIENT_ID \
-var client_secret=$CLIENT_SECRET \
-var subscription_id=$SUBSCRIPTION_ID \
-var tenant_id=$TENANT_ID \
-var date_string=$DATE_STRING \
-var location=$LOCATION \
-force packer_windows_server_2019_sql_2019.pkr.hcl