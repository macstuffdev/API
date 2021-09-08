#!/usr/bin/env bash

# Script to delete all the attachment on a single device.
#
# Will delete from 1 till 450 with a sleep to keep the server from being overloaded.

# --------------    edit the variables below this line    ----------------

# API username
username=""

# API password
password=""

# JSS URL without trailing slash
jamfProURL="https://url.jamfcloud.com"

# Device ID (Example where to find: https://URL.jamfcloud.com/computers.html?id=2523&o=r) ID 2523 in example.
deviceID="2227"

# ------------------  do not edit below this line  -------------------

# Create base64-encoded credentials
encodedCredentials=$( printf "${username}:${password}" | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i - )

# Generate an authorization bearer token
authToken=$( /usr/bin/curl "${jamfProURL}/uapi/auth/tokens" --silent --request POST --header "Authorization: Basic ${encodedCredentials}" )

# Clean up token to omit expiration details
token=$( /usr/bin/awk -F \" '{ print $4 }' <<< "${authToken}" | /usr/bin/xargs )

# Start deletion loop (adjust 450 to desired amount)
for attachmentId in {1..450}
  do
    # Wait 1 second to prevent the server from overloading
  sleep 1
  # Delete attachement
  curl -X DELETE "${jamfProURL}/api/v1/computers-inventory/${deviceID}/attachments/${attachmentId}" -H "accept: */*" -H "Authorization: Bearer ${token}"
done

# Expire our authorization token
curl "${jamfProURL}/uapi/auth/invalidateToken" \
--silent \
--request POST \
--header "Authorization: Bearer ${token}"

exit 1
