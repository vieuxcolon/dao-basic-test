#!/bin/bash
set -e

FILE="compatible-fullstack-versions.txt"

echo "===== Running compatibility tests (strict npm install) ====="

# Skip comment/header lines
grep -v "^#" "$FILE" | while read HARDHAT ETHERS DOTENV REACT REACTDOM; do
    echo
    echo "===== Testing combination: Hardhat $HARDHAT, Ethers $ETHERS, Dotenv $DOTENV, React $REACT, ReactDOM $REACTDOM ====="

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

    # Install dependencies strictly (same as Docker)
    if npm install > install-log.txt 2>&1; then
        echo "✅ Combination succeeded: Hardhat $HARDHAT, Ethers $ETHERS, Dotenv $DOTENV, React $REACT, ReactDOM $REACTDOM"
    else
        echo "❌ Combination FAILED. Check install-log.txt for details."
    fi

    # Cleanup after each iteration
    rm -rf node_modules package-lock.json temp-package.json
done

echo "===== Compatibility test completed ====="
