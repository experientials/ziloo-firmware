"""Reboot tests — soft reset over each transport, then re-establish access.

These are slow (a full boot cycle, ~30-60 s) and marked `reboot` so they can be excluded from a
quick run: `pytest -m 'not reboot'`. No hardware reset line is needed — the board is responsive,
so a soft `reboot` suffices. Hung-board (hard-reset) recovery is the deferred A4 tier.
"""
import pytest

from conftest import boot_id, reconnect_ssh, wait_for_new_boot

pytestmark = [pytest.mark.on_board, pytest.mark.reboot]


def test_soft_reboot_over_ssh(ssh, target):
    """`reboot` over the network path; board comes back with a new kernel boot_id.

    boot_id (not uptime) is the reliable signal: it changes iff a real reboot happened, so
    polling for it can't be fooled by reconnecting during the ~1s pre-shutdown window.
    """
    before = boot_id(ssh)
    # Detach the reboot from the SSH channel so closing the connection doesn't abort it.
    ssh.run("(sleep 1; systemctl reboot) >/dev/null 2>&1 &")
    after = wait_for_new_boot(target, before, timeout=180)
    assert after != before, "boot_id unchanged — board did not reboot"


def test_soft_reboot_observed_on_serial(ssh, target, serial_console):
    """Trigger the reboot over SSH, watch the boot happen on the out-of-band console.

    This is the cross-transport proof: the network path issues the command, the serial console
    (which survives a dead network) witnesses U-Boot/kernel come back up. Skips if serial isn't
    attached.
    """
    ssh.run("(sleep 1; systemctl reboot) >/dev/null 2>&1 &")
    # U-Boot banner is the earliest deterministic marker on this NXP image.
    idx = serial_console.expect(r"U-Boot (SPL )?20\d\d", timeout=120)[0]
    assert idx == 0, "did not observe U-Boot banner on the serial console after reboot"
    # And Linux userspace returns.
    reconnect_ssh(target, timeout=180)
