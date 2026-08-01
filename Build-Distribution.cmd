@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\Build-Distribution.ps1"
if errorlevel 1 pause
