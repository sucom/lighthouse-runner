#!/usr/bin/env bash

# =========================================================================
# Phase 1: Environment Detection & Dependencies
# =========================================================================
OS_TYPE=$(uname -s)

if ! command -v lighthouse >/dev/null 2>&1; then
  echo "Error: Lighthouse CLI is not installed globally via npm."
  echo "Please run: npm install -g lighthouse"
  exit 1
fi

# =========================================================================
# Phase 2: Input & Argument Parsing
# =========================================================================
TARGET_URL="$1"

if [ -z "$TARGET_URL" ]; then
  echo "Usage: lh [URL] [Preset: -d|--desktop|-m|--mobile] [Output: -o=PATH|--output=PATH]"
  exit 1
fi

if ! echo "$TARGET_URL" | grep -iq "^http"; then
  echo "Error: The first argument must be a valid URL starting with http or https"
  exit 1
fi

PRESET="desktop"

# Set default Output Directory based on Operating System
if [[ "$OS_TYPE" == MINGW* || "$OS_TYPE" == CYGWIN* ]]; then
  OUT_DIR="/c/LightHouseReports"
else
  OUT_DIR="$HOME/LightHouseReports"
fi

shift

while [ "$#" -gt 0 ]; do
  case "$1" in
    -d|--desktop) PRESET="desktop"; shift ;;
    -m|--mobile) PRESET="mobile"; shift ;;
    -o=*|--output=*) OUT_DIR="${1#*=}"; shift ;;
    *) shift ;;
  esac
done

# =========================================================================
# Phase 3: String Sanitization & Dynamic Naming
# =========================================================================
if [ "$OUT_DIR" = "." ]; then
  OUT_DIR="$PWD"
fi

mkdir -p "$OUT_DIR"

SAFE_NAME="${TARGET_URL//[:\/.-]/_}"
TIMESTAMP=$(date "+%Y%m%d-%H%M%S")

ABS_OUT_DIR=$(cd "$OUT_DIR" && pwd)
FINAL_REPORT_PATH="$ABS_OUT_DIR/$SAFE_NAME-$TIMESTAMP.html"

# =========================================================================
# Phase 4: Lighthouse Execution
# =========================================================================
echo "Running Lighthouse performance evaluation on $TARGET_URL with Preset Mode: $PRESET"
echo "... ... ..."

LH_PRESET_FLAG=""
if [ "$PRESET" = "desktop" ]; then
  LH_PRESET_FLAG="--preset=desktop"
fi

TEMP_DIR="/tmp/lh-temp"
mkdir -p "$TEMP_DIR"

lighthouse "$TARGET_URL" $LH_PRESET_FLAG --output=html --output-path="$FINAL_REPORT_PATH" --chrome-flags="--user-data-dir=$TEMP_DIR" --quiet

# =========================================================================
# Phase 5: Result Delivery & Path Translation
# =========================================================================
if [ -f "$FINAL_REPORT_PATH" ]; then
  echo "------------------------------------------------"
  echo "Audit successfully completed."
  echo "The HTML performance report is available at:"

  # Translate path for Windows browsers if on Git Bash
  if [[ "$OS_TYPE" == MINGW* || "$OS_TYPE" == CYGWIN* ]]; then
    WIN_PATH=$(cygpath -m "$FINAL_REPORT_PATH")
    echo "file:///$WIN_PATH"
  else
    echo "file://$FINAL_REPORT_PATH"
  fi
else
  echo "Error: The performance audit execution failed to yield a report file."
fi