#!/bin/bash

# Delete the old zookeeper config direcory
# Afterwards start zookeeper

sudo rm -r /var/zookeeper/version-2
sudo sh /var/zookeeper/zookeeper-3.3.2/bin/zkServer.sh start
