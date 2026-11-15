#!/usr/bin/env bash
# Source-first capability repro for existing OpenSiro Upstream batch 40.
# Requires separately obtained, checksum-verified official VictoriaLogs v1.54.0.
# No Docker, external credentials, live LLM, or real operations required.
set -euo pipefail
: "${AKMATORI_VL_BINARY:?path to official victoria-logs-prod v1.54.0}"
: "${AKMATORI_PATCHED_REPO:?path to disposable source checkout patched from b2aae689...}"
PIN='b2aae68949ae888a90a7436610d74b7b93507e7a'
BIN_SHA='46aaf57c79c30c81dd047f150fcedff065f182369fb9e65a0de4032f91d40005'
ACTUAL=$(git -C "$AKMATORI_PATCHED_REPO" rev-parse HEAD)
test "$ACTUAL" = "$PIN" || { echo "WRONG_SOURCE_PIN: $ACTUAL" >&2; exit 23; }
printf '%s  %s\n' "$BIN_SHA" "$AKMATORI_VL_BINARY" | sha256sum -c -
PORT=${AKMATORI_VL_PORT:-19428}
[[ "$PORT" =~ ^[0-9]+$ ]] && (( PORT>1024 && PORT<65536 )) || { echo invalid_port >&2;exit 23; }
WORK=$(mktemp -d)
PID=''
cleanup() {
 if [[ -n "$PID" ]]; then kill "$PID" >/dev/null 2>&1 || true; wait "$PID" >/dev/null 2>&1 || true; fi
 rm -rf "$WORK"
}
trap cleanup EXIT
if curl -fsS --max-time 1 "http://127.0.0.1:${PORT}/health" >/dev/null 2>&1; then
 echo "PORT_ALREADY_IN_USE" >&2
 exit 23
fi
"$AKMATORI_VL_BINARY" -httpListenAddr="127.0.0.1:${PORT}" -storageDataPath="$WORK/store" -loggerLevel=ERROR >"$WORK/server.log" 2>&1 &
PID=$!
ready=0
for i in $(seq 1 70); do
 if curl -fsS --max-time 2 "http://127.0.0.1:${PORT}/health" >/dev/null 2>&1; then ready=1;break;fi
 if ! kill -0 "$PID" 2>/dev/null;then echo server_exited >&2;cat "$WORK/server.log" >&2;exit 24;fi
 sleep 0.2
done
test "$ready" = 1 || { echo health_timeout >&2;exit 24; }
cat > "$WORK/three-journal-lines.jsonl" <<'NDJSON'
{"_time":"2026-11-14T19:00:00Z","_msg":"myservice systemd crash loop exit 1 on node-a","host":"node-a","service":"myservice","level":"error"}
{"_time":"2026-11-14T19:01:00Z","_msg":"myservice systemd restarted after crash on node-a","host":"node-a","service":"myservice","level":"warn"}
{"_time":"2026-11-14T19:02:00Z","_msg":"myservice stabilized on node-b","host":"node-b","service":"myservice","level":"info"}
NDJSON
curl --fail --silent --show-error --max-time 15 -X POST \
  -H 'Content-Type: application/stream+json' \
  --data-binary @"$WORK/three-journal-lines.jsonl" \
  "http://127.0.0.1:${PORT}/insert/jsonline?_time_field=_time&_msg_field=_msg&_stream_fields=service,host"
export AKMATORI_VL_INTEGRATION_URL="http://127.0.0.1:${PORT}"
cd "$AKMATORI_PATCHED_REPO/mcp-gateway"
go test ./internal/tools/victorialogs -run '^TestVictoriaLogsOfficialV154FiveFunctions$' -count=1 -v -timeout=60s
echo 'OFFICIAL_VICTORIALOGS_V154_ALL_FIVE_SOURCE_NATIVE_PASS'
