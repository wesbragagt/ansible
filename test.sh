#!/bin/bash

# Legacy test script - maintained for backward compatibility
# For new testing, use the specific platform test scripts:
# - test-ubuntu.sh for Ubuntu-based testing
# - test-arch.sh for Arch Linux testing  
# - test-both.sh for comprehensive cross-platform testing

echo "⚠️  This is the legacy test script."
echo "For better testing options, use:"
echo "  ./test-ubuntu.sh  - Ubuntu environment (macOS simulation)"
echo "  ./test-arch.sh    - Arch Linux environment"
echo "  ./test-both.sh    - Both platforms"
echo ""
echo "Continuing with Ubuntu environment for backward compatibility..."

docker compose down ubuntu_test 2>/dev/null || true
docker compose up --build -d ubuntu_test
docker compose exec ubuntu_test bash
