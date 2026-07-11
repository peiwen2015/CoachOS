#!/bin/zsh
set -e

cd "$(dirname "$0")"

PYTHON_CMD="python3"
APP_PYTHON="$PYTHON_CMD"
CONVERTER_PORT="8765"
DASHBOARD_PORT="8766"
CONVERTER_LOG="tmp/converter_server.log"
DASHBOARD_LOG="tmp/dashboard_server.log"

stop_server_on_port() {
  local port="$1"
  local label="$2"
  local pids
  pids=$(lsof -tiTCP:"$port" -sTCP:LISTEN 2>/dev/null || true)
  if [ -z "$pids" ]; then
    return 0
  fi

  echo "偵測到 $label http://127.0.0.1:$port 已經在執行，正在關閉舊伺服器..."
  for pid in ${(f)pids}; do
    kill "$pid" 2>/dev/null || true
  done

  for _ in {1..30}; do
    if ! lsof -tiTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
      echo "$label 舊伺服器已關閉。"
      return 0
    fi
    sleep 0.2
  done

  echo "無法自動關閉 $label。請先關掉舊視窗，或在終端機執行："
  echo "lsof -nP -iTCP:$port -sTCP:LISTEN"
  exit 1
}

wait_for_url() {
  local url="$1"
  local label="$2"
  for _ in {1..50}; do
    if "$APP_PYTHON" - "$url" >/dev/null 2>&1 <<'PY'
import sys
from urllib.request import urlopen

with urlopen(sys.argv[1], timeout=1) as response:
    response.read(64)
PY
    then
      echo "$label 已啟動：$url"
      return 0
    fi
    sleep 0.2
  done

  echo "$label 啟動逾時，請查看 log。"
  return 1
}

if [ -x ".venv/bin/python" ]; then
  APP_PYTHON=".venv/bin/python"
elif [ -d ".venv/lib/python3.14/site-packages" ]; then
  export PYTHONPATH=".venv/lib/python3.14/site-packages${PYTHONPATH:+:$PYTHONPATH}"
else
  "$PYTHON_CMD" -m venv .venv
  APP_PYTHON=".venv/bin/python"
fi

if ! "$APP_PYTHON" - <<'PY' >/dev/null 2>&1
import garmin_fit_sdk
import openpyxl
import garminconnect
PY
then
  "$PYTHON_CMD" -m venv --clear .venv
  APP_PYTHON=".venv/bin/python"
  "$APP_PYTHON" -m pip install -r requirements.txt
fi

mkdir -p tmp

stop_server_on_port "$CONVERTER_PORT" "轉檔工具"
stop_server_on_port "$DASHBOARD_PORT" "Dashboard"

echo "啟動轉檔工具..."
"$APP_PYTHON" app.py > "$CONVERTER_LOG" 2>&1 &
CONVERTER_PID=$!

echo "啟動 Dashboard..."
"$APP_PYTHON" analysis_platform/dashboard_app.py analysis_platform/running_analytics.sqlite --port "$DASHBOARD_PORT" --no-browser > "$DASHBOARD_LOG" 2>&1 &
DASHBOARD_PID=$!

cleanup() {
  echo ""
  echo "正在關閉本機服務..."
  kill "$CONVERTER_PID" "$DASHBOARD_PID" 2>/dev/null || true
}
trap cleanup INT TERM EXIT

if ! wait_for_url "http://127.0.0.1:$CONVERTER_PORT/" "轉檔工具"; then
  echo "轉檔工具 log：$CONVERTER_LOG"
  kill "$CONVERTER_PID" "$DASHBOARD_PID" 2>/dev/null || true
  exit 1
fi

if ! wait_for_url "http://127.0.0.1:$DASHBOARD_PORT/" "Dashboard"; then
  echo "Dashboard log：$DASHBOARD_LOG"
  kill "$CONVERTER_PID" "$DASHBOARD_PID" 2>/dev/null || true
  exit 1
fi

open "http://127.0.0.1:$CONVERTER_PORT/"
open "http://127.0.0.1:$DASHBOARD_PORT/"

echo ""
echo "兩個服務都已啟動。"
echo "轉檔工具：http://127.0.0.1:$CONVERTER_PORT/"
echo "Dashboard：http://127.0.0.1:$DASHBOARD_PORT/"
echo ""
echo "請保持這個視窗開著。關閉視窗會停止 8765 與 8766。"
echo "若要結束服務，可直接關閉此視窗或按 Ctrl+C。"

wait "$CONVERTER_PID" "$DASHBOARD_PID"
