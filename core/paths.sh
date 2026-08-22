#!/usr/bin/env bash

STORAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/storage"

FOCUS_STATE_FILE="$STORAGE_DIR/focus.state"
POMODORO_STATE_FILE="$STORAGE_DIR/pomodoro.state"
POMODORO_CYCLE_FILE="$STORAGE_DIR/pomodoro.cycle"
POMODORO_PROGRESS_FILE="$STORAGE_DIR/pomodoro.progress"
