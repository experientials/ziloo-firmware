#!/bin/sh
# usb-gadget.sh — bring up the UCM CDC-NCM network gadget on USB-C (USB1 / 38100000.dwc3).
#
# The board's network fast-path: a pure-software USB NIC (usb0) presented to whatever host the
# USB-C is plugged into — no Ethernet PHY needed (the module is non-'E'). **NCM, not ECM**: macOS's
# CDC-ECM support flaps (the link comes up but ARP never completes and usb0 carrier drops), whereas
# its NCM support is reliable; NCM also binds in-box on Linux/Windows. Idempotent: tears down an
# existing 'ucm' gadget (and any prior usb0 udhcpd) first, so it is safe to re-run and to invoke at
# boot from systemd.
#
# Env overrides: UCM_USB0_IP (default 10.55.0.1/24), UCM_GADGET_VID, UCM_GADGET_PID,
# UCM_HOST_DHCP (default 1 — serve the host its address so no manual config is needed),
# UCM_HOST_IP (default 10.55.0.2), UCM_HOST_MASK (default 255.255.255.0).
# The host can also reach the board over IPv6 link-local (no static IP needed on either side).
set -eu
export PATH=/usr/sbin:/sbin:/usr/bin:/bin:${PATH:-}

G=/sys/kernel/config/usb_gadget/ucm
IF_IP="${UCM_USB0_IP:-10.55.0.1/24}"
VID="${UCM_GADGET_VID:-0x1d6b}"     # Linux Foundation
PID="${UCM_GADGET_PID:-0x0104}"     # Multifunction Composite Gadget
FN=ncm.usb0

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
# stop a prior udhcpd bound to usb0, if any
if [ -f /run/udhcpd.usb0.pid ]; then kill "$(cat /run/udhcpd.usb0.pid)" 2>/dev/null || true; fi

# --- build the NCM gadget ---
mkdir -p "$G"; cd "$G"
echo "$VID" > idVendor
echo "$PID" > idProduct
mkdir -p strings/0x409
echo "0001"    > strings/0x409/serialnumber
echo "Thepia"  > strings/0x409/manufacturer
echo "UCM CDC" > strings/0x409/product
mkdir -p "functions/$FN"
# Fixed, locally-administered MACs so the board's usb0 (and its IPv6 link-local) are STABLE
# across rebinds/reboots — automation/daemon can rely on a deterministic address.
echo "${UCM_DEV_MAC:-02:22:82:a5:1f:12}"  > "functions/$FN/dev_addr"   # board side (usb0)
echo "${UCM_HOST_MAC:-02:22:82:a5:1f:11}" > "functions/$FN/host_addr"  # host side (Mac en*)
mkdir -p configs/c.1/strings/0x409
echo "CDC NCM" > configs/c.1/strings/0x409/configuration
ln -s "functions/$FN" configs/c.1/
echo "$UDC" > UDC

# --- bring up the board-side interface ---
# Bring the link UP first, then assign the address, so the kernel installs the connected route while
# the interface is up (assigning while down left no route, so replies used eth0's default gateway).
i=0; while [ ! -e /sys/class/net/usb0 ] && [ $i -lt 20 ]; do sleep 0.1; i=$((i+1)); done
ip link set usb0 up
ip addr replace "$IF_IP" dev usb0
# Belt-and-braces: make sure the connected /24 route points at usb0.
ADDR="${IF_IP%/*}"; PFX="${IF_IP#*/}"
NET="$(echo "$ADDR" | cut -d. -f1-3).0/$PFX"
ip route replace "$NET" dev usb0 2>/dev/null || ip route add "$NET" dev usb0 2>/dev/null || true
echo "usb-gadget: NCM up on usb0 ($IF_IP), bound to $UDC"

# --- optionally serve the host its address (zero-touch host config) ---
if [ "${UCM_HOST_DHCP:-1}" = "1" ] && command -v udhcpd >/dev/null 2>&1; then
  HOST_IP="${UCM_HOST_IP:-10.55.0.2}"
  MASK="${UCM_HOST_MASK:-255.255.255.0}"
  CONF=/run/udhcpd.usb0.conf
  cat > "$CONF" <<EOF
start $HOST_IP
end $HOST_IP
interface usb0
max_leases 1
option subnet $MASK
lease_file /run/udhcpd.usb0.leases
pidfile /run/udhcpd.usb0.pid
EOF
  : > /run/udhcpd.usb0.leases
  if udhcpd "$CONF" 2>/dev/null; then
    echo "usb-gadget: udhcpd serving $HOST_IP on usb0 (host can use DHCP or a static IP)"
  else
    echo "usb-gadget: udhcpd failed to start; host can still use a static IP ($HOST_IP)"
  fi
fi
