@echo off
chcp 65001 >nul
echo ========================================
echo   바탕화면 바로가기 생성 중...
echo ========================================
echo.

set DESKTOP=%USERPROFILE%\Desktop
set SOURCE=%~dp0

echo [1/3] 파일정리 바로가기 생성...
powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%DESKTOP%\파일정리.lnk');$s.TargetPath='%SOURCE%⚡ 파일정리_바로실행.bat';$s.IconLocation='shell32.dll,166';$s.Save()"

echo [2/3] 대시보드 바로가기 생성...
powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%DESKTOP%\대시보드.lnk');$s.TargetPath='%SOURCE%🌐 대시보드_실행.bat';$s.IconLocation='shell32.dll,14';$s.Save()"

echo [3/3] 통합메뉴 바로가기 생성...
powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%DESKTOP%\파일정리시스템.lnk');$s.TargetPath='%SOURCE%🎯 통합실행메뉴.bat';$s.IconLocation='shell32.dll,147';$s.Save()"

echo.
echo ========================================
echo   완료!
echo ========================================
echo.
echo 바탕화면에 3개의 바로가기가 생성되었습니다:
echo   1. 파일정리.lnk
echo   2. 대시보드.lnk
echo   3. 파일정리시스템.lnk
echo.
echo 이제 바탕화면에서 더블클릭하세요!
echo.
pause
