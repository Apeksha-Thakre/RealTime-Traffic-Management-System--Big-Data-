#!/bin/bash
set -e

TRAFFIC_DIR=~/trafficmanagementsystem/traffic_deployable/traffic
KAFKA_DIR=/home/talentum/kafka
SPARK_DIR=/home/talentum/spark
HADOOP_DIR=/home/talentum/hadoop

echo "📦 [1/10] Updating system and installing required packages..."
sudo apt update
sudo apt install -y openjdk-11-jdk python3-pip curl wget git unzip coreutils netcat

echo "🐍 [2/10] Installing Python dependencies..."
pip3 install kafka-python requests pyspark

echo "🚀 [3/10] Starting HDFS..."
$HADOOP_DIR/sbin/start-dfs.sh
sleep 5

echo "🧵 [4/10] Starting YARN..."
$HADOOP_DIR/sbin/start-yarn.sh
sleep 5

echo "🧠 [5/10] JVM Processes after Hadoop start:"
jps

echo "🐘 [6/10] Starting Zookeeper..."
nohup $KAFKA_DIR/bin/zookeeper-server-start.sh $KAFKA_DIR/config/zookeeper.properties > $TRAFFIC_DIR/zk.log 2>&1 &
sleep 10

echo "📦 [7/10] Starting Kafka Broker..."
nohup $KAFKA_DIR/bin/kafka-server-start.sh $KAFKA_DIR/config/server.properties > $TRAFFIC_DIR/kafka.log 2>&1 &

echo "⏳ Waiting for Kafka to become available..."
until nc -z localhost 9092; do
  echo "⏳ Waiting for Kafka broker on port 9092..."
  sleep 2
done

echo "📡 [8/10] Creating Kafka Topic (traffic_data)..."
$KAFKA_DIR/bin/kafka-topics.sh --create \
  --zookeeper localhost:2181 \
  --replication-factor 1 \
  --partitions 1 \
  --topic traffic_data || echo "⚠️ Topic already exists or Kafka not fully ready."

echo "🚦 [9/10] Starting traffic producer..."
nohup python3 $TRAFFIC_DIR/traffic_producer.py > $TRAFFIC_DIR/producer.log 2>&1 &
sleep 2
echo "✅ Producer started. Log: tail -f $TRAFFIC_DIR/producer.log"

echo "⚙️  [10/10] Starting Spark consumer..."
nohup $SPARK_DIR/bin/spark-submit --master local[*] $TRAFFIC_DIR/spark_traffic_consumer.py > $TRAFFIC_DIR/spark.log 2>&1 &
sleep 5
echo "✅ Spark started. Log: tail -f $TRAFFIC_DIR/spark.log"

echo "⏳ Waiting 2 minutes for data to reach HDFS..."
sleep 120

echo "📂 HDFS Output Check:"
$HADOOP_DIR/bin/hdfs dfs -ls /traffic/aggregated || echo "⚠️ No output yet in /traffic/aggregated."

echo "📜 Producer Log Preview:"
tail -n 5 $TRAFFIC_DIR/producer.log

echo "📜 Spark Log Preview:"
tail -n 5 $TRAFFIC_DIR/spark.log

echo "✅ ✅ All services are running. Monitor logs or HDFS output as needed."