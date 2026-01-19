#!/bin/bash
set -e

# Input and output files
FILE="compatibility-results.txt"   # already generated from compatibility test
NPM_FILE="npm-available.txt"

echo "===== Checking which compatible versions exist on npm ====="
# Clear previous results
> "$NPM_FILE"

# Read file line by line (avoids subshell issues)
while read -r HARDHAT ETHERS DOTENV REACT REACTDOM; do
    # Skip empty lines
    [[ -z "$HARDHAT" ]] && continue

    COMBO="$HARDHAT $ETHERS $DOTENV $REACT $REACTDOM"
    echo -n "Testing npm availability for $COMBO ... "

    AVAILABLE=true

    # Check main packages
    for PKG in hardhat@$HARDHAT ethers@$ETHERS dotenv@$DOTENV react@$REACT react-dom@$REACTDOM; do
        if ! npm view "$PKG" version >/dev/null 2>&1; then
            AVAILABLE=false
            break
        fi
    done

    # Only check Hardhat Toolbox if the main Hardhat version exists
    if [ "$AVAILABLE" = true ]; then
        # Find the latest @nomicfoundation/hardhat-toolbox that matches major.minor of Hardhat
        TOOLBOX_MAJOR_MINOR=$(echo "$HARDHAT" | awk -F. '{print $1 "." $2}')
        TOOLBOX_VERSION=$(npm view @nomicfoundation/hardhat-toolbox@"$TOOLBOX_MAJOR_MINOR".* version 2>/dev/null || true)

        if [ -z "$TOOLBOX_VERSION" ]; then
            AVAILABLE=false
        fi
    fi

    # Write to file if all packages exist
    if [ "$AVAILABLE" = true ]; then
        echo "$COMBO" >> "$NPM_FILE"
        echo "✅ Available (Toolbox: $TOOLBOX_VERSION)"
    else
        echo "❌ Not available on npm"
    fi

done < <(grep -v "^#" "$FILE")  # skip header/comments

echo "===== npm availability check completed ====="
echo "✅ Results written to $NPM_FILE"
