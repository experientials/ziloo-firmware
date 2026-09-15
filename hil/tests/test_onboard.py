"""On-board (native aarch64) HIL smoke tests — dispatched over SSHDriver."""
import pytest

pytestmark = pytest.mark.on_board


def test_arch_is_aarch64(ssh):
    out, _, rc = ssh.run("uname -srm")
    assert rc == 0 and "aarch64" in out[0]


def test_udc_in_device_mode(ssh):
    # USB1 (dwc3) must present a UDC for the CDC gadget to bind.
    out, _, rc = ssh.run("ls /sys/class/udc")
    assert rc == 0 and any("dwc3" in line for line in out)


def test_cdc_gadget_service_enabled(ssh):
    out, _, rc = ssh.run("systemctl is-enabled usb-gadget.service")
    assert rc == 0 and out and out[0].strip() == "enabled"


def test_cdc_usb0_present(ssh):
    # The ECM gadget interface exists (carrier depends on a host being attached).
    out, _, rc = ssh.run("cat /sys/class/net/usb0/address")
    assert rc == 0 and out and out[0].strip() == "02:22:82:a5:1f:12"
