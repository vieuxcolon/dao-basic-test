# -----------------------------
# Dockerfile for DAO compatibility test + Hardhat 3 stack
# -----------------------------

# Use official Node 22 LTS image
FROM node:22.10.0

# Set working directory
WORKDIR /app

# Copy main project files
COPY package.json hardhat.config.js .env ./ 
COPY contracts ./contracts
COPY scripts ./scripts
COPY test-compatibility.sh ./test-compatibility.sh
COPY compatible-fullstack-versions.txt ./compatible-fullstack-versions.txt

# Make test script executable
RUN chmod +x ./test-compatibility.sh

# Install initial dependencies (needed to run compatibility test)
RUN npm install --force

# Run compatibility test during image build
RUN ./test-compatibility.sh

# Copy frontend for completeness (optional)
COPY frontend ./frontend

# Expose default Hardhat port
EXPOSE 8545

# Default entrypoint: bash for interactive container
CMD ["bash"]
