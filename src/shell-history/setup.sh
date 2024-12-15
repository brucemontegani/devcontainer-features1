#!/bin/bash
set -e

# Read feature options
INCLUDE_BASH="${INCLUDEBASH:-"true"}"
INCLUDE_ZSH="${INCLUDEZSH:-"false"}"
INCLUDE_FISH="${INCLUDEFISH:-"false"}"

MOUNT_TGT="/var/data/shell-history"

echo "Current User: $(whoami)"
# "${_REMOTE_USER:=$(id -un)}"
# "${_CONTAINER_USER:=$(id -un)}"

echo "_REMOTE_USER: ${_REMOTE_USER:-unset}"
echo "_CONTAINER_USER: ${_CONTAINER_USER:-unset}"


# "${_CONTAINER_USER:=$(id -un)}"     # Default to root if _CONTAINER_USER is not set
# "${_REMOTE_USER:=$_CONTAINER_USER}" # Default _REMOTE_USER to _CONTAINER_USER if blank

USER_NAME="${_REMOTE_USER:=$(id -un)}"

echo "Remote User: ${USER_NAME}"
echo "Container User: ${_CONTAINER_USER}"
echo "Current User: $(whoami)"

# Ensure the user exists
if ! id "$USER_NAME" >/dev/null 2>&1; then
    echo "User '$USER_NAME' does not exist. Exiting."
    exit 1
fi

sudo -i    # Run the following section as sudo

# Create shell history directory if it doesn't already exist
HISTORY_DIR="${MOUNT_TGT}/${USER_NAME}"
echo "HISTORY_DIR: ${HISTORY_DIR}"
if [ ! -d "$HISTORY_DIR" ]; then
    echo "${HISTORY_DIR} being created"

    mkdir -p "$HISTORY_DIR"
    echo "Created $HISTORY_DIR"
fi


# Create Bash history file if it doesn't already exist
if [ "${INCLUDE_BASH}" = "true" ]; then
    BASH_HIST_FILE="${HISTORY_DIR}/bash_history"
    if [ ! -f "$BASH_HIST_FILE" ]; then
        touch $BASH_HIST_FILE
        echo "Created $BASH_HIST_FILE"
    fi
fi

# Create Zsh history file if it doesn't already exist
if [ "${INCLUDE_ZSH}" = "true" ]; then
    ZSH_HIST_FILE="${HISTORY_DIR}/zsh_history"
    if [ ! -f "$ZSH_HIST_FILE" ]; then
        touch $ZSH_HIST_FILE
        echo "Created $ZSH_HIST_FILE"
    fi
fi


if [ ${INCLUDE_FISH} = "true" ]; then
    FISH_HIST_FILE="${HISTORY_DIR}/fish_history"
    if [ ! -f "$FISH_HIST_FILE" ]; then
        touch $FISH_HIST_FILE
        echo "Created $FISH_HIST_FILE"
    fi
fi

chown -R "$USER_NAME:$USER_NAME" "$HISTORY_DIR"

exit

echo "Per-user shell history setup for '$USER_NAME'."
