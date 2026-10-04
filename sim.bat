@echo off
rem Usage: sim <module_name>    example: sim ram16x8

if "%~1"=="" (
    echo Usage: sim ^<module_name^>
    exit /b 1
)

setlocal enabledelayedexpansion
cd /d "%~dp0"
if not exist build mkdir build
cd build

rem Collect all design files from rtl/
set SRC=
for %%f in (..\rtl\*.v) do set SRC=!SRC! %%f

call xvlog %SRC% ..\tb\tb_%~1.v || goto :fail
call xelab tb_%~1 -debug typical -s %~1_sim || goto :fail
call xsim %~1_sim -runall || goto :fail
exit /b 0

:fail
echo.
echo *** SIMULATION FAILED ***
exit /b 1