#!/bin/bash

# Build runtime arguments array based on environment
USER_ARGS=("${@}")
ARGS=()

# Checks if ARGS already contains the given value
function hasArg {
    local element
    for element in "${@:2}"; do
        [ "${element}" == "${1}" ] && return 0
    done
    return 1
}

# Adds the given argument if it's not already specified.
function addArg {
    local arg="${1}"
    [ $# -ge 1 ] && local val="${2}"
    if ! hasArg "${arg}" "${USER_ARGS[@]}"; then
        ARGS+=("${arg}")
        [ $# -ge 1 ] && ARGS+=("${val}")
    fi

}
if [ -n "${DEBUG}" ]; then
    addArg "--debug"
    set -x
else
    addArg "--mute"
fi

# Initialize defaults
LISTEN_ADDR="${LISTEN_ADDR:-0.0.0.0}"
STUBS_PORT=${STUBSPORT:-8882}

# Keep watching git directory and generate new combined YAML file
while true; do
    if [ -d /stub-repo/stubs ]; then
        for file in $(find /stub-repo/stubs/ -name '*.yaml'); do
            if $(ruby -e "require 'yaml'; YAML.load_file('${file}')"); then
                cat $file >> /stub-repo/tmp-generated.yaml
            else
                echo "Skipping ${file}, contains invalid YAML"
            fi
        done
        mv /stub-repo/tmp-generated.yaml /stub-repo/generated.yaml
        ln -f -s /stub-repo/stubs/files /stub-repo/files

				# Watch repo for changes
        inotifywait -qq -e modify -e create -e delete /stub-repo/stubs

        # Give it time to settle
        sleep 10
    else
        # Watch repo directory for git repo initialization
        inotifywait -qq -e create /stub-repo

        # Give it time to settle
        sleep 10
    fi
done &

while [ ! -f /stub-repo/generated.yaml ]; do
    sleep 10
    echo "Waiting for generated.yaml"
done

addArg "--data" "/stub-repo/generated.yaml"

[ -n ${LISTEN_ADDR} ] && addArg "--location" $LISTEN_ADDR
[ -n ${STUBS_PORT} ]  && addArg "--stubs" $STUBS_PORT

if [ -n ${ADMIN_PORT} ]; then
    addArg "--admin" $ADMIN_PORT
else
    addArg "--disable_admin_portal"
fi

addArg "--watch"
addArg "--disable_ssl"

echo "$(date "+%a %b %d %H:%M:%S %Y") Running 'java -jar /stubby4j.jar ${ARGS[@]} ${USER_ARGS[@]}'"

exec java -jar /stubby4j.jar ${ARGS[@]} ${USER_ARGS[@]}
