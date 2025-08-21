#!/bin/bash
echo "🛑 Stopping Traffic Management System..."

echo "🔍 Killing traffic_producer.py..."
pkill -f traffic_producer.py || echo "Producer not running."

echo "🔍 Killing Spark jobs..."
pkill -f spark-submit || echo "Spark job not running."

echo "🔍 Stopping Kafka server..."
pkill -f kafka.Kafka || echo "Kafka not running."

echo "🔍 Stopping Zookeeper..."
pkill -f zookeeper || echo "Zookeeper not running."

echo "🔍 Stopping Hadoop/YARN/NameNode/DataNode..."
$HADOOP_HOME/sbin/stop-dfs.sh
$HADOOP_HOME/sbin/stop-yarn.sh

echo "✅ All services attempted to shut down."