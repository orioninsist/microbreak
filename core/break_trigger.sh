#!/usr/bin/env bash

trigger_microbreak() {
    echo "Starting microbreak"

    systemctl --user start microbreak.service
}
