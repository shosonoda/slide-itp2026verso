#!/usr/bin/env bash
set -eu

SRC_DIR="_slides"
DEST_DIR="docs"

if [ ! -d "$SRC_DIR" ]; then
  echo "Error: source directory '$SRC_DIR' does not exist. Run 'lake exe generate-book' first." >&2
  exit 1
fi

mkdir -p "$DEST_DIR"

echo "Copying generated site from '$SRC_DIR' to '$DEST_DIR'..."
rm -rf "$DEST_DIR"/*
cp -a "$SRC_DIR"/. "$DEST_DIR"/

touch "$DEST_DIR/.nojekyll"

echo "Done. Generated pages are now available in '$DEST_DIR'."
