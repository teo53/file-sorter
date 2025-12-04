@echo off
chcp 65001 >nul

echo ========================================
echo   Dashboard System Starting
echo ========================================
echo.
echo 1. Starting FastAPI server...
echo 2. Starting Next.js dashboard...
echo.
echo Please wait...
echo.

cd /d "%~dp0"

:: Start FastAPI server (background)
start "FastAPI Server" cmd /k "cd /d %~dp0api && echo [FastAPI] Starting server... && python main.py"

:: Wait 3 seconds
timeout /t 3 /nobreak >nul

:: Start Next.js dashboard (background)
start "Next.js Dashboard" cmd /k "cd /d %~dp0dashboard && echo [Dashboard] Starting... && npm run dev"

:: Wait 5 seconds then open browser
timeout /t 5 /nobreak >nul

echo.
echo ========================================
echo   Dashboard Running!
echo ========================================
echo.
echo FastAPI: http://localhost:8000
echo Dashboard: http://localhost:3000
echo.
echo Opening browser automatically...
echo.

:: Open browser
start http://localhost:3000

echo.
echo Close both windows to stop the dashboard.
echo.
pause
