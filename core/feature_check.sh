#!/usr/bin/env bash

is_feature_enabled() {
    local feature="$1"
    local value="${!feature}"

    if [ "$value" = "true" ]; then
        return 0
    fi

    return 1
}
