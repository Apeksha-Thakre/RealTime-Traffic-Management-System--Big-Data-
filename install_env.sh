#!/bin/bash
set -e
# Variables
KAFKA_VERSION="3.6.0"
SCALA_VERSION="2.13"
SPARK_VERSION="3.5.0"
HADOOP_VERSION="3.3.6"

# Java
sudo apt update
sudo apt install -y openjdk-11-jdk python3-pip

# Kafka
wget https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz
tar -xzf kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz
mv kafka_${SCALA_VERSION}-${KAFKA_VERSION} ~/kafka

# Spark
wget https://downloads.apache.org/spark/spark-${SPARK_VERSION}-bin-hadoop3.tgz
tar -xzf spark-${SPARK_VERSION}-bin-hadoop3.tgz
mv spark-${SPARK_VERSION}-bin-hadoop3 ~/spark

# Hadoop
wget https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
tar -xzf hadoop-${HADOOP_VERSION}.tar.gz
mv hadoop-${HADOOP_VERSION} ~/hadoop

# Python deps
pip3 install kafka-python requests pyspark
