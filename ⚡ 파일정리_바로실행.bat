@echo off
chcp 65001 >nul
title 파일 정리 시스템 - 자동 실행

echo ========================================
echo   파일 정리 시스템 - 자동 모드
echo ========================================
echo.
echo Desktop 파일을 자동으로 정리합니다...
echo.

cd /d "%~dp0src"
python main.py --auto --no-ocr

echo.
echo ========================================
echo   정리 완료!
echo ========================================
echo.
echo 결과를 확인하려면 Desktop을 확인하세요.
echo 로그: movement_log.json
echo.
pause
