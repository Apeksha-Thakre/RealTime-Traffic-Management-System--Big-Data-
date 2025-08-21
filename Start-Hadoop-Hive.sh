#!/bin/bash

# Author: Hitesh
# This script starts the HiveMetastore service, Hadoop services (Hdfs and YARN)
# Prerequisit is that this file should be in same directory as that of run-hdfs.sh & run-yarn.sh
# It aslo creates home directory for Hadoop at /user/talentum/ as well as Hive warehouse.
# Usage: ./Start-Hadoop-Hive.sh

[ -d "/tmp/hadoop-talentum/dfs/data/current" ] && rm -r /tmp/hadoop-talentum/dfs/data/current

[ -d "/tmp/hadoop-talentum/dfs/name/current" ] && rm -r /tmp/hadoop-talentum/dfs/name/current

[ -d "/tmp/hadoop-talentum/dfs/namesecondary/current" ] && rm -r /tmp/hadoop-talentum/dfs/namesecondary/current

hdfs namenode -format

~/run-hdfs.sh -s start
echo "-----Running HDFS-----"

~/run-yarn.sh -s start
echo "-----Running YARN-----"
echo "-----Running HADOOP-----"

hdfs dfs -mkdir -p /user/talentum/

hdfs dfs -mkdir -p /user/hive/warehouse/

echo "-----Running Hive-----"
~/run-hivemetastore.sh -s start&>/dev/null

jps
