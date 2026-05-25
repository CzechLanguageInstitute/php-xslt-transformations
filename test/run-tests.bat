@echo off
REM XSLT Pipeline Test Runner (Batch)
REM 
REM Runs the PHP test suite using Windows Batch
REM This script invokes the PHP test runner

setlocal enabledelayedexpansion

echo.
echo === XSLT Pipeline Test Runner (Batch) ===
echo.

REM Get the project root (parent of script directory)
set "PROJECT_ROOT=%~dp0.."
set "PHP_PATH=php"
set "TEST_SCRIPT=%~dp0run-tests.php"

echo Project Root: %PROJECT_ROOT%
echo Test Script: %TEST_SCRIPT%
echo.

REM Check if test script exists
if not exist "%TEST_SCRIPT%" (
    echo ERROR: Test script not found: %TEST_SCRIPT%
    exit /b 1
)

REM Create output directory if it doesn't exist
if not exist "%PROJECT_ROOT%\output" (
    mkdir "%PROJECT_ROOT%\output"
)

REM Run the PHP test suite
echo Running PHP test suite...
echo.

call %PHP_PATH% "%TEST_SCRIPT%"
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if %EXIT_CODE% equ 0 (
    echo All tests passed!
    color 0A
) else (
    echo Some tests failed!
    color 0C
)

pause

exit /b %EXIT_CODE%
