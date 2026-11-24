#!/usr/bin/env bash
# Ghep Splunk app: copy splunk/apps/idps_lab -> build/idps_lab, roi sinh savedsearches.conf
# tu cac file detections/*/*.spl. Chay duoc tren may dev lan VM5.
# Quy uoc header: xem docs/integration-contract.md ("Header file .spl").
#   # name / uc / technique / severity / risk_score / cron / earliest / latest
# Script tu them vao cuoi search:
#   | eval detection_name=..., uc=..., technique=..., severity=..., risk_score=...
#   | collect index=detections
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO_ROOT/splunk/apps/idps_lab"
OUT="$REPO_ROOT/build/idps_lab"

hdr() { grep -m1 "^# $2:" "$1" | sed "s/^# $2:[[:space:]]*//" || true; }

rm -rf "$OUT"
mkdir -p "$OUT"
cp -a "$SRC/." "$OUT/"

SS="$OUT/default/savedsearches.conf"
mkdir -p "$OUT/default"
: > "$SS"

shopt -s nullglob
for f in "$REPO_ROOT"/detections/*/*.spl; do
  name=$(hdr "$f" name)
  [[ -n "$name" ]] || { echo "WARN: $f thieu '# name:' - bo qua" >&2; continue; }
  uc=$(hdr "$f" uc); technique=$(hdr "$f" technique)
  severity=$(hdr "$f" severity); risk=$(hdr "$f" risk_score)
  cron=$(hdr "$f" cron); earliest=$(hdr "$f" earliest); latest=$(hdr "$f" latest)
  for k in uc technique severity risk; do
    [[ -n "${!k}" ]] || { echo "ERROR: $f thieu header '$k'" >&2; exit 1; }
  done
  case "$technique" in signature|specification|anomaly) ;; *) echo "ERROR: $f technique khong hop le: $technique" >&2; exit 1;; esac
  case "$severity" in low|medium|high|critical) ;; *) echo "ERROR: $f severity khong hop le: $severity" >&2; exit 1;; esac
  [[ "$risk" =~ ^[0-9]+$ ]] || { echo "ERROR: $f risk_score phai la so" >&2; exit 1; }

  body=$(grep -v '^#' "$f" | sed '/./,$!d' | sed -e :a -e '/^[[:space:]]*$/{$d;N;ba' -e '}')
  body+=$'\n'"| eval detection_name=\"$name\", uc=\"$uc\", technique=\"$technique\", severity=\"$severity\", risk_score=$risk"
  body+=$'\n'"| collect index=detections"
  {
    echo "[$name]"
    echo "enableSched = 1"
    echo "cron_schedule = ${cron:-*/5 * * * *}"
    echo "dispatch.earliest_time = ${earliest:--15m}"
    echo "dispatch.latest_time = ${latest:-now}"
    # Splunk can dau '\' cuoi dong de noi dong
    echo "search = $(printf '%s' "$body" | sed ':a;N;$!ba;s/\n/ \\\n/g')"
    echo
  } >> "$SS"
done

echo "Built $OUT ($(grep -c '^\[' "$SS" || true) saved searches)"
