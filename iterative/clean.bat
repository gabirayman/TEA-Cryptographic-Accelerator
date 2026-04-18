@echo off
:: Delete the files and hide errors if they don't exist
del /f /q *.vvp *.vcd 2>nul

:: Print confirmation
echo.
echo ===============================
echo   SUCCESS: Environment Cleaned
echo ===============================