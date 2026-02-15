@echo off
REM ===================================================
REM Admin Panel
REM ===================================================

:INIT
color 0F
title Livestock Dashboard Admin Panel
cls

REM Check if R is installed
where Rscript >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: R is not installed or not in PATH
    echo Please install R from https://cran.r-project.org/
    echo.
    pause
    exit /b 1
)

REM Navigate to project directory
cd /d "%~dp0"

:MENU
cls
echo.
echo ========================================
echo   LIVESTOCK DASHBOARD ADMIN PANEL
echo ========================================
echo.
echo Available Operations:
echo.
echo   1. Update Farm Databases (upload new data or create new farms)
echo   2. Deploy Code Changes to All Farms
echo   3. Revert Farm from Backup
echo   4. View Farm Status
echo   5. View All Backups
echo   6. Manage User Credentials
echo   7. Exit
echo.
echo ========================================
echo.

set /p CHOICE="Enter your choice (1-7): "

if "%CHOICE%"=="1" goto UPDATE_ALL
if "%CHOICE%"=="2" goto DEPLOY_CODE
if "%CHOICE%"=="3" goto REVERT_FARM
if "%CHOICE%"=="4" goto VIEW_STATUS
if "%CHOICE%"=="5" goto VIEW_BACKUPS
if "%CHOICE%"=="6" goto MANAGE_CREDENTIALS
if "%CHOICE%"=="7" goto EXIT

echo.
echo Invalid choice. Please try again.
timeout /t 2 >nul
goto MENU

:UPDATE_ALL
cls

Rscript admin_scripts/update_all_farms.R

echo.
echo Press any key to return to main menu...
pause >nul
goto MENU

:DEPLOY_CODE
cls

Rscript admin_scripts/deploy_code_changes.R
echo.
echo Press any key to return to main menu...
pause >nul
goto MENU

:REVERT_FARM
cls
Rscript admin_scripts/revert_farm.R
echo.
echo Press any key to return to main menu...
pause >nul
goto MENU

:VIEW_STATUS
cls
Rscript admin_scripts/view_farm_status.R
echo.
echo Press any key to return to main menu...
pause >nul
goto MENU

:VIEW_BACKUPS
cls
echo.
echo ========================================
echo   ALL FARM BACKUPS
echo ========================================
echo.

REM List backups for all farms
for /d %%D in (farm_backups\*) do (
    echo ========================================
    echo Farm: %%~nxD
    echo ========================================
    if exist "%%D\*.duckdb" (
        for %%F in ("%%D\*.duckdb") do (
            echo   - %%~nxF
        )
    ) else (
        echo   No backups found
    )
    echo.
)

echo ========================================
echo.
echo Press any key to return to main menu...
pause >nul
goto MENU

:MANAGE_CREDENTIALS
cls
Rscript admin_scripts/manage_credentials.R
goto MENU

:EXIT
exit /b 0
