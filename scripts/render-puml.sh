#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ "$(basename "$ROOT_DIR")" != "teamdev-2026" ]]; then
  echo "❌ Root directory must be teamdev-2026. Current: $(basename "$ROOT_DIR")"
  exit 1
fi

CACHE_DIR="$ROOT_DIR/.cache"
PLANTUML_JAR="$CACHE_DIR/plantuml.jar"

SRC_DIR="$ROOT_DIR/docs/diagrams"
OUT_DIR="$ROOT_DIR/docs/generated-diagrams"

if [[ ! -d "$CACHE_DIR" ]]; then
  mkdir -p "$CACHE_DIR"
fi

if [[ ! -f "$PLANTUML_JAR" ]]; then
  curl -L -o "$PLANTUML_JAR" \
    https://github.com/plantuml/plantuml/releases/latest/download/plantuml.jar
fi

if [[ ! -d "$SRC_DIR" ]]; then
  echo "❌ Source directory not found: $SRC_DIR"
  exit 1
fi

echo "🧹 Cleaning output directory: $OUT_DIR"
rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

find "$SRC_DIR" -type f -name "*.puml" -print0 | while IFS= read -r -d "" puml; do
  rel="${puml#"$SRC_DIR"/}"
  rel_dir="${rel%/*}"
  out_dir="$OUT_DIR/$rel_dir"
  mkdir -p "$out_dir"

  java -jar "$PLANTUML_JAR" \
    -tsvg "$puml" \
    -o "$out_dir"

done

count=$(find "$OUT_DIR" -type f -name "*.svg" | wc -l | tr -d ' ')
echo "✅ Generated $count SVG files in $OUT_DIR"
