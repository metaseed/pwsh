@echo off

REM Powershell 5/6
REM powershell -NoProfile -File %~dp0\CustomPreviewer.ps1 %0 %1 %2 %3 %4 %5 %6 %7 %8

REM Powershell 7+
pwsh -NoProfile -nologo -noninteractive -File %~dp0\previewer.ps1 %0 %1 %2 %3 %4 %5 %6 %7 %8