@echo off
chcp 65001 >nul
title 📦 자동 설치 스크립트

echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║         📦 파일 정리 시스템 자동 설치                  ║
echo ╚════════════════════════════════════════════════════════╝
echo.

REM 관리자 권한 확인
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ⚠️  이 스크립트는 관리자 권한이 필요합니다.
    echo.
    echo 우클릭 후 "관리자 권한으로 실행"을 선택해주세요.
    pause
    exit /b 1
)

echo [1/5] Python 설치 확인 중...
python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo ❌ Python이 설치되어 있지 않습니다.
    echo.
    echo 📥 Python을 설치하시겠습니까? (y/n^)
    set /p INSTALL_PYTHON=
    
    if /i "%INSTALL_PYTHON%"=="y" (
        echo.
        echo 🌐 Python 다운로드 페이지를 엽니다...
        start https://www.python.org/downloads/
        echo.
        echo Python 설치 후 이 스크립트를 다시 실행해주세요.
        pause
        exit /b 0
    ) else (
        echo.
        echo 설치가 취소되었습니다.
        pause
        exit /b 0
    )
) else (
    echo ✅ Python 설치 확인
    python --version
)

echo.
echo [2/5] 의존성 패키지 설치 중...
pip install -r requirements.txt
if %errorLevel% neq 0 (
    echo.
    echo ❌ 패키지 설치 실패
    pause
    exit /b 1
)
echo ✅ 패키지 설치 완료

echo.
echo [3/5] API 서버 의존성 설치 중...
cd api
pip install -r requirements.txt
cd ..
if %errorLevel% neq 0 (
    echo.
    echo ❌ API 패키지 설치 실패
    pause
    exit /b 1
)
echo ✅ API 패키지 설치 완료

echo.
echo [4/5] 바로가기 생성 중...
call "📌 바탕화면바로가기_생성.bat"
echo ✅ 바로가기 생성 완료

echo.
echo [5/5] 설정 파일 확인 중...
if not exist "config.json" (
    echo ⚠️  config.json 파일이 없습니다.
    echo 기본 설정 파일이 프로그램 실행 시 자동 생성됩니다.
) else (
    echo ✅ config.json 파일 확인
)

echo.
echo ════════════════════════════════════════════════════════
echo ✅ 설치가 완료되었습니다!
echo ════════════════════════════════════════════════════════
echo.
echo 💡 사용 방법:
echo   1. 바탕화면의 "📁 폴더선택_정리" 바로가기를 실행하세요
echo   2. 정리할 폴더를 선택하세요
echo   3. 미리보기를 확인하고 진행하세요
echo.
echo 📝 설정 변경:
echo   - config.json 파일을 메모장으로 열어 수정하세요
echo   - 안전 설정, OCR 활성화 등을 변경할 수 있습니다
echo.
pause
