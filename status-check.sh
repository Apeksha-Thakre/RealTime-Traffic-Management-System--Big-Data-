#!/bin/bash

echo "===== JVM Services (jps) ====="
jps

echo -e "\n===== Hadoop HDFS Check ====="
hdfs dfsadmin -report | grep 'Live datanodes' || echo "HDFS not running"

echo -e "\n===== Kafka Topic List ====="
~/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092 || echo "Kafka not running or topic list failed"

echo -e "\n===== Producer Log (last 5 lines) ====="
tail -n 5 ~/traffic/producer.log 2>/dev/null || echo "Producer log not found"

echo -e "\n===== Spark Job Running? ====="
ps aux | grep -v grep | grep spark-submit || echo "No active spark-submit process"

echo -e "\n===== HDFS Output Directory ====="
hdfs dfs -ls /traffic/aggregated || echo "No data found in /traffic/aggregated"

echo -e "\n===== Done ====="