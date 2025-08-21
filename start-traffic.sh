#!/bin/bash
set -e

TRAFFIC_DIR=~/traffic
KAFKA_DIR=~/kafka
SPARK_DIR=~/spark
HDFS_OUTPUT="/traffic/aggregated"
TOPIC="traffic_data"

echo "=== Starting Hadoop and Hive ==="
chmod +x $TRAFFIC_DIR/Start-Hadoop-Hive.sh
$TRAFFIC_DIR/Start-Hadoop-Hive.sh

echo "=== Starting Zookeeper ==="
nohup $KAFKA_DIR/bin/zookeeper-server-start.sh $KAFKA_DIR/config/zookeeper.properties > $TRAFFIC_DIR/zk.log 2>&1 &
sleep 5

echo "=== Starting Kafka ==="
nohup $KAFKA_DIR/bin/kafka-server-start.sh $KAFKA_DIR/config/server.properties > $TRAFFIC_DIR/kafka.log 2>&1 &
sleep 10

echo "=== Creating Kafka topic: $TOPIC ==="
$KAFKA_DIR/bin/kafka-topics.sh --create \
  --zookeeper localhost:2181 \
  --replication-factor 1 \
  --partitions 1 \
  --topic $TOPIC || echo "Topic $TOPIC already exists"

echo "=== Starting Traffic Producer ==="
nohup python3 $TRAFFIC_DIR/traffic_producer.py > $TRAFFIC_DIR/producer.log 2>&1 &

echo "=== Starting Spark Streaming Job ==="
$SPARK_DIR/bin/spark-submit --master local[*] $TRAFFIC_DIR/spark_traffic_consumer.py &

echo "=== Waiting 2 minutes for data to aggregate ==="
sleep 120

echo "=== HDFS Output Directory Listing ==="
hdfs dfs -ls $HDFS_OUTPUT || echo "No data yet. Check logs."

echo "=== Real-time traffic system is up and running ==="