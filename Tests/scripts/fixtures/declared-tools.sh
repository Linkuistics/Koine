# shellcheck shell=bash
# The executables and the spec directory that the real evidence backend binds.
# No VM, agent or app is contacted.

# declare_tools CLI: init records CLI and the real jq, and each attempt runs
# them. A configuration file of comments and one empty map, as on the host,
# keeps the host file out. XDG_STATE_HOME holds the synthetic clone specs.
declare_tools() {
    export KOINE_TESTANYWARE_CLI="$1"
    KOINE_JQ="$(python3 -I -c 'import os, shutil; print(os.path.realpath(shutil.which("jq")))')"
    export KOINE_JQ
    export XDG_STATE_HOME="${BATS_TEST_TMPDIR}/state" TESTANYWARE_CONFIG="${BATS_TEST_TMPDIR}/config.rhai"
    declare_config
    unset TESTANYWARE_APP_SOCKET
}

# declare_config: the configuration file of comments and one empty map.
declare_config() {
    printf '// This file names no setting.\n#{\n    // state_dir: "/elsewhere",\n}\n' \
        >"${BATS_TEST_TMPDIR}/config.rhai"
}

# declare_clone_spec VM [PORT]: the spec that `vm start` writes for VM.
declare_clone_spec() {
    mkdir -p "${XDG_STATE_HOME}/testanyware/vms"
    printf '{"vnc":{"host":"127.0.0.1","port":5901},"agent":{"host":"192.0.2.4","port":%s},"platform":"macos"}\n' \
        "${2:-8648}" >"${XDG_STATE_HOME}/testanyware/vms/$1.json"
}
