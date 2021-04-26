#!/bin/bash

while true; do

  token=$(cat /run/conjur/access-token | base64 | tr -d '\r\n')
  variable=$(curl -sk -H "Authorization: Token token=\"$token\"" "$CONJUR_APPLIANCE_URL/secrets/default/variable/my-secret")

  echo "My secret value is: $variable"

  sleep $SLEEP_INTERVAL

done