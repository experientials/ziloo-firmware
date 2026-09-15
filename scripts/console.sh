#!/usr/bin/env bash
#
# console.sh — reliable serial console access to the UCM-iMX8M-Plus board (macOS).
#
# Why this exists: the board's only dependable channel right now is the CP2104 USB-UART
# bridge (Ethernet DMA init fails on the current 5.10-gatesgarth image, so SSH is not a
# reliable fallback — see docs/CONSOLE.md). This wraps picocom with the right settings,
# resolves the device by the adapter's *serial number* (stable across replug, unlike the
# location-based /dev/*.usbmodem names), can wait for the board to appear, detects a port
# that another session already holds, and logs every session for the record.
#
# Usage:
#   scripts/console.sh                 # connect at 115200 to the UCM console
#   scripts/console.sh --wait          # wait (poll) for the adapter, then connect
#   scripts/console.sh --reconnect     # auto-reconnect if the USB link drops
#   scripts/console.sh --list          # list candidate USB-serial devices and exit
#   scripts/console.sh -b 115200       # override baud
#   scripts/console.sh --capture 30    # NON-INTERACTIVE: record N s (correct 8N1), print+log — good for boot logs
#   scripts/console.sh --exec "CMD"    # NON-INTERACTIVE: run CMD on the board shell, print the response
#
# Env:
#   UCM_CONSOLE_SERIAL   CP2104 serial number (default: 0236DC3C — this bench's adapter)
#   UCM_CONSOLE_DEV      full device path, bypasses serial-number resolution entirely
#
# Quit picocom with:  Ctrl-a Ctrl-x
set -euo pipefail

BAUD=115200
SERIAL="${UCM_CONSOLE_SERIAL:-0236DC3C}"
WAIT=0
RECONNECT=0
LOGDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/docs/console-logs"
DO_LOG=1
CAPTURE=0        # --capture N : passive record for N seconds
EXECCMD=""       # --exec CMD  : run CMD on the board shell
EXEC_SET=0

die() { echo "console.sh: $*" >&2; exit 1; }

# Canonical 8N1 raw at $BAUD — the framing picocom uses. Getting cs8/parity/stopbits wrong
# yields high-bit garbage, so set them explicitly (don't rely on the port's leftover state).
configure_tty() {
  stty -f "$1" "$BAUD" cs8 -parenb -cstopb -crtscts clocal cread -icanon -isig -ixon -ixoff -echo -opost 2>/dev/null \
    || stty -f "$1" "$BAUD" raw -echo 2>/dev/null
}

list_devices() {
  # macOS names Silicon Labs CP210x nodes /dev/{cu,tty}.usbserial-<SERIAL>.
  # Prefer cu.* (callout: open() does not block waiting for carrier detect).
  ls /dev/cu.usbserial-* 2>/dev/null || true
}

resolve_dev() {
  # 1) explicit override wins
  if [[ -n "${UCM_CONSOLE_DEV:-}" ]]; then echo "$UCM_CONSOLE_DEV"; return; fi
  # 2) by serial number (the stable anchor)
  local by_serial="/dev/cu.usbserial-${SERIAL}"
  if [[ -e "$by_serial" ]]; then echo "$by_serial"; return; fi
  # 3) fall back to a lone CP2104 if there's exactly one
  local -a found; found=($(list_devices))
  if [[ ${#found[@]} -eq 1 ]]; then echo "${found[0]}"; return; fi
  if [[ ${#found[@]} -gt 1 ]]; then
    echo "console.sh: multiple USB-serial devices found; set UCM_CONSOLE_SERIAL:" >&2
    printf '  %s\n' "${found[@]}" >&2
    exit 1
  fi
  return 1   # nothing present
}

# --- args ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    -b|--baud)   BAUD="$2"; shift 2;;
    --wait)      WAIT=1; shift;;
    --reconnect) RECONNECT=1; WAIT=1; shift;;   # reconnect implies wait-for-return
    --no-log)    DO_LOG=0; shift;;
    --capture)   CAPTURE="$2"; shift 2;;
    --exec)      EXECCMD="$2"; EXEC_SET=1; shift 2;;
    --list)      list_devices; exit 0;;
    -h|--help)   sed -n '2,30p' "$0"; exit 0;;
    *) die "unknown arg: $1 (try --help)";;
  esac
