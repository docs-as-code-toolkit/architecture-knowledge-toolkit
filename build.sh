#!/usr/bin/env sh
set -eu

COMMAND="${1:-build}"
DOCS_TOOLBOX_IMAGE="${DOCS_TOOLBOX_IMAGE:-ghcr.io/docs-as-code-toolkit/docs-toolbox:v1.2.0}"
BUILD_DIR="${BUILD_DIR:-build/architecture}"
SOURCE_DOC="${SOURCE_DOC:-src/docs/doc-001-arc42.adoc}"

usage() {
  cat <<'USAGE'
Usage: ./build.sh [build|validate|clean]

Commands:
  build      Validate, generate architecture fragments, and render HTML.
  validate   Validate and generate architecture documentation metadata.
  clean      Remove local architecture build output.

The build command uses the docs-toolbox container image when Docker or Podman is
available, so local and CI rendering use the same diagram-capable toolchain.
USAGE
}

find_engine() {
  if command -v podman >/dev/null 2>&1; then
    printf '%s\n' "podman"
  elif command -v docker >/dev/null 2>&1; then
    printf '%s\n' "docker"
  else
    printf '%s\n' ""
  fi
}

run_validate() {
  ruby scripts/validate-metamodel.rb --generate
}

run_build() {
  run_validate
  mkdir -p "$BUILD_DIR"
  asciidoctor \
    -r asciidoctor-diagram \
    -r asciidoctor-diagram/plantuml \
    --failure-level=ERROR \
    -a skip-front-matter \
    -a toc=left \
    -a sectanchors \
    -a icons=font \
    -a imagesdir=. \
    -a imagesoutdir="$BUILD_DIR" \
    -D "$BUILD_DIR" \
    -o index.html \
    "$SOURCE_DOC"
  echo "Built architecture HTML: $BUILD_DIR/index.html"
}

run_local() {
  case "$COMMAND" in
    build)
      run_build
      ;;
    validate)
      run_validate
      ;;
    clean)
      rm -rf "$BUILD_DIR"
      echo "Removed $BUILD_DIR"
      ;;
    help|-h|--help)
      usage
      ;;
    *)
      usage
      exit 2
      ;;
  esac
}

run_in_container() {
  ENGINE="$1"

  "$ENGINE" run --rm \
    -e ARCHITECTURE_KNOWLEDGE_TOOLKIT_IN_CONTAINER=1 \
    -e BUILD_DIR="$BUILD_DIR" \
    -e SOURCE_DOC="$SOURCE_DOC" \
    -v "$PWD":/app \
    -w /app \
    "$DOCS_TOOLBOX_IMAGE" \
    sh ./build.sh "$COMMAND"
}

if [ "${ARCHITECTURE_KNOWLEDGE_TOOLKIT_IN_CONTAINER:-}" = "1" ]; then
  run_local
  exit 0
fi

case "$COMMAND" in
  build|validate)
    ENGINE="$(find_engine)"
    if [ -n "$ENGINE" ]; then
      run_in_container "$ENGINE"
    else
      echo "No container engine found. Running locally."
      run_local
    fi
    ;;
  clean|help|-h|--help)
    run_local
    ;;
  *)
    usage
    exit 2
    ;;
esac
