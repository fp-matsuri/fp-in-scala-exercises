#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CONTENT_HASH=$("$SCRIPT_DIR/content-hash.sh")
IMAGE="ghcr.io/fp-matsuri/fp-in-scala-exercises/devcontainer:$CONTENT_HASH"

echo "Building image: $IMAGE"

docker buildx build \
  --load \
  --file "$SCRIPT_DIR/Dockerfile" \
  --tag "$IMAGE" \
  "$REPO_ROOT"

echo "Done: $IMAGE"
