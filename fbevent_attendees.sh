#!/bin/bash

# Get user authentication key and event id
auth_key="$1"
url="$2"
event_id=`echo ${url} | egrep -o [0-9]+`

# Facebook Graph API to get attendees list
curl -i -X GET \
 "https://graph.facebook.com/v2.5/${event_id}/attending?fields=name&limit=500&summary=count&access_token=${auth_key}" > attendees.txt

# Extract data from HTTP response
tail -1 attendees.txt | python -mjson.tool > attendees.json

# Extract names from JSON 

cat <<EOF > fb.py
#!/usr/bin/python

import json
import sys

# Open JSON file
file = sys.argv[1]
print(file)

with open(file) as json_file:
    json_data = json.load(json_file)

# Open output file
fl = open("names.txt", "w+")

# Extract names
for user in json_data['data']:
    fl.write(user['name'] + "\n")

# Close output file
fl.close()

EOF

chmod 755 fb.py

./fb.py attendees.json

# Remove intermediate files
rm attendees.txt
rm attendees.json
rm fb.py