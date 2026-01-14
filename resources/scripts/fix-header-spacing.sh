#!/bin/bash

# Script to fix header spacing in Swift files (add blank line after header)

set -uo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Change to project root
cd "$PROJECT_ROOT"

echo -e "${BLUE}🔧 Fixing header spacing in Swift files...${NC}"

# Find all Swift files
SWIFT_FILES=$(find Sources Tests -name "*.swift" -type f 2>/dev/null || true)

if [ -z "$SWIFT_FILES" ]; then
    echo -e "${YELLOW}No Swift files found${NC}"
    exit 0
fi

FIXED_COUNT=0

for FILE in $SWIFT_FILES; do
    # Check if file has the header pattern followed immediately by import without blank line
    if grep -q "^//  Licensed under the MIT License\.$" "$FILE" && \
       sed -n '/^\/\/  Licensed under the MIT License\.$/,/^import/p' "$FILE" | grep -q "^\/\/\s*$\|^import" ; then

        # Check if there's already a blank line
        if ! sed -n '/^\/\/  Licensed under the MIT License\.$/,/^import/p' "$FILE" | grep -q "^$" ; then
            echo -e "  ${GREEN}✓${NC} Fixing $(basename $FILE)"

            # Add blank line after the // line that follows "Licensed under the MIT License."
            sed -i.bak '/^\/\/  Licensed under the MIT License\.$/{n;/^\/\/$/a\

}' "$FILE"

            # Remove backup file
            rm "$FILE.bak"

            ((FIXED_COUNT++)) || true
        else
            echo "  ⏭️  $(basename $FILE) already has proper spacing"
        fi
    fi
done

echo -e "${GREEN}✅ Fixed $FIXED_COUNT file(s)${NC}"