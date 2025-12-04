@echo off
chcp 65001 >nul

echo ========================================
echo   대시보드 시스템 시작
echo ========================================
echo.
echo 1. FastAPI 서버 시작 중...
echo 2. Next.js 대시보드 시작 중...
echo.
echo 잠시만 기다려주세요...
echo.

cd /d "%~dp0"

:: FastAPI 서버 시작 (백그라운드)
start "FastAPI Server" cmd /k "cd /d %~dp0api && echo [FastAPI] Starting server... && python main.py"

:: 3초 대기
timeout /t 3 /nobreak >nul

:: Next.js 대시보드 시작 (백그라운드)
start "Next.js Dashboard" cmd /k "cd /d %~dp0dashboard && echo [Dashboard] Starting... && npm run dev"

:: 5초 대기 후 브라우저 열기
timeout /t 5 /nobreak >nul

echo.
echo ========================================
echo   대시보드 실행 중!
echo ========================================
echo.
echo FastAPI: http://localhost:8000
echo Dashboard: http://localhost:3000
echo.
echo 브라우저를 자동으로 엽니다...
echo.

:: 브라우저 열기
start http://localhost:3000

echo.
echo 종료하려면 두 개의 창을 모두 닫으세요.
echo.
pause
