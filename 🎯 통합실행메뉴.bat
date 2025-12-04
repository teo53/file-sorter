@echo off
chcp 65001 >nul

color 0A
echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║                                                          ║
echo ║          AI 파일 정리 시스템 - 통합 실행                ║
echo ║                                                          ║
echo ╚══════════════════════════════════════════════════════════╝
echo.
echo.
echo [1] 파일 정리만 실행 (빠름)
echo [2] 대시보드 포함 실행 (완전판)
echo [3] 테스트 모드 (미리보기)
echo [4] 종료
echo.
set /p choice="선택하세요 (1-4): "

if "%choice%"=="1" goto sort_only
if "%choice%"=="2" goto full_system
if "%choice%"=="3" goto dry_run
if "%choice%"=="4" goto end

echo 잘못된 선택입니다.
pause
goto end

:sort_only
echo.
echo ========================================
echo   파일 정리 실행 중...
echo ========================================
cd /d "%~dp0src"
python main.py --auto --no-ocr
pause
goto end

:full_system
echo.
echo ========================================
echo   전체 시스템 시작 중...
echo ========================================
echo.
cd /d "%~dp0"

:: FastAPI 시작
start "FastAPI Server" cmd /k "cd /d %~dp0api && python main.py"
timeout /t 3 /nobreak >nul

:: Dashboard 시작
start "Dashboard" cmd /k "cd /d %~dp0dashboard && npm run dev"
timeout /t 5 /nobreak >nul

:: 파일 정리 실행
echo [INFO] 파일 정리를 시작합니다...
cd /d "%~dp0src"
python main.py --auto --no-ocr

:: 브라우저 열기
echo [INFO] 대시보드를 엽니다...
start http://localhost:3000

echo.
echo ========================================
echo   완료!
echo ========================================
echo.
echo 대시보드: http://localhost:3000
echo.
pause
goto end

:dry_run
echo.
echo ========================================
echo   테스트 모드 (미리보기)
echo ========================================
cd /d "%~dp0src"
python main.py --dry-run
pause
goto end

:end
exit
