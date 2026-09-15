"""Serial console (out-of-band) tests — the path that must work when the network is down.

Driven over the CP2104 via labgrid's ShellDriver/SerialDriver. These skip cleanly when the
serial device isn't attached to the host (see conftest `serial_shell`/`serial_console`).
"""
import pytest

pytestmark = [pytest.mark.on_board, pytest.mark.serial]


def test_serial_shell_reaches_prompt(serial_shell):
    # ShellDriver activation already proved it found the auto-root prompt; confirm it can run a
    # command and read output back over the 115200 8N1 link.
    out, _, rc = serial_shell.run("echo __hil__ok__")
    assert rc == 0 and any("__hil__ok__" in line for line in out)


def test_serial_arch_is_aarch64(serial_shell):
    # Same assertion as the SSH tier, but proving it over the recovery channel.
    out, _, rc = serial_shell.run("uname -m")
    assert rc == 0 and out and out[0].strip() == "aarch64"


def test_serial_command_exit_code(serial_shell):
    # The sentinel/exit-code contract the daemon's console.exec will rely on: a failing command
    # must surface a non-zero code, not just empty output.
    _, _, rc = serial_shell.run("false")
    assert rc != 0
