#!/bin/bash
auth="admin:admin"
PROGNAME=$(basename "$0")
bIsStreamingEnabled="0"
recorderHostName=''
recorderPort=443
recorderKey=''
eRecordingLayout='0'
if [ "$#" -eq 1 ]; then
    ipFile=$1
elif [ "$#" -eq 2 ]; then
    auth="admin:${1}"
    ipFile=$2
else
    echo "USAGE: setSipDetails [auth] ipFile"
    echo "auth: specify username and password when non default (admin:admin) include the colon to separate the username from the password"
    echo "ipFile: specify filename with list of IPs"
    exit 1
fi
sed -e :a -e '/^\n*$/{$d;N;};/\n$/ba' $ipFile > temp
while IFS="" read -r line || [ -n "$line" ]
do
 ip=$line
 echo "AUTH is ${auth}"
 b64auth=$(echo -n ${auth} | base64)
 echo "IP is ${ip}"

 session=$( curl -s -H "Authorization: LSBasic ${b64auth}" -H "Content-Type: application/json" http://$ip/rest/new | awk -F\" '/session/ { print $4 }' 2> /dev/null )
# echo "SESSION is ${session}"

curl -H "Authorization: LSBasic ${b64auth}" -H "Content-Type: application/json" --data "{\"call\":\"Comm_setStreamingRecordingDetails\",\"params\":{\"pDetails\":{\"bIsStreamingEnabled\":${bIsStreamingEnabled},\"recorderHostName\":\"${recorderHostName}\",\"recorderPort\":\"${recorderPort}\",\"recorderKey\":\"${recorderKey}\",\"eRecordingLayout\":\"${eRecordingLayout}\"}}}" http://${ip}/rest/request/${session} 
done <"temp"
rm temp
