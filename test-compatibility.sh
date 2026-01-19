#!/bin/bash
set -e

FILE="compatible-fullstack-versions.txt"
RESULT_FILE="compatibility-results.txt"

# Create log directories on host
mkdir -p ./install-logs ./failed-combos-host

echo "===== Running compatibility tests (strict npm install) ====="
echo "Compatibility test results" > "$RESULT_FILE"

# Read each line from the versions file
while read HARDHAT ETHERS DOTENV REACT REACTDOM; do
    # Skip comments or empty lines
    [[ "$HARDHAT" =~ ^# ]] && continue
    [[ -z "$HARDHAT" ]] && continue

    COMBO="$HARDHAT $ETHERS $DOTENV $REACT $REACTDOM"
    LOG_FILE="./install-logs/install-${HARDHAT}-${ETHERS}.txt"
    FAILED_DIR="./failed-combos-host/${HARDHAT}-${ETHERS}"

    echo
    echo "===== Testing combination: $COMBO ====="

    # Create temp package.json for this combination
    cat > temp-package.json <<EOL
{
  "name": "dao-compatibility-test",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "hardhat": "$HARDHAT",
    "ethers": "$ETHERS",
    "dotenv": "$DOTENV",
    "react": "$REACT",
    "react-dom": "$REACTDOM"
  },
  "engines": {
    "node": ">=22.10.0"
  }
}
EOL

    # Clean old installs
    rm -rf node_modules package-lock.json

    # Run npm install and log output
    if npm install > "$LOG_FILE" 2>&1; then
        echo "✅ $COMBO" | tee -a "$RESULT_FILE"
    else
        echo "❌ $COMBO" | tee -a "$RESULT_FILE"
        echo "Check $LOG_FILE for details"
        # Save failed logs in a separate directory
        mkdir -p "$FAILED_DIR"
        cp "$LOG_FILE" "$FAILED_DIR/"
    fi

    # Cleanup for next iteration
    rm -rf node_modules temp-package.json

done < "$FILE"

echo "===== Compatibility test completed ====="
echo "✅ Results summary: $RESULT_FILE"
echo "All per-combo logs are in ./install-logs/"
echo "Failed combo environments are in ./failed-combos-host/"
