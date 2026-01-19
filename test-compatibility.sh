#!/bin/bash
set -e

FILE="compatible-fullstack-versions.txt"
RESULT_FILE="compatibility-results.txt"
LOG_DIR="install-logs"
FAILED_DIR="failed-combos"

# Create directories
mkdir -p $LOG_DIR
mkdir -p $FAILED_DIR

echo "===== Running compatibility tests (strict npm install) ====="
echo "Compatibility test results" > $RESULT_FILE

# Skip comment/header lines
grep -v "^#" "$FILE" | while read HARDHAT ETHERS DOTENV REACT REACTDOM; do
    COMBO="$HARDHAT $ETHERS $DOTENV $REACT $REACTDOM"
    LOG_FILE="$LOG_DIR/install-${HARDHAT}-${ETHERS}.txt"

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

    # Install dependencies strictly and log output
    if npm install > "$LOG_FILE" 2>&1; then
        echo "✅ $COMBO" | tee -a $RESULT_FILE
    else
        echo "❌ $COMBO" | tee -a $RESULT_FILE
        echo "Check $LOG_FILE for details"
        # Save failed combo log in failed-combos directory
        cp "$LOG_FILE" "$FAILED_DIR/"
    fi

    # Cleanup temp package.json and node_modules
    rm -rf node_modules package-lock.json temp-package.json
done

echo "===== Compatibility test completed ====="
echo "✅ Results summary: $RESULT_FILE"
echo "All per-combo logs are in $LOG_DIR/"
echo "Failed combos (if any) are in $FAILED_DIR/"
