#!/bin/bash

echo "🔁 Restarting the Real-Time Traffic Management System..."

# Set traffic dir path
TRAFFIC_DIR=~/traffic

# Ensure both scripts are executable
chmod +x $TRAFFIC_DIR/stop-all.sh
chmod +x $TRAFFIC_DIR/run-complete-traffic-system-verbose.sh

# Stop everything
echo "🛑 Stopping current services..."
$TRAFFIC_DIR/stop-all.sh

# Give a short pause
sleep 5

# Start everything
echo "🚀 Restarting all services..."
$TRAFFIC_DIR/run-complete-traffic-system-verbose.sh