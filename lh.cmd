@echo off
setlocal enabledelayedexpansion

@REM =========================================================================
@REM Phase 1: Dependency & Environment Check
@REM =========================================================================
where lighthouse >nul 2>nul
if %ERRORLEVEL% neq 0 (
  @REM Avoid round brackets in echo statements inside blocks
  echo Error: Lighthouse CLI is not installed globally via npm.
  echo Please run: npm install -g lighthouse
  exit /b 1
)

@REM =========================================================================
@REM Phase 2: Input & Argument Parsing
@REM =========================================================================
set "TARGET_URL=%~1"

@REM Validate URL input exists
if "%TARGET_URL%"=="" (
  echo Usage: lh [URL] [Preset: -d^|--desktop^|-m^|--mobile] [Output: -o=PATH^|--output=PATH]
  exit /b 1
)

@REM Validate URL starts with http/https case-insensitively
if /i "%TARGET_URL:~0,4%" neq "http" (
  echo Error: The first argument must be a valid URL starting with http or https
  exit /b 1
)

@REM Establish default fallback values
set "PRESET=desktop"
set "OUT_DIR=C:\LightHouseReports"

@REM Loop through remaining arguments to parse flags
:ParseArgs
if "%~2"=="" goto EndParseArgs

if /i "%~2"=="-d" set "PRESET=desktop" & shift & goto ParseArgs
if /i "%~2"=="--desktop" set "PRESET=desktop" & shift & goto ParseArgs
if /i "%~2"=="-m" set "PRESET=mobile" & shift & goto ParseArgs
if /i "%~2"=="--mobile" set "PRESET=mobile" & shift & goto ParseArgs

@REM Parse output directory switch
set "ARG_TWO=%~2"
if /i "%ARG_TWO:~0,3%"=="-o=" (
  set "OUT_DIR=%ARG_TWO:~3%"
  shift
  goto ParseArgs
)
if /i "%ARG_TWO:~0,9%"=="--output=" (
  set "OUT_DIR=%ARG_TWO:~9%"
  shift
  goto ParseArgs
)

@REM Shift if unmatched token to avoid infinite loop
shift
goto ParseArgs
:EndParseArgs

@REM =========================================================================
@REM Phase 3: String Sanitization & Dynamic Naming
@REM =========================================================================

@REM 1. Handle current folder notation '.'
if "%OUT_DIR%"=="." set "OUT_DIR=%CD%"

@REM 2. Create the target folder cleanly if it does not exist
if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

@REM 3. Sanitize URL to create a safe filename
set "SAFE_NAME=%TARGET_URL%"
set "SAFE_NAME=%SAFE_NAME::=_%"
set "SAFE_NAME=%SAFE_NAME:/=_%"
set "SAFE_NAME=%SAFE_NAME:.=_%"
set "SAFE_NAME=%SAFE_NAME:-=_%"

@REM 4. Generate uniform 0-padded YYYYMMDD-HHMMSS timestamp
set "RAW_DATE=%DATE%"
set "RAW_TIME=%TIME%"

@REM Scrub spaces in single-digit hours with a leading 0
set "SCRUBBED_TIME=%RAW_TIME: =0%"

@REM Extract components based on universal positioning tokens
for /f "tokens=2-4 delims=/.- " %%a in ("%RAW_DATE%") do (
  @REM Handles common standard local variations gracefully
  set "VAL_A=%%a"
  set "VAL_B=%%b"
  set "VAL_C=%%c"
)

@REM Build standard components safely from the scrubbed system variables
set "YYYY=%RAW_DATE:~-4%"
set "MM=%RAW_DATE:~4,2%"
set "DD=%RAW_DATE:~7,2%"
set "HH=%SCRUBBED_TIME:~0,2%"
set "MIN=%SCRUBBED_TIME:~3,2%"
set "SS=%SCRUBBED_TIME:~6,2%"

@REM Fallback correction check if string lengths vary by region
if "%YYYY:~0,1%"==" " set "YYYY=%VAL_C%"

set "TIMESTAMP=%YYYY%%MM%%DD%-%HH%%MIN%%SS%"
set "FINAL_REPORT_PATH=%OUT_DIR%\%SAFE_NAME%-%TIMESTAMP%.html"

@REM =========================================================================
@REM Phase 4: Lighthouse Execution (The Engine)
@REM =========================================================================
echo Running Lighthouse performance evaluation on %TARGET_URL% with Preset Mode: %PRESET%
echo ... ... ...

@REM Initialize empty, then populate with the full flag if desktop is requested
set "LH_PRESET_FLAG="
if /i "%PRESET%"=="desktop" set "LH_PRESET_FLAG=--preset=desktop"

call lighthouse "%TARGET_URL%" %LH_PRESET_FLAG% --output=html --output-path="%FINAL_REPORT_PATH%" --chrome-flags="--user-data-dir=C:\lh-temp" --quiet

@REM =========================================================================
@REM Phase 5: Result Delivery
@REM =========================================================================
if exist "%FINAL_REPORT_PATH%" (
  echo ------------------------------------------------
  echo Audit successfully completed.
  echo The HTML performance report is available at:
  echo file:///%FINAL_REPORT_PATH:\=/%
) else (
  echo Error: The performance audit execution failed to yield a report file.
)

endlocal