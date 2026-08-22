#!/usr/bin/env bash

source "$(dirname "$0")/../core/config_loader.sh"
source "$(dirname "$0")/../core/feature_check.sh"

load_config || exit 1

test_result=0

if is_feature_enabled focus_mode; then
    echo "PASS: focus_mode enabled"
else
    echo "FAIL: focus_mode enabled"
    test_result=1
fi

if is_feature_enabled movement_reminder; then
    echo "PASS: movement_reminder enabled"
else
    echo "FAIL: movement_reminder enabled"
    test_result=1
fi

if ! is_feature_enabled disabled_feature; then
    echo "PASS: disabled feature check"
else
    echo "FAIL: disabled feature check"
    test_result=1
fi

exit "$test_result"
