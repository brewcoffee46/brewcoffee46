#!/bin/bash

set -euo pipefail

if [[ $# -ne 3 || -z "$1" || "$1" == "/" ]]; then
  echo "Usage: $0 <derived-data-path> <target> <output>" >&2
  exit 1
fi

DERIVED_DATA_PATH=$1
TARGET=$2
OUTPUT=$3

# This script from:
#   https://github.com/codecov/swift-standard/blob/b65449b5a2e92468d5bf4cb7e6a5711450a2682b/.github/workflows/swift_macos-10.15.yml#L27-L32
# MIT License | Copyright (c) 2022 Codecov

# Search only the requested DerivedData directory for `Coverage.profdata`.
profile_data_path="${DERIVED_DATA_PATH%/}/Build/ProfileData"
path_coverage=$(find "$profile_data_path" -type f -name Coverage.profdata -print -quit)

if [[ -z "$path_coverage" ]]; then
  echo "Coverage.profdata was not found under $profile_data_path" >&2
  exit 1
fi

xcrun llvm-cov export \
  -format="lcov" \
  -instr-profile "$path_coverage" \
  "${DERIVED_DATA_PATH%/}/Build/Products/Debug-iphonesimulator/${TARGET}" > "$OUTPUT"

# Prevent the next test run from picking up this coverage profile while keeping
# shared build products and SourcePackages available for incremental builds.
rm -rf "$profile_data_path"
