#!/bin/bash

# Exit on first error, print all commands.
set -ev

#Detect architecture
ARCH=`uname -m`

# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#

ARCH=$ARCH docker-compose -f "${DIR}"/composer/docker-compose.yml down
ARCH=$ARCH docker-compose -f "${DIR}"/composer/docker-compose.yml up -d

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}

# Create the channel
docker exec peer0.org1.example.com peer channel create -o orderer.example.com:7050 -c composerchannel -f /etc/hyperledger/configtx/composer-channel.tx

# Join peer0.org1.example.com to the channel.
docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel join -b composerchannel.block


function createChannel() {
    # Create the channel
    # $1 = org number
    # $2 = channel number
    echo "docker exec peer0.org$1.example.com peer channel create -o orderer.example.com:7050 -c channel$2 -f /etc/hyperledger/configtx/composer-channel$2.tx"
    docker exec peer0.org$1.example.com peer channel create -o orderer.example.com:7050 -c channel$2 -f /etc/hyperledger/configtx/channel$2.tx

}

function joinChannel() {
    # $1 = org number
    # $2 = channel number
    # Join peer0.org1.example.com to the channel.
    echo "docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org$1.example.com/msp" peer0.org$1.example.com peer channel join -b channel$2.block"
    docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org$1.example.com/msp" peer0.org$1.example.com peer channel join -b channel$2.block

}

#array of channel names
CHANNELS=("1" "2" "3" "4" "5" "6" "7")

#Participants in channel as per channel index. 1st row is for channel1 , 2nd for channel2 and so on.
CHANNEL_PARTICIPANTS=("1 4 5 7 8"  "2 4 5 7 8" "1 2 5 7" "1 2 4 5 7" "1 2 5 7 8" "3 4 5 7 8" "6 8")

echo "starting channel creation"

createChannel 1 1
createChannel 2 2
createChannel 5 3
createChannel 4 4
createChannel 7 5
createChannel 3 6
createChannel 6 7


for INDEX in ${!CHANNEL_PARTICIPANTS[*]}; do 
    for PARTICIPANT in ${CHANNEL_PARTICIPANTS[$INDEX]}; do 
        CHANNEL_NUM=$(($INDEX+1))
        joinChannel $PARTICIPANT $CHANNEL_NUM
    done
done

echo "completed channel creation"