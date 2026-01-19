#!/bin/bash
set -e

CONTAINER_NAME="dao-test"

echo "===== DAO Compatibility Test: Starting ====="

# Step 1: Build the Docker image
echo "🚀 Building Docker image..."
docker compose build

# Step 2: Stop & remove any existing container
echo "🛑 Cleaning up old container if exists..."
docker rm -f $CONTAINER_NAME 2>/dev/null || true

# Step 3: Start the container (in background)
echo "🐳 Starting container..."
docker compose up -d

# Step 4: Run the compatibility test inside container
# (Optional if Dockerfile already ran it during build)
echo "🧪 Running compatibility test inside container..."
docker exec -it $CONTAINER_NAME bash -c "./test-compatibility.sh"

# Step 5: Show the results
echo "📄 Compatibility test results:"
docker exec -it $CONTAINER_NAME cat compatibility-results.txt

# Step 6: Keep the container running for inspection (optional)
echo "✅ DAO Compatibility Test completed!"
echo "You can enter the container with: docker exec -it $CONTAINER_NAME bash"
