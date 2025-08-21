#!/bin/bash
set -e

KAFKA_DIR=~/kafka
SPARK_DIR=~/spark
HDFS_OUTPUT="/traffic/aggregated"
TOPIC="traffic_data"

$KAFKA_DIR/bin/kafka-topics.sh --create \
  --zookeeper localhost:2181 \
  --replication-factor 1 \
  --partitions 1 \
  --topic $TOPIC || echo "Topic exists"

nohup $KAFKA_DIR/bin/zookeeper-server-start.sh $KAFKA_DIR/config/zookeeper.properties > zk.log 2>&1 &
nohup $KAFKA_DIR/bin/kafka-server-start.sh $KAFKA_DIR/config/server.properties > kafka.log 2>&1 &
sleep 10

nohup python3 traffic_producer.py > producer.log 2>&1 &

$SPARK_DIR/bin/spark-submit --master local[*] spark_traffic_consumer.py &

echo "Waiting for data to appear in HDFS..."
sleep 120
hdfs dfs -ls $HDFS_OUTPUT

echo "Traffic system is running!"
