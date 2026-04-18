@echo off
set /p choice="Run [1] Iterative or [2] Pipelined? "

if "%choice%"=="1" (
    cd iterative
    call run.bat
    cd ..
)

if "%choice%"=="2" (
    cd pipelined
    call run.bat
    cd ..
)