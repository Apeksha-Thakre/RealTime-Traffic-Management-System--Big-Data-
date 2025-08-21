#!/bin/bash
set -e

echo "📦 [1/10] Updating system and installing dependencies..."
sudo apt update
sudo apt install -y openjdk-11-jdk python3-pip curl wget git unzip coreutils

echo "🐍 [2/10] Installing Python packages: kafka-python, requests, pyspark..."
pip3 install kafka-python requests pyspark

echo "🚀 [3/10] Starting Hadoop and Hive..."
chmod +x ~/traffic/Start-Hadoop-Hive.sh
~/traffic/Start-Hadoop-Hive.sh

echo "🧠 [4/10] JVM Services:"
jps

echo "🐘 [5/10] Starting Zookeeper..."
nohup /home/talentum/kafka/bin/zookeeper-server-start.sh /home/talentum/kafka/config/zookeeper.properties > ~/traffic/zk.log 2>&1 &
sleep 5
echo "✅ Zookeeper started. Log: tail -f ~/traffic/zk.log"

echo "📦 [6/10] Starting Kafka Broker..."
nohup /home/talentum/kafka/bin/kafka-server-start.sh /home/talentum/kafka/config/server.properties > ~/traffic/kafka.log 2>&1 &
sleep 10
echo "✅ Kafka started. Log: tail -f ~/traffic/kafka.log"

echo "📡 [7/10] Creating Kafka topic (traffic_data) if it does not exist..."
/home/talentum/kafka/bin/kafka-topics.sh --create \
  --zookeeper localhost:2181 \
  --replication-factor 1 \
  --partitions 1 \
  --topic traffic_data || echo "⚠️ Topic already exists."

echo "🚦 [8/10] Starting Traffic Producer..."
python3 ~/traffic/traffic_producer.py > ~/traffic/producer.log 2>&1 &
sleep 2
echo "✅ Producer running. Monitor: tail -f ~/traffic/producer.log"

echo "⚙️  [9/10] Starting Spark Structured Streaming job..."
nohup /home/talentum/spark/bin/spark-submit --master local[*] ~/traffic/spark_traffic_consumer.py > ~/traffic/spark.log 2>&1 &
sleep 5
echo "✅ Spark started. Log: tail -f ~/traffic/spark.log"

echo "⏳ [10/10] Waiting 2 minutes for Spark to write to HDFS..."
sleep 120

echo "📂 Checking HDFS output at /traffic/aggregated..."
/home/talentum/hadoop/bin/hdfs dfs -ls /traffic/aggregated || echo "⚠️ No data found in /traffic/aggregated yet. Spark may still be processing."

echo "📜 Last 5 lines of producer log:"
tail -n 5 ~/traffic/producer.log

echo "📜 Last 5 lines of Spark log:"
tail -n 5 ~/traffic/spark.log

echo "✅ Traffic data pipeline is up and running. Monitor logs or check HDFS output!"