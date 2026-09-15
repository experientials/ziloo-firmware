"""pytest config for the UCM HIL harness.

Board access comes from the labgrid pytest plugin (set LG_ENV=environment.yaml). The `target`
fixture is the `main` target from environment.yaml. Tests are split into two tiers by marker:

  @pytest.mark.on_board  — runs *on* the board (native aarch64), dispatched over SSHDriver.
  @pytest.mark.host      — runs on the host (Mac/Pi), asserting the board's external behaviour.

Two transports are available and picked explicitly by fixture:
  ssh            — SSHDriver, the network fast path (default for on-board tests).
  serial_shell   — ShellDriver over the CP2104 console; the out-of-band path. SKIPS when the
                   serial device isn't attached to this host, so network-only hosts still run.
"""
import os
import subprocess
import time

import pytest


def pytest_addoption(parser):
    parser.addoption(
        "--uboot", action="store_true", default=False,
        help="run opt-in U-Boot tests (need the autoboot countdown interrupted after a reset)",
    )


def pytest_configure(config):
    config.addinivalue_line("markers", "on_board: test executes on the DUT (via SSHDriver)")
    config.addinivalue_line("markers", "host: test executes on the host, asserting DUT behaviour")
    config.addinivalue_line("markers", "serial: test uses the out-of-band serial console")
    config.addinivalue_line("markers", "reboot: test reboots the board (slow; re-establishes access)")
    config.addinivalue_line("markers", "uboot: opt-in; needs the autoboot countdown interrupted")


# --- network (SSH) -------------------------------------------------------------------------

@pytest.fixture
def ssh(target):
    """Activated SSHDriver for the board — `out, err, rc = ssh.run('...')`."""
    drv = target.get_driver("SSHDriver")
    target.activate(drv)
    return drv


@pytest.fixture
def board_address(target):
    """The board's network address from the labgrid env (host-tier tests)."""
    return target.get_resource("NetworkService").address


# --- serial (out-of-band console) ----------------------------------------------------------

def _serial_port_present(target):
    """True if the RawSerialPort device node actually exists on this host."""
    try:
        res = target.get_resource("RawSerialPort")
    except Exception:
        return False
    return bool(getattr(res, "port", None)) and os.path.exists(res.port)


@pytest.fixture
def serial_shell(target):
    """Activated ShellDriver over the CP2104 console — `out, err, rc = serial_shell.run('...')`.

    Skips (does not fail) when the serial device isn't attached, so the suite stays green on a
    network-only host. This is the path that must work when the network is down.
    """
    if not _serial_port_present(target):
        pytest.skip("serial console not attached to this host (no RawSerialPort device node)")
    drv = target.get_driver("ShellDriver")
    try:
        target.activate(drv)
    except Exception as e:  # port busy (another console holder), or login/prompt probe failed
        pytest.skip(f"serial console unavailable: {e}")
    yield drv
    target.deactivate(drv)


@pytest.fixture
def serial_console(target):
    """Activated SerialDriver (raw ConsoleProtocol) — for boot-log observation, not shell exec.

    Use `.write(b'...')` / `.expect(pattern)`. Skips when the device isn't attached.
    """
    if not _serial_port_present(target):
        pytest.skip("serial console not attached to this host (no RawSerialPort device node)")
    drv = target.get_driver("SerialDriver")
    try:
        target.activate(drv)
    except Exception as e:
        pytest.skip(f"serial console unavailable: {e}")
    yield drv
    target.deactivate(drv)


# --- helpers ---------------------------------------------------------------------------------

def host_run(cmd):
    """Run a command on the host, return (rc, stdout)."""
    p = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return p.returncode, p.stdout


def uptime_seconds(command_driver):
    """Read /proc/uptime over any labgrid CommandProtocol driver (ssh or serial_shell)."""
    out, _, rc = command_driver.run("cat /proc/uptime")
    assert rc == 0 and out, "could not read /proc/uptime"
    return float(out[0].split()[0])


def boot_id(command_driver):
    """The kernel boot id — a UUID regenerated every boot. Differs iff the board actually rebooted."""
    out, _, rc = command_driver.run("cat /proc/sys/kernel/random/boot_id")
    assert rc == 0 and out, "could not read boot_id"
    return out[0].strip()


def _fresh_ssh(target):
    """Reactivate the SSHDriver so it dials a new connection (the ControlMaster socket goes stale
    across a reboot). Raises if the board isn't answering."""
    drv = target.get_driver("SSHDriver")
    try:
        target.deactivate(drv)
    except Exception:
        pass
    target.activate(drv)
    out, _, rc = drv.run("true")
    if rc != 0:
        raise ConnectionError("ssh reachable but shell not ready")
    return drv


def reconnect_ssh(target, timeout=180, interval=3):
    """Retry a fresh SSH connection until the board answers or `timeout` elapses. Returns the
    driver. Uses time.monotonic (no wall-clock dependency)."""
    deadline = time.monotonic() + timeout
    last = None
    while time.monotonic() < deadline:
        try:
            return _fresh_ssh(target)
        except Exception as e:
            last = e
            time.sleep(interval)
    raise TimeoutError(f"board did not come back on SSH within {timeout}s (last: {last})")


def wait_for_new_boot(target, before_id, timeout=180, interval=3):
    """Poll boot_id over fresh SSH connections until it differs from `before_id`, proving a real
    reboot completed. Race-free: while the board is still up (or briefly down) the id is unchanged
    or the connection fails, so it keeps polling; it only returns once a *new* boot is up. Returns
    the new boot_id."""
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        try:
            drv = _fresh_ssh(target)
            now = boot_id(drv)
            if now != before_id:
                return now
        except Exception:
            pass  # board down mid-reboot, or not yet back — keep polling
        time.sleep(interval)
    raise TimeoutError(f"boot_id never changed within {timeout}s (still {before_id}) — no reboot")
