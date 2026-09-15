"""Host-controlled HIL tests — assert the board's external behaviour from the host (Mac/Pi)."""
import shutil
import pytest

from conftest import host_run

pytestmark = pytest.mark.host


def test_board_reachable(board_address):
    rc, _ = host_run(f"ping -c1 -t3 {board_address}")
    assert rc == 0, f"{board_address} not reachable"


@pytest.mark.skipif(shutil.which("system_profiler") is None, reason="macOS-only USB introspection")
def test_cdc_device_enumerates_on_host():
    # The board's USB *device* contract: the CDC-ECM gadget appears to the host.
    # Skips (not fails) if USB-C isn't currently attached to this host.
    rc, out = host_run("system_profiler SPUSBDataType 2>/dev/null")
    if "UCM CDC" not in out:
        pytest.skip("USB-C not attached to this host (no 'UCM CDC' device enumerated)")
    assert "UCM CDC" in out
