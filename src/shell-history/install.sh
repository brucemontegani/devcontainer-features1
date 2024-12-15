#!/bin/bash

set -e

print_message() {
    message_title=$1
    message=$2
    output_format=$(echo "$3" | tr "[:upper:]" "[:lower:]")
    if [[ $output_format == "info" ]]; then
        echo -e "INFO-> $message_title: $message"
    elif [[ $output_format == "debug" ]]; then
        echo -e "DEBUG-> $message_title: $message"
    else
        echo -e "UNKNOWN_FORMAT-> $message_title: $message"
    fi
}

user_exists() {
    local username="$1"
    getent passwd "$username" >/dev/null 2>&1
}


# Read feature options
INCLUDE_BASH="${INCLUDEBASH:-"true"}"
INCLUDE_ZSH="${INCLUDEZSH:-"false"}"
INCLUDE_FISH="${INCLUDEFISH:-"false"}"

MOUNT_TGT="/var/data/shell-history"

print_message "_REMOTE_USER" "${_REMOTE_USER}" "info"

USER_NAME="${_REMOTE_USER:-vscode}"
USER_HOME="/home/$USER_NAME"

# Check for user existence and create if necessary
user_exists "$USER_NAME" && echo "User '$USER_NAME' already exists." || {
    echo "User '$USER_NAME' does not exist. Creating user..." &&
    useradd -m -d "$USER_HOME" "$USER_NAME" &&
    echo "User '$USER_NAME' created successfully with home directory: $USER_HOME." &&
    _REMOTE_USER_HOME="$USER_HOME"  ||
    { echo "Failed to create user '$USER_NAME'."; exit 1;}
}

print_message "_REMOTE_USER" "${_REMOTE_USER}" "info"
print_message "_REMOTE_USER_HOME" "${_REMOTE_USER_HOME}" "info"


# echo "REMOTE_USER=${_REMOTE_USER}"
echo "REMOTE_USER_HOME=${_REMOTE_USER_HOME}"
echo "CONTAINER_USER=${_CONTAINER_USER}"
echo "CONTAINER_USER_HOME=${_CONTAINER_USER_HOME}"
echo "ACTUAL_USER: ${USER_NAME}"
echo "ACTUAL_USER_HOME: ${USER_HOME}"
echo "CURRENT_USER: $(whoami)"

# Ensure the user exists
if ! id "$USER_NAME" >/dev/null 2>&1; then
    echo "User '$USER_NAME' does not exist. Exiting."
    exit 1
fi
# Set shell history directory
HISTORY_DIR="${MOUNT_TGT}/${USER_NAME}"
echo "HISTORY_DIR: ${HISTORY_DIR}"
# if [ ! -d "$HISTORY_DIR" ]; then
#     echo "${HISTORY_DIR} being created"

#     mkdir -p "$HISTORY_DIR"
#     echo "Created $HISTORY_DIR"
# fi

# chown -R "$USER_NAME:$USER_NAME" "$HISTORY_DIR"

# Configure Bash history
if [ "${INCLUDE_BASH}" = "true" ]; then
    BASH_HIST_FILE="${HISTORY_DIR}/bash_history"
    # if [ ! -f "$BASH_HIST_FILE" ]; then
    #     touch $BASH_HIST_FILE
    #     echo "Created $BASH_HIST_FILE"
    # fi

    # Create .bashrc file if it doesn't exist already
    BASHRC_FILE="$USER_HOME/.bashrc"
    if [ ! -f "$BASHRC_FILE" ]; then
        touch $BASHRC_FILE
        echo "Created $BASHRC_FILE"
    fi

    echo "export HISTFILE=${BASH_HIST_FILE}" >>"$BASHRC_FILE"
    echo "export HISTSIZE=1000" >>"$BASHRC_FILE"
    echo "export HISTFILESIZE=2000" >>"$BASHRC_FILE"
    echo "export PROMPT_COMMAND='history -a; history -n'" >>"$BASHRC_FILE"
    echo "Updated $BASHRC_FILE"
fi

# Configure Zsh history
if [ "${INCLUDE_ZSH}" = "true" ]; then
    ZSH_HIST_FILE="${HISTORY_DIR}/zsh_history"
    # if [ ! -f "$ZSH_HIST_FILE" ]; then
    #     touch $ZSH_HIST_FILE
    #     echo "Created $ZSH_HIST_FILE"
    # fi

    ZSHRC_FILE="$USER_HOME/.bashrc"
    if [ ! -f "$ZSHRC_FILE" ]; then
        touch $ZSHRC_FILE
        echo "Created $ZSHRC_FILE"
    fi

    echo "export HISTFILE=${ZSH_HIST_FILE}" >>"$ZSHRC_FILE"
    echo "export HISTSIZE=1000" >>"$ZSHRC_FILE"
    echo "export HISTFILESIZE=2000" >>"$ZSHRC_FILE"
    echo "export PROMPT_COMMAND='history -a; history -n'" >>"$ZSHRC_FILE"
    echo "Updated $ZSHRC_FILE"
fi


if [ ${INCLUDE_FISH} = "true" ]; then
    FISH_HIST_FILE="${HISTORY_DIR}/fish_history"
    # if [ ! -f "$FISH_HIST_FILE" ]; then
    #     touch $FISH_HIST_FILE
    #     echo "Created $FISH_HIST_FILE"
    # fi

    FISH_CONFIG_DIR="$USER_HOME/.config/fish"
    mkdir -p "$FISH_CONFIG_DIR"
    FISH_CONFIG_FILE="$FISH_CONFIG_DIR/config.fish"
    #   ln -sf "$HISTORY_DIR/fish_history" "$HISTORY_DIR/fish/fish_history"
    echo "set -U fish_history ${FISH_HIST_FILE}" >"$FISH_CONFIG_FILE"
    echo "Created $FISH_CONFIG_FILE"
fi

echo "Copying runtime script..."
cp ./setup.sh /usr/local/bin/shell-history-setup.sh
chmod +x /usr/local/bin/shell-history-setup.sh

echo "Per-user shell history configured for '$USER_NAME'."