done

command -v picocom >/dev/null 2>&1 || die "picocom not found — 'brew install picocom' (or use: screen <dev> $BAUD)"

# --- wait for the adapter if asked ---
if [[ $WAIT -eq 1 ]]; then
  tries=0
  until DEV="$(resolve_dev)"; do
    [[ $((tries++)) -eq 0 ]] && echo "Waiting for UCM console (serial ${SERIAL})… power/plug the board."
    sleep 1
  done
else
  DEV="$(resolve_dev)" || die "UCM console not found (looked for /dev/cu.usbserial-${SERIAL}). Plug in the adapter, or run with --wait, or set UCM_CONSOLE_DEV."
fi

# --- refuse to fight an existing session ---
# cu.* and tty.* are two device files over the SAME UART, so a session on either one
# conflicts. Check both before opening.
TTYDEV="${DEV/cu./tty.}"
holder="$(lsof -t "$DEV" "$TTYDEV" 2>/dev/null | head -1 || true)"
if [[ -n "$holder" ]]; then
  die "console already open by PID $holder ($(ps -p "$holder" -o comm= 2>/dev/null | tr -d ' ')) on $(lsof -p "$holder" -Fn 2>/dev/null | grep -m1 usbserial | cut -c2-). Close it (Ctrl-a Ctrl-x) or 'kill $holder'."
fi

# --- non-interactive modes (built on picocom — the reliable primitive) ---
# Raw stty+cat produced garbled framing; picocom sets termios correctly, so reuse it via its
# --logfile (-g) + --exit-after (-x) + --initstring (-t) flags. Explicit 8N1 (-y n -d 8 -p 1),
# --noreset so opening the port doesn't toggle DTR and reset the board.
PICO=(picocom -b "$BAUD" -y n -d 8 -p 1 --noreset -q)
# --exec: send CMD, capture the response window, print.
if [[ $EXEC_SET -eq 1 ]]; then
  dur="$CAPTURE"; [[ "$dur" == "0" ]] && dur=5
  logf="$(mktemp -t ucmexec)"
  "${PICO[@]}" --initstring "$(printf '%s\r' "$EXECCMD")" -g "$logf" -x $(( dur * 1000 )) "$DEV" </dev/null >/dev/null 2>&1 || true
  tr -d '\000' < "$logf"; rm -f "$logf"
  exit 0
fi
# --capture: passive timed capture via picocom logfile. Good for boot logs; run backgrounded
# (redirect stdout to a file, tail it) as the "never miss output" monitor.
if [[ "$CAPTURE" != "0" ]]; then
  logf="$(mktemp -t ucmcap)"
  "${PICO[@]}" -g "$logf" -x $(( CAPTURE * 1000 )) "$DEV" </dev/null >/dev/null 2>&1 || true
  tr -d '\000' < "$logf"; rm -f "$logf"
  exit 0
fi

LOGARGS=()
if [[ $DO_LOG -eq 1 ]]; then
  mkdir -p "$LOGDIR"
  LOGFILE="$LOGDIR/console-$(date +%Y%m%d-%H%M%S).log"
  LOGARGS=(--logfile "$LOGFILE")
  echo "Logging session to $LOGFILE"
fi

echo "Connecting to $DEV @ ${BAUD} 8N1  (quit: Ctrl-a Ctrl-x)"

# ${arr[@]+...} guard: macOS ships bash 3.2, where an empty array under `set -u` is an error.
run_picocom() { picocom -b "$BAUD" ${LOGARGS[@]+"${LOGARGS[@]}"} "$DEV"; }

if [[ $RECONNECT -eq 0 ]]; then
  exec picocom -b "$BAUD" ${LOGARGS[@]+"${LOGARGS[@]}"} "$DEV"
fi

# --reconnect: loop, but honor a clean quit (picocom exits 0 on Ctrl-a Ctrl-x).
while true; do
  if run_picocom; then
    echo "console.sh: clean exit."; break
  fi
  echo "console.sh: link dropped — waiting for $DEV to return… (Ctrl-c to stop)"
  until DEV="$(resolve_dev)"; do sleep 1; done
done
