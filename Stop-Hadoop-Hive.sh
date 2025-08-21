#!/bin/bash

# Author: Hitesh
# This script stops, HiveMetastore service, Hadoop services (Hdfs and YARN)
# Prerequisit is that this file should be in same directory as that of run-hdfs.sh & run-yarn.sh & run-hivemetastore.sh
# Usage: ./Stop-Hadoop-Hive.sh

~/run-hivemetastore.sh -s stop
echo "-----Hive Stopped-----"

~/run-yarn.sh -s stop
echo "-----YARN Stopped-----"

~/run-hdfs.sh -s stop
echo "-----HDFS Stopped-----"
echo "-----HADOOP Stopped-----"

jps

