source .env.sh

# Utility functions
check_service () {
	echo -ne '\n'
	echo $1 $ELASTIC_VERSION must be available on $2
	echo -ne "Waiting for $1"

	until curl -u elastic:$ELASTIC_PASSWORD -s "$2" | grep "$3" > /dev/null; do
		  sleep 1
			echo -ne '.'
	done

	echo -ne '\n'
	echo $1 is now up.
}

# Curl Post call Param 1 is the Full URL, Param 2 is a json file, Param 3 is optional text
# 
curl_post_form () {
	if [ -z "$3" ] ; then
		echo "Calling POST FORM $1"
	else 
	  echo $3
	fi
  curl -XPOST "$1" -u elastic:$ELASTIC_PASSWORD -H 'kbn-xsrf: true' --form file="@$2" ; echo
}

# Upload component template
#upload_component_template () {
#	echo Uploading component template $1
#	curl -XPUT "$ELASTICSEARCH_URL/_component_template/$1" -u elastic:$ELASTIC_PASSWORD -H 'Content-Type: application/json' -d"@elasticsearch-config/component-$1.json" ; echo
#}

# Upload index template
#upload_index_template () {
#	echo Uploading index template $1
#	curl -XPUT "$ELASTICSEARCH_URL/_index_template/$1" -u elastic:$ELASTIC_PASSWORD -H 'Content-Type: application/json' -d"@elasticsearch-config/template-$1.json" ; echo
#}

# Start of the script
echo Installation script for Index Templates V2 demo with Elastic $ELASTIC_VERSION

echo "##################"
echo "### Pre-checks ###"
echo "##################"

if [ -z "$CLOUD_ID" ] ; then
	echo "We are running a local demo. If you did not start Elastic yet, please run:"
	echo "docker-compose up"
fi

check_service "Elasticsearch" "$ELASTICSEARCH_URL" "\"number\" : \"$ELASTIC_VERSION\""
check_service "Kibana" "$KIBANA_URL/app/home#/" "<title>Elastic</title>"

echo -ne '\n'
echo "################################"
echo "### Configure Cloud Services ###"
echo "################################"
echo -ne '\n'

echo Remove existing test* templates
curl -XDELETE "$ELASTICSEARCH_URL/_index_template/test*" -u elastic:$ELASTIC_PASSWORD ; echo

echo Remove existing test-* component templates
curl -XDELETE "$ELASTICSEARCH_URL/_component_template/test-*" -u elastic:$ELASTIC_PASSWORD ; echo

echo Remove existing test* indices
curl -XDELETE "$ELASTICSEARCH_URL/test*" -u elastic:$ELASTIC_PASSWORD ; echo

#echo Define component templates
#upload_component_template test-settings-1shard
#upload_component_template test-settings-5shards
#ipload_component_template test-settings-noreplica
#upload_component_template test-settings-1replica
#upload_component_template test-mapping-complex
#upload_component_template test-mapping-timestamp
#upload_component_template test-mapping-ip
#upload_component_template test-alias

#echo Define index templates
#upload_index_template test-simple
#upload_index_template test-overwrite

echo -ne '\n'
echo "#############################"
echo "### Install Canvas Slides ###"
echo "#############################"
echo -ne '\n'

curl_post_form "$KIBANA_URL/api/saved_objects/_import?overwrite=true" "kibana-config/canvas.ndjson"

echo -ne '\n'
echo "#####################"
echo "### Demo is ready ###"
echo "#####################"
echo -ne '\n'

open "$KIBANA_URL/app/canvas#/"

echo "If not yet there, paste the following script in Dev Tools:"
cat elasticsearch-config/devtools-script.json
echo -ne '\n'


