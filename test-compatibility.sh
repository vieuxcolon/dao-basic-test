#!/bin/bash
set -e

FILE="compatible-fullstack-versions.txt"
RESULT_FILE="compatibility-results.txt"
FAILED_DIR="failed-combos"

echo "===== Running compatibility tests (strict npm install) ====="
echo "Compatibility test results" > "$RESULT_FILE"

# Create folder for failed combinations
mkdir -p "$FAILED_DIR"

# Use redirect to avoid subshell issues
while read HARDHAT ETHERS DOTENV REACT REACTDOM; do
    COMBO="$HARDHAT $ETHERS $DOTENV $REACT $REACTDOM"
    LOG_FILE="install-${HARDHAT}-${ETHERS}.txt"
    TEMP_DIR="temp-${HARDHAT}-${ETHERS}"

    echo
    echo "===== Testing combination: $COMBO ====="

    # Create a temp folder per combination
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"

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

    # Clean old installs (just in temp folder)
    rm -rf node_modules package-lock.json

    # Install dependencies with legacy peer deps
    if npm install --legacy-peer-deps > "$LOG_FILE" 2>&1; then
        echo "✅ $COMBO" | tee -a "../$RESULT_FILE"
        # Cleanup temp folder for successful combos
        cd ..
        rm -rf "$TEMP_DIR"
    else
        echo "❌ $COMBO" | tee -a "../$RESULT_FILE"
        echo "Check $TEMP_DIR/$LOG_FILE for details"
        # Move failed combo folder to FAILED_DIR
        cd ..
        mv "$TEMP_DIR" "$FAILED_DIR/"
    fi
done < <(grep -v "^#" "$FILE")

echo "===== Compatibility test completed ====="
echo "✅ Results summary: $RESULT_FILE"
echo "❌ Failed combinations saved in: $FAILED_DIR/"
