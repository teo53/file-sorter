@echo off
chcp 65001 >nul
echo ========================================
echo   배포 패키지 생성 중...
echo ========================================
echo.

set DIST_DIR=%~dp0dist
set API_DIR=%~dp0api
set DASHBOARD_DIR=%~dp0dashboard
set SRC_DIR=%~dp0src

echo [1/4] 대시보드 빌드 중 (Next.js)...
cd /d "%DASHBOARD_DIR%"
call npm run build
if errorlevel 1 (
    echo [ERROR] 대시보드 빌드 실패!
    pause
    exit /b 1
)

echo [2/4] 배포 디렉토리 생성...
if exist "%DIST_DIR%" rmdir /s /q "%DIST_DIR%"
mkdir "%DIST_DIR%"
mkdir "%DIST_DIR%\api"
mkdir "%DIST_DIR%\api\static"
mkdir "%DIST_DIR%\src"

echo [3/4] 파일 복사 중...
:: API 파일 복사
copy "%API_DIR%\main.py" "%DIST_DIR%\api\"
copy "%API_DIR%\requirements.txt" "%DIST_DIR%\api\"
copy "%API_DIR%\__init__.py" "%DIST_DIR%\api\"

:: 정적 파일(대시보드) 복사
xcopy "%DASHBOARD_DIR%\out\*" "%DIST_DIR%\api\static\" /s /e /y

:: 소스 코드 복사
xcopy "%SRC_DIR%\*" "%DIST_DIR%\src\" /s /e /y

:: 실행 스크립트 복사
copy "%~dp0AUTO_SORT.bat" "%DIST_DIR%\"
copy "%~dp0ROLLBACK.bat" "%DIST_DIR%\"
copy "%~dp0CREATE_SHORTCUTS.bat" "%DIST_DIR%\"

echo [4/4] 실행 스크립트 생성...
(
echo @echo off
echo chcp 65001 ^>nul
echo echo ========================================
echo echo   파일 정리 시스템 시작
echo echo ========================================
echo echo.
echo echo 1. 필요한 라이브러리 설치 중...
echo pip install -r api/requirements.txt
echo pip install -r src/requirements.txt
echo.
echo echo 2. 서버 실행 중...
echo echo http://localhost:8000 접속하세요.
echo.
echo cd api
echo python main.py
echo pause
) > "%DIST_DIR%\START_SERVER.bat"

echo.
echo ========================================
echo   배포 패키지 생성 완료!
echo ========================================
echo.
echo 위치: %DIST_DIR%
echo.
echo 이 'dist' 폴더만 다른 사람에게 주면 됩니다!
echo (Python만 설치되어 있으면 됨)
echo.
pause
