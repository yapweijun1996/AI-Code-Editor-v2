@echo off
REM ==========================================================
REM  AI Code Editor - SAFE SETUP SCRIPT
REM  Runs in a simple, robust, and clear way for Windows
REM ==========================================================

REM ----- SETUP -----
setlocal enableextensions
set "ROOTDIR=%~dp0"
set "LOGFILE=%ROOTDIR%setup_debug.log"
set "BACKEND=%ROOTDIR%backend"
set "PM2_PROCESS_NAME=ai-code-editor"

REM Clear old log
echo. > "%LOGFILE%"

REM ----- HEADER -----
echo ==========================================================
echo        AI Code Editor - Setup
echo ==========================================================
echo.
echo This script will install all necessary dependencies and set up the AI Code Editor.
echo Make sure you have Node.js and npm installed!
echo.
echo Running from: %ROOTDIR%
echo ----------------------------------------------------------
REM ----- ADMIN CHECK -----
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Please run this script as Administrator!
    echo (Right-click and select "Run as administrator")
    echo ----------------------------------------------------------
    echo See any details above. Press any key to close.
    pause >nul
    goto :eof
)
echo OK: Administrative privileges confirmed.
echo.

REM ----- 1. BACKEND DEPENDENCIES -----
echo [1/3] Installing backend dependencies...
cd /d "%BACKEND%"
npm install >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Failed to install backend dependencies. See %LOGFILE% for details.
    echo ----------------------------------------------------------
    cd /d "%ROOTDIR%"
    pause
    goto SAFE_EXIT
)
cd /d "%ROOTDIR%"
echo Backend dependencies installed successfully.
echo.

REM ----- 2. INSTALL PM2 -----
echo [2/3] Installing pm2 globally...
npm install pm2 -g >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Failed to install pm2 globally. See %LOGFILE% for details.
    echo ----------------------------------------------------------
    pause
    goto SAFE_EXIT
)
echo pm2 installed successfully.
echo.

REM ----- 3. START SERVER & AUTO-START -----
echo [3/3] Starting server with pm2...
pm2 stop "%PM2_PROCESS_NAME%" >nul 2>&1
pm2 delete "%PM2_PROCESS_NAME%" >nul 2>&1
pm2 start backend/index.js --name "%PM2_PROCESS_NAME%" >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Failed to start server with pm2. See %LOGFILE% for details.
    echo ----------------------------------------------------------
    pause
    goto SAFE_EXIT
)
pm2 save >> "%LOGFILE%" 2>&1
pm2 startup >> "%LOGFILE%" 2>&1

echo Server started and configured with pm2.
echo.

REM ----- DONE -----
echo ==========================================================
echo SETUP COMPLETE!
echo ----------------------------------------------------------
echo The backend is now running via pm2.
echo Open http://localhost:3333 in your browser.
echo.
echo To check pm2 status, run: pm2 status
echo To see logs, run: pm2 logs %PM2_PROCESS_NAME%
echo Log file: %LOGFILE%
echo ----------------------------------------------------------
:SAFE_EXIT
echo Press any key to exit. The window will remain open for review until you do.
pause >nul
exit /b