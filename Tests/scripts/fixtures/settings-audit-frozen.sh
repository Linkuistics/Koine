# shellcheck shell=bash disable=SC2154 # The caller sets tool and frozen.
# A synthetic frozen subject for the audit controls: a bundle, one other input
# and a stopped golden image, all in local directories. No VM or guest exists.
# The caller sets `tool` and `frozen`.

# frozen_prepare: create the subject, and a guest copy of the installed bundle.
frozen_prepare() {
    mkdir -p "${frozen}/Koine.app/Contents/MacOS" "${frozen}/Koine.app/Contents/Resources" "${frozen}/golden"
    printf 'koine executable\n' >"${frozen}/Koine.app/Contents/MacOS/Koine"
    printf 'info property list\n' >"${frozen}/Koine.app/Contents/Info.plist"
    ln -s ../MacOS/Koine "${frozen}/Koine.app/Contents/Resources/current"
    printf 'tasks\n' >"${frozen}/Taskfile.yml"
    printf 'config\n' >"${frozen}/golden/config.json"
    printf 'disk\n' >"${frozen}/golden/disk.img"
    printf 'nvram\n' >"${frozen}/golden/nvram.bin"
    cp -R "${frozen}/Koine.app" "${frozen}/guest-bundle"
    export guest_bundle="${frozen}/guest-bundle"
}

# frozen_receipt SET FILE: write the readiness receipt of one set. The
# executables are the ones that declare_tools declared.
frozen_receipt() {
    local bundle taskfile golden cli decoder
    bundle="$(python3 -I "${tool}" inventory "${frozen}/Koine.app" bundle)"
    taskfile="$(python3 -I "${tool}" inventory "${frozen}/Taskfile.yml" taskfile)"
    golden="$(python3 -I "${tool}" inventory "${frozen}/golden" golden)"
    cli="$(python3 -I "${tool}" inventory "${KOINE_TESTANYWARE_CLI}" testanyware)"
    decoder="$(python3 -I "${tool}" inventory "${KOINE_JQ}" jq)"
    jq -n --arg set "$1" --argjson bundle "${bundle}" --argjson taskfile "${taskfile}" \
        --argjson golden "${golden}" --argjson cli "${cli}" --argjson decoder "${decoder}" \
        --arg state "${XDG_STATE_HOME}/testanyware" --arg config "${TESTANYWARE_CONFIG}" '{
            schema: 1,
            set: $set,
            environment: {
                product_version: "27.0.1",
                product_version_extra: null,
                build_version: "26A434",
                arch: "arm64",
                assessments: "enabled"
            },
            process_arguments: "/Applications/Koine.app/Contents/MacOS/Koine",
            inputs: [$bundle, $taskfile, $cli, $decoder],
            golden: $golden,
            testanyware_paths: {state_dir: $state, config: $config}
        }' >"$2"
}
