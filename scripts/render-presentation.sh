#!/usr/bin/env sh
set -eu

DOCS_TOOLBOX_IMAGE="${DOCS_TOOLBOX_IMAGE:-ghcr.io/docs-as-code-toolkit/docs-toolbox:latest}"
SOURCE_DOC="${1:-}"
OUTPUT_DIR="${2:-}"
REVEALJSDIR="${REVEALJSDIR:-https://cdn.jsdelivr.net/npm/reveal.js@5.1.0}"

usage() {
  cat <<'USAGE'
Usage: scripts/render-presentation.sh <slides.adoc> [output-dir]

Render an AsciiDoc slide deck to reveal.js HTML. The command uses the
docs-toolbox container image when Docker or Podman is available and falls back
to a local asciidoctor-revealjs executable.

Default output:
  build/talks/<talk-slug>/index.html
USAGE
}

find_engine() {
  if command -v podman >/dev/null 2>&1 && podman info >/dev/null 2>&1; then
    printf '%s\n' "podman"
  elif command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    printf '%s\n' "docker"
  else
    printf '%s\n' ""
  fi
}

default_output_dir() {
  talk_dir="$(dirname "$SOURCE_DOC")"
  case "$talk_dir" in
    talks/*)
      printf '%s\n' "build/$talk_dir"
      ;;
    *)
      stem="$(basename "$SOURCE_DOC" .adoc)"
      printf '%s\n' "build/presentations/$stem"
      ;;
  esac
}

run_render() {
  if ! command -v asciidoctor-revealjs >/dev/null 2>&1; then
    echo "asciidoctor-revealjs is not available locally." >&2
    exit 127
  fi

  mkdir -p "$OUTPUT_DIR"
  asciidoctor-revealjs \
    -r asciidoctor-diagram \
    -r asciidoctor-diagram/plantuml \
    --failure-level=ERROR \
    -a icons=font \
    -a source-highlighter=highlight.js \
    -a revealjsdir="$REVEALJSDIR" \
    -D "$OUTPUT_DIR" \
    -o index.html \
    "$SOURCE_DOC"
  echo "Built reveal.js presentation: $OUTPUT_DIR/index.html"
}

run_in_container() {
  engine="$1"
  "$engine" run --rm \
    -e ARCHITECTURE_KNOWLEDGE_TOOLKIT_PRESENTATION_IN_CONTAINER=1 \
    -e REVEALJSDIR="$REVEALJSDIR" \
    -v "$PWD":/app \
    -w /app \
    "$DOCS_TOOLBOX_IMAGE" \
    sh scripts/render-presentation.sh "$SOURCE_DOC" "$OUTPUT_DIR"
}

if [ "$SOURCE_DOC" = "" ] || [ "$SOURCE_DOC" = "-h" ] || [ "$SOURCE_DOC" = "--help" ]; then
  usage
  exit 2
fi

if [ ! -f "$SOURCE_DOC" ]; then
  echo "Slide source not found: $SOURCE_DOC" >&2
  exit 2
fi

if [ "$OUTPUT_DIR" = "" ]; then
  OUTPUT_DIR="$(default_output_dir)"
fi

if [ "${ARCHITECTURE_KNOWLEDGE_TOOLKIT_PRESENTATION_IN_CONTAINER:-}" = "1" ]; then
  run_render
  exit 0
fi

engine="$(find_engine)"
if [ -n "$engine" ]; then
  run_in_container "$engine"
else
  echo "No container engine found. Running locally."
  run_render
fi
