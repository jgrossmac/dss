#!/bin/bash
jq --version > /dev/null
if [ $? -ne 0 ]; then
  echo "This script requires the jq utility.  On Debian Linux, install with"
  echo "  sudo apt-get install jq"
  exit 1
fi

# Retrieve token from dummy OAuth server
export ACCESS_TOKEN=`curl --silent -X POST \
  "http://localhost:8085/token?grant_type=client_credentials&scope=dss.read.identification_service_areas&intended_audience=localhost&issuer=localhost" \
  | jq -r '.access_token'`

# Retrieve Identification Service Areas currently active on Mauna Loa
echo "DSS response to Mauna Loa ISA query:"
echo "============="
export TIMESTAMP_NOW=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
curl --silent -X GET \
  "http://localhost:8082/v1/dss/identification_service_areas?area=19.4763,-155.6043,19.4884,-155.5746,19.4516,-155.5941&earliest_time=${TIMESTAMP_NOW}&latest_time=${TIMESTAMP_NOW}" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}"
echo
echo "============="
echo "See https://tiny.cc/dssapi_rid for a more complete DSS API description."
echo
