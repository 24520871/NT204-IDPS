#!/usr/bin/env bash
# Ghep Splunk app: copy splunk/apps/idps_lab -> build/idps_lab, roi sinh savedsearches.conf
# tu cac file detections/*/*.spl. Chay duoc tren may dev lan VM5.
#
# Quy uoc moi file .spl (header o dau file, dong bat dau bang "#"):
#   # name: UC2 - DNS Tunneling
#   # cron: */5 * * * *
#   # earliest: -15m
#   # latest: now
#   # severity: high
#   (noi dung SPL tu dong khong bat dau bang '#')
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO_ROOT/splunk/apps/idps_lab"
OUT="$REPO_ROOT/build/idps_lab"

rm -rf "$OUT"
mkdir -p "$OUT"
cp -a "$SRC/." "$OUT/"

SS="$OUT/default/savedsearches.conf"
mkdir -p "$OUT/default"
: > "$SS"

shopt -s nullglob
for f in "$REPO_ROOT"/detections/*/*.spl; do
  name=$(grep -m1 '^# name:' "$f" | sed 's/^# name:[[:space:]]*//')
  [[ -n "$name" ]] || { echo "WARN: $f thieu '# name:' – bo qua" >&2; continue; }
  cron=$(grep -m1 '^# cron:' "$f" | sed 's/^# cron:[[:space:]]*//' || true)
  earliest=$(grep -m1 '^# earliest:' "$f" | sed 's/^# earliest:[[:space:]]*//' || true)
  latest=$(grep -m1 '^# latest:' "$f" | sed 's/^# latest:[[:space:]]*//' || true)
  {
    echo "[$name]"
    echo "enableSched = 1"
    echo "cron_schedule = ${cron:-*/5 * * * *}"
    echo "dispatch.earliest_time = ${earliest:--15m}"
    echo "dispatch.latest_time = ${latest:-now}"
    # Splunk can dau '\' cuoi dong de noi dong
    echo "search = $(grep -v '^#' "$f" | sed ':a;N;$!ba;s/\n/ \\\n/g')"
    echo
  } >> "$SS"
done

echo "Built $OUT ($(grep -c '^\[' "$SS") saved searches)"
