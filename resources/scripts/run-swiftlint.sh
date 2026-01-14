#!/bin/bash

# SwiftLint runner script for Portal package
# Can be called from Xcode build phase, CI/CD, or pre-commit hooks

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Running SwiftLint..."

# Check if SwiftLint is installed
if ! command -v swiftlint &> /dev/null; then
    echo -e "${RED}❌ SwiftLint is not installed${NC}"
    echo "Install with: brew install swiftlint"
    exit 1
fi

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Change to project root
cd "$PROJECT_ROOT"

# Run SwiftLint
if swiftlint lint --config .swiftlint.yml; then
    echo -e "${GREEN}✅ SwiftLint passed${NC}"
    exit 0
else
    echo -e "${RED}❌ SwiftLint found issues${NC}"
    exit 1
fi