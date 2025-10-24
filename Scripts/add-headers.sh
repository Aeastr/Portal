#!/bin/bash

# Script to add standard headers to all Swift files in the Portal project

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default values (can be overridden by environment variables or arguments)
AUTHOR="${PORTAL_AUTHOR:-Portal Contributors}"
COPYRIGHT_HOLDER="${PORTAL_COPYRIGHT:-Portal Contributors}"
YEAR=$(date +%Y)

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --author)
            AUTHOR="$2"
            shift 2
            ;;
        --copyright)
            COPYRIGHT_HOLDER="$2"
            shift 2
            ;;
        --year)
            YEAR="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --author NAME          Set the author name (default: Portal Contributors)"
            echo "  --copyright HOLDER     Set the copyright holder (default: Portal Contributors)"
            echo "  --year YEAR           Set the year (default: current year)"
            echo ""
            echo "You can also set environment variables:"
            echo "  PORTAL_AUTHOR         Default author name"
            echo "  PORTAL_COPYRIGHT      Default copyright holder"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Change to project root
cd "$PROJECT_ROOT"

echo -e "${BLUE}📝 Adding headers to Swift files...${NC}"
echo -e "  Author: ${YELLOW}$AUTHOR${NC}"
echo -e "  Copyright: ${YELLOW}$COPYRIGHT_HOLDER${NC}"
echo -e "  Year: ${YELLOW}$YEAR${NC}"
echo ""

# Function to add header to a file
add_header() {
    local file="$1"
    local filename=$(basename "$file")

    # Check if file already has a header
    if head -1 "$file" | grep -q "^//"; then
        echo "  ⏭️  Skipping $file (already has header)"
        return
    fi

    # Create the header from template
    if [ -f "$PROJECT_ROOT/.header-template" ]; then
        # Use template file
        sed -e "s/{{FILENAME}}/$filename/g" \
            -e "s/{{AUTHOR}}/$AUTHOR/g" \
            -e "s/{{COPYRIGHT_HOLDER}}/$COPYRIGHT_HOLDER/g" \
            -e "s/{{YEAR}}/$YEAR/g" \
            "$PROJECT_ROOT/.header-template" > "$file.tmp"
        echo "" >> "$file.tmp"
    else
        # Fallback to inline template
        cat > "$file.tmp" << EOF
//
//  $filename
//  Portal
//
//  Created by $AUTHOR, $YEAR.
//
//  Copyright © $YEAR $COPYRIGHT_HOLDER. All rights reserved.
//  Licensed under the MIT License.
//

EOF
    fi

    # Append the original content
    cat "$file" >> "$file.tmp"

    # Replace the original file
    mv "$file.tmp" "$file"

    echo -e "  ${GREEN}✓${NC} Added header to $file"
}

# Find all Swift files
SWIFT_FILES=$(find Sources Tests -name "*.swift" -type f 2>/dev/null || true)

if [ -z "$SWIFT_FILES" ]; then
    echo -e "${YELLOW}No Swift files found${NC}"
    exit 0
fi

# Process each file
COUNT=0
for FILE in $SWIFT_FILES; do
    add_header "$FILE"
    ((COUNT++)) || true
done

echo -e "${GREEN}✅ Processed $COUNT Swift files${NC}"