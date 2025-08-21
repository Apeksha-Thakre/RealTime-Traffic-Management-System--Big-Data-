#!/bin/bash
set -e

echo "📦 [1/10] Updating system and installing core packages..."
sudo apt update
sudo apt install -y openjdk-11-jdk python3-pip curl wget git unzip coreutils

echo "🐍 [2/10] Installing Python dependencies..."
pip3 install kafka-python requests pyspark

echo "🚀 [3/10] Starting HDFS..."
/home/talentum/hadoop/sbin/start-dfs.sh
sleep 5

echo "🧵 [4/10] Starting YARN..."
/home/talentum/hadoop/sbin/start-yarn.sh
sleep 5

echo "🧠 [5/10] JVM Processes after Hadoop start:"
jps

echo "🐘 [6/10] Starting Zookeeper..."
nohup /home/talentum/kafka/bin/zookeeper-server-start.sh /home/talentum/kafka/config/zookeeper.properties > ~/traffic/zk.log 2>&1 &
sleep 5

echo "📦 [7/10] Starting Kafka Broker..."
nohup /home/talentum/kafka/bin/kafka-server-start.sh /home/talentum/kafka/config/server.properties > ~/traffic/kafka.log 2>&1 &
sleep 10

echo "📡 [8/10] Creating Kafka Topic (traffic_data)..."
/home/talentum/kafka/bin/kafka-topics.sh --create \
  --zookeeper localhost:2181 \
  --replication-factor 1 \
  --partitions 1 \
  --topic traffic_data || echo "⚠️ Topic already exists."

echo "🚦 [9/10] Starting traffic producer..."
nohup python3 ~/traffic/traffic_producer.py > ~/traffic/producer.log 2>&1 &
sleep 2
echo "✅ Producer started. Log: tail -f ~/traffic/producer.log"

echo "⚙️  [10/10] Starting Spark consumer..."
nohup /home/talentum/spark/bin/spark-submit --master local[*] ~/traffic/spark_traffic_consumer.py > ~/traffic/spark.log 2>&1 &
sleep 5
echo "✅ Spark started. Log: tail -f ~/traffic/spark.log"

echo "⏳ Waiting 2 minutes for data to reach HDFS..."
sleep 120

echo "📂 HDFS Output Check:"
/home/talentum/hadoop/bin/hdfs dfs -ls /traffic/aggregated || echo "⚠️ No output yet in /traffic/aggregated."

echo "📜 Producer Log Preview:"
tail -n 5 ~/traffic/producer.log

echo "📜 Spark Log Preview:"
tail -n 5 ~/traffic/spark.log

echo "✅ ✅ All services are running. Monitor logs or HDFS output as needed."