#!/bin/bash

# Script to set up Git hooks for the Portal project

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔧 Setting up Git hooks..."

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Change to project root
cd "$PROJECT_ROOT"

# Configure Git to use the .githooks directory
git config core.hooksPath .githooks

echo -e "${GREEN}✅ Git hooks configured successfully${NC}"
echo ""
echo "The following hooks are now active:"
echo "  • pre-commit: Runs the project SwiftLint check when Swift changes are staged"
echo ""
echo -e "${YELLOW}Note: Make sure SwiftLint is installed:${NC}"
echo "  brew install swiftlint"
