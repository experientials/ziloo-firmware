#!/bin/sh
# usb-gadget.sh — bring up the UCM CDC-ECM network gadget on USB-C (USB1 / 38100000.dwc3).
#
# The board's network fast-path: a pure-software USB NIC (usb0) presented to whatever host the
# USB-C is plugged into — no Ethernet PHY needed (the module is non-'E'). ECM (not RNDIS) so
# macOS binds it with in-box drivers. Idempotent: tears down an existing 'ucm' gadget first, so
# it is safe to re-run and to invoke at boot from systemd.
#
# Env overrides: UCM_USB0_IP (default 10.55.0.1/24), UCM_GADGET_VID, UCM_GADGET_PID.
# The host can also reach the board over IPv6 link-local (no static IP needed on either side).
set -eu
export PATH=/usr/sbin:/sbin:/usr/bin:/bin:${PATH:-}

G=/sys/kernel/config/usb_gadget/ucm
IF_IP="${UCM_USB0_IP:-10.55.0.1/24}"
VID="${UCM_GADGET_VID:-0x1d6b}"     # Linux Foundation
PID="${UCM_GADGET_PID:-0x0104}"     # Multifunction Composite Gadget

mount | grep -q configfs || mount -t configfs none /sys/kernel/config

UDC="$(ls /sys/class/udc 2>/dev/null | head -1)"
[ -n "$UDC" ] || { echo "usb-gadget: no UDC — USB1 (38100000.dwc3) is not in device mode" >&2; exit 1; }

# --- teardown any existing gadget (configfs needs a specific unwind order) ---
if [ -d "$G" ]; then
  echo "" > "$G/UDC" 2>/dev/null || true
  for link in "$G"/configs/*/*.*; do [ -L "$link" ] && rm -f "$link"; done
  for d in "$G"/configs/*/strings/*; do [ -d "$d" ] && rmdir "$d"; done
  for d in "$G"/configs/*; do [ -d "$d" ] && rmdir "$d"; done
  for d in "$G"/functions/*; do [ -d "$d" ] && rmdir "$d"; done
  for d in "$G"/strings/*; do [ -d "$d" ] && rmdir "$d"; done
  rmdir "$G" 2>/dev/null || true
fi

# --- build the ECM gadget ---
mkdir -p "$G"; cd "$G"
echo "$VID" > idVendor
echo "$PID" > idProduct
mkdir -p strings/0x409
echo "0001"    > strings/0x409/serialnumber
echo "Thepia"  > strings/0x409/manufacturer
echo "UCM CDC" > strings/0x409/product
mkdir -p functions/ecm.usb0
# Fixed, locally-administered MACs so the board's usb0 (and its IPv6 link-local) are STABLE
# across rebinds/reboots — automation/daemon can rely on a deterministic address.
echo "${UCM_DEV_MAC:-02:22:82:a5:1f:12}"  > functions/ecm.usb0/dev_addr   # board side (usb0)
echo "${UCM_HOST_MAC:-02:22:82:a5:1f:11}" > functions/ecm.usb0/host_addr  # host side (Mac en*)
mkdir -p configs/c.1/strings/0x409
echo "CDC ECM" > configs/c.1/strings/0x409/configuration
ln -s functions/ecm.usb0 configs/c.1/
echo "$UDC" > UDC

# --- bring up the board-side interface ---
i=0; while [ ! -e /sys/class/net/usb0 ] && [ $i -lt 20 ]; do sleep 0.1; i=$((i+1)); done
ip addr add "$IF_IP" dev usb0 2>/dev/null || true
ip link set usb0 up
echo "usb-gadget: ECM up on usb0 ($IF_IP), bound to $UDC"
