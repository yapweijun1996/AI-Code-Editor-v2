@echo off
setlocal

REM ==========================================================
REM  AI Code Editor - Final Safe Setup Script with Debug Mode
REM ==========================================================

REM --- Failsafe: Always pause at the very start so user sees script output, even if error happens early
echo.
echo [DEBUG] Script started and reached TOP
echo [Notice] If this window closes immediately, you may need to run this script from a Command Prompt window.
timeout /t 2 >nul
echo [DEBUG] After initial timeout, proceeding to variable setup...

REM --- Configuration
REM --- Set DEBUG to 1 to enable detailed step-by-step logging
set "DEBUG=1" 
set "ROOTDIR=%~dp0"
set "LOGFILE=%ROOTDIR%setup_activity.log"
set "BACKEND_DIR=%ROOTDIR%backend"
set "PM2_PROCESS_NAME=ai-code-editor"

REM --- Clear previous log file
echo. > "%LOGFILE%"

:log
echo [%date% %time%] %* >> "%LOGFILE%"
goto :eof

:debug_log
if "%DEBUG%"=="1" (
    echo [DEBUG] %*
    call :log "[DEBUG] %*"
)
goto :eof

REM --- Header
echo [DEBUG] Reached header output
echo ==========================================================
echo        AI Code Editor Setup
echo ==========================================================
echo.
echo This script will install dependencies and configure the server.
echo Make sure Node.js and npm are installed and accessible in your PATH.
if "%DEBUG%"=="1" echo [DEBUG] Debug Mode is ON.
echo.
call :log "Setup started."

REM --- Log initial variables for debugging
call :debug_log "ROOTDIR set to: %ROOTDIR%"
call :debug_log "LOGFILE set to: %LOGFILE%"
call :debug_log "BACKEND_DIR set to: %BACKEND_DIR%"

REM --- Administrator Check
echo [DEBUG] Reached admin check
echo Verifying administrator privileges...
call :debug_log "Running 'net session' to check for admin rights."
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Administrative privileges are required.
    echo Please right-click on this script and select 'Run as administrator'.
    echo The window will remain open for 10 seconds.
    call :log "ERROR: Script not run as administrator."
    timeout /t 10
    echo [DEBUG] Exiting due to failed admin check
    goto :safe_exit
)
echo Privileges confirmed.
call :debug_log "Admin privileges check passed."
echo.

REM --- Step 1: Install Backend Dependencies
echo [DEBUG] Reached backend dependency installation
echo ----------------------------------------------------------
echo [1/3] Installing backend dependencies...
echo This may take a few moments.
echo ----------------------------------------------------------
call :debug_log "Changing directory to backend: %BACKEND_DIR%"
cd /d "%BACKEND_DIR%"
call :debug_log "Current directory: %cd%"
call :log "Changed directory to %BACKEND_DIR%"
call :log "Running: npm install"
call :debug_log "Executing 'npm install'. Output will be shown below."

npm install
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] 'npm install' failed. See the output above for details.
    call :log "ERROR: 'npm install' failed with errorlevel %errorlevel%."
    cd /d "%ROOTDIR%"
    echo [DEBUG] Exiting due to npm install failure
    goto :safe_exit
)
call :log "SUCCESS: npm dependencies installed."
call :debug_log "npm install completed successfully."
cd /d "%ROOTDIR%"
call :debug_log "Returned to root directory: %cd%"
echo ----------------------------------------------------------
echo Backend dependencies installed successfully.
echo ----------------------------------------------------------
echo.

REM --- Step 2: Install PM2
echo [DEBUG] Reached PM2 installation
echo ----------------------------------------------------------
echo [2/3] Installing PM2 process manager globally...
echo ----------------------------------------------------------
call :debug_log "Executing 'npm install pm2 -g'."
npm install pm2 -g
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Failed to install PM2 globally. See the output above for details.
    call :log "ERROR: Failed to install PM2 with errorlevel %errorlevel%."
    echo [DEBUG] Exiting due to PM2 install failure
    goto :safe_exit
)
call :log "SUCCESS: PM2 installed globally."
call :debug_log "PM2 installed successfully."
echo ----------------------------------------------------------
echo PM2 installed successfully.
echo ----------------------------------------------------------
echo.

REM --- Step 3: Configure and Start Server with PM2
echo [DEBUG] Reached PM2 configuration and server launch
echo ----------------------------------------------------------
echo [3/3] Configuring server with PM2...
echo ----------------------------------------------------------
call :log "Configuring PM2..."
call :debug_log "Stopping and deleting any existing process: %PM2_PROCESS_NAME%"
pm2 stop "%PM2_PROCESS_NAME%" >nul 2>&1
pm2 delete "%PM2_PROCESS_NAME%" >nul 2>&1
call :log "Stopped and deleted any existing process."

call :debug_log "Starting server with pm2: pm2 start '%BACKEND_DIR%\index.js' --name '%PM2_PROCESS_NAME%'"
pm2 start "%BACKEND_DIR%\index.js" --name "%PM2_PROCESS_NAME%"
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Failed to start the server with PM2.
    call :log "ERROR: Failed to start server with PM2."
    echo [DEBUG] Exiting due to PM2 server start failure
    goto :safe_exit
)
call :log "SUCCESS: Server started with PM2."
call :debug_log "Server started."

call :debug_log "Saving PM2 process list."
pm2 save
call :log "PM2 process list saved."
call :debug_log "Configuring PM2 startup."
pm2 startup
call :log "PM2 startup configured."
echo ----------------------------------------------------------
echo Server configured and started successfully.
echo ----------------------------------------------------------
echo.

REM --- Final Message
echo ==========================================================
echo SETUP COMPLETE!
echo ==========================================================
echo The AI Code Editor backend is running via PM2.
echo You can now access the editor at: http://localhost:3333
call :log "Setup completed successfully."

:safe_exit
echo.
echo ----------------------------------------------------------
echo The setup script has finished. Press any key to close this window.
pause
timeout /t 2 >nul