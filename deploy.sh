#!/bin/bash

# Initialize
source .env
source logger.sh

log "Starting deploying the logstash-kibana alerting"
# Check if connector exists
log "Create the kibana index connector for alerting rules if missing"

connector_response=`curl --header "Authorization: $API_KEY" ${KIBANA_ROOT_URL}/api/actions/connectors -s| jq ".[] | select(.name==\"$CONNECTOR_NAME\")"`

# If no connector found by name - create it
if [ -z "${connector_response}" ]
then
    log "Connector is missing. Creating $CONNECTOR_NAME"
    connector_response=`curl -s --location --request POST "${KIBANA_ROOT_URL}/api/actions/connector" \
    --header "Authorization: $API_KEY" \
    --header 'kbn-xsrf: true' \
    --header 'Content-Type: application/json' \
    --data "{
        \"name\": \"$CONNECTOR_NAME\",
        \"connector_type_id\": \".index\",
        \"config\": {
            \"index\": \"$INDEX_NAME\"
        }
    }"`
    if [ $? -ne 0 ];
    then
        log "Failed to create connector $CONNECTOR_NAME" "ERROR"
        exit 1
    fi
fi
connector_id=`echo $connector_response  | jq -r ".id"`

log "Connector exists"
log "Connector_name: $CONNECTOR_NAME, Connector_id: $connector_id"

# Deploying logstash
LOGSTASH_NAMESPACE=${LOGSTASH_NAMESPACE:-logstash}
log "Deploying logstash with elasticsearch input and microsoft teams output"
helm repo add elastic https://helm.elastic.co
helm upgrade --install  logstash --version 7.17.3 -n ${LOGSTASH_NAMESPACE} --create-namespace elastic/logstash -f values.yaml -f configs/logstash.conf -f configs/logstash.yml

if [ $? -ne 0 ];
then
    log "Failed to upgrade logstash release" "ERROR"
    exit 1
fi

log "Logstash release upgraded."
log "Pipeline is ready for alerting."
log "Create new alerts as instructed in repository's README"




