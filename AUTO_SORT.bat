@echo off
chcp 65001 >nul
title File Sorter - Auto Run (Desktop)

echo ========================================
echo   Desktop 파일 자동 정리 시스템
echo ========================================
echo.
echo 📂 Desktop 파일들을 자동으로 정리합니다...
echo.

cd /d "%~dp0src"
python main.py --auto --no-ocr

echo.
echo ========================================
echo   완료!
echo ========================================
echo.
echo 💡 다른 폴더를 정리하려면 '📁 폴더선택_정리.bat'을 실행하세요
echo 📄 로그: movement_log.json
echo.
pause
