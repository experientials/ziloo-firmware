FROM base-repo-image as facial-gate
WORKDIR /workspace
RUN repo sync -m rv1126_rv1109_linux_20210904_facial_gate.xml -c
