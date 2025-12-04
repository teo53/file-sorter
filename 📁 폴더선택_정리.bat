@echo off
chcp 65001 > nul
echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║         📂 폴더 선택 파일 정리 시스템                  ║
echo ╚════════════════════════════════════════════════════════╝
echo.
echo 🔍 정리할 폴더를 선택하세요...
echo.

REM Python 스크립트 실행
python src\main.py

echo.
echo ════════════════════════════════════════════════════════
echo 💡 사용 팁:
echo   - 특정 폴더를 지정하려면:
echo     python src\main.py --target "C:\원하는\폴더"
echo.
echo   - 테스트 모드로 실행:
echo     python src\main.py --dry-run
echo ════════════════════════════════════════════════════════
echo.
pause
