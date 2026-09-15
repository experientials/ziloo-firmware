"""On-board Rust product tests via a cargo-nextest archive.

The model: cross-compile the product's tests to aarch64 on the host and `cargo nextest archive`
them into a self-contained tarball, push it to the board, and run it *on the target* — real
hardware, real kernel, no emulation. See `make archive-help` for the build/push recipe.

Until a product crate with aarch64 tests exists, this skips: it looks for the archive and the
`cargo-nextest` runner on the board and runs them if present, otherwise reports why. This keeps
the contract in the suite without a red test.
"""
import pytest

pytestmark = pytest.mark.on_board

# Where `make push-archive` drops the artifacts on the board. Override via the board's env if you
# stage them elsewhere.
ARCHIVE = "/opt/hil/nextest-archive.tar.zst"
RUNNER = "cargo-nextest"  # a standalone aarch64 binary is enough; full cargo not required


def test_onboard_nextest_archive(ssh):
    _, _, rc = ssh.run(f"test -f {ARCHIVE}")
    if rc != 0:
        pytest.skip(f"no nextest archive on board at {ARCHIVE} (see `make archive-help`)")

    out, _, rc = ssh.run(f"command -v {RUNNER}")
    if rc != 0 or not out:
        pytest.skip(f"{RUNNER} not installed on board; drop the aarch64 musl binary in PATH")

    runner = out[0].strip()
    # --workspace-remap . lets tests that read CARGO_MANIFEST_DIR resolve against the extracted tree.
    out, err, rc = ssh.run(
        f"cd /opt/hil && {runner} nextest run --archive-file {ARCHIVE} --workspace-remap ."
    )
    assert rc == 0, "on-board nextest run failed:\n" + "\n".join(out + err)
