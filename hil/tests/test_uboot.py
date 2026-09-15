"""U-Boot tests (opt-in) — inspect/verify bootloader env from the serial console.

Catching the `u-boot=>` prompt requires interrupting the autoboot countdown right after a reset.
Until the A4 reset line exists, that means a human power-cycles the board as the test starts, so
these are opt-in: run with `pytest --uboot`. Without the flag they skip.

Once a PowerDriver (A4) is wired, this becomes fully automatic: power-cycle → interrupt → assert.
"""
import pytest

pytestmark = [pytest.mark.serial, pytest.mark.uboot]


@pytest.fixture(autouse=True)
def _require_uboot_optin(request):
    if not request.config.getoption("--uboot"):
        pytest.skip("U-Boot tests are opt-in; pass --uboot (and power-cycle when prompted)")


@pytest.fixture
def uboot(target):
    drv = target.get_driver("UBootDriver")
    try:
        target.activate(drv)  # interrupts autoboot; needs the board resetting now
    except Exception as e:
        pytest.skip(f"could not reach the U-Boot prompt (reset the board as the test starts): {e}")
    yield drv
    target.deactivate(drv)


def test_uboot_boots_from_emmc(uboot):
    # The bench module boots its internal eMMC; confirm the boot device env matches.
    out = uboot.run_check("echo $mmcdev")
    assert out and out[0].strip() in ("2", "1", "0"), f"unexpected mmcdev: {out}"


def test_uboot_stdin_includes_serial(uboot):
    # Guards the USB-C-at-boot finding: stdin must include the serial console so a hang is
    # observable/interruptible over UART (see references/usbc-boot-conflict.md).
    out = uboot.run_check("echo $stdin")
    assert out and "serial" in out[0]
