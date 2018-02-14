#!/bin/bash
cryptogen generate --config=./crypto-config.yaml
export FABRIC_CFG_PATH=$PWD
configtxgen -profile ComposerOrdererGenesis -outputBlock ./composer-genesis.block
configtxgen -profile ComposerChannel -outputCreateChannelTx ./composer-channel.tx -channelID composerchannel
configtxgen -profile Channel1 -outputCreateChannelTx ./channel1.tx -channelID channel1
configtxgen -profile Channel2 -outputCreateChannelTx ./channel2.tx -channelID channel2
configtxgen -profile Channel3 -outputCreateChannelTx ./channel3.tx -channelID channel3
configtxgen -profile Channel4 -outputCreateChannelTx ./channel4.tx -channelID channel4
configtxgen -profile Channel5 -outputCreateChannelTx ./channel5.tx -channelID channel5
configtxgen -profile Channel6 -outputCreateChannelTx ./channel6.tx -channelID channel6
configtxgen -profile Channel7 -outputCreateChannelTx ./channel7.tx -channelID channel7
