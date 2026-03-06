#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SRC_DIR="$ROOT_DIR/docs/diagrams"
OUT_DIR="$ROOT_DIR/docs/generated-diagrams"
IMAGE="plantuml/plantuml:latest"

if ! command -v docker >/dev/null 2>&1; then
  echo "❌ docker command not found. Please install/start Docker first."
  exit 1
fi

if [[ ! -d "$SRC_DIR" ]]; then
  echo "❌ Source directory not found: $SRC_DIR"
  exit 1
fi

echo "🧹 Cleaning output directory: $OUT_DIR"
rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

echo "📐 Rendering .puml files to SVG..."

count=0
while IFS= read -r -d '' file; do
  rel="${file#"$SRC_DIR"/}"
  src_rel="docs/diagrams/$rel"

  docker run --rm \
    -v "$ROOT_DIR:/workspace" \
    -w /workspace \
    "$IMAGE" \
    -charset UTF-8 \
    -tsvg \
    "$src_rel" >/dev/null

  generated="${file%.puml}.svg"
  target="$OUT_DIR/${rel%.puml}.svg"
  mkdir -p "$(dirname "$target")"
  mv "$generated" "$target"

  count=$((count + 1))
done < <(find "$SRC_DIR" -type f -name '*.puml' -print0 | sort -z)

echo "✅ Generated $count SVG files in $OUT_DIR"
