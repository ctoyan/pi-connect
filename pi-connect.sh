#!/bin/bash

#CONFIGURATION
APIKEY="WeavedDemoKey\$2015"
USERNAME="your@email.com"

echo "[-] Please enter your password: "
read -s PASSWORD

#CONSTRUCT API URLS
APIURL="https://api.weaved.com/v22/api"
loginURL="${APIURL}/user/login/${USERNAME}/${PASSWORD}"
deviceListURL="${APIURL}/device/list/all"
deviceConnectURL="${APIURL}/device/connect"

handleError() {
    requestStatus=$(echo $1 | jq -r '.status')
    if [ $requestStatus = false ]
    then
        echo $1 | jq -r '.reason'
        exit
    fi
}

connectToDevice() {
    deviceAlias=$(echo $1 | jq -r --arg chosenDeviceNumer $2 '.devices[$chosenDeviceNumer | tonumber].devicealias')
    deviceAddress=$(echo $1 | jq -r --arg chosenDeviceNumer $2 '.devices[$chosenDeviceNumer | tonumber].deviceaddress')
    echo "[*] Connecting to \"$deviceAlias\""

    deviceConnectResponse=$(curl -s -S -X POST -H "content-type:application/json" -H "apikey:${APIKEY}" -H "token:${token}" --data '{"deviceaddress":"'"$deviceAddress"'","wait":"true"}' $deviceConnectURL)
    handleError "$deviceConnectResponse"

    sshInfo=($(echo $deviceConnectResponse | jq -r '.connection.proxy' | egrep -o '[^://]+'))
    host=${sshInfo[1]}
    port=${sshInfo[2]}

    printf "[-] Login as: "
    read sshUsername
    ssh $sshUsername@$host -p $port
}

#LOGIN AND GET TOKEN
echo "[*] Logging in..."
loginResponse=$(curl -s -S -X GET -H "content-type:application/json" -H "apikey:${APIKEY}" $loginURL)
handleError "$loginResponse"
token=$(echo $loginResponse | jq -r '.token')

#GET ALL DEVICES
echo "[*] Listing devices..."
devicesListResponse=$(curl -s -S -X GET -H "content-type:application/json" -H "apikey:${APIKEY}" -H "token:${token}" $deviceListURL)
handleError "$devicesListResponse"

numberOfDevices=$(echo $devicesListResponse | jq '.devices | length')

if [ "$numberOfDevices" -gt 1 ]
then
    printf "\n%-2s | %-25s | %-23s |  %-10s \n" "#" "Device Name" "Device Address" "Device State"
    echo "----------------------------------------------------------------------------"
    for ((n=0;n<$numberOfDevices;n++))
    do
        deviceName=$(echo $devicesListResponse | jq -r --arg n $n '.devices[$n | tonumber].devicealias')
        deviceAddress=$(echo $devicesListResponse | jq -r --arg n $n '.devices[$n | tonumber].deviceaddress')
        deviceState=$(echo $devicesListResponse | jq -r --arg n $n '.devices[$n | tonumber].devicestate')
        printf "%-2d | %-25s | %-22s |  %-10s \n" $(($n+1)) $deviceName $deviceAddress $deviceState
    done

    chosenDeviceNumber=""
    while true
    do
        printf "\n%s" "[-] Number of the device you want to connect to: "
        read chosenDeviceNumber

        if [[  $chosenDeviceNumber -gt 0 && $chosenDeviceNumber -le $numberOfDevices ]]
        then
            break
        else
            echo "Please choose a number between 1 and $numberOfDevices"
        fi
    done

    connectToDevice "$devicesListResponse" $(($chosenDeviceNumber-1))
else
    connectToDevice "$devicesListResponse" 0
fi
