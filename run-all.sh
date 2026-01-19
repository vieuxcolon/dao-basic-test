#!/bin/bash
set -e

FILE="compatibility-results.txt"   # previously generated compatibility results
NPM_FILE="npm-available.txt"
TOOLBOX_VERSION="6.1.0"            # Single npm-published Hardhat Toolbox version

echo "===== Checking which compatible versions exist on npm ====="
> "$NPM_FILE"

grep -v "^#" "$FILE" | while read HARDHAT ETHERS DOTENV REACT REACTDOM; do
    COMBO="$HARDHAT $ETHERS $DOTENV $REACT $REACTDOM"

    echo -n "Testing npm availability for $COMBO with toolbox@$TOOLBOX_VERSION ... "

    AVAILABLE=true
    for PKG in "hardhat@$HARDHAT" "ethers@$ETHERS" "dotenv@$DOTENV" "react@$REACT" "react-dom@$REACTDOM" "@nomicfoundation/hardhat-toolbox@$TOOLBOX_VERSION"; do
        if ! npm view "$PKG" version >/dev/null 2>&1; then
            AVAILABLE=false
            break
        fi
    done

    if [ "$AVAILABLE" = true ]; then
        echo "$COMBO" >> "$NPM_FILE"
        echo "✅ Available"
    else
        echo "❌ Not available on npm"
    fi
done

echo "===== npm availability check completed ====="
echo "✅ Results written to $NPM_FILE"
