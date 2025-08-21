#!/bin/bash
set -e

TRAFFIC_DIR=~/traffic
KAFKA_DIR=/home/talentum/kafka
SPARK_DIR=/home/talentum/spark
HADOOP_DIR=/home/talentum/hadoop
TOPIC="traffic_data"
HDFS_OUTPUT="/traffic/aggregated"

echo "🚀 Starting Hadoop and Hive..."
chmod +x $TRAFFIC_DIR/Start-Hadoop-Hive.sh
$TRAFFIC_DIR/Start-Hadoop-Hive.sh

echo "🐘 Starting Zookeeper..."
nohup $KAFKA_DIR/bin/zookeeper-server-start.sh $KAFKA_DIR/config/zookeeper.properties > $TRAFFIC_DIR/zk.log 2>&1 &
sleep 5

echo "📦 Starting Kafka Broker..."
nohup $KAFKA_DIR/bin/kafka-server-start.sh $KAFKA_DIR/config/server.properties > $TRAFFIC_DIR/kafka.log 2>&1 &
sleep 10

echo "📡 Creating Kafka Topic if it doesn't exist..."
$KAFKA_DIR/bin/kafka-topics.sh --create \
  --zookeeper localhost:2181 \
  --replication-factor 1 \
  --partitions 1 \
  --topic $TOPIC || echo "Topic $TOPIC already exists."

echo "🚦 Starting Traffic Producer (OSRM)..."
nohup python3 $TRAFFIC_DIR/traffic_producer.py > $TRAFFIC_DIR/producer.log 2>&1 &

echo "⚙️  Starting Spark Structured Streaming job..."
nohup $SPARK_DIR/bin/spark-submit --master local[*] $TRAFFIC_DIR/spark_traffic_consumer.py > $TRAFFIC_DIR/spark.log 2>&1 &

echo "⏳ Waiting 2 minutes for HDFS output to appear..."
sleep 120

echo "📂 Checking HDFS Output Directory..."
$HADOOP_DIR/bin/hdfs dfs -ls $HDFS_OUTPUT || echo "No data written yet to $HDFS_OUTPUT"

echo "✅ Real-time traffic pipeline is up and running!"
