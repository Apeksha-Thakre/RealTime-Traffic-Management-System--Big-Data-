from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col, window
from pyspark.sql.types import StructType, StringType, IntegerType, LongType

spark = SparkSession.builder.appName("TrafficStreamProcessor").getOrCreate()

schema = StructType() \
    .add("origin", StringType()) \
    .add("destination", StringType()) \
    .add("travel_time", IntegerType()) \
    .add("timestamp", LongType())

df = spark.readStream.format("kafka") \
    .option("kafka.bootstrap.servers", "localhost:9092") \
    .option("subscribe", "traffic_data") \
    .load()

parsed = df.selectExpr("CAST(value AS STRING)") \
    .select(from_json(col("value"), schema).alias("data")) \
    .select("data.*")

agg = parsed.groupBy(
    window(col("timestamp").cast("timestamp"), "1 minute"),
    col("origin"), col("destination")
).avg("travel_time").alias("avg_travel_time")

query = agg.writeStream \
    .format("parquet") \
    .outputMode("append") \
    .option("path", "hdfs://localhost:9000/traffic/aggregated") \
    .option("checkpointLocation", "/tmp/traffic_checkpoint") \
    .start()

query.awaitTermination()
