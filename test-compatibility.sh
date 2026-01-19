#!/bin/bash
set -e

FILE="compatible-fullstack-versions.txt"
RESULT_FILE="compatibility-results.txt"

echo "===== Running compatibility tests (strict npm install) ====="
# Clear previous results
> "$RESULT_FILE"

# Skip comment/header lines
grep -v "^#" "$FILE" | while read HARDHAT ETHERS DOTENV REACT REACTDOM; do
    COMBO="$HARDHAT $ETHERS $DOTENV $REACT $REACTDOM"

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

    # Install dependencies strictly
    if npm install > /dev/null 2>&1; then
        echo "$COMBO" >> "$RESULT_FILE"   # Only write successful combinations
        echo "✅ $COMBO"
    else
        echo "❌ $COMBO (skipped in results)"
    fi

    # Cleanup
    rm -rf node_modules package-lock.json temp-package.json
done

echo "===== Compatibility test completed ====="
echo "✅ Results summary written to $RESULT_FILE"
