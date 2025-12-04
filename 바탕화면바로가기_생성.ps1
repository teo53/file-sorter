# Windows Script Host
# Desktop 바로가기 생성 스크립트

$WshShell = New-Object -ComObject WScript.Shell

# 바로가기 1: 파일 정리
$Shortcut1 = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\⚡ 파일정리.lnk")
$Shortcut1.TargetPath = "$env:USERPROFILE\Desktop\폴더 정리툴\⚡ 파일정리_바로실행.bat"
$Shortcut1.IconLocation = "shell32.dll,166"
$Shortcut1.Save()

# 바로가기 2: 대시보드
$Shortcut2 = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\🌐 대시보드.lnk")
$Shortcut2.TargetPath = "$env:USERPROFILE\Desktop\폴더 정리툴\🌐 대시보드_실행.bat"
$Shortcut2.IconLocation = "shell32.dll,14"
$Shortcut2.Save()

# 바로가기 3: 통합 메뉴
$Shortcut3 = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\🎯 파일정리시스템.lnk")
$Shortcut3.TargetPath = "$env:USERPROFILE\Desktop\폴더 정리툴\🎯 통합실행메뉴.bat"
$Shortcut3.IconLocation = "shell32.dll,147"
$Shortcut3.Save()

Write-Host "========================================" -ForegroundColor Green
Write-Host "   바탕화면 바로가기 생성 완료!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "생성된 바로가기:" -ForegroundColor Cyan
Write-Host "  1. ⚡ 파일정리 - 원클릭 자동 정리" -ForegroundColor Yellow
Write-Host "  2. 🌐 대시보드 - 모니터링 시스템" -ForegroundColor Yellow  
Write-Host "  3. 🎯 파일정리시스템 - 통합 메뉴" -ForegroundColor Yellow
Write-Host ""
Write-Host "이제 바탕화면에서 더블클릭만 하세요!" -ForegroundColor Green
Write-Host ""
pause
