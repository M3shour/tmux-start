#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <session_name> [KEY1=VALUE1] [KEY2=VALUE2] ..."
    exit 1
fi

SESSION_NAME="$1"
shift

tmux set-option -g base-index 1
tmux setw -g pane-base-index 1

tmux new-session -d -s "$SESSION_NAME"
tmux rename-window -t "$SESSION_NAME:1" "main"
tmux split-window -v -t "$SESSION_NAME:main"
tmux select-pane -t "$SESSION_NAME:main.1"
tmux split-window -h -t "$SESSION_NAME:main.1"
tmux split-window -h -t "$SESSION_NAME:main.2"
tmux new-window -t "$SESSION_NAME" -n "SubShell"
tmux split-window -v -t "$SESSION_NAME:SubShell"
tmux new-window -t "$SESSION_NAME" -n "nmap"
tmux select-pane -T "nmap"
tmux new-window -t "$SESSION_NAME" -n "OPENVPN"
tmux select-pane -T "OpenVPN"

EXPORT_COMMANDS=""
for VAR in "$@"; do
    if [[ "$VAR" == *=* ]]; then
        EXPORT_COMMANDS+="export $VAR; "
    else
        echo "Invalid format for variable: $VAR. Use KEY=VALUE format."
        exit 1
    fi
done

sleep 0.5

WINDOWS=$(tmux list-windows -t "$SESSION_NAME" -F "#{window_index}")
for WIN in $WINDOWS; do
    PANES=$(tmux list-panes -t "$SESSION_NAME:$WIN" -F "#{pane_index}")
    for PANE in $PANES; do
        tmux send-keys -t "$SESSION_NAME:$WIN.$PANE" "clear; $EXPORT_COMMANDS" C-m
    done
done

tmux attach -t "$SESSION_NAME"
