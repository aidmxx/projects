#!/bin/bash
# ===================================================
# Setup Validation
# ===================================================

# Navigate to script directory
cd "$(dirname "$0")"

echo ""
echo "========================================"
echo "   SETUP VALIDATION TOOL"
echo "========================================"
echo ""
echo "Checking if your system is ready..."
echo ""

Rscript admin_scripts/check_setup.R

echo ""
echo "========================================"
echo ""
read -p "Press Enter to continue..."
