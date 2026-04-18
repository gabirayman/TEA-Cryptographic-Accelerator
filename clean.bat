@echo off
set /p choice="clean [1] Iterative or [2] Pipelined? "

if "%choice%"=="1" (
    cd iterative
    call clean.bat
    cd ..
)

if "%choice%"=="2" (
    cd pipelined
    call clean.bat
    cd ..
)