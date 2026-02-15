#!/bin/bash
# ===================================================
# Admin Panel
# ===================================================

# Check if R is installed
if ! command -v Rscript &> /dev/null; then
    echo "ERROR: R is not installed or not in PATH"
    echo "Please install R from https://cran.r-project.org/"
    echo ""
    read -p "Press Enter to exit..."
    exit 1
fi

# Navigate to script directory
cd "$(dirname "$0")"

# Main menu function
show_menu() {
    clear
    echo ""
    echo "========================================"
    echo "   LIVESTOCK DASHBOARD ADMIN PANEL"
    echo "========================================"
    echo ""
    echo "Available Operations:"
    echo ""
    echo "   1. Update Farm Databases (upload new data or create new farms)"
    echo "   2. Deploy Code Changes to All Farms"
    echo "   3. Revert Farm from Backup"
    echo "   4. View Farm Status"
    echo "   5. View All Backups"
    echo "   6. Exit"
    echo ""
    echo "========================================"
    echo ""
}

# Main loop
while true; do
    show_menu
    read -p "Enter your choice (1-6): " choice

    case $choice in
        1)
            clear
            Rscript admin_scripts/update_all_farms.R
            echo ""
            read -p "Press any key to return to main menu..."
            ;;
        2)
            clear

            Rscript admin_scripts/deploy_code_changes.R
            echo ""
            read -p "Press any key to return to main menu..."
            ;;
        3)
            clear
            Rscript admin_scripts/revert_farm.R
            echo ""
            read -p "Press any key to return to main menu..."
            ;;
        4)
            clear
            Rscript admin_scripts/view_farm_status.R
            echo ""
            read -p "Press any key to return to main menu..."
            ;;
        5)
            clear
            echo ""
            echo "========================================"
            echo "   ALL FARM BACKUPS"
            echo "========================================"
            echo ""

            # List backups for all farms
            if [ -d "farm_backups" ]; then
                for farm_dir in farm_backups/*/; do
                    if [ -d "$farm_dir" ]; then
                        farm_name=$(basename "$farm_dir")
                        echo "========================================"
                        echo "Farm: $farm_name"
                        echo "========================================"

                        backup_count=$(find "$farm_dir" -name "*.duckdb" 2>/dev/null | wc -l)

                        if [ $backup_count -gt 0 ]; then
                            find "$farm_dir" -name "*.duckdb" -exec basename {} \; | while read backup; do
                                echo "   - $backup"
                            done
                        else
                            echo "   No backups found"
                        fi
                        echo ""
                    fi
                done
            else
                echo "No backups directory found"
                echo ""
            fi

            echo "========================================"
            echo ""
            read -p "Press any key to return to main menu..."
            ;;
        6)
            exit 0
            ;;
        *)
            echo ""
            echo "Invalid choice. Please try again."
            sleep 2
            ;;
    esac
done
