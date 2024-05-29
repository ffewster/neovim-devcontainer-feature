#!/bin/bash
set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

set -e
echo "Running tests for My Feature..."

# Add test commands here

which nvim
nvim --version

reportResults
