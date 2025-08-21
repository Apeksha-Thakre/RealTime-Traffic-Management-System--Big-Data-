import requests
import time
import json
from kafka import KafkaProducer

ORIGIN = 'Pune, Maharashtra, India'
DESTINATION = 'Mumbai, Maharashtra, India'
ORIGIN_COORDS = "18.5204,73.8567"
DESTINATION_COORDS = "19.0760,72.8777"

KAFKA_SERVERS = 'localhost:9092'
TOPIC = 'traffic_data'

producer = KafkaProducer(
    bootstrap_servers=KAFKA_SERVERS,
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

def fetch_traffic():
    origin = ORIGIN_COORDS.split(',')
    destination = DESTINATION_COORDS.split(',')
    coord_str = f"{origin[1]},{origin[0]};{destination[1]},{destination[0]}"
    
    url = f"http://router.project-osrm.org/route/v1/driving/{coord_str}?overview=false"
    response = requests.get(url)
    data = response.json()

    if 'routes' in data:
        return {
            'origin': ORIGIN,
            'destination': DESTINATION,
            'travel_time': int(data['routes'][0]['duration']),
            'timestamp': int(time.time())
        }
    else:
        print("No route found or OSRM service unavailable.")
        return None

if __name__ == "__main__":
    while True:
        traffic_data = fetch_traffic()
        if traffic_data:
            producer.send(TOPIC, traffic_data)
            print("Sent:", traffic_data)
        time.sleep(60)