@echo off
REM ===================================================
REM Setup Validation
REM ===================================================

color 0F
title Setup Validation

cd /d "%~dp0"

echo.
echo ========================================
echo   SETUP VALIDATION TOOL
echo ========================================
echo.
echo Checking if your system is ready...
echo.

Rscript admin_scripts/check_setup.R

echo.
echo ========================================
echo.
pause
