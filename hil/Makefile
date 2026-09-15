# UCM HIL harness — pytest + labgrid.
# `make test` sets up the venv and runs the suite against the board in environment.yaml.
VENV := .venv
export LG_ENV := environment.yaml
# macOS: SSHDriver's ControlMaster socket lives under $TMPDIR; the default /var/folders/... path
# overflows the 104-char unix-socket limit ("unix_listener: path too long"). Keep it short.
export TMPDIR := /tmp

.PHONY: venv test quick onboard host serial reboot uboot clean archive-help

venv: $(VENV)/.stamp
$(VENV)/.stamp: requirements.txt
	uv venv $(VENV)
	VIRTUAL_ENV=$(VENV) uv pip install -r requirements.txt
	touch $@

test: venv          ## run the full HIL suite (incl. reboot cycle — slow)
	$(VENV)/bin/pytest -v

quick: venv         ## everything except the slow reboot tests
	$(VENV)/bin/pytest -v -m 'not reboot'

onboard: venv       ## on-board tests only (SSH + serial), no reboot
	$(VENV)/bin/pytest -v -m 'on_board and not reboot'

host: venv          ## host-controlled tests only
	$(VENV)/bin/pytest -v -m host

serial: venv        ## out-of-band serial-console tests only
	$(VENV)/bin/pytest -v -m 'serial and not uboot and not reboot'

reboot: venv        ## reboot cycle tests only (soft reset + re-establish)
	$(VENV)/bin/pytest -v -m reboot

uboot: venv         ## opt-in U-Boot tests (power-cycle the board when they start)
	$(VENV)/bin/pytest -v --uboot -m uboot

clean:
	rm -rf $(VENV) .pytest_cache tests/__pycache__ __pycache__

archive-help:       ## how to build+push the on-board Rust nextest archive (test_product.py)
	@echo 'Build the product tests for the board and run them ON the board:'
	@echo '  1. rustup target add aarch64-unknown-linux-gnu   # or ...-musl for a static runner'
	@echo '  2. cargo nextest archive --release \'
	@echo '       --target aarch64-unknown-linux-gnu \'
	@echo '       --archive-file /tmp/nextest-archive.tar.zst'
	@echo '  3. ssh root@ucm-imx8m-plus.local mkdir -p /opt/hil'
	@echo '     ssh root@ucm-imx8m-plus.local "cat > /opt/hil/nextest-archive.tar.zst" < /tmp/nextest-archive.tar.zst'
	@echo '     # board has no sftp-server, so pipe over ssh (not scp)'
	@echo '  4. drop a static aarch64 cargo-nextest binary in the board PATH, then: make onboard'
