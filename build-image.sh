#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
"$(nix build --print-out-paths --no-link)" | docker load
