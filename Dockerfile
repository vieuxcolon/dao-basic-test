
# -----------------------------
# Dockerfile for DAO compatibility test
# -----------------------------

# Use official Node 22 LTS image
FROM node:22.10.0

# Set working directory
WORKDIR /app

# Copy minimal required files for compatibility test
COPY package.json hardhat.config.js ./ 
COPY contracts ./contracts
COPY scripts ./scripts
COPY test-compatibility.sh ./test-compatibility.sh
COPY compatible-fullstack-versions.txt ./compatible-fullstack-versions.txt

# Make test script executable
RUN chmod +x ./test-compatibility.sh

# Install npm initially (required to run test-compatibility.sh)
RUN npm install --force

# Run compatibility test during image build
RUN ./test-compatibility.sh

# Expose Hardhat default port (optional)
EXPOSE 8545

# Default entrypoint: bash for interactive container
CMD ["bash"]
