#!/bin/bash
set -e

CONTAINER_NAME="dao-test"
RESULT_FILE="compatibility-results.txt"
LOGS_DIR="install-logs"
FAILED_HOST_DIR="failed-combos-host"

echo "===== DAO Compatibility Test: Starting ====="

# Step 1: Build the Docker image
echo "🚀 Building Docker image..."
docker compose build

# Step 2: Stop & remove any existing container
echo "🛑 Cleaning up old container if exists..."
docker rm -f $CONTAINER_NAME 2>/dev/null || true

# Step 3: Start the container in background
echo "🐳 Starting container..."
docker compose up -d

# Step 4: Run the compatibility test inside the container
echo "🧪 Running compatibility test inside container..."
docker exec -it $CONTAINER_NAME bash -c "./test-compatibility.sh"

# Step 5: Create logs folder on host if not exists
mkdir -p "$LOGS_DIR"
mkdir -p "$FAILED_HOST_DIR"

# Step 6: Copy results and all per-combination logs from container to host
echo "📁 Copying logs and results to host..."
docker cp $CONTAINER_NAME:/app/compatibility-results.txt ./
docker cp $CONTAINER_NAME:/app/install-*.txt $LOGS_DIR/ 2>/dev/null || true

# Step 7: Copy failed combos from container to host
docker cp $CONTAINER_NAME:/app/failed-combos/. $FAILED_HOST_DIR/ 2>/dev/null || true

# Step 8: Show summary of passing combinations
echo
echo "✅ Passed combinations:"
grep "✅" "$RESULT_FILE"

# Step 9: Optional message
echo
echo "All per-combo logs are in ./$LOGS_DIR/"
echo "Failed combo environments are in ./$FAILED_HOST_DIR/"
echo "Summary in $RESULT_FILE"
echo "You can enter the container for inspection: docker exec -it $CONTAINER_NAME bash"

