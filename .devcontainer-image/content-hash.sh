#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cat "$SCRIPT_DIR/Dockerfile" "$REPO_ROOT/mise.toml" | sha256sum | cut -c1-12
