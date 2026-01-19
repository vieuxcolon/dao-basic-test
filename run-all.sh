#!/bin/bash
set -e

IMAGE_NAME="dao-basic-test-dao-test"
CONTAINER_NAME="dao-test"

echo "🛑 Cleaning up old container if exists..."
docker rm -f $CONTAINER_NAME >/dev/null 2>&1 || true

echo "🐳 Building Docker image..."
docker compose build

echo "🐳 Starting container..."
docker compose up -d

echo "🧪 Running compatibility test inside container..."
docker exec -it $CONTAINER_NAME bash -c "./test-compatibility.sh"

# Copy logs and results from container to host
echo "📁 Copying logs and results to host..."
docker cp $CONTAINER_NAME:/app/install-logs ./install-logs
docker cp $CONTAINER_NAME:/app/failed-combos ./failed-combos
docker cp $CONTAINER_NAME:/app/compatibility-results.txt ./compatibility-results.txt

echo
echo "✅ Passed combinations:"
grep "✅" compatibility-results.txt

echo
echo "All per-combo logs are in ./install-logs/"
echo "Failed combos (if any) are in ./failed-combos/"
echo "Summary in compatibility-results.txt"

echo
echo "🔹 You can enter the container for inspection:"
echo "docker exec -it $CONTAINER_NAME bash"
