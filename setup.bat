@echo off
setlocal

:: ============================================================================
:: Setup Configuration
:: ============================================================================
set "LOGFILE=setup_debug.log"
set "PM2_PROCESS_NAME=ai-code-editor"

:: ============================================================================
:: Helper Functions
:: ============================================================================
:log
echo [%date% %time%] %*>> %LOGFILE%
echo %*
goto :eof

:log_command
echo.
echo [INFO] Running command: %*
echo [INFO] Running command: %*>> %LOGFILE%
%* >> %LOGFILE% 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Command failed with errorlevel %errorlevel%. Check %LOGFILE% for details.
    call :wait_for_exit
    goto :eof
)
goto :eof

:: ============================================================================
:: Main Script
:: ============================================================================

:: Clear log file for new session
echo. > %LOGFILE%

call :log "================================================="
call :log "AI Code Editor Setup"
call :log "================================================="
echo.

:: Check for Administrator privileges
call :log "[INFO] Checking for Administrator privileges..."
net session >nul 2>&1
if %errorLevel% == 0 (
    call :log "[SUCCESS] Administrative permissions confirmed."
) else (
    call :log "[ERROR] This script requires administrative privileges."
    echo Please right-click on setup.bat and select "Run as administrator".
    call :wait_for_exit
    goto :eof
)

echo.
call :log "[INFO] This script will install all necessary dependencies and set up the AI Code Editor."
call :log "[INFO] Make sure you have Node.js installed on your system."
echo.
echo Press any key to continue...
pause >nul
echo.

:: Install backend dependencies
call :log "[STEP 1/3] Installing backend dependencies..."
cd backend
call :log_command npm install
cd ..
call :log "[SUCCESS] Backend dependencies installed successfully."
echo.

:: Install pm2 globally
call :log "[STEP 2/3] Installing pm2 process manager globally..."
call :log_command npm install pm2 -g
call :log "[SUCCESS] pm2 installed successfully."
echo.

:: Start the server with pm2 and configure auto-start
call :log "[STEP 3/3] Starting server with pm2 and configuring auto-start..."

call :log "[INFO] Stopping any existing process named '%PM2_PROCESS_NAME%'..."
pm2 stop "%PM2_PROCESS_NAME%" >nul 2>&1
pm2 delete "%PM2_PROCESS_NAME%" >nul 2>&1
call :log "[INFO] Existing processes stopped and deleted."

call :log "[INFO] Starting server with pm2..."
call :log_command pm2 start backend/index.js --name "%PM2_PROCESS_NAME%"

call :log "[INFO] Configuring pm2 to auto-start on boot..."
pm2 startup >> %LOGFILE% 2>&1
if %errorlevel% neq 0 (
    call :log "[WARNING] Failed to execute 'pm2 startup'. You may need to run this command manually."
    call :log "[WARNING] This usually requires copying and pasting a command into a new administrative shell."
)

pm2 save >> %LOGFILE% 2>&1
if %errorlevel% neq 0 (
    call :log "[WARNING] Failed to save pm2 process list. You may need to run 'pm2 save' manually."
) else (
    call :log "[SUCCESS] pm2 auto-start configured and process list saved."
)

echo.
call :log "================================================="
call :log "Setup Complete!"
call :log "================================================="
echo.
call :log "The AI Code Editor backend is now running via pm2."
call :log "You can access the editor at: http://localhost:3333"
echo.
call :log "To check the server status, run: pm2 status"
call :log "To view logs, run: pm2 logs %PM2_PROCESS_NAME%"
call :log "A detailed setup log has been saved to: %LOGFILE%"
echo.

call :wait_for_exit

endlocal
goto :eof

:: ============================================================================
:: Wait for user to choose to exit
:: ============================================================================
:wait_for_exit
echo.
echo -------------------------------------------------
echo Press E then ENTER to exit, or just ENTER to keep this window open...
set "userinput="
set /p userinput=Your choice: 
if /i "%userinput%"=="E" (
    exit /b
) else (
    echo Window will remain open for your review.
    echo Press Ctrl+C to close this window manually when done.
    :hold
    pause
    goto hold
)